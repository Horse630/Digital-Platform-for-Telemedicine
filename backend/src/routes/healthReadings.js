const express = require('express');

const { readToken } = require('../authToken');
const HealthReading = require('../models/HealthReading');
const User = require('../models/User');

const router = express.Router();
const UNITS = {
  heart_rate: 'bpm',
  steps: 'steps',
  blood_oxygen: '%',
};

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

router.get('/', requireUser, async (req, res) => {
  if (req.user.role !== 'patient') {
    res.json([]);
    return;
  }
  const readings = await HealthReading.find({ patient: req.user._id })
    .sort({ recordedAt: -1 })
    .limit(20);
  res.json(
    readings.map((row) => ({
      id: row._id.toString(),
      metric: row.metric,
      value: row.value,
      unit: row.unit,
      recordedAt: row.recordedAt.toISOString(),
    })),
  );
});

router.post('/', requireUser, async (req, res) => {
  if (req.user.role !== 'patient') {
    res.status(403).json({ message: 'Only a patient can save a reading.' });
    return;
  }
  const metric = req.body?.metric;
  const value = Number(req.body?.value);
  if (!UNITS[metric] || !Number.isFinite(value) || value < 0 || value > 100000) {
    res.status(400).json({ message: 'Enter a heart rate, step count, or blood oxygen.' });
    return;
  }
  const created = await HealthReading.create({
    patient: req.user._id,
    metric,
    value,
    unit: UNITS[metric],
    recordedAt: new Date(),
  });
  res.status(201).json({
    id: created._id.toString(),
    metric: created.metric,
    value: created.value,
    unit: created.unit,
    recordedAt: created.recordedAt.toISOString(),
  });
});

module.exports = router;
