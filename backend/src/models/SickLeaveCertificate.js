const mongoose = require('mongoose');

// A certificate is stored as data the app can render later. It is marked read-only.
const sickLeaveCertificateSchema = new mongoose.Schema(
  {
    seedKey: { type: String, unique: true, sparse: true },
    certificateNumber: { type: String, required: true, unique: true, trim: true },
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
    issuedOn: { type: Date, required: true },
    validFrom: { type: Date, required: true },
    validTo: { type: Date, required: true },
    dayCount: { type: Number, required: true, min: 1 },
    patientAddress: { type: String, required: true, trim: true, maxlength: 200 },
    unfitFor: { type: String, required: true, trim: true, maxlength: 120 },
    summary: { type: String, required: true, trim: true, maxlength: 300 },
    signature: { type: String, required: true, trim: true, maxlength: 80 },
    readOnly: { type: Boolean, required: true, default: true },
  },
  { collection: 'sick_leave_certificates', timestamps: true },
);

module.exports = mongoose.model('SickLeaveCertificate', sickLeaveCertificateSchema);
