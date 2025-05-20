const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const adminSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    lowercase: true,
    validate: {
      validator: function(v) {
        return v.endsWith('@landeed.com');
      },
      message: 'Admin email must end with @landeed.com'
    }
  },
  password: {
    type: String,
    required: true,
    minlength: 6
  },
  fullName: {
    type: String,
    required: true,
    trim: true
  },
  role: {
    type: String,
    enum: ['super_admin', 'admin'],
    default: 'admin',
  },
  isActive: {
    type: Boolean,
    default: true,
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  lastLogin: {
    type: Date,
  },
});

// Hash password before saving
adminSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  
  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

// Method to compare password
adminSchema.methods.comparePassword = async function(candidatePassword) {
  try {
    return await bcrypt.compare(candidatePassword, this.password);
  } catch (error) {
    throw error;
  }
};

// Static method to create default admin
adminSchema.statics.createDefaultAdmin = async function() {
  try {
    const defaultAdmin = {
      email: 'admin@landeed.com',
      password: 'admin123',
      fullName: 'Default Admin',
      role: 'super_admin',
      isActive: true
    };

    const existingAdmin = await this.findOne({ email: defaultAdmin.email });
    if (!existingAdmin) {
      await this.create(defaultAdmin);
    }
  } catch (error) {
    throw error;
  }
};

const Admin = mongoose.model('Admin', adminSchema);

module.exports = Admin; 