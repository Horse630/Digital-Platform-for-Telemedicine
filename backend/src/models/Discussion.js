const mongoose = require('mongoose');

const STATUSES = ['open', 'answered'];

const discussionSchema = new mongoose.Schema(
  {
    seedKey: { type: String, unique: true, sparse: true },
    patient: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    doctor: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    title: { type: String, required: true, trim: true, maxlength: 120 },
    body: { type: String, required: true, trim: true, maxlength: 1000 },
    status: { type: String, required: true, enum: STATUSES },
  },
  { collection: 'discussions', timestamps: true },
);

module.exports = mongoose.model('Discussion', discussionSchema);
