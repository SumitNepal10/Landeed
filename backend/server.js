const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');
const authRoutes = require('./routes/auth');
const propertyRoutes = require('./routes/propertyRoutes');
const adminRoutes = require('./routes/admin');
const messageRoutes = require('./routes/messageRoutes');
const chatRoutes = require('./routes/chatRoutes');
const Admin = require('./models/Admin');
const Message = require('./models/Message');
const bcrypt = require('bcryptjs');
const http = require('http');
const { Server } = require('socket.io');
const { verifyToken } = require('./middleware/auth');

// Load environment variables
dotenv.config();

// Initialize Express app
const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "http://localhost:3000",
    methods: ["GET", "POST"]
  }
});

const PORT = process.env.PORT || 5001;
const mongoURI = process.env.MONGODB_URI;

// CORS configuration
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Middleware
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/properties', propertyRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/messages', messageRoutes);
app.use('/api/chat', chatRoutes);

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

// Socket.IO Connection Handler
io.on('connection', (socket) => {
  console.log('New client connected');

  socket.on('join', (userEmail) => {
    socket.join(userEmail);
    console.log(`User ${userEmail} joined their room`);
  });

  socket.on('sendMessage', async (data) => {
    try {
      const { senderEmail, receiverEmail, message } = data;
      
      // Save message to database
      const newMessage = new Message({
        senderEmail,
        receiverEmail,
        message,
        timestamp: new Date(),
        status: 'sent'
      });
      await newMessage.save();

      // Emit to receiver's room
      io.to(receiverEmail).emit('receive_message', newMessage);
      
      // Emit back to sender for confirmation
      io.to(senderEmail).emit('message_sent', newMessage);
    } catch (error) {
      console.error('Error handling message:', error);
      socket.emit('error', { message: 'Error sending message' });
    }
  });

  // Mark message as delivered
  socket.on('mark_delivered', async (messageId) => {
    try {
      const message = await Message.findByIdAndUpdate(
        messageId,
        { status: 'delivered' },
        { new: true }
      );
      io.to(message.senderEmail).emit('message_delivered', message);
    } catch (error) {
      console.error('Failed to mark message as delivered:', error);
    }
  });

  // Mark message as read
  socket.on('mark_read', async (messageId) => {
    try {
      const message = await Message.findByIdAndUpdate(
        messageId,
        { status: 'read' },
        { new: true }
      );
      io.to(message.senderEmail).emit('message_read', message);
    } catch (error) {
      console.error('Failed to mark message as read:', error);
    }
  });

  socket.on('disconnect', () => {
    console.log('Client disconnected');
  });
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
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
}); 