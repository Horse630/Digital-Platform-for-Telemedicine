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
  String get continueAs => 'Continue as';

  @override
  String get createAccount => 'Create an account';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get resetPasswordTitle => 'Reset password';

  @override
  String get resetPasswordHint =>
      'Enter the email on your account. Sending the reset email is not connected yet.';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get resetEmailNotSent => 'The reset email is not sent yet.';

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
  String get navMessages => 'Messages';

  @override
  String get noMessages => 'No messages yet.';

  @override
  String get noMessagesHint =>
      'Message a doctor or a patient from an appointment.';

  @override
  String get messageAction => 'Message';

  @override
  String get send => 'Send';

  @override
  String get messageHint => 'Write a message';

  @override
  String get messageSent => 'Sent';

  @override
  String get messageRead => 'Read';

  @override
  String get patientProfile => 'Patient profile';

  @override
  String get msgEnterMessage => 'Enter a message.';

  @override
  String get msgMessageTooLong => 'Keep the message under 500 characters.';

  @override
  String get msgCannotMessageYourself => 'You cannot message yourself.';

  @override
  String get msgPersonNotFound => 'That person was not found.';

  @override
  String get msgMessagesUnread => 'The message list could not be read.';

  @override
  String get msgMessageFailed => 'The message request failed.';

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
  String get sickLeaveDoctorHint =>
      'Choose an appointed patient, then fill in the certificate. It cannot be edited afterwards.';

  @override
  String get sickLeavePatientHint =>
      'A certificate from your doctor is read-only. You can download a copy.';

  @override
  String get issueCertificate => 'Issue a certificate';

  @override
  String get selectAppointment => 'Appointed patient';

  @override
  String get noAppointedPatients => 'No appointed patient yet.';

  @override
  String get noSickLeave => 'No certificate yet.';

  @override
  String get patientAddress => 'Patient address';

  @override
  String get unfitFor => 'Unfit for';

  @override
  String get sickFrom => 'From';

  @override
  String get sickUntil => 'Until';

  @override
  String get numberOfDays => 'Number of days';

  @override
  String get sickness => 'Sickness';

  @override
  String get doctorSignature => 'Doctor\'s signature';

  @override
  String get dateOfIssue => 'Date of issue';

  @override
  String get referenceNumber => 'Reference No.';

  @override
  String get toWhom => 'To whom it may concern:';

  @override
  String get certifyDoctor => 'I,';

  @override
  String get herebyCertify => 'Hereby certify that';

  @override
  String get sickCertTitle => 'Sick certification';

  @override
  String get downloadCertificate => 'Download';

  @override
  String get licenceNumber => 'Licence no.';

  @override
  String get msgOnlyDoctorIssues => 'Only a doctor can issue a certificate.';

  @override
  String get msgChoosePatient => 'Choose an appointed patient.';

  @override
  String get msgEnterAddress => 'Enter the patient address.';

  @override
  String get msgAddressTooLong => 'Keep the address under 200 characters.';

  @override
  String get msgEnterUnfit => 'Enter what the patient is unfit for.';

  @override
  String get msgUnfitTooLong => 'Keep that line under 120 characters.';

  @override
  String get msgEnterSickness => 'Enter the sickness.';

  @override
  String get msgSicknessTooLong => 'Keep the sickness under 300 characters.';

  @override
  String get msgEnterSignature => 'Enter your signature.';

  @override
  String get msgSignatureTooLong => 'Keep the signature under 80 characters.';

  @override
  String get msgEnterStartDate => 'Enter the start date.';

  @override
  String get msgEnterEndDate => 'Enter the end date.';

  @override
  String get msgBadSickDates =>
      'The end date must be on or after the start date.';

  @override
  String get msgCertificateExists =>
      'A certificate already exists for that appointment.';

  @override
  String get msgAppointmentMissingSick => 'That appointment was not found.';

  @override
  String get msgCannotOpenCertificate => 'You cannot open this certificate.';

  @override
  String get msgCertificateNotFound => 'That certificate was not found.';

  @override
  String get msgSickLeaveFailed => 'The sick leave request failed.';

  @override
  String get msgSickLeaveUnread => 'The sick leave list could not be read.';

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
  String get discussionSubtitle => 'Public questions for doctors';

  @override
  String get askQuestion => 'Ask a question';

  @override
  String get questionTitle => 'Title';

  @override
  String get questionBody => 'Your question';

  @override
  String get postQuestion => 'Post';

  @override
  String get noDiscussions => 'No questions yet.';

  @override
  String get noDiscussionsHint =>
      'Everyone can read a question. Only a doctor can reply, and more than one doctor may reply.';

  @override
  String get discussionOpen => 'Waiting for a reply';

  @override
  String get discussionAnswered => 'Answered';

  @override
  String get publicReply => 'Public replies';

  @override
  String get noRepliesYet => 'No reply yet.';

  @override
  String get replyHint => 'Write advice or a short explanation';

  @override
  String get searchPosts => 'Search posts';

  @override
  String get noMatchingPosts => 'No matching posts.';

  @override
  String get editReply => 'Edit reply';

  @override
  String get saveReply => 'Save';

  @override
  String get confirmRemoveReplyTitle => 'Remove this reply?';

  @override
  String get confirmRemoveReplyMessage => 'This reply will be deleted.';

  @override
  String get msgOnlyReplyAuthor =>
      'Only the doctor who wrote this reply can change it.';

  @override
  String get replyAction => 'Reply';

  @override
  String get allComments => 'All comments';

  @override
  String get myComments => 'My comments';

  @override
  String get noStoredReplies => 'You have not stored a reply.';

  @override
  String get likeAction => 'Like';

  @override
  String get storeAction => 'Store';

  @override
  String get storedAction => 'Stored';

  @override
  String get publicDiscussions => 'Public discussions';

  @override
  String get myDiscussions => 'My discussions';

  @override
  String get noMyDiscussions => 'You have not posted a discussion.';

  @override
  String get myResponses => 'My responses';

  @override
  String get noMyResponses => 'You have not replied to a post.';

  @override
  String get confirmRemovePostTitle => 'Remove this post?';

  @override
  String get confirmRemovePostMessage =>
      'This post and its replies will be deleted.';

  @override
  String get msgOnlyPosterCanRemove =>
      'Only the person who posted can remove it.';

  @override
  String replyCount(int count) {
    return '$count replies';
  }

  @override
  String get msgOnlyPatientCanAsk => 'Only a patient can ask a question.';

  @override
  String get msgOnlyDoctorCanReply => 'Only a doctor can reply.';

  @override
  String get msgEnterTitle => 'Enter a title.';

  @override
  String get msgTitleTooLong => 'Keep the title under 120 characters.';

  @override
  String get msgEnterQuestion => 'Enter your question.';

  @override
  String get msgQuestionTooLong => 'Keep the question under 1000 characters.';

  @override
  String get msgEnterReply => 'Enter a reply.';

  @override
  String get msgReplyTooLong => 'Keep the reply under 1000 characters.';

  @override
  String get msgQuestionNotFound => 'That question was not found.';

  @override
  String get msgDiscussionFailed => 'The discussion request failed.';

  @override
  String get msgDiscussionsUnread => 'The discussion list could not be read.';

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
  String get viewDoctorProfile => 'View profile';

  @override
  String get doctorProfile => 'Doctor profile';

  @override
  String get noDescription => 'No description yet.';

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
  String get confirmCancelTitle => 'Cancel this appointment?';

  @override
  String get confirmCancelSlotMessage =>
      'Patients will no longer be able to book this time.';

  @override
  String get confirmCancelVisitMessage => 'This visit will be cancelled.';

  @override
  String get confirmCancelBookingMessage =>
      'This booking will be cancelled and the time will open again.';

  @override
  String get confirmRemoveTitle => 'Remove this appointment?';

  @override
  String get confirmRemoveMessage => 'This cancelled record will be deleted.';

  @override
  String get remove => 'Remove';

  @override
  String get keep => 'Keep';

  @override
  String get msgOnlyCancelled => 'Only a cancelled appointment can be removed.';

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
  String get fontSize => 'Font size';

  @override
  String get fontSizeSmall => 'Small';

  @override
  String get fontSizeNormal => 'Default';

  @override
  String get fontSizeLarge => 'Large';

  @override
  String get fontSizeExtra => 'Extra large';

  @override
  String get fontSizeStaysOnDevice =>
      'The font size stays on this device and applies to every page.';

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
