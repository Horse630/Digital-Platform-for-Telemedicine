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
