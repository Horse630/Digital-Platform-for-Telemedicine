const mongoose = require('mongoose');

const STATUSES = ['pending', 'paid', 'failed'];
const PURPOSES = ['consultation', 'delivery'];

// A local record of a fee. PayPal is not called by this model.
const paymentSchema = new mongoose.Schema(
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
    amount: { type: Number, required: true, min: 0 },
    currency: { type: String, required: true, default: 'HKD' },
    purpose: { type: String, required: true, enum: PURPOSES },
    status: { type: String, required: true, enum: STATUSES },
    provider: { type: String, required: true, default: 'paypal_sandbox' },
  },
  { collection: 'payments', timestamps: true },
);

module.exports = mongoose.model('Payment', paymentSchema);
