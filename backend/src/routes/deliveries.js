const express = require('express');

const { readToken } = require('../authToken');
const Appointment = require('../models/Appointment');
const Delivery = require('../models/Delivery');
const User = require('../models/User');

const router = express.Router();
const NEXT_STATUS = {
  preparing: 'in_transit',
  in_transit: 'delivered',
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

function toDeliveryJson(delivery) {
  return {
    id: delivery._id.toString(),
    appointmentId: delivery.appointment.toString(),
    medicationName: delivery.medicationName,
    quantity: delivery.quantity,
    status: delivery.status,
    destination: delivery.destination,
  };
}

router.get('/', requireUser, async (req, res) => {
  let query = { patient: req.user._id };
  if (req.user.role === 'admin') {
    query = {};
  } else if (req.user.role === 'doctor') {
    const appointments = await Appointment.find({ doctor: req.user._id }).select('_id');
    query = { appointment: { $in: appointments.map((row) => row._id) } };
  }
  const deliveries = await Delivery.find(query).sort({ createdAt: -1 });
  res.json(deliveries.map(toDeliveryJson));
});

router.post('/', requireUser, async (req, res) => {
  if (req.user.role !== 'doctor') {
    res.status(403).json({ message: 'Only a doctor can send medicine.' });
    return;
  }
  const medicationName =
    typeof req.body?.medicationName === 'string' ? req.body.medicationName.trim() : '';
  const quantity = Number(req.body?.quantity);
  if (!medicationName || medicationName.length > 80 || !Number.isInteger(quantity) || quantity < 1) {
    res.status(400).json({ message: 'Enter the medicine name and a quantity.' });
    return;
  }
  const appointment = await Appointment.findOne({
    _id: req.body?.appointmentId,
    doctor: req.user._id,
    status: { $in: ['scheduled', 'completed'] },
  }).populate('patient', 'deliveryAddress');
  if (!appointment || !appointment.patient) {
    res.status(404).json({ message: 'Appointment not found.' });
    return;
  }
  const destination = (appointment.patient.deliveryAddress || '').trim() || 'Hong Kong';
  const created = await Delivery.create({
    patient: appointment.patient._id,
    appointment: appointment._id,
    medicationName,
    quantity,
    status: 'preparing',
    destination,
  });
  res.status(201).json(toDeliveryJson(created));
});

router.post('/:id/advance', requireUser, async (req, res) => {
  if (req.user.role !== 'doctor') {
    res.status(403).json({ message: 'Only a doctor can update a delivery.' });
    return;
  }
  const delivery = await Delivery.findById(req.params.id);
  if (!delivery) {
    res.status(404).json({ message: 'Delivery not found.' });
    return;
  }
  const appointment = await Appointment.findOne({
    _id: delivery.appointment,
    doctor: req.user._id,
  });
  if (!appointment) {
    res.status(403).json({ message: 'You cannot change this delivery.' });
    return;
  }
  const next = NEXT_STATUS[delivery.status];
  if (!next) {
    res.status(400).json({ message: 'This delivery is already finished.' });
    return;
  }
  delivery.status = next;
  await delivery.save();
  res.json(toDeliveryJson(delivery));
});

module.exports = router;
