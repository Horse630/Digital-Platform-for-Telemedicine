import 'package:flutter/widgets.dart';

import 'package:digital_platform_for_telemedicine/language/app_localizations.dart';

export 'package:digital_platform_for_telemedicine/language/app_localizations.dart';

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Turns an English message from the client or the API into the current language.
///
/// The server and the service classes keep the English text. Unknown text is
/// shown as it arrived, so a new server message is still readable.
String localizeMessage(AppLocalizations l10n, String message) {
  switch (message) {
    case 'Enter your username and password.':
      return l10n.enterUsernameAndPassword;
    case 'Username or password is incorrect.':
      return l10n.msgUsernameOrPassword;
    case 'Cannot reach the service. Check your connection and try again.':
      return l10n.msgCannotReach;
    case 'That username is already used.':
      return l10n.msgUsernameUsed;
    case 'That email is already used.':
      return l10n.msgEmailUsed;
    case 'Enter a valid email.':
      return l10n.enterValidEmail;
    case 'Use at least 8 characters.':
      return l10n.atLeast8;
    case 'Use 3 to 40 letters, numbers, dots, underscores, or hyphens.':
      return l10n.usernameRule;
    case 'Sign-in failed. Try again.':
      return l10n.msgSignInFailed;
    case 'Choose patient or doctor.':
      return l10n.msgChooseRole;
    case 'Could not create the account.':
      return l10n.msgCouldNotCreate;
    case 'The request failed. Try again.':
      return l10n.msgRequestFailed;
    case 'Sign in again.':
      return l10n.msgSignInAgain;
    case 'The profile could not be read.':
      return l10n.msgProfileUnread;
    case 'The account service is not available. Try again later.':
      return l10n.msgAccountUnavailable;
    case 'The profile request failed.':
      return l10n.msgProfileFailed;
    case 'Profile saved.':
      return l10n.profileSaved;
    case 'Password updated.':
      return l10n.msgPasswordUpdated;
    case 'Current password is incorrect.':
      return l10n.msgCurrentPasswordWrong;
    case 'Choose a different password.':
      return l10n.differentPassword;
    case 'Enter your current password and a new password.':
      return l10n.msgEnterBothPasswords;
    case 'Keep the description under 280 characters.':
      return l10n.msgDescriptionLimit;
    case 'Could not save the profile.':
      return l10n.msgCouldNotSaveProfile;
    case 'Choose a JPEG, PNG, or WebP image under 512 KB.':
      return l10n.msgBadPhoto;
    case 'Choose doctor types from the list.':
      return l10n.msgChooseDoctorTypes;
    case 'Enter allergies as a list.':
      return l10n.msgAllergiesList;
    case 'Keep the allergy list to 20 items.':
      return l10n.msgAllergyCount;
    case 'Enter a short allergy name.':
      return l10n.msgAllergyName;
    case 'Keep each allergy under 40 characters.':
      return l10n.msgAllergyLength;
    case 'The appointment list could not be read.':
      return l10n.msgAppointmentUnread;
    case 'The appointment request failed.':
      return l10n.msgAppointmentFailed;
    case 'Choose a time in the future.':
      return l10n.chooseFutureTime;
    case 'You already have a slot at that time.':
      return l10n.msgSlotTaken;
    case 'Only a doctor can add a time slot.':
      return l10n.msgOnlyDoctor;
    case 'Only a patient can book a time slot.':
      return l10n.msgOnlyPatient;
    case 'Enter a short reason for the visit.':
      return l10n.enterShortReason;
    case 'That time slot is no longer available.':
      return l10n.msgSlotGone;
    case 'Appointment not found.':
      return l10n.msgAppointmentMissing;
    case 'You cannot change this appointment.':
      return l10n.msgCannotChange;
    case 'Only a cancelled appointment can be removed.':
      return l10n.msgOnlyCancelled;
    case 'Enter a message.':
      return l10n.msgEnterMessage;
    case 'Keep the message under 500 characters.':
      return l10n.msgMessageTooLong;
    case 'You cannot message yourself.':
      return l10n.msgCannotMessageYourself;
    case 'That person was not found.':
      return l10n.msgPersonNotFound;
    case 'The message list could not be read.':
      return l10n.msgMessagesUnread;
    case 'The message request failed.':
      return l10n.msgMessageFailed;
    case 'Only a patient can ask a question.':
      return l10n.msgOnlyPatientCanAsk;
    case 'Only a doctor can reply.':
      return l10n.msgOnlyDoctorCanReply;
    case 'Enter a title.':
      return l10n.msgEnterTitle;
    case 'Keep the title under 120 characters.':
      return l10n.msgTitleTooLong;
    case 'Enter your question.':
      return l10n.msgEnterQuestion;
    case 'Keep the question under 1000 characters.':
      return l10n.msgQuestionTooLong;
    case 'Enter a reply.':
      return l10n.msgEnterReply;
    case 'Keep the reply under 1000 characters.':
      return l10n.msgReplyTooLong;
    case 'That question was not found.':
      return l10n.msgQuestionNotFound;
    case 'The discussion request failed.':
      return l10n.msgDiscussionFailed;
    case 'The discussion list could not be read.':
      return l10n.msgDiscussionsUnread;
    case 'Only the person who posted can remove it.':
      return l10n.msgOnlyPosterCanRemove;
    case 'Only the doctor who wrote this reply can change it.':
      return l10n.msgOnlyReplyAuthor;
    case 'Only a doctor can issue a certificate.':
      return l10n.msgOnlyDoctorIssues;
    case 'Choose an appointed patient.':
      return l10n.msgChoosePatient;
    case 'Enter the patient address.':
      return l10n.msgEnterAddress;
    case 'Keep the address under 200 characters.':
      return l10n.msgAddressTooLong;
    case 'Keep the delivery address under 200 characters.':
      return l10n.msgDeliveryAddressTooLong;
    case 'Enter what the patient is unfit for.':
      return l10n.msgEnterUnfit;
    case 'Keep that line under 120 characters.':
      return l10n.msgUnfitTooLong;
    case 'Enter the sickness.':
      return l10n.msgEnterSickness;
    case 'Keep the sickness under 300 characters.':
      return l10n.msgSicknessTooLong;
    case 'Enter your signature.':
      return l10n.msgEnterSignature;
    case 'Keep the signature under 80 characters.':
      return l10n.msgSignatureTooLong;
    case 'Enter the start date.':
      return l10n.msgEnterStartDate;
    case 'Enter the end date.':
      return l10n.msgEnterEndDate;
    case 'The end date must be on or after the start date.':
      return l10n.msgBadSickDates;
    case 'A certificate already exists for that appointment.':
      return l10n.msgCertificateExists;
    case 'That appointment was not found.':
      return l10n.msgAppointmentMissingSick;
    case 'You cannot open this certificate.':
      return l10n.msgCannotOpenCertificate;
    case 'That certificate was not found.':
      return l10n.msgCertificateNotFound;
    case 'The sick leave request failed.':
      return l10n.msgSickLeaveFailed;
    case 'The sick leave list could not be read.':
      return l10n.msgSickLeaveUnread;
    default:
      return message;
  }
}

String localizedRole(AppLocalizations l10n, String role) {
  switch (role) {
    case 'doctor':
      return l10n.doctor;
    case 'admin':
      return l10n.admin;
    default:
      return l10n.patient;
  }
}

String localizedDashboard(AppLocalizations l10n, String role) {
  switch (role) {
    case 'doctor':
      return l10n.doctorDashboard;
    case 'admin':
      return l10n.adminDashboard;
    default:
      return l10n.patientDashboard;
  }
}

String localizedDoctorType(AppLocalizations l10n, String type) {
  switch (type) {
    case 'General Practice':
      return l10n.typeGeneralPractice;
    case 'Family Medicine':
      return l10n.typeFamilyMedicine;
    case 'Internal Medicine':
      return l10n.typeInternalMedicine;
    case 'Paediatrics':
      return l10n.typePaediatrics;
    case 'Obstetrics and Gynaecology':
      return l10n.typeObstetrics;
    case 'Surgery':
      return l10n.typeSurgery;
    case 'Orthopaedics':
      return l10n.typeOrthopaedics;
    case 'Dermatology':
      return l10n.typeDermatology;
    case 'Psychiatry':
      return l10n.typePsychiatry;
    case 'Ophthalmology':
      return l10n.typeOphthalmology;
    case 'Otorhinolaryngology':
      return l10n.typeOtorhinolaryngology;
    case 'Cardiology':
      return l10n.typeCardiology;
    default:
      return type;
  }
}

/// Shows a stored specialty string in the current language.
///
/// The value saved on the account stays the English doctor-type name.
String localizedSpecialtyLine(AppLocalizations l10n, String specialty) {
  if (specialty.trim().isEmpty) {
    return specialty;
  }
  return specialty
      .split(',')
      .map((part) => localizedDoctorType(l10n, part.trim()))
      .where((part) => part.isNotEmpty)
      .join(', ');
}

String localizedStatus(AppLocalizations l10n, String status) {
  switch (status) {
    case 'available':
      return l10n.statusAvailable;
    case 'scheduled':
      return l10n.statusScheduled;
    case 'cancelled':
      return l10n.statusCancelled;
    default:
      return status;
  }
}

String localizedColorName(AppLocalizations l10n, String name) {
  switch (name) {
    case 'Teal':
      return l10n.teal;
    case 'Blue':
      return l10n.blue;
    case 'Green':
      return l10n.green;
    case 'Purple':
      return l10n.purple;
    case 'Orange':
      return l10n.orange;
    default:
      return name;
  }
}
