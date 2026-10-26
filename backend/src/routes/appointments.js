const express = require('express');

const { readToken } = require('../authToken');
const Appointment = require('../models/Appointment');
const User = require('../models/User');

const router = express.Router();

// The Flutter app sends the token from POST /api/login.
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

function toAppointmentJson(appointment) {
  return {
    id: appointment._id.toString(),
    scheduledAt: appointment.scheduledAt.toISOString(),
    status: appointment.status,
    reason: appointment.reason || '',
    doctor: {
      id: appointment.doctor._id.toString(),
      fullName: appointment.doctor.fullName,
      specialty: appointment.doctor.specialty || '',
    },
    patient: appointment.patient
      ? {
          id: appointment.patient._id.toString(),
          fullName: appointment.patient.fullName,
        }
      : null,
  };
}

function listQuery(user) {
  if (user.role === 'admin') {
    return {};
  }
  if (user.role === 'doctor') {
    return { doctor: user._id };
  }
  return {
    $or: [
      { status: 'available', scheduledAt: { $gte: new Date() } },
      { patient: user._id },
    ],
  };
}

router.get('/', requireUser, async (req, res) => {
  const appointments = await Appointment.find(listQuery(req.user))
    .populate('doctor', 'fullName specialty')
    .populate('patient', 'fullName')
    .sort({ scheduledAt: 1 });
  res.json(appointments.map(toAppointmentJson));
});

router.post('/', requireUser, async (req, res) => {
  if (req.user.role !== 'doctor') {
    res.status(403).json({ message: 'Only a doctor can add a time slot.' });
    return;
  }

  const scheduledAt = new Date(req.body?.scheduledAt);
  if (Number.isNaN(scheduledAt.getTime()) || scheduledAt.getTime() <= Date.now()) {
    res.status(400).json({ message: 'Choose a time in the future.' });
    return;
  }

  const clash = await Appointment.findOne({
    doctor: req.user._id,
    scheduledAt,
    status: { $in: ['available', 'scheduled'] },
  });
  if (clash) {
    res.status(409).json({ message: 'You already have a slot at that time.' });
    return;
  }

  const created = await Appointment.create({
    doctor: req.user._id,
    scheduledAt,
    status: 'available',
  });
  await created.populate('doctor', 'fullName specialty');
  res.status(201).json(toAppointmentJson(created));
});

router.post('/:id/book', requireUser, async (req, res) => {
  if (req.user.role !== 'patient') {
    res.status(403).json({ message: 'Only a patient can book a time slot.' });
    return;
  }

  const reason = typeof req.body?.reason === 'string' ? req.body.reason.trim() : '';
  if (!reason || reason.length > 200) {
    res.status(400).json({ message: 'Enter a short reason for the visit.' });
    return;
  }

  const booked = await Appointment.findOneAndUpdate(
    { _id: req.params.id, status: 'available', scheduledAt: { $gt: new Date() } },
    { patient: req.user._id, reason, status: 'scheduled' },
    { new: true },
  );
  if (!booked) {
    res.status(409).json({ message: 'That time slot is no longer available.' });
    return;
  }
  await booked.populate('doctor', 'fullName specialty');
  await booked.populate('patient', 'fullName');
  res.json(toAppointmentJson(booked));
});

router.post('/:id/cancel', requireUser, async (req, res) => {
  const appointment = await Appointment.findById(req.params.id);
  if (!appointment) {
    res.status(404).json({ message: 'Appointment not found.' });
    return;
  }

  const isDoctor = req.user.role === 'doctor' && appointment.doctor.equals(req.user._id);
  const isPatient =
    req.user.role === 'patient' &&
    appointment.patient &&
    appointment.patient.equals(req.user._id);

  if (isPatient && appointment.status === 'scheduled') {
    await Appointment.findByIdAndUpdate(appointment._id, {
      $set: { status: 'available' },
      $unset: { patient: '', reason: '' },
    });
    appointment.status = 'available';
    appointment.patient = undefined;
    appointment.reason = undefined;
  } else if (isDoctor && (appointment.status === 'available' || appointment.status === 'scheduled')) {
    appointment.status = 'cancelled';
    await appointment.save();
  } else {
    res.status(403).json({ message: 'You cannot change this appointment.' });
    return;
  }

  await appointment.populate('doctor', 'fullName specialty');
  await appointment.populate('patient', 'fullName');
  res.json(toAppointmentJson(appointment));
});

module.exports = router;
