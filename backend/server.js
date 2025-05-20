const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');
const authRoutes = require('./routes/auth');
const propertyRoutes = require('./routes/propertyRoutes');
const adminRoutes = require('./routes/admin');
const Admin = require('./models/Admin');
const bcrypt = require('bcryptjs');

// Load environment variables
dotenv.config();

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 5000;
const mongoURI = process.env.MONGODB_URI;
// CORS configuration
app.use(cors({
  origin: '*', // Allow all origins
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Middleware
app.use(express.json({ limit: '50mb' })); // Increase limit for base64 images
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/properties', propertyRoutes);
app.use('/api/admin', adminRoutes);

// MongoDB Connection
mongoose.connect(mongoURI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(async () => {
  console.log('MongoDB Connected Successfully');
  
  // Create default admin if not exists
  const defaultAdmin = await Admin.findOne({ email: 'admin@landeed.com' });
  if (!defaultAdmin) {
    const hashedPassword = await bcrypt.hash('admin123', 10);
    await Admin.create({
      email: 'admin@landeed.com',
      password: hashedPassword,
      fullName: 'Default Admin'
    });
  }
})
.catch(err => {
  console.error('MongoDB Connection Error:', err.message);
  process.exit(1);
});

// Error handling middleware
app.use((err, req, res, next) => {
  res.status(err.status || 500).json({
    message: err.message || 'Internal Server Error',
    error: process.env.NODE_ENV === 'development' ? err : {}
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ 
    message: `Cannot ${req.method} ${req.url}`
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
}); 