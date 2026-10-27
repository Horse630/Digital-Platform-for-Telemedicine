const express = require('express');
const mongoose = require('mongoose');

const { readToken } = require('../authToken');
const Discussion = require('../models/Discussion');
const DiscussionComment = require('../models/DiscussionComment');
const User = require('../models/User');

const router = express.Router();
const personFields = 'fullName avatarBase64 role description specialties allergies';

async function requireUser(req, res, next) {
  try {
    const header = req.get('authorization') || '';
    const token = header.startsWith('Bearer ') ? header.slice('Bearer '.length) : '';
    const payload = readToken(token);
    if (!payload) {
      res.status(401).json({ message: 'Sign in again.' });
      return;
    }
    const user = await User.findById(payload.sub);
    if (!user) {
      res.status(401).json({ message: 'Sign in again.' });
      return;
    }
    req.user = user;
    next();
  } catch (_error) {
    res.status(401).json({ message: 'Sign in again.' });
  }
}

function personJson(user) {
  if (!user) {
    return null;
  }
  return {
    id: user._id.toString(),
    fullName: user.fullName,
    avatarBase64: user.avatarBase64 || '',
    role: user.role,
    description: user.description || '',
    specialties: Array.isArray(user.specialties) ? user.specialties : [],
    allergies: Array.isArray(user.allergies) ? user.allergies : [],
  };
}

function commentJson(comment, mine) {
  const likes = comment.likes || [];
  const savedBy = comment.savedBy || [];
  return {
    id: comment._id.toString(),
    body: comment.body,
    createdAt: comment.createdAt.toISOString(),
    author: personJson(comment.author),
    likeCount: likes.length,
    liked: likes.some((id) => id.equals(mine)),
    stored: savedBy.some((id) => id.equals(mine)),
  };
}

function discussionJson(discussion, commentCount, unreadCount, repliedByMe) {
  return {
    id: discussion._id.toString(),
    title: discussion.title,
    body: discussion.body,
    status: discussion.status,
    createdAt: discussion.createdAt.toISOString(),
    patient: personJson(discussion.patient),
    doctor: personJson(discussion.doctor),
    commentCount,
    unreadCount: unreadCount || 0,
    repliedByMe: Boolean(repliedByMe),
  };
}

router.get('/', requireUser, async (req, res) => {
  const discussions = await Discussion.find()
    .sort({ createdAt: -1 })
    .limit(100)
    .populate('patient', personFields)
    .populate('doctor', personFields);
  const ids = discussions.map((discussion) => discussion._id);
  const counts = await DiscussionComment.aggregate([
    { $match: { discussion: { $in: ids } } },
    { $group: { _id: '$discussion', count: { $sum: 1 } } },
  ]);
  const countById = new Map(counts.map((row) => [row._id.toString(), row.count]));
  const unreadRows = await DiscussionComment.aggregate([
    { $match: { discussion: { $in: ids }, seenByPatient: { $ne: true } } },
    { $group: { _id: '$discussion', count: { $sum: 1 } } },
  ]);
  const unreadById = new Map(unreadRows.map((row) => [row._id.toString(), row.count]));
  const repliedRows = await DiscussionComment.aggregate([
    { $match: { discussion: { $in: ids }, author: req.user._id } },
    { $group: { _id: '$discussion' } },
  ]);
  const repliedById = new Set(repliedRows.map((row) => row._id.toString()));
  const mine = req.user._id.toString();
  res.json(
    discussions.map((discussion) => {
      const askedByMe = discussion.patient && discussion.patient._id.toString() === mine;
      const unread = askedByMe ? unreadById.get(discussion._id.toString()) || 0 : 0;
      return discussionJson(
        discussion,
        countById.get(discussion._id.toString()) || 0,
        unread,
        repliedById.has(discussion._id.toString()),
      );
    }),
  );
});

router.get('/:id', requireUser, async (req, res) => {
  const discussion = await findDiscussion(req, res);
  if (!discussion) {
    return;
  }
  const askedByMe =
    discussion.patient && discussion.patient._id.equals(req.user._id);
  if (askedByMe) {
    await DiscussionComment.updateMany(
      { discussion: discussion._id, seenByPatient: { $ne: true } },
      { $set: { seenByPatient: true } },
    );
  }
  const comments = await DiscussionComment.find({ discussion: discussion._id })
    .sort({ createdAt: 1 })
    .limit(200)
    .populate('author', personFields);
  const count = comments.length;
  res.json({
    discussion: discussionJson(discussion, count, 0),
    comments: comments.map((comment) => commentJson(comment, req.user._id)),
  });
});

router.post('/', requireUser, async (req, res) => {
  if (req.user.role !== 'patient') {
    res.status(403).json({ message: 'Only a patient can ask a question.' });
    return;
  }
  const title = typeof req.body?.title === 'string' ? req.body.title.trim() : '';
  const body = typeof req.body?.body === 'string' ? req.body.body.trim() : '';
  if (!title) {
    res.status(400).json({ message: 'Enter a title.' });
    return;
  }
  if (title.length > 120) {
    res.status(400).json({ message: 'Keep the title under 120 characters.' });
    return;
  }
  if (!body) {
    res.status(400).json({ message: 'Enter your question.' });
    return;
  }
  if (body.length > 1000) {
    res.status(400).json({ message: 'Keep the question under 1000 characters.' });
    return;
  }

  const saved = await Discussion.create({
    patient: req.user._id,
    title,
    body,
    status: 'open',
  });
  await saved.populate('patient', personFields);
  res.status(201).json(discussionJson(saved, 0, 0));
});

router.post('/:id/comments', requireUser, async (req, res) => {
  if (req.user.role !== 'doctor') {
    res.status(403).json({ message: 'Only a doctor can reply.' });
    return;
  }
  const body = typeof req.body?.body === 'string' ? req.body.body.trim() : '';
  if (!body) {
    res.status(400).json({ message: 'Enter a reply.' });
    return;
  }
  if (body.length > 1000) {
    res.status(400).json({ message: 'Keep the reply under 1000 characters.' });
    return;
  }

  const discussion = await findDiscussion(req, res);
  if (!discussion) {
    return;
  }

  const saved = await DiscussionComment.create({
    discussion: discussion._id,
    author: req.user._id,
    body,
  });
  await saved.populate('author', personFields);
  if (!discussion.doctor) {
    discussion.doctor = req.user._id;
  }
  discussion.status = 'answered';
  await discussion.save();

  res.status(201).json(commentJson(saved, req.user._id));
});

router.delete('/:id', requireUser, async (req, res) => {
  const discussion = await findDiscussion(req, res);
  if (!discussion) {
    return;
  }
  const postedByMe =
    discussion.patient && discussion.patient._id.equals(req.user._id);
  if (!postedByMe) {
    res.status(403).json({ message: 'Only the person who posted can remove it.' });
    return;
  }
  await DiscussionComment.deleteMany({ discussion: discussion._id });
  await discussion.deleteOne();
  res.status(204).end();
});

router.post('/:id/comments/:commentId/like', requireUser, async (req, res) => {
  await toggleOnComment(req, res, 'likes');
});

router.post('/:id/comments/:commentId/save', requireUser, async (req, res) => {
  await toggleOnComment(req, res, 'savedBy');
});

async function toggleOnComment(req, res, field) {
  if (
    !mongoose.Types.ObjectId.isValid(req.params.id) ||
    !mongoose.Types.ObjectId.isValid(req.params.commentId)
  ) {
    res.status(404).json({ message: 'That question was not found.' });
    return;
  }
  const comment = await DiscussionComment.findOne({
    _id: req.params.commentId,
    discussion: req.params.id,
  });
  if (!comment) {
    res.status(404).json({ message: 'That question was not found.' });
    return;
  }
  const mine = req.user._id;
  const current = comment.get(field) || [];
  const has = current.some((id) => id.equals(mine));
  comment.set(
    field,
    has ? current.filter((id) => !id.equals(mine)) : current.concat(mine),
  );
  await comment.save();
  await comment.populate('author', personFields);
  res.json(commentJson(comment, mine));
}

async function findDiscussion(req, res) {
  if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
    res.status(404).json({ message: 'That question was not found.' });
    return null;
  }
  const discussion = await Discussion.findById(req.params.id)
    .populate('patient', personFields)
    .populate('doctor', personFields);
  if (!discussion) {
    res.status(404).json({ message: 'That question was not found.' });
    return null;
  }
  return discussion;
}

module.exports = router;
