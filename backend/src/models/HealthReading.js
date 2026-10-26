const mongoose = require('mongoose');

const METRICS = ['heart_rate', 'steps', 'blood_oxygen'];

// One wearable sample. The phone health library is not connected yet.
const healthReadingSchema = new mongoose.Schema(
  {
    seedKey: { type: String, unique: true, sparse: true },
    patient: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    metric: { type: String, required: true, enum: METRICS },
    value: { type: Number, required: true },
    unit: { type: String, required: true, trim: true },
    recordedAt: { type: Date, required: true },
  },
  { collection: 'health_readings', timestamps: true },
);

module.exports = mongoose.model('HealthReading', healthReadingSchema);
