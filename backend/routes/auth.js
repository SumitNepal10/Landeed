const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const auth = require('../middleware/auth');

// Signup route
router.post('/signup', authController.signup);

// Login route
router.post('/login', authController.login);

// Logout route
router.post('/logout', auth, authController.logout);

module.exports = router; 