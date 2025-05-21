const User = require('../models/User');
const Otp = require('../models/Otp');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const bcrypt = require('bcryptjs');
const nodemailer = require('nodemailer');
const dotenv = require('dotenv');

// Ensure environment variables are loaded
dotenv.config();

const generateOTP = () => {
  return crypto.randomInt(100000, 999999).toString();
};

// Configure email transporter
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASSWORD
  }
});

// Verify transporter configuration
transporter.verify(function(error, success) {
  if (error) {
    console.log('Email configuration error:', error);
  } else {
    console.log('Email server is ready to send messages');
  }
});

// Email template for OTP
const sendOTPEmail = async (email, otp) => {
  const mailOptions = {
    from: process.env.EMAIL_USER,
    to: email,
    subject: 'Email Verification Code',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #333;">Email Verification</h2>
        <p>Your verification code is:</p>
        <h1 style="color: #007bff; font-size: 32px; letter-spacing: 5px;">${otp}</h1>
        <p>This code will expire in 10 minutes.</p>
        <p>If you didn't request this code, please ignore this email.</p>
      </div>
    `
  };

  try {
    await transporter.sendMail(mailOptions);
  } catch (error) {
    console.error('Error sending email:', error);
    throw new Error('Failed to send email');
  }
};

const sendOtp = async (req, res) => {
  try {
    const { email, userData } = req.body;

    // Check if user already exists (only for signup)
    if (userData) {
      const existingUser = await User.findOne({ email });
      if (existingUser) {
        return res.status(400).json({ message: 'User already exists' });
      }
    }

    // Generate OTP
    const otp = generateOTP();
    
    // Save OTP to database
    const otpDocument = new Otp({
      email,
      otp,
      userData: userData || null
    });

    await otpDocument.save();

    // Send OTP email
    await sendOTPEmail(email, otp);

    res.json({ message: 'OTP sent successfully' });
  } catch (error) {
    console.error('Send OTP error:', error);
    res.status(500).json({ message: 'Failed to send OTP' });
  }
};

const verifyOtp = async (req, res) => {
  try {
    const { email, otp, isPasswordReset } = req.body;

    // Find OTP document
    const otpDoc = await Otp.findOne({ email, otp });
    if (!otpDoc) {
      return res.status(400).json({ message: 'Invalid OTP' });
    }

    // Check if OTP is expired
    if (Date.now() - otpDoc.createdAt > 10 * 60 * 1000) {
      await Otp.deleteOne({ _id: otpDoc._id });
      return res.status(400).json({ message: 'OTP has expired' });
    }

    // If this is a signup verification
    if (otpDoc.userData && !isPasswordReset) {
      // Check if user already exists
      const existingUser = await User.findOne({ email });
      if (existingUser) {
        await Otp.deleteOne({ _id: otpDoc._id });
        return res.status(400).json({ message: 'User already exists' });
      }

      // Create new user with the stored user data
      const user = new User({
        email: otpDoc.userData.email,
        password: otpDoc.userData.password,
        phoneNumber: otpDoc.userData.phoneNumber,
        fullName: otpDoc.userData.fullName
      });

      // Save the user (password will be hashed by the pre-save middleware)
      await user.save();

      // Generate token
      const token = jwt.sign({ _id: user._id }, process.env.JWT_SECRET, { expiresIn: '7d' });

      // Delete OTP document
      await Otp.deleteOne({ _id: otpDoc._id });

      return res.status(200).json({
        user: {
          id: user._id,
          email: user.email,
          fullName: user.fullName,
          phoneNumber: user.phoneNumber,
          profileImage: user.profileImage || null
        },
        token
      });
    }

    // For password reset verification
    if (isPasswordReset) {
      // Check if user exists
      const user = await User.findOne({ email });
      if (!user) {
        await Otp.deleteOne({ _id: otpDoc._id });
        return res.status(404).json({ message: 'User not found' });
      }

      // Delete OTP document
      await Otp.deleteOne({ _id: otpDoc._id });

      return res.status(200).json({ 
        message: 'OTP verified successfully',
        email: user.email
      });
    }

    // For other verifications
    res.status(200).json({ message: 'OTP verified successfully' });
  } catch (error) {
    console.error('Verify OTP error:', error);
    res.status(500).json({ message: 'Failed to verify OTP' });
  }
};

const resendOtp = async (req, res) => {
  try {
    const { email } = req.body;

    // Find existing OTP document
    const otpDoc = await Otp.findOne({ email });
    if (!otpDoc) {
      return res.status(400).json({ message: 'No pending verification found' });
    }

    // Generate new OTP
    const otp = generateOTP();

    // Update OTP
    otpDoc.otp = otp;
    otpDoc.createdAt = Date.now();
    await otpDoc.save();

    // Send new OTP email
    await sendOTPEmail(email, otp);

    res.status(200).json({ message: 'OTP resent successfully' });
  } catch (error) {
    console.error('Resend OTP error:', error);
    res.status(500).json({ message: 'Failed to resend OTP' });
  }
};

const signup = async (req, res) => {
  try {
    const { email, password, phoneNumber, fullName } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({ $or: [{ email }, { phoneNumber }] });
    if (existingUser) {
      return res.status(400).json({ message: 'User already exists' });
    }

    // Store user data temporarily and send OTP
    const userData = {
      email,
      password,
      phoneNumber,
      fullName
    };

    // Send OTP for verification
    const otp = generateOTP();
    
    const otpDocument = new Otp({
      email,
      otp,
      userData
    });

    await otpDocument.save();

    // Send OTP email
    await sendOTPEmail(email, otp);

    res.status(200).json({ 
      message: 'OTP sent for email verification',
      email
    });
  } catch (error) {
    console.error('Signup error:', error);
    res.status(400).json({ message: 'Failed to process signup' });
  }
};

const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Find user
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    // Check password
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    // Generate token
    const token = jwt.sign({ _id: user._id }, process.env.JWT_SECRET, { expiresIn: '7d' });

    res.json({
      user: {
        id: user._id,
        email: user.email,
        fullName: user.fullName,
        phoneNumber: user.phoneNumber,
        profileImage: user.profileImage || null
      },
      token
    });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const logout = async (req, res) => {
  try {
    // In a real application, you might want to:
    // 1. Add the token to a blacklist
    // 2. Update user's last logout time
    // 3. Clear any active sessions
    
    res.json({ message: 'Logged out successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Update user profile
const updateProfile = async (req, res) => {
  try {
    const { email, name, profileImage } = req.body;
    if (!email) {
      return res.status(400).json({ message: 'Email is required' });
    }
    // Find user by email
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    // Update fields
    if (name) user.fullName = name;
    if (profileImage) user.profileImage = profileImage;
    await user.save();
    res.json({
      user: {
        id: user._id,
        email: user.email,
        fullName: user.fullName,
        phoneNumber: user.phoneNumber,
        profileImage: user.profileImage || null
      }
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const requestPasswordReset = async (req, res) => {
  try {
    const { email } = req.body;

    // Check if user exists
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Generate OTP
    const otp = generateOTP();
    
    // Save OTP
    const otpDocument = new Otp({
      email,
      otp
    });

    await otpDocument.save();

    // Send OTP email
    await sendOTPEmail(email, otp);

    res.status(200).json({ message: 'Password reset OTP sent' });
  } catch (error) {
    console.error('Password reset request error:', error);
    res.status(500).json({ message: 'Failed to process password reset request' });
  }
};

const resetPassword = async (req, res) => {
  try {
    const { email, newPassword } = req.body;

    // Find user
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Update password
    user.password = newPassword;
    await user.save();

    res.status(200).json({ message: 'Password reset successful' });
  } catch (error) {
    console.error('Password reset error:', error);
    res.status(500).json({ message: 'Failed to reset password' });
  }
};

module.exports = {
  signup,
  login,
  logout,
  sendOtp,
  verifyOtp,
  resendOtp,
  updateProfile,
  requestPasswordReset,
  resetPassword
}; 