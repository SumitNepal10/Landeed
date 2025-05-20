const Property = require('../models/Property');
const Notification = require('../models/Notification');
const User = require('../models/User');
const Admin = require('../models/Admin');
const jwt = require('jsonwebtoken');

// Admin authentication
const adminLogin = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Find admin by email
    const admin = await Admin.findOne({ email });
    if (!admin) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    // Check password
    const isMatch = await admin.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    // Generate token
    const token = jwt.sign(
      { adminId: admin._id },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.json({
      token,
      admin: {
        id: admin._id,
        email: admin.email,
        fullName: admin.fullName
      }
    });
  } catch (error) {
    console.error('Admin login error:', error);
    res.status(500).json({ message: 'Error during login' });
  }
};

// Create new admin (only super admin can do this)
const createAdmin = async (req, res) => {
  try {
    const { email, password, fullName, role } = req.body;
    
    // Check if requesting user is super admin
    if (req.admin.role !== 'super_admin') {
      return res.status(403).json({ message: 'Only super admin can create new admins' });
    }

    const existingAdmin = await Admin.findOne({ email });
    if (existingAdmin) {
      return res.status(400).json({ message: 'Admin already exists' });
    }

    const admin = new Admin({
      email,
      password,
      fullName,
      role: role || 'admin'
    });

    await admin.save();

    res.status(201).json({
      message: 'Admin created successfully',
      admin: {
        id: admin._id,
        email: admin.email,
        fullName: admin.fullName,
        role: admin.role
      }
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Get all admins (only super admin can do this)
const getAdmins = async (req, res) => {
  try {
    if (req.admin.role !== 'super_admin') {
      return res.status(403).json({ message: 'Only super admin can view all admins' });
    }

    const admins = await Admin.find({}, '-password');
    res.json(admins);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Get all properties pending verification
const getPendingProperties = async (req, res) => {
  try {
    const properties = await Property.find({ status: 'pending' })
      .populate('user', 'fullName email phoneNumber')
      .sort({ createdAt: -1 });
    
    res.json(properties);
  } catch (error) {
    console.error('Error fetching properties:', error);
    res.status(500).json({ message: error.message });
  }
};

// Approve a property
const approveProperty = async (req, res) => {
  try {
    const { propertyId } = req.params;
    const { propertyClass } = req.body;

    console.log('Verifying property:', propertyId, 'with class:', propertyClass); // Debug log

    const property = await Property.findById(propertyId).populate('user');
    if (!property) {
      return res.status(404).json({ message: 'Property not found' });
    }

    if (!property.user) {
      return res.status(400).json({ message: 'Property has no associated user' });
    }

    // Update property status and class
    property.status = 'verified';
    property.propertyClass = propertyClass;
    property.verifiedBy = req.admin._id;
    property.verificationDate = new Date();
    
    await property.save();

    console.log('Property updated:', property); // Debug log

    // Create notification for the user
    const notification = new Notification({
      user: property.user._id,
      title: 'Property Verified',
      message: `Your property "${property.title}" has been verified as ${property.propertyClass} property.`,
      type: 'property_verified',
      propertyId: property._id
    });
    await notification.save();

    res.json({ 
      message: 'Property verified successfully',
      property: property
    });
  } catch (error) {
    console.error('Error verifying property:', error);
    res.status(500).json({ 
      message: 'Error verifying property',
      error: error.message
    });
  }
};

// Reject a property
const rejectProperty = async (req, res) => {
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

    // Create notification for the user
    const notification = new Notification({
      user: property.user,
      title: 'Property Rejected',
      message: `Your property "${property.title}" has been rejected. Reason: ${rejectionReason}`,
      type: 'property_rejected',
      propertyId: property._id
    });
    await notification.save();

    res.json({ message: 'Property rejected successfully' });
  } catch (error) {
    console.error('Error rejecting property:', error);
    res.status(500).json({ message: 'Error rejecting property' });
  }
};

// Get dashboard statistics
const getDashboardStats = async (req, res) => {
  try {
    const [
      pendingPropertiesCount,
      verifiedPropertiesCount,
      rejectedPropertiesCount,
      totalUsers,
      recentProperties
    ] = await Promise.all([
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
      pendingPropertiesCount,
      verifiedPropertiesCount,
      rejectedPropertiesCount,
      totalUsers,
      recentProperties
    });
  } catch (error) {
    console.error('Error getting dashboard stats:', error);
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  adminLogin,
  createAdmin,
  getAdmins,
  getPendingProperties,
  approveProperty,
  rejectProperty,
  getDashboardStats
}; 