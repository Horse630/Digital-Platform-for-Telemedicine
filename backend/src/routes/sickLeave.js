const express = require('express');
const mongoose = require('mongoose');

const { readToken } = require('../authToken');
const Appointment = require('../models/Appointment');
const SickLeaveCertificate = require('../models/SickLeaveCertificate');
const User = require('../models/User');

const router = express.Router();
const personFields = 'fullName licenseNumber';

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
    licenseNumber: user.licenseNumber || '',
  };
}

function dayCount(from, to) {
  return Math.round((to.getTime() - from.getTime()) / 86400000) + 1;
}

function certificateJson(row) {
  const from = row.validFrom;
  const to = row.validTo;
  return {
    id: row._id.toString(),
    certificateNumber: row.certificateNumber,
    appointmentId: row.appointment ? row.appointment.toString() : '',
    issuedOn: row.issuedOn.toISOString(),
    validFrom: from.toISOString(),
    validTo: to.toISOString(),
    dayCount: row.dayCount || dayCount(from, to),
    patientAddress: row.patientAddress || '',
    unfitFor: row.unfitFor || '',
    summary: row.summary,
    signature: row.signature || '',
    readOnly: true,
    patient: personJson(row.patient),
    doctor: personJson(row.doctor),
  };
}

function parseDay(value) {
  if (typeof value !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(value)) {
    return null;
  }
  const date = new Date(`${value}T00:00:00.000Z`);
  return Number.isNaN(date.getTime()) ? null : date;
}

function text(value) {
  return typeof value === 'string' ? value.trim() : '';
}

router.get('/', requireUser, async (req, res) => {
  const filter = {};
  if (req.user.role === 'doctor') {
    filter.doctor = req.user._id;
  } else if (req.user.role === 'patient') {
    filter.patient = req.user._id;
  }
  const rows = await SickLeaveCertificate.find(filter)
    .sort({ issuedOn: -1 })
    .limit(100)
    .populate('patient', personFields)
    .populate('doctor', personFields);
  res.json(rows.map(certificateJson));
});

router.get('/:id', requireUser, async (req, res) => {
  const row = await findReadable(req, res);
  if (!row) {
    return;
  }
  res.json(certificateJson(row));
});

router.post('/', requireUser, async (req, res) => {
  if (req.user.role !== 'doctor') {
    res.status(403).json({ message: 'Only a doctor can issue a certificate.' });
    return;
  }
  const appointmentId = text(req.body?.appointmentId);
  if (!mongoose.Types.ObjectId.isValid(appointmentId)) {
    res.status(400).json({ message: 'Choose an appointed patient.' });
    return;
  }
  const patientAddress = text(req.body?.patientAddress);
  const unfitFor = text(req.body?.unfitFor);
  const summary = text(req.body?.summary);
  const signature = text(req.body?.signature);
  const validFrom = parseDay(req.body?.validFrom);
  const validTo = parseDay(req.body?.validTo);
  if (!patientAddress) {
    res.status(400).json({ message: 'Enter the patient address.' });
    return;
  }
  if (patientAddress.length > 200) {
    res.status(400).json({ message: 'Keep the address under 200 characters.' });
    return;
  }
  if (!unfitFor) {
    res.status(400).json({ message: 'Enter what the patient is unfit for.' });
    return;
  }
  if (unfitFor.length > 120) {
    res.status(400).json({ message: 'Keep that line under 120 characters.' });
    return;
  }
  if (!summary) {
    res.status(400).json({ message: 'Enter the sickness.' });
    return;
  }
  if (summary.length > 300) {
    res.status(400).json({ message: 'Keep the sickness under 300 characters.' });
    return;
  }
  if (!signature) {
    res.status(400).json({ message: 'Enter your signature.' });
    return;
  }
  if (signature.length > 80) {
    res.status(400).json({ message: 'Keep the signature under 80 characters.' });
    return;
  }
  if (!validFrom) {
    res.status(400).json({ message: 'Enter the start date.' });
    return;
  }
  if (!validTo) {
    res.status(400).json({ message: 'Enter the end date.' });
    return;
  }
  if (validTo < validFrom) {
    res.status(400).json({ message: 'The end date must be on or after the start date.' });
    return;
  }

  const appointment = await Appointment.findById(appointmentId);
  if (!appointment || !appointment.doctor.equals(req.user._id) || !appointment.patient) {
    res.status(404).json({ message: 'That appointment was not found.' });
    return;
  }
  if (appointment.status !== 'scheduled' && appointment.status !== 'completed') {
    res.status(400).json({ message: 'Choose an appointed patient.' });
    return;
  }
  const existing = await SickLeaveCertificate.findOne({ appointment: appointment._id });
  if (existing) {
    res.status(409).json({ message: 'A certificate already exists for that appointment.' });
    return;
  }

  const saved = await SickLeaveCertificate.create({
    certificateNumber: `SL-${Date.now().toString(36).toUpperCase()}`,
    appointment: appointment._id,
    patient: appointment.patient,
    doctor: req.user._id,
    issuedOn: new Date(),
    validFrom,
    validTo,
    dayCount: dayCount(validFrom, validTo),
    patientAddress,
    unfitFor,
    summary,
    signature,
    readOnly: true,
  });
  await saved.populate('patient', personFields);
  await saved.populate('doctor', personFields);
  res.status(201).json(certificateJson(saved));
});

async function findReadable(req, res) {
  if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
    res.status(404).json({ message: 'That certificate was not found.' });
    return null;
  }
  const row = await SickLeaveCertificate.findById(req.params.id)
    .populate('patient', personFields)
    .populate('doctor', personFields);
  if (!row) {
    res.status(404).json({ message: 'That certificate was not found.' });
    return null;
  }
  const mine = req.user._id;
  const allowed =
    req.user.role === 'admin' ||
    (row.patient && row.patient._id.equals(mine)) ||
    (row.doctor && row.doctor._id.equals(mine));
  if (!allowed) {
    res.status(403).json({ message: 'You cannot open this certificate.' });
    return null;
  }
  return row;
}

module.exports = router;
