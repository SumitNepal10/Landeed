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

module.exports = router; 