const express = require('express');
const mongoose = require('mongoose');

const { readToken } = require('../authToken');
const DirectMessage = require('../models/DirectMessage');
const User = require('../models/User');

const router = express.Router();

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
  return {
    id: user._id.toString(),
    fullName: user.fullName,
    avatarBase64: user.avatarBase64 || '',
  };
}

function messageJson(message, mine) {
  return {
    id: message._id.toString(),
    text: message.text,
    fromMe: mine.equals(message.sender),
    sentAt: message.createdAt.toISOString(),
    read: Boolean(message.readAt),
  };
}

router.get('/', requireUser, async (req, res) => {
  const mine = req.user._id;
  const rows = await DirectMessage.aggregate([
    { $match: { $or: [{ sender: mine }, { recipient: mine }] } },
    { $sort: { createdAt: -1 } },
    {
      $addFields: {
        other: {
          $cond: [{ $eq: ['$sender', mine] }, '$recipient', '$sender'],
        },
      },
    },
    {
      $group: {
        _id: '$other',
        text: { $first: '$text' },
        sentAt: { $first: '$createdAt' },
        unread: {
          $sum: {
            $cond: [
              {
                $and: [
                  { $eq: ['$recipient', mine] },
                  { $eq: [{ $ifNull: ['$readAt', null] }, null] },
                ],
              },
              1,
              0,
            ],
          },
        },
      },
    },
    { $sort: { sentAt: -1 } },
  ]);

  const people = await User.find({ _id: { $in: rows.map((row) => row._id) } }).select(
    'fullName avatarBase64',
  );
  const byId = new Map(people.map((person) => [person._id.toString(), person]));

  res.json(
    rows
      .filter((row) => byId.has(row._id.toString()))
      .map((row) => ({
        user: personJson(byId.get(row._id.toString())),
        text: row.text,
        sentAt: row.sentAt.toISOString(),
        unread: row.unread,
      })),
  );
});

router.get('/:userId', requireUser, async (req, res) => {
  const other = await findOther(req, res);
  if (!other) {
    return;
  }
  const mine = req.user._id;
  await DirectMessage.updateMany(
    { sender: other._id, recipient: mine, readAt: null },
    { $set: { readAt: new Date() } },
  );
  const messages = await DirectMessage.find({
    $or: [
      { sender: mine, recipient: other._id },
      { sender: other._id, recipient: mine },
    ],
  })
    .sort({ createdAt: 1 })
    .limit(200);

  res.json({
    user: personJson(other),
    messages: messages.map((message) => messageJson(message, mine)),
  });
});

router.post('/:userId', requireUser, async (req, res) => {
  const text = typeof req.body?.text === 'string' ? req.body.text.trim() : '';
  if (!text) {
    res.status(400).json({ message: 'Enter a message.' });
    return;
  }
  if (text.length > 500) {
    res.status(400).json({ message: 'Keep the message under 500 characters.' });
    return;
  }

  const other = await findOther(req, res);
  if (!other) {
    return;
  }

  const saved = await DirectMessage.create({
    sender: req.user._id,
    recipient: other._id,
    text,
  });
  res.status(201).json(messageJson(saved, req.user._id));
});

async function findOther(req, res) {
  if (!mongoose.Types.ObjectId.isValid(req.params.userId)) {
    res.status(404).json({ message: 'That person was not found.' });
    return null;
  }
  if (req.params.userId === req.user._id.toString()) {
    res.status(400).json({ message: 'You cannot message yourself.' });
    return null;
  }
  const other = await User.findById(req.params.userId).select('fullName avatarBase64');
  if (!other) {
    res.status(404).json({ message: 'That person was not found.' });
    return null;
  }
  return other;
}

module.exports = router;
