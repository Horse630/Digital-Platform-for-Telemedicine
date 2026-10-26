# Digital Platform for Telemedicine

Cross-platform telemedicine app for Hong Kong Baptist University COMP4878-9. It is meant to cover a remote visit and the logistics around it: appointments, video consultation, sick leave certificates, payment, and medication delivery.

The frontend is Flutter and Dart. Sign-in calls a Node API in `backend/`, and that API checks the password against MongoDB Atlas. Doctors publish appointment times, and patients book those times. The other screens do not load their sample records yet.

## Demo sign-in

Start the API first, then the app. The login form sends the username and password to `POST /api/login`. Spaces around the username are ignored. The password must match exactly. A failed attempt stays on the login screen.

| Role | Username | Password |
| --- | --- | --- |
| Admin | `admin` | `Admin123!` |
| Doctor | `doctor` | `Doctor123!` |
| Patient | `patient` | `Patient123!` |

These are application accounts. They are not the Atlas login in `backend/.env`.

## Run

In one PowerShell window:

```powershell
cd backend
npm install
npm start
```

In a second window, from the repository root:

```bash
flutter pub get
flutter run
```

Use an Android Studio emulator, a phone, or Chrome:

```bash
flutter run -d chrome
```

The Android emulator calls the API at `http://10.0.2.2:3000`. Chrome, desktop, and the iOS simulator use `http://localhost:3000`. A physical phone needs your computer's LAN address in `lib/services/api_config.dart`.

## Screens

- **Login** calls `POST /api/login` and opens the shell when MongoDB accepts the account. **Create an account** opens sign-up.
- **Sign up** asks for an email, username, and password, and a choice of patient or doctor. Both roles use those same fields. The API rejects a username that is already stored.
- **Home** greets the signed-in person and lists the core functions and sub-functions from the progress report. Appointments and Consultation open their tabs. The other modules explain that this build does not save new data.
- **Appointments** lets a doctor add a future time slot. A patient sees open slots, including the doctor's name, and books one with a short reason. Cancelling a booking opens that slot again. An admin can read every row.
- **Consultation** is an empty state until a video SDK is added.
- **Profile** shows the database account, including a saved photo and description. It opens Settings and logs out.
- **Settings** uploads a profile photo, changes the username, description, and password, and switches the UI color and dark mode. A doctor chooses one or more doctor types from a fixed list. A patient types allergy tags. The photo, account fields, doctor types, and allergies are stored in MongoDB. Color and dark mode stay on the device.

On a phone the tabs sit in a bottom bar. When the window is at least 840 pixels wide, the same tabs move to a side rail.

## Layout

```text
lib/
  main.dart
  navigation/app_destination.dart
  services/api_config.dart
  services/appointment_api.dart
  services/auth_service.dart
  services/avatar_image.dart
  services/doctor_types.dart
  services/profile_api.dart
  theme/app_theme.dart
  theme/theme_settings.dart
  screens/
    login_screen.dart
    sign_up_screen.dart
    main_shell.dart
    home_screen.dart
    appointments_screen.dart
    consultation_screen.dart
    profile_screen.dart
    settings_screen.dart
  widgets/
    account_avatar.dart
    content_frame.dart
    status_placeholder.dart
backend/
  .env.example
  package.json
  scripts/seed.js
  src/server.js
  src/authToken.js
  src/db.js
  src/routes/appointments.js
  src/routes/profile.js
  src/models/
    User.js
    Appointment.js
    Consultation.js
    SickLeaveCertificate.js
    Payment.js
    Delivery.js
    ChatbotMessage.js
    Discussion.js
    DiscussionComment.js
    HealthReading.js
```

## Backend

Node code lives in `backend/`. MongoDB stores collections, not SQL tables. Each file in `backend/src/models/` describes one collection. Doctor, Patient, and Admin share `users`, and `role` is `doctor`, `patient`, or `admin`. Passwords in `users` are bcrypt hashes. A person can also store a description and a profile photo on that same document. The photo is base64 text, limited to a JPEG, PNG, or WebP under 512 KB.

`GET /api/profile` and `PATCH /api/profile` read and update the username, description, and photo for the signed-in account. `POST /api/profile/password` checks the current password, then stores a new bcrypt hash. Changing the username returns a new bearer token. UI color and dark mode are not sent to the API.

`backend/scripts/seed.js` is the starter-data script. It connects with `process.env.MONGODB_URI` and writes the sample rows below. Running it again updates those same rows. That script belongs in the project.

Atlas credentials belong only in `backend/.env`. Git ignores that file. `backend/.env.example` is safe to commit because its values are empty.

### Collections

| Collection | Sample record |
| --- | --- |
| `users` | `admin`, `doctor`, and `patient`. Description and profile photo are empty until someone saves them in Settings. |
| `appointments` | One booked sample visit on 3 Nov 2026, plus one open slot on 5 Nov 2026 |
| `consultations` | Video visit `demo-visit-1`, status `scheduled` |
| `sick_leave_certificates` | `SL-DEMO-0001`, marked read-only |
| `payments` | HKD 200 consultation fee, status `pending` |
| `deliveries` | Sample tablets to Kowloon, status `preparing` |
| `chatbot_messages` | One patient question and one demo reply |
| `discussions` | Question about when to take the tablets |
| `discussion_comments` | One doctor reply |
| `health_readings` | Heart rate `72 bpm` |

Refresh the Atlas collection list after seeding. Login reads `users`. The appointment screen reads and writes `appointments`. Settings reads and writes the signed-in user's username, description, photo, and password hash. The other collections are not loaded by the app yet.

`POST /api/login` also returns a bearer token. Appointment requests send `Authorization: Bearer <token>`. The token secret is `AUTH_TOKEN_SECRET` in `backend/.env`, separate from the Atlas password.

### Seed accounts

These are application demo users, not the Atlas login. Running the seed again updates the same three usernames.

| Role | Username | Password | Email |
| --- | --- | --- | --- |
| Admin | `admin` | `Admin123!` | `admin@telemedicine.local` |
| Doctor | `doctor` | `Doctor123!` | `doctor@telemedicine.local` |
| Patient | `patient` | `Patient123!` | `patient@telemedicine.local` |

The doctor record also stores specialty `General Practice` and license `DEMO-HK-DOCTOR-001`. The patient record stores a date of birth. Documents are written to the `telemedicine` database.

### Run the seed

From the repository root in PowerShell:

```powershell
cd backend
npm install
copy .env.example .env
```

Open `backend/.env` and set `MONGODB_USERNAME`, `MONGODB_PASSWORD`, and `MONGODB_URI` from MongoDB Atlas. Then:

```powershell
npm run seed
```

`npm run seed` reads `process.env.MONGODB_URI` from `backend/.env`. A successful run prints `Created` or `Updated` for each sample document, then a count for every collection. The script does not print the Atlas password or connection string.

## Tests

```bash
flutter test
```

## Later phases

Appointment booking and the settings page are in this build. PayPal Sandbox, read-only sick leave PDFs, video, the delivery map, the chatbot, discussion, and wearable sync are not connected yet. The home screen entries for those modules are still navigation targets.
