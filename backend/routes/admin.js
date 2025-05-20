const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const adminAuth = require('../middleware/adminAuth');
const Property = require('../models/Property');
const User = require('../models/User');
const Admin = require('../models/Admin');
const bcrypt = require('bcryptjs');
const { verifyToken } = require('../middleware/auth');
const Notification = require('../models/Notification');

// Admin authentication routes (no auth required)
router.post('/login', adminController.adminLogin);

// Protected admin routes (require admin authentication)
router.use(adminAuth);

// Admin management routes
router.post('/create', adminController.createAdmin);
router.get('/admins', adminController.getAdmins);

// Property management routes
router.get('/properties/:status', async (req, res) => {
  try {
    const { status } = req.params;
    
    // Validate status parameter
    if (!['pending', 'verified', 'rejected'].includes(status)) {
      return res.status(400).json({ message: 'Invalid status parameter' });
    }

    const properties = await Property.find({ status })
      .populate('user', 'fullName email phoneNumber')
      .populate('verifiedBy', 'fullName email')
      .sort({ createdAt: -1 });

    res.json(properties);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post('/properties/:propertyId/verify', async (req, res) => {
  try {
    const { propertyId } = req.params;
    const { propertyClass } = req.body;

    // Validate propertyClass
    if (!['Regular', 'Premium', 'Top'].includes(propertyClass)) {
      return res.status(400).json({ 
        message: 'Invalid property class. Must be Regular, Premium, or Top' 
      });
    }

    const property = await Property.findById(propertyId);
    if (!property) {
      return res.status(404).json({ message: 'Property not found' });
    }

    // Update property status and class
    property.status = 'verified';
    property.propertyClass = propertyClass;
    property.verifiedBy = req.admin._id;
    property.verificationDate = new Date();
    
    await property.save();

    // Create notification for the user
    if (property.user) {
      const notification = new Notification({
        user: property.user,
        title: 'Property Verified',
        message: `Your property "${property.title}" has been verified as ${propertyClass} property.`,
        type: 'property_verified',
        propertyId: property._id
      });
      await notification.save();
    }

    res.json({ 
      success: true,
      message: 'Property verified successfully',
      property: property
    });
  } catch (error) {
    console.error('Error verifying property:', error);
    res.status(500).json({ 
      success: false,
      message: 'Error verifying property',
      error: error.message
    });
  }
});

router.post('/properties/:propertyId/reject', async (req, res) => {
  try {
    const { propertyId } = req.params;
    const { rejectionReason } = req.body;

    const property = await Property.findById(propertyId);
    if (!property) {
      return res.status(404).json({ message: 'Property not found' });
    }

    property.status = 'rejected';
    property.rejectionReason = rejectionReason;
    property.verifiedBy = req.admin._id;
    property.verificationDate = new Date();
    await property.save();

    res.json({ message: 'Property rejected successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get admin statistics
router.get('/statistics', async (req, res) => {
  try {
    const [
      totalProperties,
      pendingProperties,
      verifiedProperties,
      rejectedProperties,
      totalUsers,
      recentProperties
    ] = await Promise.all([
      Property.countDocuments(),
      Property.countDocuments({ status: 'pending' }),
      Property.countDocuments({ status: 'verified' }),
      Property.countDocuments({ status: 'rejected' }),
      User.countDocuments(),
      Property.find()
        .populate('user', 'fullName email')
        .sort({ createdAt: -1 })
        .limit(5)
    ]);

    res.json({
      totalProperties,
      pendingPropertiesCount: pendingProperties,
      verifiedPropertiesCount: verifiedProperties,
      rejectedPropertiesCount: rejectedProperties,
      totalUsers,
      recentProperties
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Create new admin
router.post('/create', async (req, res) => {
  try {
    const { email, password, fullName } = req.body;

    // Validate email domain
    if (!email.endsWith('@landeed.com')) {
      return res.status(400).json({ message: 'Admin email must end with @landeed.com' });
    }

    // Check if admin already exists
    const existingAdmin = await Admin.findOne({ email });
    if (existingAdmin) {
      return res.status(400).json({ message: 'Admin with this email already exists' });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Create new admin
    const newAdmin = new Admin({
      email,
      password: hashedPassword,
      fullName
    });

    await newAdmin.save();

    res.status(201).json({ message: 'Admin created successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error creating admin' });
  }
});

// Verify property
router.post('/properties/:id/verify', async (req, res) => {
  try {
    const { id } = req.params;
    const { status, rejectionReason } = req.body;

    const property = await Property.findById(id);
    if (!property) {
      return res.status(404).json({ message: 'Property not found' });
    }

    property.status = status;
    if (status === 'rejected' && rejectionReason) {
      property.rejectionReason = rejectionReason;
    }

    await property.save();

    res.json({ message: 'Property status updated successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error verifying property' });
  }
});

module.exports = router; 