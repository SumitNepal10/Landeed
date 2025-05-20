const mongoose = require('mongoose');

const propertySchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true
  },
  type: {
    type: String,
    required: true,
    enum: ['House', 'Apartment', 'Land', 'Commercial Space', 'Flat']
  },
  purpose: {
    type: String,
    required: true,
    enum: ['Sale', 'Rent']
  },
  propertyClass: {
    type: String,
    enum: ['Regular', 'Premium', 'Top'],
    default: 'Regular'
  },
  location: {
    type: String,
    required: true
  },
  size: {
    type: String,
    required: true
  },
  price: {
    type: String,
    required: true
  },
  isNegotiable: {
    type: Boolean,
    default: false
  },
  description: {
    type: String,
    required: true
  },
  images: [{
    type: String,
    required: true
  }],
  contactInfo: {
    type: String,
    required: true
  },
  roomDetails: {
    bedrooms: String,
    bathrooms: String,
    kitchen: String,
    livingRooms: String
  },
  features: {
    furnished: Boolean,
    parking: Boolean,
    garden: Boolean,
    swimmingPool: Boolean
  },
  floorLevel: {
    type: String,
    enum: ['Ground Floor', 'First Floor', 'Second Floor', 'Third Floor', 'Fourth Floor', 'Fifth Floor']
  },
  facingDirection: {
    type: String,
    enum: ['East', 'West', 'North', 'South', 'North-East', 'North-West', 'South-East', 'South-West']
  },
  status: {
    type: String,
    required: true,
    enum: ['pending', 'verified', 'rejected'],
    default: 'pending'
  },
  rejectionReason: {
    type: String,
    default: null
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: false
  },
  userEmail: {
    type: String,
    required: false
  },
  verifiedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Admin',
    default: null
  },
  verificationDate: {
    type: Date,
    default: null
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Property', propertySchema); 