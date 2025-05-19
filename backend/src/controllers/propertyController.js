const Property = require('../models/Property');
const jwt = require('jsonwebtoken');

exports.uploadProperty = async (req, res) => {
  try {
    // Verify the token and get user ID
    const token = req.headers.authorization.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const userId = decoded.userId;

    // Create new property
    const property = new Property({
      ...req.body,
      postedBy: userId,
      availabilityDate: new Date(req.body.availabilityDate),
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
    res.status(500).json({
      success: false,
      message: 'Error uploading property',
      error: error.message,
    });
  }
}; 