const mongoose = require('mongoose');

const SPEAKERS = ['user', 'assistant'];

// One line in a chatbot transcript. The HKBU assistant is not connected yet.
const chatbotMessageSchema = new mongoose.Schema(
  {
    seedKey: { type: String, unique: true, sparse: true },
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    speaker: { type: String, required: true, enum: SPEAKERS },
    text: { type: String, required: true, trim: true, maxlength: 1000 },
  },
  { collection: 'chatbot_messages', timestamps: true },
);

module.exports = mongoose.model('ChatbotMessage', chatbotMessageSchema);
