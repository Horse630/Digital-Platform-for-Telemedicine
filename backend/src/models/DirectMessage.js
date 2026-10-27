const mongoose = require('mongoose');

// A direct message between two signed-in people.
// This is not the HKBU chatbot. Those rows stay in chatbot_messages.
const directMessageSchema = new mongoose.Schema(
  {
    sender: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    recipient: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    text: { type: String, required: true, trim: true, maxlength: 500 },
    // Null until the recipient opens the conversation.
    readAt: { type: Date, default: null },
  },
  { collection: 'direct_messages', timestamps: true },
);

directMessageSchema.index({ sender: 1, recipient: 1, createdAt: -1 });

module.exports = mongoose.model('DirectMessage', directMessageSchema);
