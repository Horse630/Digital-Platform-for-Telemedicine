const express = require('express');

const { readToken } = require('../authToken');
const Appointment = require('../models/Appointment');
const Consultation = require('../models/Consultation');
const User = require('../models/User');

const router = express.Router();
const JOIN_EARLY_MS = 10 * 60 * 1000;
const ROOM_PATTERN = /^[A-Za-z0-9-]{4,12}$/;

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

function canJoin(scheduledAt, now) {
  return now.getTime() >= new Date(scheduledAt).getTime() - JOIN_EARLY_MS;
}

async function ensureRoomCode(user) {
  const current = typeof user.meetingRoomCode === 'string' ? user.meetingRoomCode.trim() : '';
  if (current) {
    return current;
  }
  const code = String(100000 + (Date.now() % 900000));
  user.meetingRoomCode = code;
  await user.save();
  return code;
}

function meetingJson(appointment, consultation) {
  const patient = appointment.patient;
  const doctor = appointment.doctor;
  return {
    appointmentId: appointment._id.toString(),
    scheduledAt: appointment.scheduledAt.toISOString(),
    patientName: patient && patient.fullName ? patient.fullName : '',
    doctorName: doctor && doctor.fullName ? doctor.fullName : '',
    roomCode: consultation ? consultation.channelName : '',
    status: consultation ? consultation.status : 'closed',
    waiting: Boolean(consultation && consultation.waiting),
    admitted: Boolean(consultation && consultation.admitted),
    canEnter: canJoin(appointment.scheduledAt, new Date()),
  };
}

async function loadAppointment(id) {
  if (!id || !id.match(/^[a-f0-9]{24}$/i)) {
    return null;
  }
  return Appointment.findById(id).populate('patient', 'fullName').populate('doctor', 'fullName');
}

router.get('/', requireUser, async (req, res) => {
  const now = new Date();
  if (req.user.role === 'doctor') {
    const from = new Date(req.query.from);
    const to = new Date(req.query.to);
    if (Number.isNaN(from.getTime()) || Number.isNaN(to.getTime())) {
      res.status(400).json({ message: 'The meeting request failed.' });
      return;
    }
    const roomCode = await ensureRoomCode(req.user);
    const appointments = await Appointment.find({
      doctor: req.user._id,
      status: 'scheduled',
      patient: { $ne: null },
      scheduledAt: { $gte: from, $lt: to },
    })
      .populate('patient', 'fullName')
      .populate('doctor', 'fullName')
      .sort({ scheduledAt: 1 });
    const consultations = await Consultation.find({
      appointment: { $in: appointments.map((row) => row._id) },
    });
    const byAppointment = new Map(
      consultations.map((row) => [row.appointment.toString(), row]),
    );
    res.json({
      roomCode,
      meetings: appointments.map((row) =>
        meetingJson(row, byAppointment.get(row._id.toString())),
      ),
    });
    return;
  }

  if (req.user.role === 'patient') {
    const consultations = await Consultation.find({
      patient: req.user._id,
      status: 'live',
    }).populate({
      path: 'appointment',
      populate: [
        { path: 'patient', select: 'fullName' },
        { path: 'doctor', select: 'fullName' },
      ],
    });
  const meetings = consultations
    .filter((row) => row.appointment)
    .map((row) => meetingJson(row.appointment, row));
    res.json({ meetings });
    return;
  }

  res.json({ meetings: [] });
});

router.patch('/room', requireUser, async (req, res) => {
  if (req.user.role !== 'doctor') {
    res.status(403).json({ message: 'Only a doctor can change the room number.' });
    return;
  }
  const code = typeof req.body?.roomCode === 'string' ? req.body.roomCode.trim() : '';
  if (!ROOM_PATTERN.test(code)) {
    res.status(400).json({ message: 'Use 4 to 12 letters or numbers for the room number.' });
    return;
  }
  req.user.meetingRoomCode = code;
  await req.user.save();
  await Consultation.updateMany(
    { doctor: req.user._id, status: 'live' },
    { channelName: code },
  );
  res.json({ roomCode: code });
});

router.post('/:appointmentId/host', requireUser, async (req, res) => {
  if (req.user.role !== 'doctor') {
    res.status(403).json({ message: 'Only a doctor can host a meeting.' });
    return;
  }
  const appointment = await loadAppointment(req.params.appointmentId);
  if (
    !appointment ||
    appointment.doctor._id.toString() !== req.user._id.toString() ||
    !appointment.patient ||
    appointment.status !== 'scheduled'
  ) {
    res.status(404).json({ message: 'That appointment was not found.' });
    return;
  }
  const roomCode = await ensureRoomCode(req.user);
  let consultation = await Consultation.findOne({ appointment: appointment._id });
  if (!consultation) {
    consultation = await Consultation.create({
      appointment: appointment._id,
      patient: appointment.patient._id,
      doctor: req.user._id,
      status: 'live',
      channelName: roomCode,
      waiting: false,
      admitted: false,
    });
  } else {
    consultation.status = 'live';
    consultation.channelName = roomCode;
    consultation.waiting = false;
    consultation.admitted = false;
    await consultation.save();
  }
  res.status(201).json(meetingJson(appointment, consultation));
});

router.post('/:appointmentId/join', requireUser, async (req, res) => {
  const appointment = await loadAppointment(req.params.appointmentId);
  if (
    !appointment ||
    !appointment.patient ||
    appointment.patient._id.toString() !== req.user._id.toString()
  ) {
    res.status(404).json({ message: 'That appointment was not found.' });
    return;
  }
  if (!canJoin(appointment.scheduledAt, new Date())) {
    res.status(400).json({ message: 'You can join from 10 minutes before the meeting.' });
    return;
  }
  const consultation = await Consultation.findOne({ appointment: appointment._id, status: 'live' });
  if (!consultation) {
    res.status(400).json({ message: 'The doctor has not opened this meeting yet.' });
    return;
  }
  if (!consultation.admitted) {
    consultation.waiting = true;
    await consultation.save();
  }
  res.json(meetingJson(appointment, consultation));
});

router.post('/:appointmentId/admit', requireUser, async (req, res) => {
  if (req.user.role !== 'doctor') {
    res.status(403).json({ message: 'Only a doctor can host a meeting.' });
    return;
  }
  const appointment = await loadAppointment(req.params.appointmentId);
  const consultation = appointment
    ? await Consultation.findOne({ appointment: appointment._id, doctor: req.user._id, status: 'live' })
    : null;
  if (!appointment || !consultation) {
    res.status(404).json({ message: 'That appointment was not found.' });
    return;
  }
  consultation.admitted = true;
  consultation.waiting = false;
  await consultation.save();
  res.json(meetingJson(appointment, consultation));
});

router.post('/:appointmentId/end', requireUser, async (req, res) => {
  if (req.user.role !== 'doctor') {
    res.status(403).json({ message: 'Only a doctor can host a meeting.' });
    return;
  }
  const appointment = await loadAppointment(req.params.appointmentId);
  const consultation = appointment
    ? await Consultation.findOne({ appointment: appointment._id, doctor: req.user._id })
    : null;
  if (!appointment || !consultation) {
    res.status(404).json({ message: 'That appointment was not found.' });
    return;
  }
  consultation.status = 'ended';
  consultation.waiting = false;
  await consultation.save();
  res.json(meetingJson(appointment, consultation));
});

router.get('/:appointmentId', requireUser, async (req, res) => {
  const appointment = await loadAppointment(req.params.appointmentId);
  if (!appointment) {
    res.status(404).json({ message: 'That appointment was not found.' });
    return;
  }
  const doctorId = appointment.doctor._id.toString();
  const patientId = appointment.patient ? appointment.patient._id.toString() : '';
  const userId = req.user._id.toString();
  if (userId !== doctorId && userId !== patientId && req.user.role !== 'admin') {
    res.status(403).json({ message: 'You cannot open this meeting.' });
    return;
  }
  const consultation = await Consultation.findOne({ appointment: appointment._id });
  res.json(meetingJson(appointment, consultation));
});

module.exports = router;
