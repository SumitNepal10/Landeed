const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const adminAuth = require('../middleware/adminAuth');

// Admin authentication routes (no auth required)
router.post('/login', adminController.adminLogin);

// Apply admin middleware to all routes below
router.use(adminAuth);

// Admin dashboard routes
router.get('/dashboard', adminController.getDashboardStats);
router.get('/properties/pending', adminController.getPendingProperties);
router.post('/properties/:propertyId/approve', adminController.approveProperty);
router.post('/properties/:propertyId/reject', adminController.rejectProperty);

module.exports = router; 