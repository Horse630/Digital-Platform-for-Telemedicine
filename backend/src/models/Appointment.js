const mongoose = require('mongoose');

// available: a doctor published this time and nobody has booked it.
// scheduled: a patient booked it.
const STATUSES = ['available', 'scheduled', 'completed', 'cancelled'];

const appointmentSchema = new mongoose.Schema(
  {
    // Lets the seed script update this demo row instead of inserting a copy.
    seedKey: { type: String, unique: true, sparse: true },
    patient: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: function patientRequired() {
        return this.status === 'scheduled' || this.status === 'completed';
      },
    },
    doctor: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    scheduledAt: { type: Date, required: true },
    reason: {
      type: String,
      trim: true,
      maxlength: 200,
      required: function reasonRequired() {
        return this.status === 'scheduled' || this.status === 'completed';
      },
    },
    // Short note the doctor writes when the visit is marked completed.
    visitNote: {
      type: String,
      trim: true,
      maxlength: 500,
      default: '',
    },
    // 1 to 5, set once by the patient after the visit is completed.
    patientRating: {
      type: Number,
      min: 1,
      max: 5,
    },
    status: { type: String, required: true, enum: STATUSES },
  },
  { collection: 'appointments', timestamps: true },
);

module.exports = mongoose.model('Appointment', appointmentSchema);
