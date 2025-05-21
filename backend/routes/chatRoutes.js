const express = require('express');
const router = express.Router();
const ChatMessage = require('../models/ChatMessage');
const { verifyToken } = require('../middleware/auth');
const User = require('../models/User');

// Save a new message
router.post('/send', async (req, res) => {
  try {
    const { senderEmail, receiverEmail, message } = req.body;
    const newMessage = new ChatMessage({
      senderEmail,
      receiverEmail,
      message,
      timestamp: new Date(),
      isRead: false
    });
    await newMessage.save();
    res.status(201).json(newMessage);
  } catch (error) {
    console.error('Error saving message:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get chat history with a specific user (by email)
router.get('/history/:receiverEmail', async (req, res) => {
  try {
    const { userId } = req.query;
    const receiverEmail = req.params.receiverEmail;

    if (!userId) {
      return res.status(400).json({ message: 'Logged-in user email is required' });
    }

    const user = await User.findOne({ email: userId });
    if (!user) {
      return res.status(404).json({ message: 'Logged-in user not found' });
    }

    const messages = await ChatMessage.find({
      $or: [
        { senderEmail: user.email, receiverEmail: receiverEmail },
        { senderEmail: receiverEmail, receiverEmail: user.email }
      ]
    }).sort({ timestamp: 1 });

    res.json(messages);
  } catch (error) {
    console.error('Error getting chat history:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get all chat rooms for current user
router.get('/rooms', async (req, res) => {
  try {
    const { userId } = req.query;

    if (!userId) {
      return res.status(400).json({ message: 'User ID is required' });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const messages = await ChatMessage.find({
      $or: [
        { senderEmail: user.email },
        { receiverEmail: user.email }
      ]
    }).sort({ timestamp: -1 });

    // Group messages by chat partner
    const chatRooms = new Map();
    messages.forEach(message => {
      const otherUserEmail = message.senderEmail === user.email ? message.receiverEmail : message.senderEmail;
      if (!chatRooms.has(otherUserEmail)) {
        chatRooms.set(otherUserEmail, {
          lastMessage: message.message,
          lastMessageTime: message.timestamp,
          unreadCount: message.receiverEmail === user.email && !message.isRead ? 1 : 0
        });
      } else {
        const room = chatRooms.get(otherUserEmail);
        if (message.receiverEmail === user.email && !message.isRead) {
          room.unreadCount++;
        }
      }
    });

    // Convert to array and include user details (including _id)
    const chatRoomsArray = await Promise.all(
      Array.from(chatRooms.entries()).map(async ([userEmail, roomData]) => {
        const otherUser = await User.findOne({ email: userEmail }).select('_id fullName email');
        return {
          otherUser: otherUser,
          lastMessage: roomData.lastMessage,
          lastMessageTime: roomData.lastMessageTime,
          unreadCount: roomData.unreadCount
        };
      })
    );

    res.json(chatRoomsArray);
  } catch (error) {
    console.error('Error getting chat rooms:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Mark messages as read
router.post('/mark-read/:senderEmail', verifyToken, async (req, res) => {
  try {
    await ChatMessage.updateMany(
      {
        senderEmail: req.params.senderEmail,
        receiverEmail: req.user.email,
        isRead: false
      },
      { isRead: true }
    );
    res.json({ message: 'Messages marked as read' });
  } catch (error) {
    console.error('Error marking messages as read:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Delete a conversation by ID
router.delete('/rooms/:conversationId', async (req, res) => {
  try {
    const conversationId = req.params.conversationId;
    console.log('Attempting to delete conversation with ID:', conversationId);

    // Validate conversationId
    if (!conversationId || conversationId === 'null' || conversationId === 'undefined') {
      return res.status(400).json({ 
        message: 'Invalid conversation ID',
        details: 'The conversation ID is required and must be in the format "email1_email2"'
      });
    }

    const [user1Email, user2Email] = conversationId.split('_');
    
    // Validate split emails
    if (!user1Email || !user2Email) {
      return res.status(400).json({ 
        message: 'Invalid conversation ID format',
        details: 'The conversation ID must be in the format "email1_email2"'
      });
    }

    console.log('Split emails:', { user1Email, user2Email });

    // First, let's check if any messages exist with these emails
    const existingMessages = await ChatMessage.find({
      $or: [
        { senderEmail: user1Email, receiverEmail: user2Email },
        { senderEmail: user2Email, receiverEmail: user1Email }
      ]
    });
    
    console.log('Found existing messages:', existingMessages.length);
    if (existingMessages.length > 0) {
      console.log('Sample message:', {
        senderEmail: existingMessages[0].senderEmail,
        receiverEmail: existingMessages[0].receiverEmail
      });
    }

    const deleteResult = await ChatMessage.deleteMany({
      $or: [
        { senderEmail: user1Email, receiverEmail: user2Email },
        { senderEmail: user2Email, receiverEmail: user1Email }
      ]
    });
    console.log('Delete result:', deleteResult);

    if (deleteResult.deletedCount === 0) {
      console.log('No messages were found to delete');
      return res.status(404).json({ 
        message: 'No messages found to delete',
        details: {
          searchedEmails: { user1Email, user2Email },
          existingMessagesCount: existingMessages.length
        }
      });
    }

    res.status(200).json({ 
      message: 'Conversation deleted successfully',
      deletedCount: deleteResult.deletedCount 
    });
  } catch (error) {
    console.error('Error deleting conversation:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

module.exports = router; 