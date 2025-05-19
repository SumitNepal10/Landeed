const mongoose = require('mongoose');

const propertySchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
  },
  type: {
    type: String,
    required: true,
  },
  purpose: {
    type: String,
    required: true,
  },
  location: {
    type: String,
    required: true,
  },
  size: {
    type: String,
    required: true,
  },
  price: {
    type: String,
    required: true,
  },
  isNegotiable: {
    type: Boolean,
    default: false,
  },
  description: {
    type: String,
    required: true,
  },
  availabilityDate: {
    type: Date,
    required: true,
  },
  contactInfo: {
    type: String,
    required: true,
  },
  images: [{
    type: String, // Store base64 images
  }],
  roomDetails: {
    bedrooms: String,
    bathrooms: String,
    kitchen: String,
    livingRooms: String,
  },
  features: {
    furnished: Boolean,
    parking: Boolean,
    garden: Boolean,
    swimmingPool: Boolean,
  },
  floorLevel: {
    type: String,
    required: true,
  },
  facingDirection: {
    type: String,
    required: true,
  },
  postedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('Property', propertySchema); 