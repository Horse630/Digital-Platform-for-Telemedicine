const path = require('path');

const cors = require('cors');
const dotenv = require('dotenv');
const express = require('express');

// Load backend/.env. The Atlas URI is not hard-coded.
dotenv.config({ path: path.resolve(__dirname, '../.env') });

const { signToken } = require('./authToken');
const { connectDatabase } = require('./db');
const User = require('./models/User');
const appointmentsRouter = require('./routes/appointments');

const PORT = Number(process.env.PORT) || 3000;
const app = express();

app.use(cors());
// Profile photos are sent as base64, so the JSON body can be larger than the default 100 KB.
app.use(express.json({ limit: '2mb' }));
app.use('/api/appointments', appointmentsRouter);
app.use('/api/profile', require('./routes/profile'));

app.get('/api/health', (_req, res) => {
  res.json({ ok: true });
});

// Checks the users collection. The Flutter app calls this instead of MongoDB directly.
app.post('/api/login', async (req, res) => {
  const username =
    typeof req.body?.username === 'string' ? req.body.username.trim() : '';
  const password = typeof req.body?.password === 'string' ? req.body.password : '';

  if (!username || !password) {
    res.status(400).json({ message: 'Enter your username and password.' });
    return;
  }

  try {
    const user = await User.findOne({
      username: new RegExp(`^${escapeRegex(username)}$`, 'i'),
    });
    const passwordMatches = user ? await user.comparePassword(password) : false;
    if (!user || !passwordMatches) {
      res.status(401).json({ message: 'Username or password is incorrect.' });
      return;
    }

    res.json({
      username: user.username,
      role: user.role,
      fullName: user.fullName,
      token: signToken(user),
    });
  } catch (_error) {
    res.status(500).json({ message: 'Sign-in failed. Try again.' });
  }
});

function escapeRegex(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

const USERNAME_PATTERN = /^[A-Za-z0-9._-]{3,40}$/;
const EMAIL_PATTERN = /^\S+@\S+\.\S+$/;

// Creates a patient or a doctor. Admin accounts are not created here.
// Both roles send the same fields until doctor sign-up collects a license.
app.post('/api/signup', async (req, res) => {
  const username =
    typeof req.body?.username === 'string' ? req.body.username.trim() : '';
  const email = typeof req.body?.email === 'string' ? req.body.email.trim().toLowerCase() : '';
  const password = typeof req.body?.password === 'string' ? req.body.password : '';
  const role = typeof req.body?.role === 'string' ? req.body.role : '';

  if (role !== 'patient' && role !== 'doctor') {
    res.status(400).json({ message: 'Choose patient or doctor.' });
    return;
  }
  if (!USERNAME_PATTERN.test(username)) {
    res.status(400).json({
      message: 'Use 3 to 40 letters, numbers, dots, underscores, or hyphens.',
    });
    return;
  }
  if (!EMAIL_PATTERN.test(email)) {
    res.status(400).json({ message: 'Enter a valid email.' });
    return;
  }
  if (password.length < 8) {
    res.status(400).json({ message: 'Use at least 8 characters.' });
    return;
  }

  try {
    const takenName = await User.findOne({
      username: new RegExp(`^${escapeRegex(username)}$`, 'i'),
    });
    if (takenName) {
      res.status(409).json({ message: 'That username is already used.' });
      return;
    }
    const takenEmail = await User.findOne({ email });
    if (takenEmail) {
      res.status(409).json({ message: 'That email is already used.' });
      return;
    }

    const user = await User.create({
      username,
      email,
      passwordHash: await User.hashPassword(password),
      role,
      fullName: username,
    });
    res.status(201).json({
      username: user.username,
      role: user.role,
      fullName: user.fullName,
      token: signToken(user),
    });
  } catch (error) {
    if (error && error.code === 11000) {
      const keys = error.keyPattern || {};
      const message = keys.email
        ? 'That email is already used.'
        : 'That username is already used.';
      res.status(409).json({ message });
      return;
    }
    res.status(400).json({ message: 'Could not create the account.' });
  }
});

app.use((error, _req, res, _next) => {
  const message = error && error.message ? error.message : 'Request failed';
  console.error(message.replace(/mongodb(\+srv)?:\/\/\S+/gi, 'mongodb://***'));
  if (!res.headersSent) {
    res.status(500).json({ message: 'The request failed. Try again.' });
  }
});

async function start() {
  await connectDatabase(process.env.MONGODB_URI);
  app.listen(PORT, () => {
    console.log(`API listening on http://localhost:${PORT}`);
  });
}

if (require.main === module) {
  start().catch((error) => {
    const message = error && error.message ? error.message : 'Could not start the API';
    console.error(message.replace(/mongodb(\+srv)?:\/\/\S+/gi, 'mongodb://***'));
    process.exit(1);
  });
}

module.exports = { app, start };
