const mongoose = require('mongoose');

// Database name is not a secret. The URI and password stay in backend/.env.
const DB_NAME = 'telemedicine';

/**
 * Opens the Atlas connection named in MONGODB_URI.
 * The database is selected here so the secret URI can stay exactly as Atlas shows it.
 */
async function connectDatabase(uri) {
  if (!uri) {
    throw new Error(
      'MONGODB_URI is missing. Copy backend/.env.example to backend/.env and fill it in.',
    );
  }

  await mongoose.connect(uri, { dbName: DB_NAME });
  return mongoose.connection;
}

async function disconnectDatabase() {
  await mongoose.disconnect();
}

module.exports = {
  DB_NAME,
  connectDatabase,
  disconnectDatabase,
};
