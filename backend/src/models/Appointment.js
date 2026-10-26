const mongoose = require('mongoose');

const STATUSES = ['scheduled', 'completed', 'cancelled'];

const appointmentSchema = new mongoose.Schema(
  {
    // Lets the seed script update this demo row instead of inserting a copy.
    seedKey: { type: String, unique: true, sparse: true },
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
    scheduledAt: { type: Date, required: true },
    reason: { type: String, required: true, trim: true, maxlength: 200 },
    status: { type: String, required: true, enum: STATUSES },
  },
  { collection: 'appointments', timestamps: true },
);

module.exports = mongoose.model('Appointment', appointmentSchema);
