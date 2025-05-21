const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { verifyToken } = require('../middleware/auth');

// Authentication routes
router.post('/login', authController.login);
router.post('/signup', authController.signup);
router.post('/send-otp', authController.sendOtp);
router.post('/verify-otp', authController.verifyOtp);
router.post('/resend-otp', authController.resendOtp);
router.post('/logout', verifyToken, authController.logout);

// Password reset routes
router.post('/request-password-reset', authController.requestPasswordReset);
router.post('/reset-password', authController.resetPassword);

// Update user profile (no token required)
router.put('/update-profile', authController.updateProfile);

module.exports = router; 