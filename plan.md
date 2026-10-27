# Handoff for the next coding session

Read this file, then the source files it names. Do not invent screens, routes, packages, or database fields.

If this file and the code disagree, trust the code, then correct this file. The first progress report describes the intended product. It is not a list of finished features. A schema file or a seed row is not a working screen.

The student wants explanations in Traditional Chinese. Code comments, `README.md`, and this file stay in English. Do not commit `backend/.env`. Flutter must not open MongoDB. Do not put Atlas usernames, passwords, or connection strings in code, tests, README, or this file. Do not restore the old local `Admin` / `Admin` login.

## Project

Hong Kong Baptist University, COMP4878-9 Innovative Computing Project I. Project name: Digital Platform for Telemedicine. Student: Ma Chun Kit. Supervisor: Prof. LEUNG, Yiu Wing. The report is `MA_Chun_Kit_Frist_Progress_Report_23230215.docx` at the repository root. The filename spells "First" as "Frist". That report says Google Gemini was used only to edit the report's grammar and wording. That sentence is about the document, not about which code exists.

The report's stack is Flutter and Dart for the app, MongoDB for storage, and a separate backend. The backend in this repository is Node.js, Express 5, and Mongoose. It is not a Dart server. An earlier attempt to rewrite the backend in Dart was stopped. Do not start that rewrite again unless the student asks.

## How to run

From `backend/`: `npm install`, then `npm start` (`node src/server.js`, port 3000). From the repository root: `flutter pub get`, then `flutter run`. Android emulator API base is `http://10.0.2.2:3000` (`lib/services/api_config.dart`). Chrome, desktop, and the iOS simulator use `http://localhost:3000`. A physical phone needs the computer's LAN address in that same file. Android allows cleartext HTTP. iOS allows local networking.

Keep `MONGODB_URI` and `AUTH_TOKEN_SECRET` in `backend/.env`. Copy `backend/.env.example` and fill those values on each machine. Do not print those values, and do not commit `backend/.env`. The database name `telemedicine` is set in `backend/src/db.js`. It is not part of the URI.

Demo application accounts, from `backend/scripts/seed.js`. These are not the Atlas login.

| Role | Username | Password |
| --- | --- | --- |
| Admin | `admin` | `Admin123!` |
| Doctor | `doctor` | `Doctor123!` |
| Patient | `patient` | `Patient123!` |

The doctor document also has specialty `General Practice` and license `DEMO-HK-DOCTOR-001`. The patient document has date of birth 20 May 1998. Passwords in MongoDB are bcrypt hashes (`bcryptjs`, 12 rounds). Login compares the typed password with `passwordHash`. It does not store or return the plain password.

## Report schedule against the code

The report's phases are the plan, not the current build.

| Report phase | Report asked for | In the code now |
| --- | --- | --- |
| Phase 1, through late October | Login, patient dashboard, navigation, backend, MongoDB connection | Done. Settings was added later and is not in the report. |
| Phase 2, November | Appointment scheduling, PayPal Sandbox, read-only sick-leave PDFs | Appointment scheduling is done. PayPal and PDF generation are not. |
| Phase 3, December to January | Video SDK and Hong Kong Vector Map delivery tracking | Not started. No video or map package is installed. |
| Phase 4, February to March | HKBU chatbot, discussion board, wearable health sync | Discussion is done. The chatbot and wearable sync are not started. Their seed documents exist. The app does not load them. |
| Phase 5, April | Full testing, UI polish, final report | Not started. `flutter test` covers the current screens with a fake HTTP client. Those tests do not prove Atlas is running. |

## Done

Login, shell, and theme:

- `lib/screens/login_screen.dart` posts to `POST /api/login`. A failed login stays on that screen. Success replaces the route with `lib/screens/main_shell.dart`. **Create an account** opens `lib/screens/sign_up_screen.dart`.
- The login screen also has three temporary buttons: Admin, Doctor, and Patient. Each one signs in as the matching seeded account (`admin` / `Admin123!`, `doctor` / `Doctor123!`, `patient` / `Patient123!`) without typing. The username and password fields stay. Remove these buttons later. See To do.
- `POST /api/signup` in `backend/src/server.js` accepts `email`, `username`, `password`, and `role`. `role` must be `patient` or `doctor`. It rejects `admin`. The username is checked without case sensitivity against `users`. A duplicate username returns 409, `That username is already used.` A duplicate email returns 409, `That email is already used.` The password must be at least 8 characters. The new document stores `fullName` as the username because sign-up does not ask for a separate name. Success returns the same JSON as login, including a token, and the app opens the shell.
- Patient and doctor sign-up send the same fields. `User.js` no longer rejects a doctor who has no specialty or license number. The seeded doctor still has those values.
- `POST /api/login` in `backend/src/server.js` trims the username, matches it without case sensitivity, checks bcrypt, and returns `username`, `role`, `fullName`, and `token`.
- The token is an HMAC-SHA256 bearer token from `backend/src/authToken.js`. It is not produced by a JWT library. The payload keys are `sub`, `username`, `role`, and `exp`. It lasts 7 days. The secret is `AUTH_TOKEN_SECRET`.
- Tabs are Home, Appointments, Messages, Consultation, and Profile (`lib/navigation/app_destination.dart`). Messages is the middle tab. Width under 840 uses a bottom bar. Width of 840 or more uses a side rail.
- Messages (`lib/screens/messages_screen.dart`, `lib/screens/chat_thread_screen.dart`, `lib/services/message_api.dart`, `backend/src/routes/messages.js`) lists people this account has messaged, or who have messaged this account. Each row shows the latest line. A row with unread messages shows a green count. The Messages icon on the bottom bar and the side rail shows a red count of every unread message. Opening a conversation sets `readAt` on messages sent to you. Under each of your own messages, the time is shown with one tick when it is sent and two blue ticks when the other person has opened it. The list refreshes while the app is open. A notification when the app is closed is still to do.
- Discussion (`lib/screens/discussions_screen.dart`, `lib/services/discussion_api.dart`, `backend/src/routes/discussions.js`) is a public board. A patient posts a question with `POST /api/discussions` and body `{ "title", "body" }`. The title is 1 to 120 characters. The question is 1 to 1000 characters. Status starts as `open`, and `doctor` stays empty until the first doctor replies. Any signed-in person can read every question. Only a doctor can reply, with `POST /api/discussions/:id/comments` and body `{ "body" }` (1 to 1000 characters). More than one doctor can reply to the same question. Each reply sets status to `answered`. The Discussion tile on Home shows a red count when a doctor has replied to one of this patient's questions and the patient has not opened that question yet. Opening the question clears that count (`seenByPatient` on the comment). A reply has a like button and a store button. The discussion list has **Public discussions** and a second filter. Public discussions shows every post. For a patient, the second filter is **My discussions** and shows posts this person created. For a doctor, it is **My responses** and shows posts this doctor has replied to. The list includes `repliedByMe` for that filter. The person who posted can remove that post. The confirmation puts a small grey **Keep** button above **Remove**, the same pattern as a cancelled appointment. `DELETE /api/discussions/:id` deletes that post and its replies. Anyone else receives 403. The patient icon or name, and each doctor's icon or name, open that person's profile. The profile has a **Message** button when it is not the signed-in person. An admin can read and cannot ask, reply, remove a post, or receive that reply count. A doctor cannot ask, and a patient cannot reply.
- `GET /api/health` returns `{ "ok": true }`.
- Light and dark mode, the accent colors teal, blue, green, purple, and orange, and the font size are in `lib/theme/theme_settings.dart` and `lib/theme/app_theme.dart`. They are stored on the device with `shared_preferences`. MongoDB does not store them. The default is light teal. Font size choices are small, default, large, and extra large (`ui_font_size`). The default scale is 1. `MaterialApp` applies that scale to the text on every page.
- The client can show English, Traditional Chinese, or Simplified Chinese. Settings has a language control. The choice is stored on the device as `ui_language` (`lib/language/language_settings.dart`). The default is English until someone chooses a language. The strings are in `lib/language/app_en.arb`, `app_zh.arb`, `app_zh_Hant.arb`, and `app_zh_Hans.arb`. `app_zh.arb` is the Traditional Chinese fallback Flutter requires. `lib/l10n/app_localizations.dart` only re-exports `lib/language/app_localizations.dart`, so the old folder path still resolves in the editor. Doctor-type values stored in MongoDB stay the English names from `DOCTOR_TYPES`. The screen translates those names when it draws a chip, a filter, or a profile tag. API response messages and Node terminal logs stay English. `lib/language/ui_text.dart` translates a known English message only when the screen shows it.
- The launcher icon is a teal medical cross with a white video camera. The source file is `assets/app_icon.png` (1024×1024). `flutter_launcher_icons` ^0.14.4 is a dev dependency. Its config is the `flutter_launcher_icons` block in `pubspec.yaml`. Run `dart run flutter_launcher_icons` from the repository root after changing that source file. It writes Android (`mipmap-*/ic_launcher.png`, adaptive icon `mipmap-anydpi-v26/ic_launcher.xml`, foreground drawables, and `values/colors.xml` color `#0F766E`), iOS (`ios/Runner/Assets.xcassets/AppIcon.appiconset`), web (`web/favicon.png`, `web/icons/Icon-*.png`, and `web/manifest.json` background and theme `#0F766E`), Windows (`windows/runner/resources/app_icon.ico`), and macOS (`macos/Runner/Assets.xcassets/AppIcon.appiconset`). Linux still uses the default icon. A hot restart does not replace an already installed launcher icon; run the app again.

Appointments, the only clinical workflow that saves data:

- Screen: `lib/screens/appointments_screen.dart`. Client: `lib/services/appointment_api.dart`. Routes: `backend/src/routes/appointments.js`.
- A doctor creates a future slot with `POST /api/appointments` and body `{ "scheduledAt" }`. Status becomes `available`. A second slot for the same doctor at the same time returns 409. When the doctor has no rows, the Appointments tab shows `No appointment` and a **Make an appointment** button that opens the date and time pickers. The same button stays above the list when the doctor already has a slot.
- A patient sees future `available` slots, including the doctor's name and specialty, on a separate booking page. The Appointments tab itself lists only that patient's own rows. When that list is empty, it shows `No appointment` and a **Book an appointment** button that opens the booking page. The same button stays above the list when the patient already has a booking. On both of those patient screens, each card shows the doctor's photo, or a doctor icon when there is no photo, and the doctor's name. Tapping the photo or the name opens the profile. The profile shows the name, photo, doctor types, and description already saved on that doctor, plus **Message**. It does not show the username, email, or password. A doctor's card for a booked or cancelled visit shows the patient's photo, or a person icon, and the patient's name. Tapping either opens the profile, which shows the name, photo, allergies, description, and **Message**. **Message** opens a direct chat with that person. Booking is `POST /api/appointments/:id/book` with `{ "reason" }`. The reason is 1 to 200 characters. Status becomes `scheduled`.
- A doctor's Appointments tab and a patient's Appointments tab default to a calendar. Days with a row show a dot. Choosing a day lists that day's rows under the month. A **List** button shows the previous scrolling list, and **Calendar** switches back. An admin uses the same two formats. The booking page for open times stays a list. On that page, a search field matches the doctor name. A doctor-type menu uses the same fixed list as Settings (`doctorTypes` / `DOCTOR_TYPES`). Choosing one type keeps slots whose doctor has that type. Sort choices are soonest, latest, name A–Z, and name Z–A. The default sort is soonest. These controls filter the list already loaded by `GET /api/appointments`. They do not call a new route. `doctor.specialties`, `doctor.description`, and `doctor.avatarBase64` are included in each appointment JSON. If `specialties` is empty, the client splits the `specialty` string on commas.
- A patient cancel of a `scheduled` row sets it back to `available` and removes `patient` and `reason`. A doctor cancel of an `available` or `scheduled` row sets `cancelled`. Both ask for confirmation first. A cancelled row shows a cross at the top right for the doctor who owns it, or for the patient on that row. Confirming that cross calls `DELETE /api/appointments/:id` and deletes the row. The route rejects any row that is not `cancelled`. An admin can read every row and cannot change or delete one. There is no route that sets `completed`.
- The home card "Next appointment" in `lib/screens/home_screen.dart` reads `GET /api/appointments` and shows the soonest future row with status `scheduled`. A patient sees the date, time, and doctor. A doctor sees the date, time, and patient. An open slot is not shown. When there is no booked visit, the card says `Not scheduled`. Tapping it opens the Appointments tab. Medication delivery on that card stays the fixed text `No active order`.
- The booking design in the code is: the doctor publishes a time, and the patient books that time. Do not add a separate "pick a doctor, then contact that doctor" flow unless the student asks.

Profile and settings, added after the report:

- Profile is `lib/screens/profile_screen.dart`. Settings opens from the Settings button. It is not a fifth tab. Screen: `lib/screens/settings_screen.dart`. Client: `lib/services/profile_api.dart`. Routes: `backend/src/routes/profile.js`.
- `GET /api/profile` returns `username`, `role`, `fullName`, `description`, `avatarBase64`, `avatarMime`, `specialties`, and `allergies`.
- `PATCH /api/profile` updates username, description, and photo. Username is 3 to 40 characters and may contain letters, numbers, `.`, `_`, and `-`. Description is at most 280 characters. A photo must be JPEG, PNG, or WebP, at most 512 KB, stored as base64 without a data-url prefix. A username change returns a new `token`.
- A doctor can select more than one type from this fixed list: General Practice, Family Medicine, Internal Medicine, Paediatrics, Obstetrics and Gynaecology, Surgery, Orthopaedics, Dermatology, Psychiatry, Ophthalmology, Otorhinolaryngology, Cardiology. The list is `DOCTOR_TYPES` in `backend/src/models/User.js` and `doctorTypes` in `lib/services/doctor_types.dart`. Keep those two lists identical. The chosen values are stored in `specialties`. `specialty` is the same names joined with commas so appointment rows can still show one string. A value outside the list is rejected.
- A patient can type allergy names. Each name is at most 40 characters, and the list holds at most 20. Duplicates that differ only by letter case are stored once. They are stored in `allergies`. A doctor does not edit allergies, and a patient does not edit doctor types. An admin sees neither control.
- `POST /api/profile/password` needs `currentPassword` and `newPassword`. The new password must be at least 8 characters and must differ from the current one. The response message is `Password updated.` The hash stays in MongoDB.
- `backend/scripts/seed.js` updates the three demo users but does not clear `description`, `avatarBase64`, `specialties`, or `allergies`. If a doctor has no `specialties` yet but `specialty` is one of the fixed names, the settings page shows that one name as selected.

Navigation placeholders:

- Home lists the report's core and sub-functions. Appointments and Consultation open their tabs. Discussion opens the public question board. Sick leave, Payment, Medication delivery, AI chatbot, and IoT health open a dialog that says the service is not available yet (`lib/screens/home_screen.dart`). The dialog does not mention the database, the build, or sample data.
- Consultation (`lib/screens/consultation_screen.dart`) says video visits are not available yet.

## Not done

Do not claim any of the following exist. Do not add their packages or routes unless the student asks.

- No video call. `pubspec.yaml` does not depend on `agora_rtc_engine`, `stream_video_flutter`, or `videosdk`. The report names all three and does not pick one. `consultations` has a `channelName` string only. Seed row `demo-consultation` uses `demo-visit-1` and status `scheduled`. Status values in the schema are `scheduled`, `live`, and `ended`. Nothing in the app sets `live` or `ended`.
- No PayPal call. `payments.provider` defaults to the string `paypal_sandbox`. Seed row `demo-payment` is HKD 200, purpose `consultation`, status `pending`. Schema statuses are `pending`, `paid`, and `failed`. Purposes are `consultation` and `delivery`. No payment route exists.
- No PDF. `syncfusion_flutter_pdf` is not installed. `sick_leave_certificates` is a schema plus seed row `demo-sick-leave`, certificate number `SL-DEMO-0001`, `readOnly: true`. The app cannot open or generate it.
- No map and no live delivery tracking. The Hong Kong Vector Map API is not called. Seed row `demo-delivery` is `Sample tablets`, quantity 1, status `preparing`, destination `Kowloon, Hong Kong`. Schema statuses are `preparing`, `in_transit`, and `delivered`.
- No HKBU chatbot. Seed rows `demo-chat-user` and `demo-chat-assistant` are fixed sentences. Speakers in the schema are `user` and `assistant`. The Messages tab is direct messages between two accounts. It does not use `chatbot_messages`.
- No wearable sync. The `health` package is not installed. Seed row `demo-heart-rate` is 72 bpm on 26 Oct 2026. Schema metrics are `heart_rate`, `steps`, and `blood_oxygen`. The app has no health screen.
- No route creates, edits, or deletes consultations, certificates, payments, deliveries, chatbot messages, or health readings. `server.js` mounts `/api/health`, `/api/login`, `/api/signup`, `/api/appointments`, `/api/messages`, `/api/discussions`, and `/api/profile`.
- The home dashboard does not load a live delivery count. The next-appointment card does read booked visits.
- Phase 5 system testing and the final report are not done.

## Collections

MongoDB collections, not SQL tables. All of these model files are in `backend/src/models/`. `npm run seed` upserts the demo rows by username or `seedKey`. Running it again updates those same rows.

| Collection | Used by the running app | What exists today |
| --- | --- | --- |
| `users` | Yes. Login, sign-up, profile, settings. | Three demo accounts, plus any account created from sign-up. Optional `description`, `avatarBase64`, `avatarMime`, `specialties`, and `allergies`. A self-signed-up doctor may have no specialty, specialties, or license. |
| `appointments` | Yes. The appointments screen. | Seed: `demo-appointment` on 3 Nov 2026 at 02:00 UTC, status `scheduled`, reason `Sample sore throat visit`. Seed: `demo-open-slot` on 5 Nov 2026 at 02:00 UTC, status `available`. |
| `direct_messages` | Yes. The Messages tab and the message button on an appointment card. | Empty until someone sends a message. Each row stores `sender`, `recipient`, `text` (1 to 500 characters), and `readAt`. `readAt` stays empty until the recipient opens that conversation. |
| `consultations` | No | Schema and one seed row. |
| `sick_leave_certificates` | No | Schema and one seed row. |
| `payments` | No | Schema and one seed row. |
| `deliveries` | No | Schema and one seed row. |
| `chatbot_messages` | No | Schema and two seed rows. |
| `discussions` | Yes. The Discussion tile on Home. The list switches between every post, posts this patient created, and posts this doctor has replied to. | Seed: `demo-discussion`, question about sample tablets, status `answered`, linked to the demo patient and demo doctor. A new patient question starts as `open` with no doctor. The author can delete the post, which also deletes its replies. |
| `discussion_comments` | Yes. Doctor replies on a question. More than one doctor can reply to the same question. | Seed: `demo-comment`, a sample reply from the demo doctor. A comment also stores `likes`, `savedBy`, and `seenByPatient`. |
| `health_readings` | No | Schema and one seed row. |

Atlas also has system databases such as `admin`, `config`, and `local`. Those are not this app. Another database on the same cluster, if present, is not this app. This app uses `telemedicine`.

## Tests

`flutter test` uses `MockClient`. It checks login validation, sign-up, the doctor dashboard, the empty doctor appointment state and its **Make an appointment** button, the soonest future booked visit for the home card, patient appointment search, doctor-type filtering, appointment sorting, logout, the side rail, settings save, doctor type tags, allergy tags, dark mode, theme color, password confirmation, and avatar byte checks. Those tests run in English, which is the default language when no language has been saved. A passing test does not mean `npm start` is running or that Atlas accepted a password. The calendar and list switch is described above and is not covered by a widget test. The language control is described above and is not covered by a widget test.

## To do

- Remove the three demo sign-in buttons on the login screen (`demoAdminButton`, `demoDoctorButton`, and `demoPatientButton` in `lib/screens/login_screen.dart`). They sign in as the seeded admin, doctor, and patient accounts without a typed password. Take them out before real patients use the app. Keep the username and password form.
- Change the doctor sign-up process. Sign-up is still the same form for a patient and a doctor: email, username, and password. Doctor type tags are chosen later in Settings from the fixed list above. Do not add a license number or an approval step to sign-up until the student asks. The seeded doctor account is separate and already has specialty `General Practice` and license `DEMO-HK-DOCTOR-001`.
- Doctor reputation. Show a star rating on a doctor, such as 5 or 4.8, where a patient chooses a doctor. This is not in the app or the database. `users` has no rating field, no review collection exists, and the appointment cards do not show stars. Do not invent a rating, a review screen, or seed scores until the student asks.
- Message notifications outside the open app. The red count on the Messages icon and the green count on each conversation already show unread messages while the app is open. Still to do: notify the signed-in person when a new message arrives and this app is in the background or closed. Do not add email, SMS, or a push service until the student asks.
- Appointment confirmation page with payment. This covers the report's online payment for a consultation and for delivery. Booking still saves as soon as the patient sends a reason. Still to do: after the patient chooses a time, show a confirmation page before the booking is saved, and include payment on that page. The `payments` collection and the PayPal Sandbox seed row are unused. Do not add the page, a payment route, or a PayPal call until the student asks.
- Terms and conditions. The app has no terms page and no checkbox that must be accepted before sign-up, booking, or payment. Still to do: show the terms and require acceptance. Do not write the legal text until the student provides it.
- Action notifications with a setting. The app shows unread counts while it is open. Still to do: notify the signed-in person about actions such as a new reply, a booking change, or a message, and add a Settings control for those notifications. Do not add email, SMS, or a push service until the student asks.
- Easy mode screens. Still to do: a simpler set of screens with fewer choices. Do not add that mode until the student asks. The font size control in Settings is separate and is already in the app.

These report functions are not built. Appointment booking and the discussion board are already in the app, so the report's older wording for those two is not copied here.

- Online face-to-face video call. The report asks for a real-time video and audio visit between a doctor and a patient. The Consultation tab (`lib/screens/consultation_screen.dart`) only says video visits are not available yet. The report names `agora_rtc_engine`, `stream_video_flutter`, and `videosdk`, and it does not pick one. `consultations` is a schema and one seed row. Do not install a video package or start a call until the student asks.
- Read-only sick leave certificates. The report asks for a system-generated certificate that cannot be edited. `syncfusion_flutter_pdf` is not installed. `sick_leave_certificates` is a schema and seed row `demo-sick-leave`. The Home tile only says the service is not available yet. Do not generate a PDF until the student asks.
- Medication delivery tracking. The report asks for live tracking of prescribed medication, using the Hong Kong Vector Map API. No map call exists. `deliveries` is a schema and seed row `demo-delivery`. The Home card still says `No active order`. Do not add the map until the student asks.
- AI chatbot. The report asks for an assistant for system guidance and general medical support, using the HKBU GenAI API. The Messages tab is direct chat between two accounts. It does not use `chatbot_messages`. Do not call that API until the student asks.
- Wearable health sync. The report asks for an IoT connection that reads wearable data through the `health` package. That package is not installed. `health_readings` is a schema and seed row `demo-heart-rate`. Do not add a health screen until the student asks.

## Do not start unless the student asks

The unfinished report items above are recorded as to-do only. Do not start PayPal, PDF certificates, a video SDK, the Vector Map, the HKBU chatbot, or wearable sync until the student asks to build that item. Also do not rewrite the backend in Dart, do not connect Flutter to MongoDB, and do not invent a second appointment flow. The appointment booking screen and the discussion board already replace the report's older description of those two functions.
