const Message = require('../models/Message');

// Save a new message
exports.saveMessage = async (req, res) => {
  try {
    const message = new Message(req.body);
    await message.save();
    res.status(201).json(message);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Get messages for a specific property
exports.getMessagesForProperty = async (req, res) => {
  try {
    const messages = await Message.find({ propertyId: req.params.propertyId })
      .sort({ timestamp: 1 });
    res.json(messages);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Get messages between two users for a specific property
exports.getMessagesBetweenUsers = async (req, res) => {
  try {
    const { propertyId, user1Id, user2Id } = req.params;
    const messages = await Message.find({
      propertyId,
      $or: [
        { senderId: user1Id, receiverId: user2Id },
        { senderId: user2Id, receiverId: user1Id }
      ]
    }).sort({ timestamp: 1 });
    res.json(messages);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
}; 