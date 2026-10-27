# Digital Platform for Telemedicine

Cross-platform telemedicine app for Hong Kong Baptist University COMP4878-9. It is meant to cover a remote visit and the logistics around it: appointments, video consultation, sick leave certificates, payment, and medication delivery.

The frontend is Flutter and Dart. Sign-in calls a Node API in `backend/`, and that API checks the password against MongoDB Atlas. Doctors publish appointment times, and patients book those times. The other screens do not load their sample records yet.

## Demo sign-in

Start the API first, then the app. The login form sends the username and password to `POST /api/login`. Spaces around the username are ignored. The password must match exactly. A failed attempt stays on the login screen. Three buttons on that screen sign in as these accounts without typing. Those buttons are a temporary shortcut.

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

The app icon is `assets/app_icon.png`, a teal medical cross with a video camera. Platform icon files are generated from that image.

## Screens

- **Login** calls `POST /api/login` and opens the shell when MongoDB accepts the account. Three buttons sign in as the seeded admin, doctor, or patient without typing. **Create an account** opens sign-up.
- **Sign up** asks for an email, username, and password, and a choice of patient or doctor. Both roles use those same fields. The API rejects a username that is already stored.
- **Home** greets the signed-in person and lists the core functions and sub-functions from the progress report. The next-appointment card shows that person's soonest booked visit, or "Not scheduled" when there is none. Appointments and Consultation open their tabs. Discussion opens the public question board. The other modules explain that this build does not save new data.
- **Appointments** lists a doctor's own time slots and a patient's own bookings. The default view is a calendar. A **List** button switches to the scrolling cards, and **Calendar** switches back. An empty list shows "No appointment" and a button: **Make an appointment** for a doctor, **Book an appointment** for a patient. The booking page searches by doctor name, filters by doctor type, and sorts by time or name. Booking needs a short reason. Cancelling asks for confirmation. A patient cancel opens that slot again. A doctor cancel marks the row cancelled, and a cross on that card can delete it after another confirmation. An admin can read every row in either format and cannot change one.
- **Doctor profile on a patient's card.** A patient's own bookings and the booking page show the doctor's saved photo, or a doctor icon when there is no photo, and the doctor's name. Tapping the photo or the name opens the profile. That profile shows the doctor's name, photo, doctor types, and description, and a **Message** button. It does not show the username, email, or password. The appointment response already includes `description` and `avatarBase64`, so this does not call a separate profile route.
- **Patient profile on a doctor's card.** When a visit has a patient, the card shows that patient's photo, or a person icon, and the name. Tapping either opens the profile. That profile shows the name, photo, allergies, description, and a **Message** button. It does not show the username, email, or password.
- **Messages** is the middle tab. It lists people this account has messaged, or who have messaged this account, with the latest line and time. A green count on a row shows how many of that person's messages are still unread. A red count on the Messages icon shows the total. Opening a person shows the conversation and marks those messages read. Under a message you sent, the time sits with one tick when it is sent and two ticks when the other person has opened it. **Message** on that person's profile, opened from an appointment card, starts the same conversation.
- **Discussion** opens from Home. The list has **Public discussions** and a second filter. Public discussions shows every post. A patient sees **My discussions**, which shows posts they created. A doctor sees **My responses**, which shows posts they have replied to. Everyone who is signed in can read a post. Only a doctor can reply, and more than one doctor can reply to the same post. Each reply has **Like** and **Store**. The person who posted can remove that post. A confirmation shows **Keep** above **Remove**. A red count on the Discussion tile tells the patient that a doctor replied and they have not opened that post yet. The patient icon or name, and a doctor's icon or name, open that profile. **Message** is on the profile when it is someone else. An admin can read and cannot post or remove a post.
- **Consultation** is an empty state until a video SDK is added.
- **Profile** shows the database account, including a saved photo and description. It opens Settings and logs out.
- **Settings** uploads a profile photo, changes the username, description, and password, and switches the language, UI color, and dark mode. A doctor chooses one or more doctor types from a fixed list. A patient types allergy tags. The photo, account fields, doctor types, and allergies are stored in MongoDB. Language, color, and dark mode stay on the device. The app starts in English until a language is chosen.

On a phone the tabs sit in a bottom bar. When the window is at least 840 pixels wide, the same tabs move to a side rail.

## Layout

```text
l10n.yaml
lib/
  main.dart
  language/
    app_en.arb
    app_zh.arb
    app_zh_Hant.arb
    app_zh_Hans.arb
    language_settings.dart
    ui_text.dart
  l10n/app_localizations.dart
  navigation/app_destination.dart
  services/api_config.dart
  services/appointment_api.dart
  services/appointment_filter.dart
  services/auth_service.dart
  services/avatar_image.dart
  services/doctor_types.dart
  services/message_api.dart
  services/discussion_api.dart
  services/profile_api.dart
  theme/app_theme.dart
  theme/theme_settings.dart
  screens/
    login_screen.dart
    sign_up_screen.dart
    main_shell.dart
    home_screen.dart
    appointments_screen.dart
    messages_screen.dart
    discussions_screen.dart
    chat_thread_screen.dart
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
  src/routes/messages.js
  src/routes/discussions.js
  src/routes/profile.js
  src/models/
    User.js
    Appointment.js
    DirectMessage.js
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

`GET /api/profile` and `PATCH /api/profile` read and update the username, description, and photo for the signed-in account. `POST /api/profile/password` checks the current password, then stores a new bcrypt hash. Changing the username returns a new bearer token. UI color, dark mode, and language stay on the device. The client can show English, Traditional Chinese, or Simplified Chinese. The default is English until a language is chosen in Settings. Server messages and the Node terminal stay in English.

A doctor can save one or more doctor types from a fixed list, and a patient can save allergy tags. Appointment JSON includes the doctor's types, description, and photo, and, when a patient is booked, that patient's description, photo, and allergies. `GET /api/messages` and `POST /api/messages/:userId` read and write `direct_messages`. Opening a conversation sets `readAt` on messages sent to the signed-in person.

`backend/scripts/seed.js` is the starter-data script. It connects with `process.env.MONGODB_URI` and writes the sample rows below. Running it again updates those same rows. That script belongs in the project.

Atlas credentials belong only in `backend/.env`. Git ignores that file. `backend/.env.example` is safe to commit because its values are empty.

### Collections

| Collection | Sample record |
| --- | --- |
| `users` | `admin`, `doctor`, and `patient`. Description and profile photo are empty until someone saves them in Settings. |
| `appointments` | One booked sample visit on 3 Nov 2026, plus one open slot on 5 Nov 2026 |
| `direct_messages` | Empty until a doctor and a patient send a message |
| `consultations` | Video visit `demo-visit-1`, status `scheduled` |
| `sick_leave_certificates` | `SL-DEMO-0001`, marked read-only |
| `payments` | HKD 200 consultation fee, status `pending` |
| `deliveries` | Sample tablets to Kowloon, status `preparing` |
| `chatbot_messages` | One patient question and one demo reply |
| `discussions` | Question about when to take the tablets |
| `discussion_comments` | One doctor reply |
| `health_readings` | Heart rate `72 bpm` |

Refresh the Atlas collection list after seeding. Login reads `users`. The appointment screen reads and writes `appointments`, including deleting a cancelled row. Settings reads and writes the signed-in user's username, description, photo, password hash, doctor types, and allergies. The Messages tab reads and writes `direct_messages`. Discussion reads and writes `discussions` and `discussion_comments`. Consultations, certificates, payments, deliveries, chatbot messages, and health readings are not loaded by the app yet.

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

Appointment booking, settings, and the public discussion board are in this build. PayPal Sandbox, read-only sick leave PDFs, video, the delivery map, the chatbot, and wearable sync are not connected yet. The home screen entries for those modules are still navigation targets.
