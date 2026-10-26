const mongoose = require('mongoose');

const STATUSES = ['preparing', 'in_transit', 'delivered'];

const deliverySchema = new mongoose.Schema(
  {
    seedKey: { type: String, unique: true, sparse: true },
    patient: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    appointment: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Appointment',
      required: true,
    },
    medicationName: { type: String, required: true, trim: true },
    quantity: { type: Number, required: true, min: 1 },
    status: { type: String, required: true, enum: STATUSES },
    destination: { type: String, required: true, trim: true },
  },
  { collection: 'deliveries', timestamps: true },
);

module.exports = mongoose.model('Delivery', deliverySchema);
