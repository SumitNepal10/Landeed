const User = require('../models/User');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const bcrypt = require('bcryptjs');
const nodemailer = require('nodemailer');

const generateOTP = () => {
  return crypto.randomInt(100000, 999999).toString();
};

// Configure email transporter
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'landeed7@gmail.com',
    pass: process.env.EMAIL_PASSWORD
  }
});

const sendOtp = async (req, res) => {
  try {
    const { email } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: 'User already exists' });
    }

    // Generate OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    
    // Save OTP to database
    const otpDocument = new Otp({
      email,
      otp,
      expiresAt: new Date(Date.now() + 10 * 60 * 1000) // 10 minutes
    });

    await otpDocument.save();

    // Send OTP email
    await sendOTPEmail(email, otp);

    res.json({ message: 'OTP sent successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const verifyOtp = async (req, res) => {
  try {
    const { email, otp } = req.body;

    // Find OTP document
    const otpDoc = await OTP.findOne({ email, otp });
    if (!otpDoc) {
      return res.status(400).json({ message: 'Invalid OTP' });
    }

    // Create user
    const { userData } = otpDoc;
    const user = new User({
      email: userData.email,
      password: userData.password,
      phoneNumber: userData.phoneNumber,
      fullName: userData.fullName
    });

    await user.save();

    // Delete OTP document
    await OTP.deleteOne({ _id: otpDoc._id });

    // Generate token
    const token = jwt.sign({ _id: user._id }, process.env.JWT_SECRET, { expiresIn: '7d' });

    res.status(200).json({
      user: {
        id: user._id,
        email: user.email,
        fullName: user.fullName,
        phoneNumber: user.phoneNumber
      },
      token
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const resendOtp = async (req, res) => {
  try {
    const { email } = req.body;

    // Find existing OTP document
    const otpDoc = await OTP.findOne({ email });
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
    res.status(500).json({ message: error.message });
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

    // Create new user
    const user = new User({
      email,
      password,
      phoneNumber,
      fullName
    });

    await user.save();

    // Generate token
    const token = jwt.sign({ _id: user._id }, process.env.JWT_SECRET, { expiresIn: '7d' });

    res.status(201).json({
      user: {
        id: user._id,
        email: user.email,
        fullName: user.fullName,
        phoneNumber: user.phoneNumber
      },
      token
    });
  } catch (error) {
    res.status(400).json({ message: error.message });
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
        phoneNumber: user.phoneNumber
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

module.exports = {
  signup,
  login,
  logout,
  sendOtp,
  verifyOtp,
  resendOtp
}; 