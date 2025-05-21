const express = require('express');
const router = express.Router();
const Property = require('../models/Property');
const User = require('../models/User');
const { verifyToken } = require('../middleware/auth');

// Create a new property
router.post('/', async (req, res) => {
  try {
    const { userEmail } = req.body;
    if (!userEmail) {
      return res.status(400).json({ message: 'User email is required' });
    }

    // Find the user by email
    const user = await User.findOne({ email: userEmail });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Create new property and associate with user
    const property = new Property({
      ...req.body,
      user: user._id, // associate property with user
      status: 'pending' // Set initial status as pending
    });

    // Save property to database
    await property.save();

    res.status(201).json({
      success: true,
      message: 'Property uploaded successfully',
      property,
    });
  } catch (error) {
    console.error('Error uploading property:', error);
    res.status(400).json({
      success: false,
      message: 'Error uploading property',
      error: error.message,
    });
  }
});

// Get user's properties
router.get('/my-properties', async (req, res) => {
  try {
    const { email } = req.query;
    console.log('Received email:', email); // Debug log
    
    if (!email) {
      return res.status(400).json({ message: 'Email is required' });
    }

    const properties = await Property.find({ userEmail: email })
      .sort({ createdAt: -1 });
    console.log('Found properties:', properties); // Debug log
    
    res.json(properties);
  } catch (error) {
    console.error('Error in my-properties:', error); // Debug log
    res.status(500).json({ message: error.message });
  }
});

// Get all properties (only verified ones for public view)
router.get('/', async (req, res) => {
  try {
    const { propertyClass, type, purpose, status, minPrice, maxPrice, location } = req.query;
    const query = { status: 'verified' };
    
    if (propertyClass) {
      query.propertyClass = propertyClass;
    }
    if (type) query.type = type;
    if (purpose) query.purpose = purpose;
    if (status) query.status = status;
    if (location) query.location = { $regex: location, $options: 'i' };
    if (minPrice || maxPrice) {
      query.price = {};
      if (minPrice) query.price.$gte = minPrice;
      if (maxPrice) query.price.$lte = maxPrice;
    }
    
    const properties = await Property.find(query)
      .populate('user', 'fullName email phoneNumber')
      .sort({ createdAt: -1 })
      .limit(req.query.limit ? parseInt(req.query.limit) : undefined);
    res.json(properties);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get properties by category (Regular, Premium, Top)
router.get('/category/:category', async (req, res) => {
  try {
    const { category } = req.params;
    if (!['Regular', 'Premium', 'Top'].includes(category)) {
      return res.status(400).json({ message: 'Invalid category' });
    }

    const properties = await Property.find({ 
      status: 'verified',
      propertyClass: category 
    })
      .populate('user', 'fullName email phoneNumber')
      .sort({ createdAt: -1 });
    res.json(properties);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get all favorite properties for the user (no token, use email)
router.get('/favorites', async (req, res) => {
  try {
    const { email } = req.query;
    if (!email) return res.status(400).json({ message: 'Email is required' });
    const user = await User.findOne({ email }).populate('favorites');
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.status(200).json(user.favorites);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get a single property
router.get('/:id', async (req, res) => {
  try {
    const property = await Property.findOne({ 
      _id: req.params.id,
      status: 'verified'
    })
      .populate('user', 'fullName email phoneNumber')
      .populate('verifiedBy', 'fullName email');
    
    if (!property) {
      return res.status(404).json({ message: 'Property not found' });
    }
    res.json(property);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Update a property
router.patch('/:id', async (req, res) => {
  try {
    const property = await Property.findById(req.params.id);
    if (!property) {
      return res.status(404).json({ message: 'Property not found' });
    }
    Object.assign(property, req.body);
    property.status = 'pending'; // Set status to pending after edit
    await property.save();
    res.json(property);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Delete a property
router.delete('/:id', async (req, res) => {
  try {
    const property = await Property.findById(req.params.id);
    if (!property) {
      return res.status(404).json({ message: 'Property not found' });
    }
    await property.deleteOne();
    res.json({ message: 'Property deleted' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Move property to appropriate collection based on verification status
router.post('/admin/properties/:id/move', verifyToken, async (req, res) => {
  try {
    const { status, reason } = req.body;
    
    // Get the property from ToBeVerifiedProperty collection
    const property = await ToBeVerifiedProperty.findById(req.params.id);
    if (!property) {
      return res.status(404).json({ message: 'Property not found' });
    }

    // Create new property object with existing data
    const propertyData = property.toObject();
    delete propertyData._id; // Remove _id to allow new document creation

    // Add verification details
    propertyData.verificationDate = new Date();
    propertyData.verifiedBy = req.user._id;
    
    let newProperty;
    
    if (status === 'verified') {
      // Move to verified properties
      newProperty = new VerifiedProperty(propertyData);
    } else if (status === 'rejected') {
      // Add rejection reason and move to rejected properties
      propertyData.rejectionReason = reason;
      newProperty = new RejectedProperty(propertyData);
    } else {
      return res.status(400).json({ message: 'Invalid status' });
    }

    // Save the property in new collection
    await newProperty.save();

    // Remove from ToBeVerifiedProperty collection
    await ToBeVerifiedProperty.findByIdAndDelete(req.params.id);

    res.json({ message: `Property moved to ${status} properties successfully` });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get admin dashboard statistics
router.get('/admin/statistics', verifyToken, async (req, res) => {
  try {
    // Get counts from different statuses in the Property collection
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
      User.countDocuments({ role: 'user' }), // Only count regular users
      Property.find()
        .populate('user', 'fullName email')
        .sort({ createdAt: -1 })
        .limit(5)
    ]);

    // Return the stats
    res.json({
      totalProperties,
      pendingPropertiesCount: pendingProperties,
      verifiedPropertiesCount: verifiedProperties,
      rejectedPropertiesCount: rejectedProperties,
      totalUsers,
      recentProperties
    });
  } catch (error) {
    console.error('Error fetching statistics:', error);
    res.status(500).json({ message: error.message });
  }
});

// Toggle favorite for a property (no token, use email)
router.post('/:id/toggle-favorite', async (req, res) => {
  try {
    const { email } = req.body;
    const propertyId = req.params.id;
    if (!email) return res.status(400).json({ message: 'Email is required' });
    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ message: 'User not found' });
    const index = user.favorites.findIndex(fav => fav.toString() === propertyId);
    if (index === -1) {
      user.favorites.push(propertyId);
    } else {
      user.favorites.splice(index, 1);
    }
    await user.save();
    res.status(200).json({ message: 'Favorite updated', favorites: user.favorites });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router; 