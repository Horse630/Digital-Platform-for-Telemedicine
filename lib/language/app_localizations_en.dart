// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Digital Platform for Telemedicine';

  @override
  String get appTagline =>
      'Remote care, appointments, and follow-up in one place.';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get email => 'Email';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get enterUsername => 'Enter your username';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get enterUsernameAndPassword => 'Enter your username and password.';

  @override
  String get enterValidEmail => 'Enter a valid email.';

  @override
  String get usernameRule =>
      'Use 3 to 40 letters, numbers, dots, underscores, or hyphens.';

  @override
  String get atLeast8 => 'Use at least 8 characters.';

  @override
  String get samePasswordTwice => 'Enter the same password twice.';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create an account';

  @override
  String get createAccountAction => 'Create account';

  @override
  String get creating => 'Creating...';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get patient => 'Patient';

  @override
  String get doctor => 'Doctor';

  @override
  String get admin => 'Admin';

  @override
  String welcomeBack(String name) {
    return 'Welcome back, $name';
  }

  @override
  String get doctorDashboard => 'Doctor dashboard';

  @override
  String get patientDashboard => 'Patient dashboard';

  @override
  String get adminDashboard => 'Admin dashboard';

  @override
  String get navHome => 'Home';

  @override
  String get navAppointments => 'Appointments';

  @override
  String get navConsultation => 'Consultation';

  @override
  String get navProfile => 'Profile';

  @override
  String get overview => 'Overview';

  @override
  String get coreServices => 'Core services';

  @override
  String get otherServices => 'Other services';

  @override
  String get nextAppointment => 'Next appointment';

  @override
  String get notScheduled => 'Not scheduled';

  @override
  String get noActiveOrder => 'No active order';

  @override
  String get appointmentsSubtitle => 'Book a remote visit';

  @override
  String get consultationTitle => 'Consultation';

  @override
  String get consultationSubtitle => 'Talk with a doctor';

  @override
  String get sickLeave => 'Sick leave';

  @override
  String get sickLeaveSubtitle => 'Read-only certificate';

  @override
  String get payment => 'Payment';

  @override
  String get paymentSubtitle => 'Fees for care and delivery';

  @override
  String get medicationDelivery => 'Medication delivery';

  @override
  String get medicationDeliverySubtitle => 'Track a prescription';

  @override
  String get aiChatbot => 'AI chatbot';

  @override
  String get aiChatbotSubtitle => 'Guidance and questions';

  @override
  String get discussion => 'Discussion';

  @override
  String get discussionSubtitle => 'Ask the care team';

  @override
  String get iotHealth => 'IoT health';

  @override
  String get iotHealthSubtitle => 'Wearable readings';

  @override
  String get serviceUnavailable => 'This service is not available yet.';

  @override
  String get close => 'Close';

  @override
  String patientLine(String name) {
    return 'Patient: $name';
  }

  @override
  String get unknown => 'Unknown';

  @override
  String get noPatientYet => 'No patient yet';

  @override
  String get openForPatients => 'Open for patients';

  @override
  String get noAppointment => 'No appointment';

  @override
  String get noAppointmentYet => 'You have no appointment yet.';

  @override
  String get noAppointmentOnDay => 'No appointment on this day.';

  @override
  String get noAppointmentsYet => 'No appointments yet';

  @override
  String get doctorsHaveNotPublished =>
      'Doctors have not published a time slot.';

  @override
  String get appointmentsUnavailable => 'Appointments unavailable';

  @override
  String get makeAppointment => 'Make an appointment';

  @override
  String get bookAppointment => 'Book an appointment';

  @override
  String get bookThisTime => 'Book this time';

  @override
  String get reasonForVisit => 'Reason for the visit';

  @override
  String get enterShortReason => 'Enter a short reason for the visit.';

  @override
  String get book => 'Book';

  @override
  String get openTimes => 'Open times';

  @override
  String get doctorName => 'Doctor name';

  @override
  String get allTypes => 'All types';

  @override
  String get doctorTypeLabel => 'Doctor type';

  @override
  String get sort => 'Sort';

  @override
  String get soonest => 'Soonest';

  @override
  String get latest => 'Latest';

  @override
  String get nameAz => 'Name A–Z';

  @override
  String get nameZa => 'Name Z–A';

  @override
  String get noOpenTimes =>
      'No open time slots. A doctor has not published a time yet.';

  @override
  String get noOpenTimesMatch => 'No open times match this search.';

  @override
  String get calendar => 'Calendar';

  @override
  String get list => 'List';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get cancelSlot => 'Cancel slot';

  @override
  String get cancelBooking => 'Cancel booking';

  @override
  String get chooseFutureTime => 'Choose a time in the future.';

  @override
  String get statusAvailable => 'available';

  @override
  String get statusScheduled => 'scheduled';

  @override
  String get statusCancelled => 'cancelled';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageStaysOnDevice => 'The language stays on this device.';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get darkModeSubtitle => 'Switch the app between light and dark';

  @override
  String get appColor => 'App color';

  @override
  String get colorStaysOnDevice => 'Color and dark mode stay on this device.';

  @override
  String get account => 'Account';

  @override
  String get passwordSection => 'Password';

  @override
  String get uploadPhoto => 'Upload photo';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get description => 'Description';

  @override
  String get saveProfile => 'Save profile';

  @override
  String get saving => 'Saving...';

  @override
  String get profileSaved => 'Profile saved.';

  @override
  String get allergies => 'Allergies';

  @override
  String get addAllergyHint => 'Add an allergy';

  @override
  String get addAllergy => 'Add allergy';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmNewPassword => 'Confirm new password';

  @override
  String get changePassword => 'Change password';

  @override
  String get updating => 'Updating...';

  @override
  String get enterCurrentPassword => 'Enter your current password.';

  @override
  String get differentPassword => 'Choose a different password.';

  @override
  String get retry => 'Retry';

  @override
  String get logOut => 'Log out';

  @override
  String get videoNotAvailable => 'Video visits are not available yet';

  @override
  String get videoNotAvailableMessage =>
      'You can book a time now. The video call will open here when it is ready.';

  @override
  String get teal => 'Teal';

  @override
  String get blue => 'Blue';

  @override
  String get green => 'Green';

  @override
  String get purple => 'Purple';

  @override
  String get orange => 'Orange';

  @override
  String get typeGeneralPractice => 'General Practice';

  @override
  String get typeFamilyMedicine => 'Family Medicine';

  @override
  String get typeInternalMedicine => 'Internal Medicine';

  @override
  String get typePaediatrics => 'Paediatrics';

  @override
  String get typeObstetrics => 'Obstetrics and Gynaecology';

  @override
  String get typeSurgery => 'Surgery';

  @override
  String get typeOrthopaedics => 'Orthopaedics';

  @override
  String get typeDermatology => 'Dermatology';

  @override
  String get typePsychiatry => 'Psychiatry';

  @override
  String get typeOphthalmology => 'Ophthalmology';

  @override
  String get typeOtorhinolaryngology => 'Otorhinolaryngology';

  @override
  String get typeCardiology => 'Cardiology';

  @override
  String get msgUsernameOrPassword => 'Username or password is incorrect.';

  @override
  String get msgCannotReach =>
      'Cannot reach the service. Check your connection and try again.';

  @override
  String get msgUsernameUsed => 'That username is already used.';

  @override
  String get msgEmailUsed => 'That email is already used.';

  @override
  String get msgSignInFailed => 'Sign-in failed. Try again.';

  @override
  String get msgChooseRole => 'Choose patient or doctor.';

  @override
  String get msgCouldNotCreate => 'Could not create the account.';

  @override
  String get msgRequestFailed => 'The request failed. Try again.';

  @override
  String get msgSignInAgain => 'Sign in again.';

  @override
  String get msgProfileUnread => 'The profile could not be read.';

  @override
  String get msgAccountUnavailable =>
      'The account service is not available. Try again later.';

  @override
  String get msgProfileFailed => 'The profile request failed.';

  @override
  String get msgPasswordUpdated => 'Password updated.';

  @override
  String get msgCurrentPasswordWrong => 'Current password is incorrect.';

  @override
  String get msgEnterBothPasswords =>
      'Enter your current password and a new password.';

  @override
  String get msgDescriptionLimit =>
      'Keep the description under 280 characters.';

  @override
  String get msgCouldNotSaveProfile => 'Could not save the profile.';

  @override
  String get msgBadPhoto => 'Choose a JPEG, PNG, or WebP image under 512 KB.';

  @override
  String get msgChooseDoctorTypes => 'Choose doctor types from the list.';

  @override
  String get msgAllergiesList => 'Enter allergies as a list.';

  @override
  String get msgAllergyCount => 'Keep the allergy list to 20 items.';

  @override
  String get msgAllergyName => 'Enter a short allergy name.';

  @override
  String get msgAllergyLength => 'Keep each allergy under 40 characters.';

  @override
  String get msgAppointmentUnread => 'The appointment list could not be read.';

  @override
  String get msgAppointmentFailed => 'The appointment request failed.';

  @override
  String get msgSlotTaken => 'You already have a slot at that time.';

  @override
  String get msgOnlyDoctor => 'Only a doctor can add a time slot.';

  @override
  String get msgOnlyPatient => 'Only a patient can book a time slot.';

  @override
  String get msgSlotGone => 'That time slot is no longer available.';

  @override
  String get msgAppointmentMissing => 'Appointment not found.';

  @override
  String get msgCannotChange => 'You cannot change this appointment.';
}
