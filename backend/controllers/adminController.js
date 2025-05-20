const ToBeVerifiedProperty = require('../models/ToBeVerifiedProperty');
const VerifiedProperty = require('../models/VerifiedProperty');
const Notification = require('../models/Notification');
const User = require('../models/User');
const Admin = require('../models/Admin');
const jwt = require('jsonwebtoken');

// Admin authentication
const adminLogin = async (req, res) => {
  try {
    console.log('Admin login attempt:', { email: req.body.email });
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password are required' });
    }

    const admin = await Admin.findOne({ email });
    console.log('Admin found:', admin ? 'Yes' : 'No');
    
    if (!admin) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    if (!admin.isActive) {
      return res.status(401).json({ message: 'Account is deactivated' });
    }

    const isMatch = await admin.comparePassword(password);
    console.log('Password match:', isMatch ? 'Yes' : 'No');

    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    // Update last login
    admin.lastLogin = new Date();
    await admin.save();

    const token = jwt.sign(
      { id: admin._id, role: admin.role },
      process.env.JWT_SECRET,
      { expiresIn: '1d' }
    );

    console.log('Admin login successful:', { adminId: admin._id, role: admin.role });

    res.json({
      token,
      admin: {
        id: admin._id,
        email: admin.email,
        fullName: admin.fullName,
        role: admin.role
      }
    });
  } catch (error) {
    console.error('Admin login error:', error);
    res.status(500).json({ message: 'Internal server error during login' });
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
    const properties = await ToBeVerifiedProperty.find({ status: 'pending' })
      .populate('uploadedBy', 'fullName email phoneNumber')
      .sort({ createdAt: -1 });
    
    res.json(properties);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Approve a property
const approveProperty = async (req, res) => {
  try {
    const { propertyId } = req.params;
    const adminId = req.admin._id;

    const property = await ToBeVerifiedProperty.findById(propertyId);
    if (!property) {
      return res.status(404).json({ message: 'Property not found' });
    }

    // Map the fields correctly
    const verifiedProperty = new VerifiedProperty({
      title: property.title,
      description: property.description,
      price: parseFloat(property.price),
      location: property.location,
      propertyType: property.type,
      bedrooms: property.roomDetails?.bedrooms || 0,
      bathrooms: property.roomDetails?.bathrooms || 0,
      area: parseFloat(property.size) || 0,
      images: property.images || [],
      amenities: Object.entries(property.features || {})
        .filter(([_, value]) => value === true)
        .map(([key]) => key),
      uploadedBy: property.uploadedBy,
      verifiedBy: adminId,
      verificationDate: new Date(),
      status: 'active'
    });

    await verifiedProperty.save();

    // Create notification for the user
    const notification = new Notification({
      user: property.uploadedBy,
      title: 'Property Approved',
      message: `Your property "${property.title}" has been approved and is now live on our platform.`,
      type: 'property_approved',
      propertyId: property._id,
      isRead: false
    });
    await notification.save();

    // Delete from ToBeVerifiedProperty
    await ToBeVerifiedProperty.findByIdAndDelete(propertyId);

    res.json({ 
      message: 'Property approved successfully',
      property: verifiedProperty
    });
  } catch (error) {
    console.error('Error approving property:', error);
    res.status(500).json({ message: error.message });
  }
};

// Reject a property
const rejectProperty = async (req, res) => {
  try {
    const { propertyId } = req.params;
    const { reason } = req.body;

    if (!reason) {
      return res.status(400).json({ message: 'Rejection reason is required' });
    }

    const property = await ToBeVerifiedProperty.findById(propertyId);
    if (!property) {
      return res.status(404).json({ message: 'Property not found' });
    }

    // Create notification for the user
    const notification = new Notification({
      user: property.uploadedBy,
      title: 'Property Rejected',
      message: `Your property "${property.title}" has been rejected. Reason: ${reason}`,
      type: 'property_rejected',
      propertyId: property._id,
      isRead: false
    });
    await notification.save();

    // Delete from ToBeVerifiedProperty
    await ToBeVerifiedProperty.findByIdAndDelete(propertyId);

    res.json({ 
      message: 'Property rejected successfully',
      notification: notification
    });
  } catch (error) {
    console.error('Error rejecting property:', error);
    res.status(500).json({ message: error.message });
  }
};

// Get dashboard statistics
const getDashboardStats = async (req, res) => {
  try {
    const [
      pendingPropertiesCount,
      verifiedPropertiesCount,
      totalUsers,
      recentProperties
    ] = await Promise.all([
      ToBeVerifiedProperty.countDocuments({ status: 'pending' }),
      VerifiedProperty.countDocuments(),
      User.countDocuments(),
      ToBeVerifiedProperty.find({ status: 'pending' })
        .populate('uploadedBy', 'fullName email')
        .sort({ createdAt: -1 })
        .limit(5)
    ]);

    res.json({
      pendingPropertiesCount,
      verifiedPropertiesCount,
      totalUsers,
      recentProperties
    });
  } catch (error) {
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