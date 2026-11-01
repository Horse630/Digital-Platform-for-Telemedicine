const mongoose = require('mongoose');

const STATUSES = ['scheduled', 'live', 'ended'];

// One video visit. The video SDK is not connected yet, so channelName is only a label.
const consultationSchema = new mongoose.Schema(
  {
    seedKey: { type: String, unique: true, sparse: true },
    appointment: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Appointment',
      required: true,
    },
    patient: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    doctor: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    status: { type: String, required: true, enum: STATUSES },
    channelName: { type: String, required: true, trim: true },
    // The patient is in the waiting room until the doctor lets them in.
    waiting: { type: Boolean, default: false },
    admitted: { type: Boolean, default: false },
  },
  { collection: 'consultations', timestamps: true },
);

module.exports = mongoose.model('Consultation', consultationSchema);
