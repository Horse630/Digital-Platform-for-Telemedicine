# Digital Platform for Telemedicine

Cross-platform telemedicine app for Hong Kong Baptist University COMP4878-9. It is meant to cover a remote visit and the logistics around it: appointments, video consultation, sick leave certificates, payment, and medication delivery.

The frontend is Flutter and Dart. The screens still sign in with a local demo account. A Node backend in `backend/` stores sample documents in MongoDB Atlas. The Flutter app does not read that database yet.

## Demo sign-in

The login form checks one account stored in the app:

| Field | Value |
| --- | --- |
| Username | `Admin` |
| Password | `Admin` |

The username may have spaces around it. The password must match exactly, including letter case. A failed attempt stays on the login screen. Logging out returns to that screen. Nothing is written to a database.

When the Flutter app calls the backend, replace `AuthService.signIn` in `lib/services/auth_service.dart`.

## Run

```bash
flutter pub get
flutter run
```

Use an Android Studio emulator, a phone, or Chrome:

```bash
flutter run -d chrome
```

## Screens

- **Login** checks the demo account above.
- **Home** is the patient dashboard. It lists the core functions and sub-functions from the progress report. Appointments and Consultation open their tabs. The other modules explain that this build does not save data.
- **Appointments** is an empty state until booking is stored.
- **Consultation** is an empty state until a video SDK is added.
- **Profile** shows the demo account and logs out.

On a phone the tabs sit in a bottom bar. When the window is at least 840 pixels wide, the same tabs move to a side rail.

## Layout

```text
lib/
  main.dart
  navigation/app_destination.dart
  services/auth_service.dart
  theme/app_theme.dart
  screens/
    login_screen.dart
    main_shell.dart
    home_screen.dart
    appointments_screen.dart
    consultation_screen.dart
    profile_screen.dart
  widgets/
    content_frame.dart
    status_placeholder.dart
backend/
  .env.example
  package.json
  scripts/seed.js
  src/db.js
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

Node code lives in `backend/`. MongoDB stores collections, not SQL tables. Each file in `backend/src/models/` describes one collection. Doctor, Patient, and Admin share `users`, and `role` is `doctor`, `patient`, or `admin`. Passwords in `users` are bcrypt hashes.

`backend/scripts/seed.js` is the starter-data script. It connects with `process.env.MONGODB_URI` and writes the sample rows below. Running it again updates those same rows. That script belongs in the project.

Atlas credentials belong only in `backend/.env`. Git ignores that file. `backend/.env.example` is safe to commit because its values are empty.

### Collections

| Collection | Sample record |
| --- | --- |
| `users` | `admin`, `doctor`, and `patient` |
| `appointments` | Sore throat visit on 3 Nov 2026, status `scheduled` |
| `consultations` | Video visit `demo-visit-1`, status `scheduled` |
| `sick_leave_certificates` | `SL-DEMO-0001`, marked read-only |
| `payments` | HKD 200 consultation fee, status `pending` |
| `deliveries` | Sample tablets to Kowloon, status `preparing` |
| `chatbot_messages` | One patient question and one demo reply |
| `discussions` | Question about when to take the tablets |
| `discussion_comments` | One doctor reply |
| `health_readings` | Heart rate `72 bpm` |

Refresh the Atlas collection list after seeding. The app still does not load these documents.

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

The collections above are sample storage only. Phase 2 adds appointment booking, PayPal Sandbox, and read-only sick leave PDFs. Video, the delivery map, the chatbot, discussion, and wearable sync come after that. The home screen entries are still navigation targets in this build.
