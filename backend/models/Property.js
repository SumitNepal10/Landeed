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
    enum: ['Apartment', 'House', 'Villa', 'Land', 'Commercial']
  },
  purpose: {
    type: String,
    required: true,
    enum: ['Sale', 'Rent']
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
  availabilityDate: {
    type: String,
    required: true
  },
  contactInfo: {
    type: String,
    required: true
  },
  images: [{
    type: String
  }],
  roomDetails: {
    bedrooms: { type: Number },
    bathrooms: { type: Number },
    kitchens: { type: Number },
    livingRooms: { type: Number }
  },
  features: {
    parking: { type: Boolean, default: false },
    garden: { type: Boolean, default: false },
    security: { type: Boolean, default: false },
    swimmingPool: { type: Boolean, default: false },
    airConditioning: { type: Boolean, default: false },
    furnished: { type: Boolean, default: false }
  },
  floorLevel: {
    type: String
  },
  facingDirection: {
    type: String,
    enum: ['North', 'South', 'East', 'West', 'North-East', 'North-West', 'South-East', 'South-West']
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'User'
  }
}, {
  timestamps: true
});

const Property = mongoose.model('Property', propertySchema);

module.exports = Property; 