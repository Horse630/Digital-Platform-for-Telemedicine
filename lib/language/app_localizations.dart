import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'language/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Digital Platform for Telemedicine'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Remote care, appointments, and follow-up in one place.'**
  String get appTagline;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get enterUsername;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @enterUsernameAndPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your username and password.'**
  String get enterUsernameAndPassword;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email.'**
  String get enterValidEmail;

  /// No description provided for @usernameRule.
  ///
  /// In en, this message translates to:
  /// **'Use 3 to 40 letters, numbers, dots, underscores, or hyphens.'**
  String get usernameRule;

  /// No description provided for @atLeast8.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters.'**
  String get atLeast8;

  /// No description provided for @samePasswordTwice.
  ///
  /// In en, this message translates to:
  /// **'Enter the same password twice.'**
  String get samePasswordTwice;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @continueAs.
  ///
  /// In en, this message translates to:
  /// **'Continue as'**
  String get continueAs;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the email on your account. Sending the reset email is not connected yet.'**
  String get resetPasswordHint;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @resetEmailNotSent.
  ///
  /// In en, this message translates to:
  /// **'The reset email is not sent yet.'**
  String get resetEmailNotSent;

  /// No description provided for @createAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccountAction;

  /// No description provided for @creating.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get creating;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @patient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patient;

  /// No description provided for @doctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctor;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}'**
  String welcomeBack(String name);

  /// No description provided for @doctorDashboard.
  ///
  /// In en, this message translates to:
  /// **'Doctor dashboard'**
  String get doctorDashboard;

  /// No description provided for @patientDashboard.
  ///
  /// In en, this message translates to:
  /// **'Patient dashboard'**
  String get patientDashboard;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin dashboard'**
  String get adminDashboard;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navAppointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get navAppointments;

  /// No description provided for @navMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get navMessages;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet.'**
  String get noMessages;

  /// No description provided for @noMessagesHint.
  ///
  /// In en, this message translates to:
  /// **'Message a doctor or a patient from an appointment.'**
  String get noMessagesHint;

  /// No description provided for @messageAction.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageAction;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @messageHint.
  ///
  /// In en, this message translates to:
  /// **'Write a message'**
  String get messageHint;

  /// No description provided for @messageSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get messageSent;

  /// No description provided for @messageRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get messageRead;

  /// No description provided for @patientProfile.
  ///
  /// In en, this message translates to:
  /// **'Patient profile'**
  String get patientProfile;

  /// No description provided for @msgEnterMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter a message.'**
  String get msgEnterMessage;

  /// No description provided for @msgMessageTooLong.
  ///
  /// In en, this message translates to:
  /// **'Keep the message under 500 characters.'**
  String get msgMessageTooLong;

  /// No description provided for @msgCannotMessageYourself.
  ///
  /// In en, this message translates to:
  /// **'You cannot message yourself.'**
  String get msgCannotMessageYourself;

  /// No description provided for @msgPersonNotFound.
  ///
  /// In en, this message translates to:
  /// **'That person was not found.'**
  String get msgPersonNotFound;

  /// No description provided for @msgMessagesUnread.
  ///
  /// In en, this message translates to:
  /// **'The message list could not be read.'**
  String get msgMessagesUnread;

  /// No description provided for @msgMessageFailed.
  ///
  /// In en, this message translates to:
  /// **'The message request failed.'**
  String get msgMessageFailed;

  /// No description provided for @navConsultation.
  ///
  /// In en, this message translates to:
  /// **'Consultation'**
  String get navConsultation;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @coreServices.
  ///
  /// In en, this message translates to:
  /// **'Core services'**
  String get coreServices;

  /// No description provided for @otherServices.
  ///
  /// In en, this message translates to:
  /// **'Other services'**
  String get otherServices;

  /// No description provided for @nextAppointment.
  ///
  /// In en, this message translates to:
  /// **'Next appointment'**
  String get nextAppointment;

  /// No description provided for @notScheduled.
  ///
  /// In en, this message translates to:
  /// **'Not scheduled'**
  String get notScheduled;

  /// No description provided for @noActiveOrder.
  ///
  /// In en, this message translates to:
  /// **'No active order'**
  String get noActiveOrder;

  /// No description provided for @appointmentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Book a remote visit'**
  String get appointmentsSubtitle;

  /// No description provided for @consultationTitle.
  ///
  /// In en, this message translates to:
  /// **'Consultation'**
  String get consultationTitle;

  /// No description provided for @consultationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Talk with a doctor'**
  String get consultationSubtitle;

  /// No description provided for @sickLeave.
  ///
  /// In en, this message translates to:
  /// **'Sick leave'**
  String get sickLeave;

  /// No description provided for @sickLeaveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read-only certificate'**
  String get sickLeaveSubtitle;

  /// No description provided for @sickLeaveDoctorHint.
  ///
  /// In en, this message translates to:
  /// **'Choose an appointed patient, then fill in the certificate. It cannot be edited afterwards.'**
  String get sickLeaveDoctorHint;

  /// No description provided for @sickLeavePatientHint.
  ///
  /// In en, this message translates to:
  /// **'A certificate from your doctor is read-only. You can download a copy.'**
  String get sickLeavePatientHint;

  /// No description provided for @issueCertificate.
  ///
  /// In en, this message translates to:
  /// **'Issue a certificate'**
  String get issueCertificate;

  /// No description provided for @selectAppointment.
  ///
  /// In en, this message translates to:
  /// **'Appointed patient'**
  String get selectAppointment;

  /// No description provided for @noAppointedPatients.
  ///
  /// In en, this message translates to:
  /// **'No appointed patient yet.'**
  String get noAppointedPatients;

  /// No description provided for @noSickLeave.
  ///
  /// In en, this message translates to:
  /// **'No certificate yet.'**
  String get noSickLeave;

  /// No description provided for @patientAddress.
  ///
  /// In en, this message translates to:
  /// **'Patient address'**
  String get patientAddress;

  /// No description provided for @unfitFor.
  ///
  /// In en, this message translates to:
  /// **'Unfit for'**
  String get unfitFor;

  /// No description provided for @sickFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get sickFrom;

  /// No description provided for @sickUntil.
  ///
  /// In en, this message translates to:
  /// **'Until'**
  String get sickUntil;

  /// No description provided for @numberOfDays.
  ///
  /// In en, this message translates to:
  /// **'Number of days'**
  String get numberOfDays;

  /// No description provided for @sickness.
  ///
  /// In en, this message translates to:
  /// **'Sickness'**
  String get sickness;

  /// No description provided for @doctorSignature.
  ///
  /// In en, this message translates to:
  /// **'Doctor\'s signature'**
  String get doctorSignature;

  /// No description provided for @dateOfIssue.
  ///
  /// In en, this message translates to:
  /// **'Date of issue'**
  String get dateOfIssue;

  /// No description provided for @referenceNumber.
  ///
  /// In en, this message translates to:
  /// **'Reference No.'**
  String get referenceNumber;

  /// No description provided for @toWhom.
  ///
  /// In en, this message translates to:
  /// **'To whom it may concern:'**
  String get toWhom;

  /// No description provided for @certifyDoctor.
  ///
  /// In en, this message translates to:
  /// **'I,'**
  String get certifyDoctor;

  /// No description provided for @herebyCertify.
  ///
  /// In en, this message translates to:
  /// **'Hereby certify that'**
  String get herebyCertify;

  /// No description provided for @sickCertTitle.
  ///
  /// In en, this message translates to:
  /// **'Sick certification'**
  String get sickCertTitle;

  /// No description provided for @downloadCertificate.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get downloadCertificate;

  /// No description provided for @licenceNumber.
  ///
  /// In en, this message translates to:
  /// **'Licence no.'**
  String get licenceNumber;

  /// No description provided for @msgOnlyDoctorIssues.
  ///
  /// In en, this message translates to:
  /// **'Only a doctor can issue a certificate.'**
  String get msgOnlyDoctorIssues;

  /// No description provided for @msgChoosePatient.
  ///
  /// In en, this message translates to:
  /// **'Choose an appointed patient.'**
  String get msgChoosePatient;

  /// No description provided for @msgEnterAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter the patient address.'**
  String get msgEnterAddress;

  /// No description provided for @msgAddressTooLong.
  ///
  /// In en, this message translates to:
  /// **'Keep the address under 200 characters.'**
  String get msgAddressTooLong;

  /// No description provided for @msgEnterUnfit.
  ///
  /// In en, this message translates to:
  /// **'Enter what the patient is unfit for.'**
  String get msgEnterUnfit;

  /// No description provided for @msgUnfitTooLong.
  ///
  /// In en, this message translates to:
  /// **'Keep that line under 120 characters.'**
  String get msgUnfitTooLong;

  /// No description provided for @msgEnterSickness.
  ///
  /// In en, this message translates to:
  /// **'Enter the sickness.'**
  String get msgEnterSickness;

  /// No description provided for @msgSicknessTooLong.
  ///
  /// In en, this message translates to:
  /// **'Keep the sickness under 300 characters.'**
  String get msgSicknessTooLong;

  /// No description provided for @msgEnterSignature.
  ///
  /// In en, this message translates to:
  /// **'Enter your signature.'**
  String get msgEnterSignature;

  /// No description provided for @msgSignatureTooLong.
  ///
  /// In en, this message translates to:
  /// **'Keep the signature under 80 characters.'**
  String get msgSignatureTooLong;

  /// No description provided for @msgEnterStartDate.
  ///
  /// In en, this message translates to:
  /// **'Enter the start date.'**
  String get msgEnterStartDate;

  /// No description provided for @msgEnterEndDate.
  ///
  /// In en, this message translates to:
  /// **'Enter the end date.'**
  String get msgEnterEndDate;

  /// No description provided for @msgBadSickDates.
  ///
  /// In en, this message translates to:
  /// **'The end date must be on or after the start date.'**
  String get msgBadSickDates;

  /// No description provided for @msgCertificateExists.
  ///
  /// In en, this message translates to:
  /// **'A certificate already exists for that appointment.'**
  String get msgCertificateExists;

  /// No description provided for @msgAppointmentMissingSick.
  ///
  /// In en, this message translates to:
  /// **'That appointment was not found.'**
  String get msgAppointmentMissingSick;

  /// No description provided for @msgCannotOpenCertificate.
  ///
  /// In en, this message translates to:
  /// **'You cannot open this certificate.'**
  String get msgCannotOpenCertificate;

  /// No description provided for @msgCertificateNotFound.
  ///
  /// In en, this message translates to:
  /// **'That certificate was not found.'**
  String get msgCertificateNotFound;

  /// No description provided for @msgSickLeaveFailed.
  ///
  /// In en, this message translates to:
  /// **'The sick leave request failed.'**
  String get msgSickLeaveFailed;

  /// No description provided for @msgSickLeaveUnread.
  ///
  /// In en, this message translates to:
  /// **'The sick leave list could not be read.'**
  String get msgSickLeaveUnread;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @paymentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fees for care and delivery'**
  String get paymentSubtitle;

  /// No description provided for @medicationDelivery.
  ///
  /// In en, this message translates to:
  /// **'Medication delivery'**
  String get medicationDelivery;

  /// No description provided for @medicationDeliverySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track a prescription'**
  String get medicationDeliverySubtitle;

  /// No description provided for @aiChatbot.
  ///
  /// In en, this message translates to:
  /// **'AI chatbot'**
  String get aiChatbot;

  /// No description provided for @aiChatbotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Guidance and questions'**
  String get aiChatbotSubtitle;

  /// No description provided for @discussion.
  ///
  /// In en, this message translates to:
  /// **'Discussion'**
  String get discussion;

  /// No description provided for @discussionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Public questions for doctors'**
  String get discussionSubtitle;

  /// No description provided for @askQuestion.
  ///
  /// In en, this message translates to:
  /// **'Ask a question'**
  String get askQuestion;

  /// No description provided for @questionTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get questionTitle;

  /// No description provided for @questionBody.
  ///
  /// In en, this message translates to:
  /// **'Your question'**
  String get questionBody;

  /// No description provided for @postQuestion.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postQuestion;

  /// No description provided for @noDiscussions.
  ///
  /// In en, this message translates to:
  /// **'No questions yet.'**
  String get noDiscussions;

  /// No description provided for @noDiscussionsHint.
  ///
  /// In en, this message translates to:
  /// **'Everyone can read a question. Only a doctor can reply, and more than one doctor may reply.'**
  String get noDiscussionsHint;

  /// No description provided for @discussionOpen.
  ///
  /// In en, this message translates to:
  /// **'Waiting for a reply'**
  String get discussionOpen;

  /// No description provided for @discussionAnswered.
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get discussionAnswered;

  /// No description provided for @publicReply.
  ///
  /// In en, this message translates to:
  /// **'Public replies'**
  String get publicReply;

  /// No description provided for @noRepliesYet.
  ///
  /// In en, this message translates to:
  /// **'No reply yet.'**
  String get noRepliesYet;

  /// No description provided for @replyHint.
  ///
  /// In en, this message translates to:
  /// **'Write advice or a short explanation'**
  String get replyHint;

  /// No description provided for @searchPosts.
  ///
  /// In en, this message translates to:
  /// **'Search posts'**
  String get searchPosts;

  /// No description provided for @noMatchingPosts.
  ///
  /// In en, this message translates to:
  /// **'No matching posts.'**
  String get noMatchingPosts;

  /// No description provided for @editReply.
  ///
  /// In en, this message translates to:
  /// **'Edit reply'**
  String get editReply;

  /// No description provided for @saveReply.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveReply;

  /// No description provided for @confirmRemoveReplyTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this reply?'**
  String get confirmRemoveReplyTitle;

  /// No description provided for @confirmRemoveReplyMessage.
  ///
  /// In en, this message translates to:
  /// **'This reply will be deleted.'**
  String get confirmRemoveReplyMessage;

  /// No description provided for @msgOnlyReplyAuthor.
  ///
  /// In en, this message translates to:
  /// **'Only the doctor who wrote this reply can change it.'**
  String get msgOnlyReplyAuthor;

  /// No description provided for @replyAction.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get replyAction;

  /// No description provided for @allComments.
  ///
  /// In en, this message translates to:
  /// **'All comments'**
  String get allComments;

  /// No description provided for @myComments.
  ///
  /// In en, this message translates to:
  /// **'My comments'**
  String get myComments;

  /// No description provided for @noStoredReplies.
  ///
  /// In en, this message translates to:
  /// **'You have not stored a reply.'**
  String get noStoredReplies;

  /// No description provided for @likeAction.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get likeAction;

  /// No description provided for @storeAction.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get storeAction;

  /// No description provided for @storedAction.
  ///
  /// In en, this message translates to:
  /// **'Stored'**
  String get storedAction;

  /// No description provided for @publicDiscussions.
  ///
  /// In en, this message translates to:
  /// **'Public discussions'**
  String get publicDiscussions;

  /// No description provided for @myDiscussions.
  ///
  /// In en, this message translates to:
  /// **'My discussions'**
  String get myDiscussions;

  /// No description provided for @noMyDiscussions.
  ///
  /// In en, this message translates to:
  /// **'You have not posted a discussion.'**
  String get noMyDiscussions;

  /// No description provided for @myResponses.
  ///
  /// In en, this message translates to:
  /// **'My responses'**
  String get myResponses;

  /// No description provided for @noMyResponses.
  ///
  /// In en, this message translates to:
  /// **'You have not replied to a post.'**
  String get noMyResponses;

  /// No description provided for @confirmRemovePostTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this post?'**
  String get confirmRemovePostTitle;

  /// No description provided for @confirmRemovePostMessage.
  ///
  /// In en, this message translates to:
  /// **'This post and its replies will be deleted.'**
  String get confirmRemovePostMessage;

  /// No description provided for @msgOnlyPosterCanRemove.
  ///
  /// In en, this message translates to:
  /// **'Only the person who posted can remove it.'**
  String get msgOnlyPosterCanRemove;

  /// No description provided for @replyCount.
  ///
  /// In en, this message translates to:
  /// **'{count} replies'**
  String replyCount(int count);

  /// No description provided for @msgOnlyPatientCanAsk.
  ///
  /// In en, this message translates to:
  /// **'Only a patient can ask a question.'**
  String get msgOnlyPatientCanAsk;

  /// No description provided for @msgOnlyDoctorCanReply.
  ///
  /// In en, this message translates to:
  /// **'Only a doctor can reply.'**
  String get msgOnlyDoctorCanReply;

  /// No description provided for @msgEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a title.'**
  String get msgEnterTitle;

  /// No description provided for @msgTitleTooLong.
  ///
  /// In en, this message translates to:
  /// **'Keep the title under 120 characters.'**
  String get msgTitleTooLong;

  /// No description provided for @msgEnterQuestion.
  ///
  /// In en, this message translates to:
  /// **'Enter your question.'**
  String get msgEnterQuestion;

  /// No description provided for @msgQuestionTooLong.
  ///
  /// In en, this message translates to:
  /// **'Keep the question under 1000 characters.'**
  String get msgQuestionTooLong;

  /// No description provided for @msgEnterReply.
  ///
  /// In en, this message translates to:
  /// **'Enter a reply.'**
  String get msgEnterReply;

  /// No description provided for @msgReplyTooLong.
  ///
  /// In en, this message translates to:
  /// **'Keep the reply under 1000 characters.'**
  String get msgReplyTooLong;

  /// No description provided for @msgQuestionNotFound.
  ///
  /// In en, this message translates to:
  /// **'That question was not found.'**
  String get msgQuestionNotFound;

  /// No description provided for @msgDiscussionFailed.
  ///
  /// In en, this message translates to:
  /// **'The discussion request failed.'**
  String get msgDiscussionFailed;

  /// No description provided for @msgDiscussionsUnread.
  ///
  /// In en, this message translates to:
  /// **'The discussion list could not be read.'**
  String get msgDiscussionsUnread;

  /// No description provided for @iotHealth.
  ///
  /// In en, this message translates to:
  /// **'IoT health'**
  String get iotHealth;

  /// No description provided for @iotHealthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Wearable readings'**
  String get iotHealthSubtitle;

  /// No description provided for @serviceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This service is not available yet.'**
  String get serviceUnavailable;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @patientLine.
  ///
  /// In en, this message translates to:
  /// **'Patient: {name}'**
  String patientLine(String name);

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @noPatientYet.
  ///
  /// In en, this message translates to:
  /// **'No patient yet'**
  String get noPatientYet;

  /// No description provided for @openForPatients.
  ///
  /// In en, this message translates to:
  /// **'Open for patients'**
  String get openForPatients;

  /// No description provided for @noAppointment.
  ///
  /// In en, this message translates to:
  /// **'No appointment'**
  String get noAppointment;

  /// No description provided for @noAppointmentYet.
  ///
  /// In en, this message translates to:
  /// **'You have no appointment yet.'**
  String get noAppointmentYet;

  /// No description provided for @noAppointmentOnDay.
  ///
  /// In en, this message translates to:
  /// **'No appointment on this day.'**
  String get noAppointmentOnDay;

  /// No description provided for @noAppointmentsYet.
  ///
  /// In en, this message translates to:
  /// **'No appointments yet'**
  String get noAppointmentsYet;

  /// No description provided for @doctorsHaveNotPublished.
  ///
  /// In en, this message translates to:
  /// **'Doctors have not published a time slot.'**
  String get doctorsHaveNotPublished;

  /// No description provided for @appointmentsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Appointments unavailable'**
  String get appointmentsUnavailable;

  /// No description provided for @makeAppointment.
  ///
  /// In en, this message translates to:
  /// **'Make an appointment'**
  String get makeAppointment;

  /// No description provided for @bookAppointment.
  ///
  /// In en, this message translates to:
  /// **'Book an appointment'**
  String get bookAppointment;

  /// No description provided for @bookThisTime.
  ///
  /// In en, this message translates to:
  /// **'Book this time'**
  String get bookThisTime;

  /// No description provided for @reasonForVisit.
  ///
  /// In en, this message translates to:
  /// **'Reason for the visit'**
  String get reasonForVisit;

  /// No description provided for @enterShortReason.
  ///
  /// In en, this message translates to:
  /// **'Enter a short reason for the visit.'**
  String get enterShortReason;

  /// No description provided for @book.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get book;

  /// No description provided for @openTimes.
  ///
  /// In en, this message translates to:
  /// **'Open times'**
  String get openTimes;

  /// No description provided for @doctorName.
  ///
  /// In en, this message translates to:
  /// **'Doctor name'**
  String get doctorName;

  /// No description provided for @viewDoctorProfile.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get viewDoctorProfile;

  /// No description provided for @doctorProfile.
  ///
  /// In en, this message translates to:
  /// **'Doctor profile'**
  String get doctorProfile;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description yet.'**
  String get noDescription;

  /// No description provided for @allTypes.
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get allTypes;

  /// No description provided for @doctorTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Doctor type'**
  String get doctorTypeLabel;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @soonest.
  ///
  /// In en, this message translates to:
  /// **'Soonest'**
  String get soonest;

  /// No description provided for @latest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latest;

  /// No description provided for @nameAz.
  ///
  /// In en, this message translates to:
  /// **'Name A–Z'**
  String get nameAz;

  /// No description provided for @nameZa.
  ///
  /// In en, this message translates to:
  /// **'Name Z–A'**
  String get nameZa;

  /// No description provided for @noOpenTimes.
  ///
  /// In en, this message translates to:
  /// **'No open time slots. A doctor has not published a time yet.'**
  String get noOpenTimes;

  /// No description provided for @noOpenTimesMatch.
  ///
  /// In en, this message translates to:
  /// **'No open times match this search.'**
  String get noOpenTimesMatch;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get list;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @cancelSlot.
  ///
  /// In en, this message translates to:
  /// **'Cancel slot'**
  String get cancelSlot;

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel booking'**
  String get cancelBooking;

  /// No description provided for @confirmCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this appointment?'**
  String get confirmCancelTitle;

  /// No description provided for @confirmCancelSlotMessage.
  ///
  /// In en, this message translates to:
  /// **'Patients will no longer be able to book this time.'**
  String get confirmCancelSlotMessage;

  /// No description provided for @confirmCancelVisitMessage.
  ///
  /// In en, this message translates to:
  /// **'This visit will be cancelled.'**
  String get confirmCancelVisitMessage;

  /// No description provided for @confirmCancelBookingMessage.
  ///
  /// In en, this message translates to:
  /// **'This booking will be cancelled and the time will open again.'**
  String get confirmCancelBookingMessage;

  /// No description provided for @confirmRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this appointment?'**
  String get confirmRemoveTitle;

  /// No description provided for @confirmRemoveMessage.
  ///
  /// In en, this message translates to:
  /// **'This cancelled record will be deleted.'**
  String get confirmRemoveMessage;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @keep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get keep;

  /// No description provided for @msgOnlyCancelled.
  ///
  /// In en, this message translates to:
  /// **'Only a cancelled appointment can be removed.'**
  String get msgOnlyCancelled;

  /// No description provided for @chooseFutureTime.
  ///
  /// In en, this message translates to:
  /// **'Choose a time in the future.'**
  String get chooseFutureTime;

  /// No description provided for @statusAvailable.
  ///
  /// In en, this message translates to:
  /// **'available'**
  String get statusAvailable;

  /// No description provided for @statusScheduled.
  ///
  /// In en, this message translates to:
  /// **'scheduled'**
  String get statusScheduled;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'cancelled'**
  String get statusCancelled;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageStaysOnDevice.
  ///
  /// In en, this message translates to:
  /// **'The language stays on this device.'**
  String get languageStaysOnDevice;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch the app between light and dark'**
  String get darkModeSubtitle;

  /// No description provided for @appColor.
  ///
  /// In en, this message translates to:
  /// **'App color'**
  String get appColor;

  /// No description provided for @colorStaysOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Color and dark mode stay on this device.'**
  String get colorStaysOnDevice;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get fontSize;

  /// No description provided for @fontSizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get fontSizeSmall;

  /// No description provided for @fontSizeNormal.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get fontSizeNormal;

  /// No description provided for @fontSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get fontSizeLarge;

  /// No description provided for @fontSizeExtra.
  ///
  /// In en, this message translates to:
  /// **'Extra large'**
  String get fontSizeExtra;

  /// No description provided for @fontSizeStaysOnDevice.
  ///
  /// In en, this message translates to:
  /// **'The font size stays on this device and applies to every page.'**
  String get fontSizeStaysOnDevice;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @passwordSection.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordSection;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload photo'**
  String get uploadPhoto;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get saveProfile;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved.'**
  String get profileSaved;

  /// No description provided for @allergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergies;

  /// No description provided for @addAllergyHint.
  ///
  /// In en, this message translates to:
  /// **'Add an allergy'**
  String get addAllergyHint;

  /// No description provided for @addAllergy.
  ///
  /// In en, this message translates to:
  /// **'Add allergy'**
  String get addAllergy;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @updating.
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get updating;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password.'**
  String get enterCurrentPassword;

  /// No description provided for @differentPassword.
  ///
  /// In en, this message translates to:
  /// **'Choose a different password.'**
  String get differentPassword;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @videoNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Video visits are not available yet'**
  String get videoNotAvailable;

  /// No description provided for @videoNotAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'You can book a time now. The video call will open here when it is ready.'**
  String get videoNotAvailableMessage;

  /// No description provided for @teal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get teal;

  /// No description provided for @blue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get blue;

  /// No description provided for @green.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get green;

  /// No description provided for @purple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get purple;

  /// No description provided for @orange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get orange;

  /// No description provided for @typeGeneralPractice.
  ///
  /// In en, this message translates to:
  /// **'General Practice'**
  String get typeGeneralPractice;

  /// No description provided for @typeFamilyMedicine.
  ///
  /// In en, this message translates to:
  /// **'Family Medicine'**
  String get typeFamilyMedicine;

  /// No description provided for @typeInternalMedicine.
  ///
  /// In en, this message translates to:
  /// **'Internal Medicine'**
  String get typeInternalMedicine;

  /// No description provided for @typePaediatrics.
  ///
  /// In en, this message translates to:
  /// **'Paediatrics'**
  String get typePaediatrics;

  /// No description provided for @typeObstetrics.
  ///
  /// In en, this message translates to:
  /// **'Obstetrics and Gynaecology'**
  String get typeObstetrics;

  /// No description provided for @typeSurgery.
  ///
  /// In en, this message translates to:
  /// **'Surgery'**
  String get typeSurgery;

  /// No description provided for @typeOrthopaedics.
  ///
  /// In en, this message translates to:
  /// **'Orthopaedics'**
  String get typeOrthopaedics;

  /// No description provided for @typeDermatology.
  ///
  /// In en, this message translates to:
  /// **'Dermatology'**
  String get typeDermatology;

  /// No description provided for @typePsychiatry.
  ///
  /// In en, this message translates to:
  /// **'Psychiatry'**
  String get typePsychiatry;

  /// No description provided for @typeOphthalmology.
  ///
  /// In en, this message translates to:
  /// **'Ophthalmology'**
  String get typeOphthalmology;

  /// No description provided for @typeOtorhinolaryngology.
  ///
  /// In en, this message translates to:
  /// **'Otorhinolaryngology'**
  String get typeOtorhinolaryngology;

  /// No description provided for @typeCardiology.
  ///
  /// In en, this message translates to:
  /// **'Cardiology'**
  String get typeCardiology;

  /// No description provided for @msgUsernameOrPassword.
  ///
  /// In en, this message translates to:
  /// **'Username or password is incorrect.'**
  String get msgUsernameOrPassword;

  /// No description provided for @msgCannotReach.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the service. Check your connection and try again.'**
  String get msgCannotReach;

  /// No description provided for @msgUsernameUsed.
  ///
  /// In en, this message translates to:
  /// **'That username is already used.'**
  String get msgUsernameUsed;

  /// No description provided for @msgEmailUsed.
  ///
  /// In en, this message translates to:
  /// **'That email is already used.'**
  String get msgEmailUsed;

  /// No description provided for @msgSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Try again.'**
  String get msgSignInFailed;

  /// No description provided for @msgChooseRole.
  ///
  /// In en, this message translates to:
  /// **'Choose patient or doctor.'**
  String get msgChooseRole;

  /// No description provided for @msgCouldNotCreate.
  ///
  /// In en, this message translates to:
  /// **'Could not create the account.'**
  String get msgCouldNotCreate;

  /// No description provided for @msgRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'The request failed. Try again.'**
  String get msgRequestFailed;

  /// No description provided for @msgSignInAgain.
  ///
  /// In en, this message translates to:
  /// **'Sign in again.'**
  String get msgSignInAgain;

  /// No description provided for @msgProfileUnread.
  ///
  /// In en, this message translates to:
  /// **'The profile could not be read.'**
  String get msgProfileUnread;

  /// No description provided for @msgAccountUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The account service is not available. Try again later.'**
  String get msgAccountUnavailable;

  /// No description provided for @msgProfileFailed.
  ///
  /// In en, this message translates to:
  /// **'The profile request failed.'**
  String get msgProfileFailed;

  /// No description provided for @msgPasswordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated.'**
  String get msgPasswordUpdated;

  /// No description provided for @msgCurrentPasswordWrong.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect.'**
  String get msgCurrentPasswordWrong;

  /// No description provided for @msgEnterBothPasswords.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password and a new password.'**
  String get msgEnterBothPasswords;

  /// No description provided for @msgDescriptionLimit.
  ///
  /// In en, this message translates to:
  /// **'Keep the description under 280 characters.'**
  String get msgDescriptionLimit;

  /// No description provided for @msgCouldNotSaveProfile.
  ///
  /// In en, this message translates to:
  /// **'Could not save the profile.'**
  String get msgCouldNotSaveProfile;

  /// No description provided for @msgBadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose a JPEG, PNG, or WebP image under 512 KB.'**
  String get msgBadPhoto;

  /// No description provided for @msgChooseDoctorTypes.
  ///
  /// In en, this message translates to:
  /// **'Choose doctor types from the list.'**
  String get msgChooseDoctorTypes;

  /// No description provided for @msgAllergiesList.
  ///
  /// In en, this message translates to:
  /// **'Enter allergies as a list.'**
  String get msgAllergiesList;

  /// No description provided for @msgAllergyCount.
  ///
  /// In en, this message translates to:
  /// **'Keep the allergy list to 20 items.'**
  String get msgAllergyCount;

  /// No description provided for @msgAllergyName.
  ///
  /// In en, this message translates to:
  /// **'Enter a short allergy name.'**
  String get msgAllergyName;

  /// No description provided for @msgAllergyLength.
  ///
  /// In en, this message translates to:
  /// **'Keep each allergy under 40 characters.'**
  String get msgAllergyLength;

  /// No description provided for @msgAppointmentUnread.
  ///
  /// In en, this message translates to:
  /// **'The appointment list could not be read.'**
  String get msgAppointmentUnread;

  /// No description provided for @msgAppointmentFailed.
  ///
  /// In en, this message translates to:
  /// **'The appointment request failed.'**
  String get msgAppointmentFailed;

  /// No description provided for @msgSlotTaken.
  ///
  /// In en, this message translates to:
  /// **'You already have a slot at that time.'**
  String get msgSlotTaken;

  /// No description provided for @msgOnlyDoctor.
  ///
  /// In en, this message translates to:
  /// **'Only a doctor can add a time slot.'**
  String get msgOnlyDoctor;

  /// No description provided for @msgOnlyPatient.
  ///
  /// In en, this message translates to:
  /// **'Only a patient can book a time slot.'**
  String get msgOnlyPatient;

  /// No description provided for @msgSlotGone.
  ///
  /// In en, this message translates to:
  /// **'That time slot is no longer available.'**
  String get msgSlotGone;

  /// No description provided for @msgAppointmentMissing.
  ///
  /// In en, this message translates to:
  /// **'Appointment not found.'**
  String get msgAppointmentMissing;

  /// No description provided for @msgCannotChange.
  ///
  /// In en, this message translates to:
  /// **'You cannot change this appointment.'**
  String get msgCannotChange;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
