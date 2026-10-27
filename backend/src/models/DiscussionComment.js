const mongoose = require('mongoose');

const discussionCommentSchema = new mongoose.Schema(
  {
    seedKey: { type: String, unique: true, sparse: true },
    discussion: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Discussion',
      required: true,
    },
    author: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    body: { type: String, required: true, trim: true, maxlength: 1000 },
    likes: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
    savedBy: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
    // False until the patient who asked opens the question.
    seenByPatient: { type: Boolean, default: false },
  },
  { collection: 'discussion_comments', timestamps: true },
);

module.exports = mongoose.model('DiscussionComment', discussionCommentSchema);
