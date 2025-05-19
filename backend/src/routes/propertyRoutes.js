const express = require('express');
const router = express.Router();
const propertyController = require('../controllers/propertyController');
const authMiddleware = require('../middleware/authMiddleware');

// Apply auth middleware to all property routes
router.use(authMiddleware);

// Upload property
router.post('/properties', propertyController.uploadProperty);

module.exports = router; 