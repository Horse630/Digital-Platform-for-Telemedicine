const bcrypt = require('bcryptjs');
const mongoose = require('mongoose');

// One users collection. role decides whether the document is an admin, doctor, or patient.
const ROLES = ['admin', 'doctor', 'patient'];
const BCRYPT_ROUNDS = 12;

const userSchema = new mongoose.Schema(
  {
    username: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      minlength: 3,
      maxlength: 40,
    },
    // Store a hash. The plain password is never written to MongoDB.
    passwordHash: {
      type: String,
      required: true,
    },
    role: {
      type: String,
      required: true,
      enum: ROLES,
    },
    fullName: {
      type: String,
      required: true,
      trim: true,
      maxlength: 80,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      lowercase: true,
      match: [/^\S+@\S+\.\S+$/, 'Enter a valid email'],
    },
    // Filled for doctors. Admin and patient documents leave these empty.
    specialty: {
      type: String,
      trim: true,
    },
    licenseNumber: {
      type: String,
      trim: true,
    },
    // Filled for patients. Admin and doctor documents leave this empty.
    dateOfBirth: {
      type: Date,
    },
    // Optional note the person writes on the settings page.
    description: {
      type: String,
      trim: true,
      maxlength: 280,
      default: '',
    },
    // Profile photo as base64, without a data-url prefix. Empty when unset.
    avatarBase64: {
      type: String,
      default: '',
      maxlength: 700000,
    },
    avatarMime: {
      type: String,
      enum: ['', 'image/jpeg', 'image/png', 'image/webp'],
      default: '',
    },
  },
  {
    collection: 'users',
    timestamps: true,
  },
);

// Specialty and license are optional for now. Patient and doctor sign-up
// use the same fields. A later doctor sign-up step should require them.
userSchema.statics.hashPassword = function hashPassword(plainPassword) {
  return bcrypt.hash(plainPassword, BCRYPT_ROUNDS);
};

userSchema.methods.comparePassword = function comparePassword(plainPassword) {
  return bcrypt.compare(plainPassword, this.passwordHash);
};

// Hide the hash if a later API sends the document as JSON.
userSchema.set('toJSON', {
  transform(_doc, ret) {
    delete ret.passwordHash;
    return ret;
  },
});

const User = mongoose.model('User', userSchema);
User.ROLES = ROLES;

module.exports = User;
