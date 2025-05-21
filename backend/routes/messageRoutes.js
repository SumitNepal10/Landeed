const express = require('express');
const router = express.Router();
const messageController = require('../controllers/messageController');

// Save a new message
router.post('/', messageController.saveMessage);

// Get messages for a specific property
router.get('/property/:propertyId', messageController.getMessagesForProperty);

// Get messages between two users for a specific property
router.get('/property/:propertyId/users/:user1Id/:user2Id', messageController.getMessagesBetweenUsers);

module.exports = router; 