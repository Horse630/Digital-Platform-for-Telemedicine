const express = require('express');

const { readToken, signToken } = require('../authToken');
const User = require('../models/User');

const router = express.Router();

const USERNAME_PATTERN = /^[A-Za-z0-9._-]{3,40}$/;
const AVATAR_MIMES = ['image/jpeg', 'image/png', 'image/webp'];
const MAX_AVATAR_CHARS = 700000;

// Same bearer-token check the appointment routes use.
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

function escapeRegex(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function profileJson(user, token) {
  const body = {
    username: user.username,
    role: user.role,
    fullName: user.fullName,
    description: user.description || '',
    avatarBase64: user.avatarBase64 || '',
    avatarMime: user.avatarMime || '',
  };
  if (token) {
    body.token = token;
  }
  return body;
}

function readAvatar(body) {
  if (!Object.prototype.hasOwnProperty.call(body, 'avatarBase64')) {
    return { skip: true };
  }
  const value = body.avatarBase64;
  if (value === '' || value === null) {
    return { avatarBase64: '', avatarMime: '' };
  }
  const mime = body.avatarMime;
  const validText =
    typeof value === 'string' &&
    value.length <= MAX_AVATAR_CHARS &&
    /^[A-Za-z0-9+/]+={0,2}$/.test(value);
  if (!validText || !AVATAR_MIMES.includes(mime)) {
    return { error: 'Choose a JPEG, PNG, or WebP image under 512 KB.' };
  }
  return { avatarBase64: value, avatarMime: mime };
}

router.get('/', requireUser, (req, res) => {
  res.json(profileJson(req.user));
});

// Username, description, and photo. The password has its own route.
router.patch('/', requireUser, async (req, res) => {
  const username = typeof req.body?.username === 'string' ? req.body.username.trim() : '';
  const description =
    typeof req.body?.description === 'string' ? req.body.description.trim() : null;

  if (!USERNAME_PATTERN.test(username)) {
    res.status(400).json({
      message: 'Use 3 to 40 letters, numbers, dots, underscores, or hyphens.',
    });
    return;
  }
  if (description === null || description.length > 280) {
    res.status(400).json({ message: 'Keep the description under 280 characters.' });
    return;
  }

  const avatar = readAvatar(req.body || {});
  if (avatar.error) {
    res.status(400).json({ message: avatar.error });
    return;
  }

  if (username.toLowerCase() !== req.user.username.toLowerCase()) {
    const taken = await User.findOne({
      _id: { $ne: req.user._id },
      username: new RegExp(`^${escapeRegex(username)}$`, 'i'),
    });
    if (taken) {
      res.status(409).json({ message: 'That username is already used.' });
      return;
    }
  }

  req.user.username = username;
  req.user.description = description;
  if (!avatar.skip) {
    req.user.avatarBase64 = avatar.avatarBase64;
    req.user.avatarMime = avatar.avatarMime;
  }

  try {
    await req.user.save();
  } catch (error) {
    if (error && error.code === 11000) {
      res.status(409).json({ message: 'That username is already used.' });
      return;
    }
    res.status(400).json({ message: 'Could not save the profile.' });
    return;
  }

  res.json(profileJson(req.user, signToken(req.user)));
});

router.post('/password', requireUser, async (req, res) => {
  const currentPassword =
    typeof req.body?.currentPassword === 'string' ? req.body.currentPassword : '';
  const newPassword = typeof req.body?.newPassword === 'string' ? req.body.newPassword : '';

  if (!currentPassword || !newPassword) {
    res.status(400).json({ message: 'Enter your current password and a new password.' });
    return;
  }
  if (newPassword.length < 8) {
    res.status(400).json({ message: 'Use at least 8 characters.' });
    return;
  }

  const currentMatches = await req.user.comparePassword(currentPassword);
  if (!currentMatches) {
    res.status(401).json({ message: 'Current password is incorrect.' });
    return;
  }
  if (await req.user.comparePassword(newPassword)) {
    res.status(400).json({ message: 'Choose a different password.' });
    return;
  }

  req.user.passwordHash = await User.hashPassword(newPassword);
  await req.user.save();
  res.json({ message: 'Password updated.' });
});

module.exports = router;
