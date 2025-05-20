const nodemailer = require('nodemailer');
require('dotenv').config();

// Debug logging for email configuration
console.log('Email configuration:');
console.log('User:', process.env.EMAIL_USER);
console.log('Password:', process.env.EMAIL_PASSWORD ? 'Password is set' : 'Password is missing');

const transporter = nodemailer.createTransport({
  host: 'smtp.gmail.com',
  port: 587,
  secure: false,
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASSWORD,
  },
});

// Verify transporter configuration
transporter.verify(function(error, success) {
  if (error) {
    console.error('Email configuration error:', error);
    console.error('Email user:', process.env.EMAIL_USER);
    console.error('Email password length:', process.env.EMAIL_PASSWORD?.length);
  } else {
    console.log('Email server is ready to send messages');
  }
});

const sendOTPEmail = async (email, otp) => {
  console.log('Attempting to send email to:', email);
  console.log('Using email user:', process.env.EMAIL_USER);

  const mailOptions = {
    from: process.env.EMAIL_USER,
    to: email,
    subject: "Email Verification OTP",
    text: `Your OTP is: ${otp}`,
    html: `
      <body style="font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px;">
        <div style="max-width: 600px; margin: 0 auto; padding: 20px; background-color: #ffffff; border-radius: 10px; box-shadow: 0px 0px 10px 0px rgba(0,0,0,0.1);">
          <h1 style="color: #333333; text-align: center;">🔐 Email Verification</h1>
          <p style="color: #666666; text-align: center;">Thank you for registering with Rise Real Estate. Please use the following OTP to verify your email address:</p>
          <div style="text-align: center; background-color: #f4f4f4; padding: 15px; margin: 20px 0; border-radius: 5px;">
            <h1 style="color: #4CAF50; margin: 0; letter-spacing: 5px;">${otp}</h1>
          </div>
          <p style="color: #666666; text-align: center;">This OTP will expire in 5 minutes.</p>
          <p style="color: #999999; font-size: 12px; text-align: center;">If you didn't request this verification, please ignore this email.</p>
        </div>
      </body>
    `
  };

  return new Promise((resolve, reject) => {
    transporter.sendMail(mailOptions, function (error, info) {
      if (error) {
        console.error('Email sending error:', error);
        reject(new Error('Failed to send OTP email: ' + error.message));
      } else {
        console.log('Email sent successfully:', info.response);
        resolve(info);
      }
    });
  });
};

module.exports = {
  sendOTPEmail
}; 