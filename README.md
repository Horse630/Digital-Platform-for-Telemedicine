# Digital Platform for Telemedicine

Cross-platform telemedicine app for Hong Kong Baptist University COMP4878-9. It is meant to cover a remote visit and the logistics around it: appointments, video consultation, sick leave certificates, payment, and medication delivery.

The frontend is Flutter and Dart. This repository is in Phase 1. MongoDB is not connected, and the other libraries from the progress report are not dependencies yet.

## Demo sign-in

The login form checks one account stored in the app:

| Field | Value |
| --- | --- |
| Username | `Admin` |
| Password | `Admin` |

The username may have spaces around it. The password must match exactly, including letter case. A failed attempt stays on the login screen. Logging out returns to that screen. Nothing is written to a database.

When user profiles move to MongoDB, replace `AuthService.signIn` in `lib/services/auth_service.dart`.

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
```

## Tests

```bash
flutter test
```

## Later phases

Phase 2 adds appointment booking, PayPal Sandbox, and read-only sick leave PDFs. Video, the delivery map, the chatbot, discussion, and wearable data come after that. Those entries on the home screen are only navigation targets in this build.
