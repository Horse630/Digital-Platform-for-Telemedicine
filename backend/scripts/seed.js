const path = require('path');

const dotenv = require('dotenv');
const mongoose = require('mongoose');

// Load backend/.env. The Atlas username, password, and URI are not hard-coded.
dotenv.config({ path: path.resolve(__dirname, '../.env') });

const { DB_NAME, connectDatabase, disconnectDatabase } = require('../src/db');
const User = require('../src/models/User');
const Appointment = require('../src/models/Appointment');
const Consultation = require('../src/models/Consultation');
const SickLeaveCertificate = require('../src/models/SickLeaveCertificate');
const Payment = require('../src/models/Payment');
const Delivery = require('../src/models/Delivery');
const ChatbotMessage = require('../src/models/ChatbotMessage');
const Discussion = require('../src/models/Discussion');
const DiscussionComment = require('../src/models/DiscussionComment');
const HealthReading = require('../src/models/HealthReading');

// App demo accounts. These are not the Atlas login.
const SEED_USERS = [
  {
    username: 'admin',
    password: 'Admin123!',
    role: 'admin',
    fullName: 'Demo Admin',
    email: 'admin@telemedicine.local',
  },
  {
    username: 'doctor',
    password: 'Doctor123!',
    role: 'doctor',
    fullName: 'Demo Doctor',
    email: 'doctor@telemedicine.local',
    specialty: 'General Practice',
    licenseNumber: 'DEMO-HK-DOCTOR-001',
  },
  {
    username: 'patient',
    password: 'Patient123!',
    role: 'patient',
    fullName: 'Demo Patient',
    email: 'patient@telemedicine.local',
    dateOfBirth: new Date('1998-05-20'),
  },
];

const DEMO_COLLECTIONS = [
  'users',
  'appointments',
  'consultations',
  'sick_leave_certificates',
  'payments',
  'deliveries',
  'chatbot_messages',
  'discussions',
  'discussion_comments',
  'health_readings',
];

async function upsertUser(account) {
  const passwordHash = await User.hashPassword(account.password);
  const fields = {
    username: account.username,
    passwordHash,
    role: account.role,
    fullName: account.fullName,
    email: account.email,
    specialty: account.specialty,
    licenseNumber: account.licenseNumber,
    dateOfBirth: account.dateOfBirth,
  };

  const existing = await User.findOne({ username: account.username });
  if (existing) {
    existing.set(fields);
    await existing.save();
    console.log(`Updated users: ${account.username}`);
    return existing;
  }

  const created = await User.create(fields);
  console.log(`Created users: ${account.username}`);
  return created;
}

// Find the demo document by seedKey so a second run updates it.
async function upsertBySeedKey(Model, seedKey, fields) {
  const existing = await Model.findOne({ seedKey });
  if (existing) {
    existing.set({ ...fields, seedKey });
    await existing.save();
    console.log(`Updated ${Model.collection.name}: ${seedKey}`);
    return existing;
  }

  const created = await Model.create({ ...fields, seedKey });
  console.log(`Created ${Model.collection.name}: ${seedKey}`);
  return created;
}

async function seedClinicalRecords(doctor, patient) {
  const scheduledAt = new Date('2026-11-03T02:00:00.000Z');

  const appointment = await upsertBySeedKey(Appointment, 'demo-appointment', {
    patient: patient._id,
    doctor: doctor._id,
    scheduledAt,
    reason: 'Sample sore throat visit',
    status: 'scheduled',
  });

  await upsertBySeedKey(Appointment, 'demo-open-slot', {
    doctor: doctor._id,
    scheduledAt: new Date('2026-11-05T02:00:00.000Z'),
    status: 'available',
    patient: undefined,
    reason: undefined,
  });

  await upsertBySeedKey(Consultation, 'demo-consultation', {
    appointment: appointment._id,
    patient: patient._id,
    doctor: doctor._id,
    status: 'scheduled',
    channelName: 'demo-visit-1',
  });

  await upsertBySeedKey(SickLeaveCertificate, 'demo-sick-leave', {
    certificateNumber: 'SL-DEMO-0001',
    appointment: appointment._id,
    patient: patient._id,
    doctor: doctor._id,
    issuedOn: scheduledAt,
    validFrom: new Date('2026-11-03T00:00:00.000Z'),
    validTo: new Date('2026-11-04T00:00:00.000Z'),
    summary: 'Sample certificate for one day. This is demo text.',
    readOnly: true,
  });

  await upsertBySeedKey(Payment, 'demo-payment', {
    patient: patient._id,
    appointment: appointment._id,
    amount: 200,
    currency: 'HKD',
    purpose: 'consultation',
    status: 'pending',
    provider: 'paypal_sandbox',
  });

  await upsertBySeedKey(Delivery, 'demo-delivery', {
    patient: patient._id,
    appointment: appointment._id,
    medicationName: 'Sample tablets',
    quantity: 1,
    status: 'preparing',
    destination: 'Kowloon, Hong Kong',
  });

  await upsertBySeedKey(ChatbotMessage, 'demo-chat-user', {
    user: patient._id,
    speaker: 'user',
    text: 'What is this app for?',
  });

  await upsertBySeedKey(ChatbotMessage, 'demo-chat-assistant', {
    user: patient._id,
    speaker: 'assistant',
    text: 'This is a demo reply. A real assistant is not connected yet.',
  });

  const discussion = await upsertBySeedKey(Discussion, 'demo-discussion', {
    patient: patient._id,
    doctor: doctor._id,
    title: 'When should I take the sample tablets?',
    body: 'Should I take them after food?',
    status: 'answered',
  });

  await upsertBySeedKey(DiscussionComment, 'demo-comment', {
    discussion: discussion._id,
    author: doctor._id,
    body: 'This is a sample reply. Take them after a meal.',
  });

  await upsertBySeedKey(HealthReading, 'demo-heart-rate', {
    patient: patient._id,
    metric: 'heart_rate',
    value: 72,
    unit: 'bpm',
    recordedAt: new Date('2026-10-26T10:00:00.000Z'),
  });
}

async function printCounts() {
  for (const name of DEMO_COLLECTIONS) {
    const count = await mongoose.connection.collection(name).countDocuments();
    console.log(`${name}: ${count}`);
  }
}

async function seed() {
  await connectDatabase(process.env.MONGODB_URI);
  console.log(`Connected to database "${DB_NAME}".`);

  const savedUsers = [];
  for (const account of SEED_USERS) {
    savedUsers.push(await upsertUser(account));
  }

  const doctor = savedUsers.find((user) => user.role === 'doctor');
  const patient = savedUsers.find((user) => user.role === 'patient');
  await seedClinicalRecords(doctor, patient);

  console.log('Seed finished.');
  await printCounts();
}

seed()
  .catch((error) => {
    // Log the message only. Connection errors can echo the URI, which contains the password.
    const message = error && error.message ? error.message : 'Unknown seed error';
    const safeMessage = message.replace(/mongodb(\+srv)?:\/\/\S+/gi, 'mongodb://***');
    console.error(`Seed failed: ${safeMessage}`);
    process.exitCode = 1;
  })
  .finally(async () => {
    await disconnectDatabase();
  });
