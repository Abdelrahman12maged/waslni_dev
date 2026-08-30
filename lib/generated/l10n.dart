// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Mobile Number`
  String get loginmobiletitle {
    return Intl.message(
      'Mobile Number',
      name: 'loginmobiletitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Mobile Number`
  String get loginmobilelabel {
    return Intl.message(
      'Enter Your Mobile Number',
      name: 'loginmobilelabel',
      desc: '',
      args: [],
    );
  }

  /// `password`
  String get loginpasswordtitle {
    return Intl.message(
      'password',
      name: 'loginpasswordtitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your password`
  String get loginpasswordlabel {
    return Intl.message(
      'Enter Your password',
      name: 'loginpasswordlabel',
      desc: '',
      args: [],
    );
  }

  /// `Remember Me`
  String get loginrememberme {
    return Intl.message(
      'Remember Me',
      name: 'loginrememberme',
      desc: '',
      args: [],
    );
  }

  /// `Forget Password?`
  String get loginforgetpassword {
    return Intl.message(
      'Forget Password?',
      name: 'loginforgetpassword',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get loginbutton {
    return Intl.message('Login', name: 'loginbutton', desc: '', args: []);
  }

  /// `Don't Have An Account?`
  String get logindonthaveaccount {
    return Intl.message(
      'Don\'t Have An Account?',
      name: 'logindonthaveaccount',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get loginsignupbutton {
    return Intl.message(
      'Sign Up',
      name: 'loginsignupbutton',
      desc: '',
      args: [],
    );
  }

  /// `Welcome, You Have To Choose The Type Of Account`
  String get logindialogwelcome {
    return Intl.message(
      'Welcome, You Have To Choose The Type Of Account',
      name: 'logindialogwelcome',
      desc: '',
      args: [],
    );
  }

  /// `Driver`
  String get logindialogdriver {
    return Intl.message(
      'Driver',
      name: 'logindialogdriver',
      desc: '',
      args: [],
    );
  }

  /// `Passenger`
  String get logindialogpassenger {
    return Intl.message(
      'Passenger',
      name: 'logindialogpassenger',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get logindialogbutton {
    return Intl.message(
      'Continue',
      name: 'logindialogbutton',
      desc: '',
      args: [],
    );
  }

  /// `Welcome, You Have To Choose The Gender`
  String get logingenderdialogwelcome {
    return Intl.message(
      'Welcome, You Have To Choose The Gender',
      name: 'logingenderdialogwelcome',
      desc: '',
      args: [],
    );
  }

  /// `Male`
  String get logingenderdialogmale {
    return Intl.message(
      'Male',
      name: 'logingenderdialogmale',
      desc: '',
      args: [],
    );
  }

  /// `Female`
  String get logingenderdialogfemale {
    return Intl.message(
      'Female',
      name: 'logingenderdialogfemale',
      desc: '',
      args: [],
    );
  }

  /// `Trip completed successfully`
  String get tripEndedSuccessfully {
    return Intl.message(
      'Trip completed successfully',
      name: 'tripEndedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Shared trip ended successfully`
  String get sharedTripEndedSuccessfully {
    return Intl.message(
      'Shared trip ended successfully',
      name: 'sharedTripEndedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Passenger`
  String get passenger {
    return Intl.message('Passenger', name: 'passenger', desc: '', args: []);
  }

  /// `Passengers`
  String get passengers {
    return Intl.message('Passengers', name: 'passengers', desc: '', args: []);
  }

  /// `Track Shared Trip`
  String get trackSharedTrip {
    return Intl.message(
      'Track Shared Trip',
      name: 'trackSharedTrip',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get userlayouthometitle {
    return Intl.message(
      'Home',
      name: 'userlayouthometitle',
      desc: '',
      args: [],
    );
  }

  /// `Start New Trip`
  String get userlayouthomestarttrip {
    return Intl.message(
      'Start New Trip',
      name: 'userlayouthomestarttrip',
      desc: '',
      args: [],
    );
  }

  /// `Private Trip`
  String get userlayouthomeprivatetrip {
    return Intl.message(
      'Private Trip',
      name: 'userlayouthomeprivatetrip',
      desc: '',
      args: [],
    );
  }

  /// `Shared Trip`
  String get userlayouthomesharedtrip {
    return Intl.message(
      'Shared Trip',
      name: 'userlayouthomesharedtrip',
      desc: '',
      args: [],
    );
  }

  /// `Scheduled Trip`
  String get userlayouthomesceduledtrip {
    return Intl.message(
      'Scheduled Trip',
      name: 'userlayouthomesceduledtrip',
      desc: '',
      args: [],
    );
  }

  /// `Trips Near Your Location`
  String get userlayouthometripsnearyourlocation {
    return Intl.message(
      'Trips Near Your Location',
      name: 'userlayouthometripsnearyourlocation',
      desc: '',
      args: [],
    );
  }

  /// `View All`
  String get userlayouthomeviewall {
    return Intl.message(
      'View All',
      name: 'userlayouthomeviewall',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get userlayoutsettingstitle {
    return Intl.message(
      'Settings',
      name: 'userlayoutsettingstitle',
      desc: '',
      args: [],
    );
  }

  /// `My Profile`
  String get userlayoutsettingsmyprofile {
    return Intl.message(
      'My Profile',
      name: 'userlayoutsettingsmyprofile',
      desc: '',
      args: [],
    );
  }

  /// `Saved Locations`
  String get userlayoutsettingssavelocations {
    return Intl.message(
      'Saved Locations',
      name: 'userlayoutsettingssavelocations',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get userlayoutsettingsLanguage {
    return Intl.message(
      'Language',
      name: 'userlayoutsettingsLanguage',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get userlayoutsettingsLanguageenglish {
    return Intl.message(
      'English',
      name: 'userlayoutsettingsLanguageenglish',
      desc: '',
      args: [],
    );
  }

  /// `Arabic`
  String get userlayoutsettingsLanguagearabic {
    return Intl.message(
      'Arabic',
      name: 'userlayoutsettingsLanguagearabic',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get userlayoutsettingspolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'userlayoutsettingspolicy',
      desc: '',
      args: [],
    );
  }

  /// `Terms & Conditions`
  String get userlayoutsettingsterms {
    return Intl.message(
      'Terms & Conditions',
      name: 'userlayoutsettingsterms',
      desc: '',
      args: [],
    );
  }

  /// `Contact Us`
  String get userlayoutsettingscontactus {
    return Intl.message(
      'Contact Us',
      name: 'userlayoutsettingscontactus',
      desc: '',
      args: [],
    );
  }

  /// `Delete Account`
  String get userlayoutsettingsdeleteaccount {
    return Intl.message(
      'Delete Account',
      name: 'userlayoutsettingsdeleteaccount',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get userlayoutsettingslogout {
    return Intl.message(
      'Logout',
      name: 'userlayoutsettingslogout',
      desc: '',
      args: [],
    );
  }

  /// `Full Name`
  String get usersignupnametitle {
    return Intl.message(
      'Full Name',
      name: 'usersignupnametitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Name`
  String get usersignupnamelabel {
    return Intl.message(
      'Enter Your Name',
      name: 'usersignupnamelabel',
      desc: '',
      args: [],
    );
  }

  /// `Mobile Number`
  String get usersignupmobiletitle {
    return Intl.message(
      'Mobile Number',
      name: 'usersignupmobiletitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Mobile Number`
  String get usersignupmobilelabel {
    return Intl.message(
      'Enter Your Mobile Number',
      name: 'usersignupmobilelabel',
      desc: '',
      args: [],
    );
  }

  /// `password`
  String get usersignuppasswordtitle {
    return Intl.message(
      'password',
      name: 'usersignuppasswordtitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your password`
  String get usersignuppasswordlabel {
    return Intl.message(
      'Enter Your password',
      name: 'usersignuppasswordlabel',
      desc: '',
      args: [],
    );
  }

  /// `I Have Agree`
  String get usersignupagree {
    return Intl.message(
      'I Have Agree',
      name: 'usersignupagree',
      desc: '',
      args: [],
    );
  }

  /// `Terms And Conditions`
  String get usersignupterms {
    return Intl.message(
      'Terms And Conditions',
      name: 'usersignupterms',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get usersignupbutton {
    return Intl.message(
      'Sign Up',
      name: 'usersignupbutton',
      desc: '',
      args: [],
    );
  }

  /// `Do You Have An Account?`
  String get usersignuphaveaccount {
    return Intl.message(
      'Do You Have An Account?',
      name: 'usersignuphaveaccount',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get usersignuploginbutton {
    return Intl.message(
      'Login',
      name: 'usersignuploginbutton',
      desc: '',
      args: [],
    );
  }

  /// `From`
  String get chatFrom {
    return Intl.message('From', name: 'chatFrom', desc: '', args: []);
  }

  /// `To`
  String get chatTo {
    return Intl.message('To', name: 'chatTo', desc: '', args: []);
  }

  /// `Time`
  String get chatTime {
    return Intl.message('Time', name: 'chatTime', desc: '', args: []);
  }

  /// `Agreed Price`
  String get chatAgreedPrice {
    return Intl.message(
      'Agreed Price',
      name: 'chatAgreedPrice',
      desc: '',
      args: [],
    );
  }

  /// `Driver`
  String get chatDriver {
    return Intl.message('Driver', name: 'chatDriver', desc: '', args: []);
  }

  /// `Phone`
  String get chatPhone {
    return Intl.message('Phone', name: 'chatPhone', desc: '', args: []);
  }

  /// `Online now`
  String get chatOnlineNow {
    return Intl.message(
      'Online now',
      name: 'chatOnlineNow',
      desc: '',
      args: [],
    );
  }

  /// `✅ Driver offer accepted: {name}\nAgreed price: {price} JOD`
  String chatOfferAcceptedMsg(Object name, Object price) {
    return Intl.message(
      '✅ Driver offer accepted: $name\nAgreed price: $price JOD',
      name: 'chatOfferAcceptedMsg',
      desc: '',
      args: [name, price],
    );
  }

  /// `Type a message...`
  String get chatTypeMessage {
    return Intl.message(
      'Type a message...',
      name: 'chatTypeMessage',
      desc: '',
      args: [],
    );
  }

  /// `Counter Offer`
  String get chatCounterOffer {
    return Intl.message(
      'Counter Offer',
      name: 'chatCounterOffer',
      desc: '',
      args: [],
    );
  }

  /// `Offered price: {price} JOD`
  String chatOfferedPrice(Object price) {
    return Intl.message(
      'Offered price: $price JOD',
      name: 'chatOfferedPrice',
      desc: '',
      args: [price],
    );
  }

  /// `Send Offer`
  String get chatSendOffer {
    return Intl.message(
      'Send Offer',
      name: 'chatSendOffer',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid price`
  String get chatEnterValidPrice {
    return Intl.message(
      'Please enter a valid price',
      name: 'chatEnterValidPrice',
      desc: '',
      args: [],
    );
  }

  /// `Your offer of {price} JOD has been sent`
  String chatOfferSentMsg(Object price) {
    return Intl.message(
      'Your offer of $price JOD has been sent',
      name: 'chatOfferSentMsg',
      desc: '',
      args: [price],
    );
  }

  /// `Your Private Trip`
  String get yourPrivateTrip {
    return Intl.message(
      'Your Private Trip',
      name: 'yourPrivateTrip',
      desc: '',
      args: [],
    );
  }

  /// `Open`
  String get openTrip {
    return Intl.message('Open', name: 'openTrip', desc: '', args: []);
  }

  /// `Updates every 10 seconds`
  String get updatesEvery10Sec {
    return Intl.message(
      'Updates every 10 seconds',
      name: 'updatesEvery10Sec',
      desc: '',
      args: [],
    );
  }

  /// `Offers ({count})`
  String offersCount(Object count) {
    return Intl.message(
      'Offers ($count)',
      name: 'offersCount',
      desc: '',
      args: [count],
    );
  }

  /// `Counter offer sent`
  String get counterOfferSent {
    return Intl.message(
      'Counter offer sent',
      name: 'counterOfferSent',
      desc: '',
      args: [],
    );
  }

  /// `My Trips`
  String get myTrips {
    return Intl.message('My Trips', name: 'myTrips', desc: '', args: []);
  }

  /// `New Trip`
  String get newTrip {
    return Intl.message('New Trip', name: 'newTrip', desc: '', args: []);
  }

  /// `Current`
  String get currentTrips {
    return Intl.message('Current', name: 'currentTrips', desc: '', args: []);
  }

  /// `Completed`
  String get completedTrips {
    return Intl.message(
      'Completed',
      name: 'completedTrips',
      desc: '',
      args: [],
    );
  }

  /// `Canceled`
  String get canceledTrips {
    return Intl.message('Canceled', name: 'canceledTrips', desc: '', args: []);
  }

  /// `No Trips Found`
  String get noTrips {
    return Intl.message('No Trips Found', name: 'noTrips', desc: '', args: []);
  }

  /// `Confirm Start Location`
  String get confirmStartLocation {
    return Intl.message(
      'Confirm Start Location',
      name: 'confirmStartLocation',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Destination`
  String get confirmDestination {
    return Intl.message(
      'Confirm Destination',
      name: 'confirmDestination',
      desc: '',
      args: [],
    );
  }

  /// `Select Start Location`
  String get selectStartLocation {
    return Intl.message(
      'Select Start Location',
      name: 'selectStartLocation',
      desc: '',
      args: [],
    );
  }

  /// `Select Destination`
  String get selectDestination {
    return Intl.message(
      'Select Destination',
      name: 'selectDestination',
      desc: '',
      args: [],
    );
  }

  /// `Start Location`
  String get startLocation {
    return Intl.message(
      'Start Location',
      name: 'startLocation',
      desc: '',
      args: [],
    );
  }

  /// `Destination`
  String get destination {
    return Intl.message('Destination', name: 'destination', desc: '', args: []);
  }

  /// `Number of Seats`
  String get numberOfSeats {
    return Intl.message(
      'Number of Seats',
      name: 'numberOfSeats',
      desc: '',
      args: [],
    );
  }

  /// `Gender Preference`
  String get genderPreference {
    return Intl.message(
      'Gender Preference',
      name: 'genderPreference',
      desc: '',
      args: [],
    );
  }

  /// `Everyone`
  String get everyone {
    return Intl.message('Everyone', name: 'everyone', desc: '', args: []);
  }

  /// `Males`
  String get males {
    return Intl.message('Males', name: 'males', desc: '', args: []);
  }

  /// `Females`
  String get females {
    return Intl.message('Females', name: 'females', desc: '', args: []);
  }

  /// `Notes (Optional)`
  String get notesOptional {
    return Intl.message(
      'Notes (Optional)',
      name: 'notesOptional',
      desc: '',
      args: [],
    );
  }

  /// `Create Trip`
  String get createTripButton {
    return Intl.message(
      'Create Trip',
      name: 'createTripButton',
      desc: '',
      args: [],
    );
  }

  /// `Please select start and destination locations`
  String get requiredLocations {
    return Intl.message(
      'Please select start and destination locations',
      name: 'requiredLocations',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to cancel this trip?`
  String get cancelTripConfirm {
    return Intl.message(
      'Are you sure you want to cancel this trip?',
      name: 'cancelTripConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Dismiss`
  String get dismiss {
    return Intl.message('Dismiss', name: 'dismiss', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Ongoing Trip`
  String get ongoingTrip {
    return Intl.message(
      'Ongoing Trip',
      name: 'ongoingTrip',
      desc: '',
      args: [],
    );
  }

  /// `Complete Trip`
  String get completeTrip {
    return Intl.message(
      'Complete Trip',
      name: 'completeTrip',
      desc: '',
      args: [],
    );
  }

  /// `Chat`
  String get chat {
    return Intl.message('Chat', name: 'chat', desc: '', args: []);
  }

  /// `No offers yet`
  String get noOffersYet {
    return Intl.message(
      'No offers yet',
      name: 'noOffersYet',
      desc: '',
      args: [],
    );
  }

  /// `Drivers will contact you soon`
  String get offersWillArriveSoon {
    return Intl.message(
      'Drivers will contact you soon',
      name: 'offersWillArriveSoon',
      desc: '',
      args: [],
    );
  }

  /// `Seats`
  String get seats {
    return Intl.message('Seats', name: 'seats', desc: '', args: []);
  }

  /// `Your Current Trip`
  String get currentOngoingTrip {
    return Intl.message(
      'Your Current Trip',
      name: 'currentOngoingTrip',
      desc: '',
      args: [],
    );
  }

  /// `Open`
  String get statusOpen {
    return Intl.message('Open', name: 'statusOpen', desc: '', args: []);
  }

  /// `Accepted`
  String get statusAccepted {
    return Intl.message('Accepted', name: 'statusAccepted', desc: '', args: []);
  }

  /// `Completed`
  String get statusCompleted {
    return Intl.message(
      'Completed',
      name: 'statusCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Suspended`
  String get statusSuspended {
    return Intl.message(
      'Suspended',
      name: 'statusSuspended',
      desc: '',
      args: [],
    );
  }

  /// `Canceled`
  String get statusCanceled {
    return Intl.message('Canceled', name: 'statusCanceled', desc: '', args: []);
  }

  /// `Closed`
  String get statusClosed {
    return Intl.message('Closed', name: 'statusClosed', desc: '', args: []);
  }

  /// `Pending`
  String get offerStatusPending {
    return Intl.message(
      'Pending',
      name: 'offerStatusPending',
      desc: '',
      args: [],
    );
  }

  /// `Accepted`
  String get offerStatusAccepted {
    return Intl.message(
      'Accepted',
      name: 'offerStatusAccepted',
      desc: '',
      args: [],
    );
  }

  /// `Rejected`
  String get offerStatusRejected {
    return Intl.message(
      'Rejected',
      name: 'offerStatusRejected',
      desc: '',
      args: [],
    );
  }

  /// `Reject`
  String get reject {
    return Intl.message('Reject', name: 'reject', desc: '', args: []);
  }

  /// `Accept`
  String get accept {
    return Intl.message('Accept', name: 'accept', desc: '', args: []);
  }

  /// `Proposed Price`
  String get proposedPrice {
    return Intl.message(
      'Proposed Price',
      name: 'proposedPrice',
      desc: '',
      args: [],
    );
  }

  /// `Please wait for user approval`
  String get pleaseWaitForUserApproval {
    return Intl.message(
      'Please wait for user approval',
      name: 'pleaseWaitForUserApproval',
      desc: '',
      args: [],
    );
  }

  /// `Price accepted`
  String get priceAccepted {
    return Intl.message(
      'Price accepted',
      name: 'priceAccepted',
      desc: '',
      args: [],
    );
  }

  /// `Attach Photo`
  String get attachPhoto {
    return Intl.message(
      'Attach Photo',
      name: 'attachPhoto',
      desc: '',
      args: [],
    );
  }

  /// `Please wait for driver`
  String get pleaseWaitForDriver {
    return Intl.message(
      'Please wait for driver',
      name: 'pleaseWaitForDriver',
      desc: '',
      args: [],
    );
  }

  /// `Type Of Car:`
  String get typeOfCar {
    return Intl.message('Type Of Car:', name: 'typeOfCar', desc: '', args: []);
  }

  /// `Model Of Car:`
  String get modelOfCar {
    return Intl.message(
      'Model Of Car:',
      name: 'modelOfCar',
      desc: '',
      args: [],
    );
  }

  /// `Plate Number`
  String get plateNumber {
    return Intl.message(
      'Plate Number',
      name: 'plateNumber',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Car Type`
  String get enterCarType {
    return Intl.message(
      'Enter Your Car Type',
      name: 'enterCarType',
      desc: '',
      args: [],
    );
  }

  /// `Enter Number Of Seats`
  String get enterNumberOfSeats {
    return Intl.message(
      'Enter Number Of Seats',
      name: 'enterNumberOfSeats',
      desc: '',
      args: [],
    );
  }

  /// `Number Of Seats Can't Be Empty!!`
  String get numberOfSeatsCantBeEmpty {
    return Intl.message(
      'Number Of Seats Can\'t Be Empty!!',
      name: 'numberOfSeatsCantBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Car Model`
  String get enterCarModel {
    return Intl.message(
      'Enter Your Car Model',
      name: 'enterCarModel',
      desc: '',
      args: [],
    );
  }

  /// `Car Model Can't Be Empty!!`
  String get carModelCantBeEmpty {
    return Intl.message(
      'Car Model Can\'t Be Empty!!',
      name: 'carModelCantBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Car Model Can't Be Less Than 2 Characters`
  String get carModelCantBeLessThan2Char {
    return Intl.message(
      'Car Model Can\'t Be Less Than 2 Characters',
      name: 'carModelCantBeLessThan2Char',
      desc: '',
      args: [],
    );
  }

  /// `Enter Plate Number`
  String get enterPlateNumber {
    return Intl.message(
      'Enter Plate Number',
      name: 'enterPlateNumber',
      desc: '',
      args: [],
    );
  }

  /// `Plate Number Can't Be Empty!!`
  String get plateNumberCantBeEmpty {
    return Intl.message(
      'Plate Number Can\'t Be Empty!!',
      name: 'plateNumberCantBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Driving License`
  String get drivingLicense {
    return Intl.message(
      'Driving License',
      name: 'drivingLicense',
      desc: '',
      args: [],
    );
  }

  /// `The Car From Inside`
  String get carInterior {
    return Intl.message(
      'The Car From Inside',
      name: 'carInterior',
      desc: '',
      args: [],
    );
  }

  /// `The Car From Outside`
  String get carExterior {
    return Intl.message(
      'The Car From Outside',
      name: 'carExterior',
      desc: '',
      args: [],
    );
  }

  /// `License Image Can't Be Empty`
  String get licenseImageCantBeEmpty {
    return Intl.message(
      'License Image Can\'t Be Empty',
      name: 'licenseImageCantBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Car From Inside Image Can't Be Empty`
  String get carInsideImageCantBeEmpty {
    return Intl.message(
      'Car From Inside Image Can\'t Be Empty',
      name: 'carInsideImageCantBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Car From Outside Image Can't Be Empty`
  String get carOutsideImageCantBeEmpty {
    return Intl.message(
      'Car From Outside Image Can\'t Be Empty',
      name: 'carOutsideImageCantBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Forget Password`
  String get forgetPassword {
    return Intl.message(
      'Forget Password',
      name: 'forgetPassword',
      desc: '',
      args: [],
    );
  }

  /// `Enter The Mobile Number, To Be Able To Enter The Application`
  String get enterTheMobileNumberForAccess {
    return Intl.message(
      'Enter The Mobile Number, To Be Able To Enter The Application',
      name: 'enterTheMobileNumberForAccess',
      desc: '',
      args: [],
    );
  }

  /// `Mobile Number`
  String get mobileNumber {
    return Intl.message(
      'Mobile Number',
      name: 'mobileNumber',
      desc: '',
      args: [],
    );
  }

  /// `Your Mobile Number Can't Be Empty!!`
  String get yourMobileNumberCantBeEmpty {
    return Intl.message(
      'Your Mobile Number Can\'t Be Empty!!',
      name: 'yourMobileNumberCantBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get send {
    return Intl.message('Send', name: 'send', desc: '', args: []);
  }

  /// `Password Can't Be Empty`
  String get passwordCantBeEmpty {
    return Intl.message(
      'Password Can\'t Be Empty',
      name: 'passwordCantBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Account Confirmation`
  String get accountConfirmation {
    return Intl.message(
      'Account Confirmation',
      name: 'accountConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Enter The Code Sent To The Mobile Number`
  String get enterCodeSentToMobile {
    return Intl.message(
      'Enter The Code Sent To The Mobile Number',
      name: 'enterCodeSentToMobile',
      desc: '',
      args: [],
    );
  }

  /// `New Password`
  String get newPassword {
    return Intl.message(
      'New Password',
      name: 'newPassword',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your New Password`
  String get enterNewPassword {
    return Intl.message(
      'Enter Your New Password',
      name: 'enterNewPassword',
      desc: '',
      args: [],
    );
  }

  /// `Your Password Can't Be Empty!!`
  String get yourPasswordCantBeEmpty {
    return Intl.message(
      'Your Password Can\'t Be Empty!!',
      name: 'yourPasswordCantBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Your Password Should Be At Least 6 Characters`
  String get passwordShouldBe6Chars {
    return Intl.message(
      'Your Password Should Be At Least 6 Characters',
      name: 'passwordShouldBe6Chars',
      desc: '',
      args: [],
    );
  }

  /// `Your Password Should Contain At Least 1 Capital Character`
  String get passwordShouldContainCapital {
    return Intl.message(
      'Your Password Should Contain At Least 1 Capital Character',
      name: 'passwordShouldContainCapital',
      desc: '',
      args: [],
    );
  }

  /// `Your Password Should Contain At Least 1 Small Character`
  String get passwordShouldContainSmall {
    return Intl.message(
      'Your Password Should Contain At Least 1 Small Character',
      name: 'passwordShouldContainSmall',
      desc: '',
      args: [],
    );
  }

  /// `Your Password Should Contain At Least 1 Number`
  String get passwordShouldContainNumber {
    return Intl.message(
      'Your Password Should Contain At Least 1 Number',
      name: 'passwordShouldContainNumber',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get confirmPassword {
    return Intl.message(
      'Confirm Password',
      name: 'confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Password Confirm`
  String get EnterYourPasswordConfirm {
    return Intl.message(
      'Enter Your Password Confirm',
      name: 'EnterYourPasswordConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Your Passwords Must Be Matched`
  String get passwordsMustMatch {
    return Intl.message(
      'Your Passwords Must Be Matched',
      name: 'passwordsMustMatch',
      desc: '',
      args: [],
    );
  }

  /// `done`
  String get done {
    return Intl.message('done', name: 'done', desc: '', args: []);
  }

  /// `resend code within`
  String get resendCodeWithin {
    return Intl.message(
      'resend code within',
      name: 'resendCodeWithin',
      desc: '',
      args: [],
    );
  }

  /// `Full Name`
  String get fullName {
    return Intl.message('Full Name', name: 'fullName', desc: '', args: []);
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Enter Your Name`
  String get enterYourName {
    return Intl.message(
      'Enter Your Name',
      name: 'enterYourName',
      desc: '',
      args: [],
    );
  }

  /// `Welcome, Please Choose The Appropriate Language`
  String get welcomeChooseLanguage {
    return Intl.message(
      'Welcome, Please Choose The Appropriate Language',
      name: 'welcomeChooseLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to Car App`
  String get welcomeToCarApp {
    return Intl.message(
      'Welcome to Car App',
      name: 'welcomeToCarApp',
      desc: '',
      args: [],
    );
  }

  /// `Simplifying your digital experience with seamless integration and powerful tools at your fingertips.`
  String get introMessage {
    return Intl.message(
      'Simplifying your digital experience with seamless integration and powerful tools at your fingertips.',
      name: 'introMessage',
      desc: '',
      args: [],
    );
  }

  /// `Your Journey Starts Here`
  String get journeyStartsHere {
    return Intl.message(
      'Your Journey Starts Here',
      name: 'journeyStartsHere',
      desc: '',
      args: [],
    );
  }

  /// `Unlock endless possibilities and innovative solutions designed to make life easier, smarter, and more connected.`
  String get unlockPossibilities {
    return Intl.message(
      'Unlock endless possibilities and innovative solutions designed to make life easier, smarter, and more connected.',
      name: 'unlockPossibilities',
      desc: '',
      args: [],
    );
  }

  /// `Experience the Future`
  String get experienceFuture {
    return Intl.message(
      'Experience the Future',
      name: 'experienceFuture',
      desc: '',
      args: [],
    );
  }

  /// `Join us as we bring you the latest in technology, designed to empower and inspire your day-to-day.`
  String get joinInnovation {
    return Intl.message(
      'Join us as we bring you the latest in technology, designed to empower and inspire your day-to-day.',
      name: 'joinInnovation',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get skip {
    return Intl.message('Skip', name: 'skip', desc: '', args: []);
  }

  /// `New Trips`
  String get newTrips {
    return Intl.message('New Trips', name: 'newTrips', desc: '', args: []);
  }

  /// `Welcome, please choose trip type`
  String get create_new_dialog_welcome {
    return Intl.message(
      'Welcome, please choose trip type',
      name: 'create_new_dialog_welcome',
      desc: '',
      args: [],
    );
  }

  /// `Current`
  String get currentW {
    return Intl.message('Current', name: 'currentW', desc: '', args: []);
  }

  /// `Completed`
  String get completed {
    return Intl.message('Completed', name: 'completed', desc: '', args: []);
  }

  /// `Canceled`
  String get canceled {
    return Intl.message('Canceled', name: 'canceled', desc: '', args: []);
  }

  /// `Out At: `
  String get outAt {
    return Intl.message('Out At: ', name: 'outAt', desc: '', args: []);
  }

  /// `No Passengers`
  String get noPassengers {
    return Intl.message(
      'No Passengers',
      name: 'noPassengers',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get settingsLanguage {
    return Intl.message(
      'Language',
      name: 'settingsLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Shared Trips`
  String get sharedTrip {
    return Intl.message('Shared Trips', name: 'sharedTrip', desc: '', args: []);
  }

  /// `Private Trips`
  String get privateTrip {
    return Intl.message(
      'Private Trips',
      name: 'privateTrip',
      desc: '',
      args: [],
    );
  }

  /// `No Drivers Yet`
  String get noDriversYet {
    return Intl.message(
      'No Drivers Yet',
      name: 'noDriversYet',
      desc: '',
      args: [],
    );
  }

  /// `Not Accepted By Driver Yet`
  String get notAcceptedByDriver {
    return Intl.message(
      'Not Accepted By Driver Yet',
      name: 'notAcceptedByDriver',
      desc: '',
      args: [],
    );
  }

  /// `Suspended Trips`
  String get suspendedTrips {
    return Intl.message(
      'Suspended Trips',
      name: 'suspendedTrips',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `Ready`
  String get ready {
    return Intl.message('Ready', name: 'ready', desc: '', args: []);
  }

  /// `Pending`
  String get pending {
    return Intl.message('Pending', name: 'pending', desc: '', args: []);
  }

  /// `On My Way`
  String get onMyWay {
    return Intl.message('On My Way', name: 'onMyWay', desc: '', args: []);
  }

  /// `Start`
  String get start {
    return Intl.message('Start', name: 'start', desc: '', args: []);
  }

  /// `Out Of Range!`
  String get outOfRange {
    return Intl.message(
      'Out Of Range!',
      name: 'outOfRange',
      desc: '',
      args: [],
    );
  }

  /// `End Trip`
  String get endTrip {
    return Intl.message('End Trip', name: 'endTrip', desc: '', args: []);
  }

  /// `Not All Passengers Arrived!`
  String get notAllPassengersArrived {
    return Intl.message(
      'Not All Passengers Arrived!',
      name: 'notAllPassengersArrived',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get continueAction {
    return Intl.message('Continue', name: 'continueAction', desc: '', args: []);
  }

  /// `Arrived Customer`
  String get arrivedCustomer {
    return Intl.message(
      'Arrived Customer',
      name: 'arrivedCustomer',
      desc: '',
      args: [],
    );
  }

  /// `No Notifications Yet!`
  String get noNotificationsYet {
    return Intl.message(
      'No Notifications Yet!',
      name: 'noNotificationsYet',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get Loading {
    return Intl.message('Loading...', name: 'Loading', desc: '', args: []);
  }

  /// `Trip datetime`
  String get tripDatetime {
    return Intl.message(
      'Trip datetime',
      name: 'tripDatetime',
      desc: '',
      args: [],
    );
  }

  /// `Starting Location`
  String get startingLocation {
    return Intl.message(
      'Starting Location',
      name: 'startingLocation',
      desc: '',
      args: [],
    );
  }

  /// `Destination Location`
  String get destinationLocation {
    return Intl.message(
      'Destination Location',
      name: 'destinationLocation',
      desc: '',
      args: [],
    );
  }

  /// `Select Time`
  String get selectTime {
    return Intl.message('Select Time', name: 'selectTime', desc: '', args: []);
  }

  /// `Select Date`
  String get selectDate {
    return Intl.message('Select Date', name: 'selectDate', desc: '', args: []);
  }

  /// `No Preference`
  String get noPreference {
    return Intl.message(
      'No Preference',
      name: 'noPreference',
      desc: '',
      args: [],
    );
  }

  /// `Add Shared Trip`
  String get addSharedTrip {
    return Intl.message(
      'Add Shared Trip',
      name: 'addSharedTrip',
      desc: '',
      args: [],
    );
  }

  /// `Female`
  String get female {
    return Intl.message('Female', name: 'female', desc: '', args: []);
  }

  /// `Male`
  String get male {
    return Intl.message('Male', name: 'male', desc: '', args: []);
  }

  /// `Select Trip Date`
  String get selectTripDate {
    return Intl.message(
      'Select Trip Date',
      name: 'selectTripDate',
      desc: '',
      args: [],
    );
  }

  /// `Add Trip`
  String get addTrip {
    return Intl.message('Add Trip', name: 'addTrip', desc: '', args: []);
  }

  /// `Request Trip Again`
  String get requestTripAgain {
    return Intl.message(
      'Request Trip Again',
      name: 'requestTripAgain',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure?`
  String get areYouSure {
    return Intl.message(
      'Are You Sure?',
      name: 'areYouSure',
      desc: '',
      args: [],
    );
  }

  /// `Total:`
  String get total {
    return Intl.message('Total:', name: 'total', desc: '', args: []);
  }

  /// `Cancel Trip`
  String get cancelTrip {
    return Intl.message('Cancel Trip', name: 'cancelTrip', desc: '', args: []);
  }

  /// `What is the reason for canceling the trip?`
  String get reasonForCanceling {
    return Intl.message(
      'What is the reason for canceling the trip?',
      name: 'reasonForCanceling',
      desc: '',
      args: [],
    );
  }

  /// `Ok`
  String get ok {
    return Intl.message('Ok', name: 'ok', desc: '', args: []);
  }

  /// `Suspended`
  String get suspended {
    return Intl.message('Suspended', name: 'suspended', desc: '', args: []);
  }

  /// `Offers List`
  String get offersList {
    return Intl.message('Offers List', name: 'offersList', desc: '', args: []);
  }

  /// `Offer Status`
  String get offerStatus {
    return Intl.message(
      'Offer Status',
      name: 'offerStatus',
      desc: '',
      args: [],
    );
  }

  /// `Offer Price:`
  String get offerPrice {
    return Intl.message('Offer Price:', name: 'offerPrice', desc: '', args: []);
  }

  /// `Average Price`
  String get averagePrice {
    return Intl.message(
      'Average Price',
      name: 'averagePrice',
      desc: '',
      args: [],
    );
  }

  /// `JOD`
  String get jod {
    return Intl.message('JOD', name: 'jod', desc: '', args: []);
  }

  /// `Please enter a value within the range!`
  String get pleaseEnterValue {
    return Intl.message(
      'Please enter a value within the range!',
      name: 'pleaseEnterValue',
      desc: '',
      args: [],
    );
  }

  /// `Successfully Rated!`
  String get successfullyRated {
    return Intl.message(
      'Successfully Rated!',
      name: 'successfullyRated',
      desc: '',
      args: [],
    );
  }

  /// `Please rate the driver`
  String get pleaseRateDriver {
    return Intl.message(
      'Please rate the driver',
      name: 'pleaseRateDriver',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message('No', name: 'no', desc: '', args: []);
  }

  /// `Yes`
  String get yes {
    return Intl.message('Yes', name: 'yes', desc: '', args: []);
  }

  /// `Total Per Seat:`
  String get totalPerSeat {
    return Intl.message(
      'Total Per Seat:',
      name: 'totalPerSeat',
      desc: '',
      args: [],
    );
  }

  /// `Contact Now`
  String get contactNow {
    return Intl.message('Contact Now', name: 'contactNow', desc: '', args: []);
  }

  /// `Offer Now`
  String get offerNow {
    return Intl.message('Offer Now', name: 'offerNow', desc: '', args: []);
  }

  /// `Driver Details`
  String get driverDetails {
    return Intl.message(
      'Driver Details',
      name: 'driverDetails',
      desc: '',
      args: [],
    );
  }

  /// `Trip Details`
  String get tripDetails {
    return Intl.message(
      'Trip Details',
      name: 'tripDetails',
      desc: '',
      args: [],
    );
  }

  /// `Subscribe Now`
  String get subscribeNow {
    return Intl.message(
      'Subscribe Now',
      name: 'subscribeNow',
      desc: '',
      args: [],
    );
  }

  /// `Search For Trip Near By Your Current Location!`
  String get searchForTrip {
    return Intl.message(
      'Search For Trip Near By Your Current Location!',
      name: 'searchForTrip',
      desc: '',
      args: [],
    );
  }

  /// `No Trips Near By Your Current Location!`
  String get noTripsNearby {
    return Intl.message(
      'No Trips Near By Your Current Location!',
      name: 'noTripsNearby',
      desc: '',
      args: [],
    );
  }

  /// `Add New Trip`
  String get addNewTrip {
    return Intl.message('Add New Trip', name: 'addNewTrip', desc: '', args: []);
  }

  /// `Available`
  String get available {
    return Intl.message('Available', name: 'available', desc: '', args: []);
  }

  /// `Price`
  String get price {
    return Intl.message('Price', name: 'price', desc: '', args: []);
  }

  /// `The Reason May Not Be Convincing And You Will Be Banned`
  String get bannedReasonWarning {
    return Intl.message(
      'The Reason May Not Be Convincing And You Will Be Banned',
      name: 'bannedReasonWarning',
      desc: '',
      args: [],
    );
  }

  /// `What Is The Reason For Canceling The Trip?`
  String get cancelingReasonPrompt {
    return Intl.message(
      'What Is The Reason For Canceling The Trip?',
      name: 'cancelingReasonPrompt',
      desc: '',
      args: [],
    );
  }

  /// `Approved By the driver`
  String get approvedByDriver {
    return Intl.message(
      'Approved By the driver',
      name: 'approvedByDriver',
      desc: '',
      args: [],
    );
  }

  /// `Sorry you can't get a driver`
  String get noDriverFound {
    return Intl.message(
      'Sorry you can\'t get a driver',
      name: 'noDriverFound',
      desc: '',
      args: [],
    );
  }

  /// `Sorry We Can't Find A Deal`
  String get noDealFound {
    return Intl.message(
      'Sorry We Can\'t Find A Deal',
      name: 'noDealFound',
      desc: '',
      args: [],
    );
  }

  /// `This Default Text Is Subject To Change And Modification`
  String get defaultTextChangeable {
    return Intl.message(
      'This Default Text Is Subject To Change And Modification',
      name: 'defaultTextChangeable',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Reason`
  String get enterYourReason {
    return Intl.message(
      'Enter Your Reason',
      name: 'enterYourReason',
      desc: '',
      args: [],
    );
  }

  /// `What Is The Reason For Rejecting The Trip?`
  String get rejectingReasonPrompt {
    return Intl.message(
      'What Is The Reason For Rejecting The Trip?',
      name: 'rejectingReasonPrompt',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Reason (optional)`
  String get optionalReasonPrompt {
    return Intl.message(
      'Enter Your Reason (optional)',
      name: 'optionalReasonPrompt',
      desc: '',
      args: [],
    );
  }

  /// `Successfully Rejected!`
  String get successfullyRejected {
    return Intl.message(
      'Successfully Rejected!',
      name: 'successfullyRejected',
      desc: '',
      args: [],
    );
  }

  /// `The Percentage Of Each New User`
  String get newUserPercentage {
    return Intl.message(
      'The Percentage Of Each New User',
      name: 'newUserPercentage',
      desc: '',
      args: [],
    );
  }

  /// `Enter Destination Location`
  String get enterDestinationLocation {
    return Intl.message(
      'Enter Destination Location',
      name: 'enterDestinationLocation',
      desc: '',
      args: [],
    );
  }

  /// `Enter Starting Location`
  String get enterStartingLocation {
    return Intl.message(
      'Enter Starting Location',
      name: 'enterStartingLocation',
      desc: '',
      args: [],
    );
  }

  /// `Passengers Names`
  String get passengersNames {
    return Intl.message(
      'Passengers Names',
      name: 'passengersNames',
      desc: '',
      args: [],
    );
  }

  /// `Warning`
  String get warning {
    return Intl.message('Warning', name: 'warning', desc: '', args: []);
  }

  /// `Something wrong`
  String get somethingWrong {
    return Intl.message(
      'Something wrong',
      name: 'somethingWrong',
      desc: '',
      args: [],
    );
  }

  /// `Suspended Trip`
  String get suspendedTrip {
    return Intl.message(
      'Suspended Trip',
      name: 'suspendedTrip',
      desc: '',
      args: [],
    );
  }

  /// `4 Seats`
  String get fourSeats {
    return Intl.message('4 Seats', name: 'fourSeats', desc: '', args: []);
  }

  /// `3 Seats`
  String get threeSeats {
    return Intl.message('3 Seats', name: 'threeSeats', desc: '', args: []);
  }

  /// `2 seats`
  String get twoSeats {
    return Intl.message('2 seats', name: 'twoSeats', desc: '', args: []);
  }

  /// `1 Seat`
  String get oneSeat {
    return Intl.message('1 Seat', name: 'oneSeat', desc: '', args: []);
  }

  /// `Search For Chat`
  String get searchForChat {
    return Intl.message(
      'Search For Chat',
      name: 'searchForChat',
      desc: '',
      args: [],
    );
  }

  /// `Your Total Balance:`
  String get yourTotalBalance {
    return Intl.message(
      'Your Total Balance:',
      name: 'yourTotalBalance',
      desc: '',
      args: [],
    );
  }

  /// `Ready To Receive Orders`
  String get readyToReceiveOrders {
    return Intl.message(
      'Ready To Receive Orders',
      name: 'readyToReceiveOrders',
      desc: '',
      args: [],
    );
  }

  /// `The Specified Working Distance:`
  String get specifiedWorkingDistance {
    return Intl.message(
      'The Specified Working Distance:',
      name: 'specifiedWorkingDistance',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
  }

  /// `Contact Us`
  String get contactUs {
    return Intl.message('Contact Us', name: 'contactUs', desc: '', args: []);
  }

  /// `Personal Information`
  String get personalInformation {
    return Intl.message(
      'Personal Information',
      name: 'personalInformation',
      desc: '',
      args: [],
    );
  }

  /// `Work Information`
  String get workInformation {
    return Intl.message(
      'Work Information',
      name: 'workInformation',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Mobile Number`
  String get enterYourMobileNumber {
    return Intl.message(
      'Enter Your Mobile Number',
      name: 'enterYourMobileNumber',
      desc: '',
      args: [],
    );
  }

  /// `Edit Profile`
  String get editProfile {
    return Intl.message(
      'Edit Profile',
      name: 'editProfile',
      desc: '',
      args: [],
    );
  }

  /// `Website`
  String get website {
    return Intl.message('Website', name: 'website', desc: '', args: []);
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Welcome`
  String get welcome {
    return Intl.message('Welcome', name: 'welcome', desc: '', args: []);
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `A New Address Has Been Added Successfully`
  String get addressAddedSuccessfully {
    return Intl.message(
      'A New Address Has Been Added Successfully',
      name: 'addressAddedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `New Address`
  String get NewAddress {
    return Intl.message('New Address', name: 'NewAddress', desc: '', args: []);
  }

  /// `Successfully Sent`
  String get SuccessfullySent {
    return Intl.message(
      'Successfully Sent',
      name: 'SuccessfullySent',
      desc: '',
      args: [],
    );
  }

  /// `No Data`
  String get noData {
    return Intl.message('No Data', name: 'noData', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Add New Location`
  String get addNewLocation {
    return Intl.message(
      'Add New Location',
      name: 'addNewLocation',
      desc: '',
      args: [],
    );
  }

  /// `Type a message`
  String get typeMessage {
    return Intl.message(
      'Type a message',
      name: 'typeMessage',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message('Error', name: 'error', desc: '', args: []);
  }

  /// `Failed to send message. Please try again.`
  String get failedToSendMessage {
    return Intl.message(
      'Failed to send message. Please try again.',
      name: 'failedToSendMessage',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `No Image License Selected`
  String get noImageLicenseSelected {
    return Intl.message(
      'No Image License Selected',
      name: 'noImageLicenseSelected',
      desc: '',
      args: [],
    );
  }

  /// `No Image Inside Selected`
  String get noImageInteriorSelected {
    return Intl.message(
      'No Image Inside Selected',
      name: 'noImageInteriorSelected',
      desc: '',
      args: [],
    );
  }

  /// `No Image Car Outside Selected`
  String get noImageExteriorSelected {
    return Intl.message(
      'No Image Car Outside Selected',
      name: 'noImageExteriorSelected',
      desc: '',
      args: [],
    );
  }

  /// `Updated Successfully`
  String get updatedSuccessfully {
    return Intl.message(
      'Updated Successfully',
      name: 'updatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `To Reject`
  String get toReject {
    return Intl.message('To Reject', name: 'toReject', desc: '', args: []);
  }

  /// `Pricing`
  String get pricing {
    return Intl.message('Pricing', name: 'pricing', desc: '', args: []);
  }

  /// `Successfully Accepted`
  String get successfullyAccepted {
    return Intl.message(
      'Successfully Accepted',
      name: 'successfullyAccepted',
      desc: '',
      args: [],
    );
  }

  /// `Total Until Now:`
  String get totalUntilNow {
    return Intl.message(
      'Total Until Now:',
      name: 'totalUntilNow',
      desc: '',
      args: [],
    );
  }

  /// `Your Number Should Be 10 Digits`
  String get yourNumberShouldBe10Digits {
    return Intl.message(
      'Your Number Should Be 10 Digits',
      name: 'yourNumberShouldBe10Digits',
      desc: '',
      args: [],
    );
  }

  /// `resend code within 00:30`
  String get resendCodeWithin30 {
    return Intl.message(
      'resend code within 00:30',
      name: 'resendCodeWithin30',
      desc: '',
      args: [],
    );
  }

  /// `Your Name Can't Be Empty!!`
  String get nameCantBeEmpty {
    return Intl.message(
      'Your Name Can\'t Be Empty!!',
      name: 'nameCantBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Name Should Be At Least 6 Characters`
  String get nameShouldBe6Chars {
    return Intl.message(
      'Name Should Be At Least 6 Characters',
      name: 'nameShouldBe6Chars',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Password Confirm`
  String get enterPasswordConfirm {
    return Intl.message(
      'Enter Your Password Confirm',
      name: 'enterPasswordConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Your Password Should Be At Least 6 Characters`
  String get passwordShouldBeAtLeast6Chars {
    return Intl.message(
      'Your Password Should Be At Least 6 Characters',
      name: 'passwordShouldBeAtLeast6Chars',
      desc: '',
      args: [],
    );
  }

  /// `Your Password Should Contain At Least 1 Small Character`
  String get passwordShouldContainSmallChar {
    return Intl.message(
      'Your Password Should Contain At Least 1 Small Character',
      name: 'passwordShouldContainSmallChar',
      desc: '',
      args: [],
    );
  }

  /// `I Agree`
  String get iAgree {
    return Intl.message('I Agree', name: 'iAgree', desc: '', args: []);
  }

  /// `Disagree`
  String get disagree {
    return Intl.message('Disagree', name: 'disagree', desc: '', args: []);
  }

  /// `Agree`
  String get agree {
    return Intl.message('Agree', name: 'agree', desc: '', args: []);
  }

  /// `Near by Trips`
  String get nearbyTrips {
    return Intl.message(
      'Near by Trips',
      name: 'nearbyTrips',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get continueTrip {
    return Intl.message('Continue', name: 'continueTrip', desc: '', args: []);
  }

  /// `I'm Close`
  String get iAmClose {
    return Intl.message('I\'m Close', name: 'iAmClose', desc: '', args: []);
  }

  /// `Successfully Canceled!`
  String get successfullyCanceled {
    return Intl.message(
      'Successfully Canceled!',
      name: 'successfullyCanceled',
      desc: '',
      args: [],
    );
  }

  /// `trip Status`
  String get tripStatus {
    return Intl.message('trip Status', name: 'tripStatus', desc: '', args: []);
  }

  /// `Do you want to logout?`
  String get doYouWantToLogout {
    return Intl.message(
      'Do you want to logout?',
      name: 'doYouWantToLogout',
      desc: '',
      args: [],
    );
  }

  /// `( Me )`
  String get me {
    return Intl.message('( Me )', name: 'me', desc: '', args: []);
  }

  /// `Enter Your Password`
  String get enterYourPassword {
    return Intl.message(
      'Enter Your Password',
      name: 'enterYourPassword',
      desc: '',
      args: [],
    );
  }

  /// `Your Name Can't Be Empty!!`
  String get yourNameCantBeEmpty {
    return Intl.message(
      'Your Name Can\'t Be Empty!!',
      name: 'yourNameCantBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Arrived Car`
  String get ArrivedCar {
    return Intl.message('Arrived Car', name: 'ArrivedCar', desc: '', args: []);
  }

  /// `Driver Info`
  String get driverInfo {
    return Intl.message('Driver Info', name: 'driverInfo', desc: '', args: []);
  }

  /// `Driver is on the way`
  String get driverOnTheWay {
    return Intl.message(
      'Driver is on the way',
      name: 'driverOnTheWay',
      desc: '',
      args: [],
    );
  }

  /// `Driver Is Nearby`
  String get driverIsNear {
    return Intl.message(
      'Driver Is Nearby',
      name: 'driverIsNear',
      desc: '',
      args: [],
    );
  }

  /// `Driver Has Arrived`
  String get driverArrived {
    return Intl.message(
      'Driver Has Arrived',
      name: 'driverArrived',
      desc: '',
      args: [],
    );
  }

  /// `Trip In Progress`
  String get tripInProgress {
    return Intl.message(
      'Trip In Progress',
      name: 'tripInProgress',
      desc: '',
      args: [],
    );
  }

  /// `Your driver is heading to your location`
  String get driverComingToPickYouUp {
    return Intl.message(
      'Your driver is heading to your location',
      name: 'driverComingToPickYouUp',
      desc: '',
      args: [],
    );
  }

  /// `Your driver is almost there!`
  String get driverAlmostThere {
    return Intl.message(
      'Your driver is almost there!',
      name: 'driverAlmostThere',
      desc: '',
      args: [],
    );
  }

  /// `Your driver is waiting for you`
  String get driverWaitingForYou {
    return Intl.message(
      'Your driver is waiting for you',
      name: 'driverWaitingForYou',
      desc: '',
      args: [],
    );
  }

  /// `Sit back and enjoy your ride`
  String get enjoyYourTrip {
    return Intl.message(
      'Sit back and enjoy your ride',
      name: 'enjoyYourTrip',
      desc: '',
      args: [],
    );
  }

  /// `Waiting for driver...`
  String get waitingForDriver {
    return Intl.message(
      'Waiting for driver...',
      name: 'waitingForDriver',
      desc: '',
      args: [],
    );
  }

  /// `You're In The Car!`
  String get youAreInTheCar {
    return Intl.message(
      'You\'re In The Car!',
      name: 'youAreInTheCar',
      desc: '',
      args: [],
    );
  }

  /// `On the Way`
  String get onTheWay {
    return Intl.message('On the Way', name: 'onTheWay', desc: '', args: []);
  }

  /// `Nearby`
  String get nearby {
    return Intl.message('Nearby', name: 'nearby', desc: '', args: []);
  }

  /// `In Trip`
  String get inTrip {
    return Intl.message('In Trip', name: 'inTrip', desc: '', args: []);
  }

  /// `Pickup`
  String get pickupLocation {
    return Intl.message('Pickup', name: 'pickupLocation', desc: '', args: []);
  }

  /// `Login Successful`
  String get loginSuccessful {
    return Intl.message(
      'Login Successful',
      name: 'loginSuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Registration Successful`
  String get registrationSuccessful {
    return Intl.message(
      'Registration Successful',
      name: 'registrationSuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Verification code sent successfully`
  String get verificationCodeSent {
    return Intl.message(
      'Verification code sent successfully',
      name: 'verificationCodeSent',
      desc: '',
      args: [],
    );
  }

  /// `Please agree to our terms and conditions`
  String get pleaseAgreeToTerms {
    return Intl.message(
      'Please agree to our terms and conditions',
      name: 'pleaseAgreeToTerms',
      desc: '',
      args: [],
    );
  }

  /// `Please upload your profile image`
  String get pleaseUploadProfileImage {
    return Intl.message(
      'Please upload your profile image',
      name: 'pleaseUploadProfileImage',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the full 6-digit code`
  String get pleaseEnterFull6DigitCode {
    return Intl.message(
      'Please enter the full 6-digit code',
      name: 'pleaseEnterFull6DigitCode',
      desc: '',
      args: [],
    );
  }

  /// `Resend code is available now`
  String get resendCodeAvailableNow {
    return Intl.message(
      'Resend code is available now',
      name: 'resendCodeAvailableNow',
      desc: '',
      args: [],
    );
  }

  /// `Car type can't be empty`
  String get carTypeCantBeEmpty {
    return Intl.message(
      'Car type can\'t be empty',
      name: 'carTypeCantBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Car type must be at least 2 characters`
  String get carTypeCantBeLessThan2Char {
    return Intl.message(
      'Car type must be at least 2 characters',
      name: 'carTypeCantBeLessThan2Char',
      desc: '',
      args: [],
    );
  }

  /// `Number should be 9 to 14 digits`
  String get numberShouldBe9To14Digits {
    return Intl.message(
      'Number should be 9 to 14 digits',
      name: 'numberShouldBe9To14Digits',
      desc: '',
      args: [],
    );
  }

  /// `Search for a location...`
  String get searchForLocation {
    return Intl.message(
      'Search for a location...',
      name: 'searchForLocation',
      desc: '',
      args: [],
    );
  }

  /// `Pickup Location`
  String get pickupPoint {
    return Intl.message(
      'Pickup Location',
      name: 'pickupPoint',
      desc: '',
      args: [],
    );
  }

  /// `Destination`
  String get destinationPoint {
    return Intl.message(
      'Destination',
      name: 'destinationPoint',
      desc: '',
      args: [],
    );
  }

  /// `Pickup location selected`
  String get pickupSelected {
    return Intl.message(
      'Pickup location selected',
      name: 'pickupSelected',
      desc: '',
      args: [],
    );
  }

  /// `Destination selected`
  String get destinationSelected {
    return Intl.message(
      'Destination selected',
      name: 'destinationSelected',
      desc: '',
      args: [],
    );
  }

  /// `Move map and tap confirm`
  String get moveMapAndConfirm {
    return Intl.message(
      'Move map and tap confirm',
      name: 'moveMapAndConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Move map and select destination`
  String get moveMapAndSelectDestination {
    return Intl.message(
      'Move map and select destination',
      name: 'moveMapAndSelectDestination',
      desc: '',
      args: [],
    );
  }

  /// `Tap 'Trip Details' to continue`
  String get tapTripDetailsToContinue {
    return Intl.message(
      'Tap \'Trip Details\' to continue',
      name: 'tapTripDetailsToContinue',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Pickup Location`
  String get confirmPickupLocation {
    return Intl.message(
      'Confirm Pickup Location',
      name: 'confirmPickupLocation',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Destination`
  String get confirmDestinationLocation {
    return Intl.message(
      'Confirm Destination',
      name: 'confirmDestinationLocation',
      desc: '',
      args: [],
    );
  }

  /// `Date & Time`
  String get dateTimeLabel {
    return Intl.message(
      'Date & Time',
      name: 'dateTimeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Gender Preference`
  String get genderPreferenceLabel {
    return Intl.message(
      'Gender Preference',
      name: 'genderPreferenceLabel',
      desc: '',
      args: [],
    );
  }

  /// `Number of Seats`
  String get numberOfSeatsLabel {
    return Intl.message(
      'Number of Seats',
      name: 'numberOfSeatsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Requested Number of Seats`
  String get requestedNumberOfSeats {
    return Intl.message(
      'Requested Number of Seats',
      name: 'requestedNumberOfSeats',
      desc: '',
      args: [],
    );
  }

  /// `Pickup and destination cannot be the same location`
  String get originAndDestinationCannotBeSame {
    return Intl.message(
      'Pickup and destination cannot be the same location',
      name: 'originAndDestinationCannotBeSame',
      desc: '',
      args: [],
    );
  }

  /// `Note for Driver (Optional)`
  String get noteForDriverOptional {
    return Intl.message(
      'Note for Driver (Optional)',
      name: 'noteForDriverOptional',
      desc: '',
      args: [],
    );
  }

  /// `Price will be set by driver and you can review before confirmation`
  String get driverPriceNotice {
    return Intl.message(
      'Price will be set by driver and you can review before confirmation',
      name: 'driverPriceNotice',
      desc: '',
      args: [],
    );
  }

  /// `Please select trip date and time`
  String get pleaseSelectDateTime {
    return Intl.message(
      'Please select trip date and time',
      name: 'pleaseSelectDateTime',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Trip Request`
  String get confirmTripRequest {
    return Intl.message(
      'Confirm Trip Request',
      name: 'confirmTripRequest',
      desc: '',
      args: [],
    );
  }

  /// `Male Only`
  String get maleOnly {
    return Intl.message('Male Only', name: 'maleOnly', desc: '', args: []);
  }

  /// `Female Only`
  String get femaleOnly {
    return Intl.message('Female Only', name: 'femaleOnly', desc: '', args: []);
  }

  /// `Edit`
  String get edit {
    return Intl.message('Edit', name: 'edit', desc: '', args: []);
  }

  /// `Trip Cancellation`
  String get tripCancellation {
    return Intl.message(
      'Trip Cancellation',
      name: 'tripCancellation',
      desc: '',
      args: [],
    );
  }

  /// `Trip Members`
  String get tripMembers {
    return Intl.message(
      'Trip Members',
      name: 'tripMembers',
      desc: '',
      args: [],
    );
  }

  /// `What Is The Reason For Canceling The Trip?`
  String get whatIsReasonForCancelingTrip {
    return Intl.message(
      'What Is The Reason For Canceling The Trip?',
      name: 'whatIsReasonForCancelingTrip',
      desc: '',
      args: [],
    );
  }

  /// `Trip canceled successfully`
  String get tripCanceledSuccessfully {
    return Intl.message(
      'Trip canceled successfully',
      name: 'tripCanceledSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Today`
  String get today {
    return Intl.message('Today', name: 'today', desc: '', args: []);
  }

  /// `Yesterday`
  String get yesterday {
    return Intl.message('Yesterday', name: 'yesterday', desc: '', args: []);
  }

  /// `Aa`
  String get writeMessageHint {
    return Intl.message('Aa', name: 'writeMessageHint', desc: '', args: []);
  }

  /// `Choose Image Source`
  String get chooseImageSource {
    return Intl.message(
      'Choose Image Source',
      name: 'chooseImageSource',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get camera {
    return Intl.message('Camera', name: 'camera', desc: '', args: []);
  }

  /// `Gallery`
  String get gallery {
    return Intl.message('Gallery', name: 'gallery', desc: '', args: []);
  }

  /// `Accept Offer`
  String get acceptOffer {
    return Intl.message(
      'Accept Offer',
      name: 'acceptOffer',
      desc: '',
      args: [],
    );
  }

  /// `Reject Offer`
  String get rejectOffer {
    return Intl.message(
      'Reject Offer',
      name: 'rejectOffer',
      desc: '',
      args: [],
    );
  }

  /// `No offers yet`
  String get noOffers {
    return Intl.message('No offers yet', name: 'noOffers', desc: '', args: []);
  }

  /// `Waiting for offers...`
  String get waitingForOffers {
    return Intl.message(
      'Waiting for offers...',
      name: 'waitingForOffers',
      desc: '',
      args: [],
    );
  }

  /// `Passenger wait time`
  String get passengerWaitTime {
    return Intl.message(
      'Passenger wait time',
      name: 'passengerWaitTime',
      desc: '',
      args: [],
    );
  }

  /// `Cancel due to passenger no-show`
  String get cancelDueToNoShow {
    return Intl.message(
      'Cancel due to passenger no-show',
      name: 'cancelDueToNoShow',
      desc: '',
      args: [],
    );
  }

  /// `Trip Passengers`
  String get tripPassengers {
    return Intl.message(
      'Trip Passengers',
      name: 'tripPassengers',
      desc: '',
      args: [],
    );
  }

  /// `Offers closed: Passenger accepted another driver's offer`
  String get offersClosed {
    return Intl.message(
      'Offers closed: Passenger accepted another driver\'s offer',
      name: 'offersClosed',
      desc: '',
      args: [],
    );
  }

  /// `SAR`
  String get sar {
    return Intl.message('SAR', name: 'sar', desc: '', args: []);
  }

  /// `Add New Car Type`
  String get addCarType {
    return Intl.message(
      'Add New Car Type',
      name: 'addCarType',
      desc: '',
      args: [],
    );
  }

  /// `Add New Model`
  String get addCarModel {
    return Intl.message(
      'Add New Model',
      name: 'addCarModel',
      desc: '',
      args: [],
    );
  }

  /// `Add new option`
  String get addCustomOption {
    return Intl.message(
      'Add new option',
      name: 'addCustomOption',
      desc: '',
      args: [],
    );
  }

  /// `Select car type first`
  String get selectCarTypeFirst {
    return Intl.message(
      'Select car type first',
      name: 'selectCarTypeFirst',
      desc: '',
      args: [],
    );
  }

  /// `Camera only`
  String get cameraOnly {
    return Intl.message('Camera only', name: 'cameraOnly', desc: '', args: []);
  }

  /// `Search...`
  String get searchHint {
    return Intl.message('Search...', name: 'searchHint', desc: '', args: []);
  }

  /// `Type here...`
  String get typeHere {
    return Intl.message('Type here...', name: 'typeHere', desc: '', args: []);
  }

  /// `Add`
  String get add {
    return Intl.message('Add', name: 'add', desc: '', args: []);
  }

  /// `No profile image selected`
  String get noProfileImageSelected {
    return Intl.message(
      'No profile image selected',
      name: 'noProfileImageSelected',
      desc: '',
      args: [],
    );
  }

  /// `Enter email`
  String get enterEmail {
    return Intl.message('Enter email', name: 'enterEmail', desc: '', args: []);
  }

  /// `Preferred Language`
  String get preferredLanguage {
    return Intl.message(
      'Preferred Language',
      name: 'preferredLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Gender`
  String get gender {
    return Intl.message('Gender', name: 'gender', desc: '', args: []);
  }

  /// `Cancel Request`
  String get cancelOrder {
    return Intl.message(
      'Cancel Request',
      name: 'cancelOrder',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Offer Acceptance`
  String get confirmAcceptOffer {
    return Intl.message(
      'Confirm Offer Acceptance',
      name: 'confirmAcceptOffer',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to accept this offer for {price} {currency}?`
  String confirmOfferQuestion(Object price, Object currency) {
    return Intl.message(
      'Are you sure you want to accept this offer for $price $currency?',
      name: 'confirmOfferQuestion',
      desc: '',
      args: [price, currency],
    );
  }

  /// `Confirm Acceptance`
  String get confirmAccept {
    return Intl.message(
      'Confirm Acceptance',
      name: 'confirmAccept',
      desc: '',
      args: [],
    );
  }

  /// `Driver`
  String get driverDefaultName {
    return Intl.message(
      'Driver',
      name: 'driverDefaultName',
      desc: '',
      args: [],
    );
  }

  /// `Choose Driver ({count})`
  String chooseDriverWithCount(Object count) {
    return Intl.message(
      'Choose Driver ($count)',
      name: 'chooseDriverWithCount',
      desc: '',
      args: [count],
    );
  }

  /// `Shared trip. Your request has priority`
  String get sharedTripPriorityBanner {
    return Intl.message(
      'Shared trip. Your request has priority',
      name: 'sharedTripPriorityBanner',
      desc: '',
      args: [],
    );
  }

  /// `Private trip. Your request has priority`
  String get privateTripPriorityBanner {
    return Intl.message(
      'Private trip. Your request has priority',
      name: 'privateTripPriorityBanner',
      desc: '',
      args: [],
    );
  }

  /// `Total fare for {seats} seats`
  String totalFareForSeats(Object seats) {
    return Intl.message(
      'Total fare for $seats seats',
      name: 'totalFareForSeats',
      desc: '',
      args: [seats],
    );
  }

  /// `Total fare for all seats`
  String get totalFareForSeatsPrivate {
    return Intl.message(
      'Total fare for all seats',
      name: 'totalFareForSeatsPrivate',
      desc: '',
      args: [],
    );
  }

  /// `Increase Fare (+5 {currency})`
  String increaseFarePlus5(Object currency) {
    return Intl.message(
      'Increase Fare (+5 $currency)',
      name: 'increaseFarePlus5',
      desc: '',
      args: [currency],
    );
  }

  /// `Auto-accept nearest driver for {price} {currency}`
  String autoAcceptNearestDriver(Object price, Object currency) {
    return Intl.message(
      'Auto-accept nearest driver for $price $currency',
      name: 'autoAcceptNearestDriver',
      desc: '',
      args: [price, currency],
    );
  }

  /// `Top 3% of Drivers`
  String get topDriversBadge {
    return Intl.message(
      'Top 3% of Drivers',
      name: 'topDriversBadge',
      desc: '',
      args: [],
    );
  }

  /// `Your Trip Fare`
  String get yourTripFare {
    return Intl.message(
      'Your Trip Fare',
      name: 'yourTripFare',
      desc: '',
      args: [],
    );
  }

  /// `Legendary Driver`
  String get legendaryDriver {
    return Intl.message(
      'Legendary Driver',
      name: 'legendaryDriver',
      desc: '',
      args: [],
    );
  }

  /// `• {count} trips`
  String tripsCountLabel(Object count) {
    return Intl.message(
      '• $count trips',
      name: 'tripsCountLabel',
      desc: '',
      args: [count],
    );
  }

  /// `{minutes} min`
  String etaMinutes(Object minutes) {
    return Intl.message(
      '$minutes min',
      name: 'etaMinutes',
      desc: '',
      args: [minutes],
    );
  }

  /// `{count} seats requested`
  String seatsRequestedBadge(Object count) {
    return Intl.message(
      '$count seats requested',
      name: 'seatsRequestedBadge',
      desc: '',
      args: [count],
    );
  }

  /// `{price} {currency} Cash`
  String cashPayment(Object price, Object currency) {
    return Intl.message(
      '$price $currency Cash',
      name: 'cashPayment',
      desc: '',
      args: [price, currency],
    );
  }

  /// `Cancel and Return`
  String get cancelAndGoBack {
    return Intl.message(
      'Cancel and Return',
      name: 'cancelAndGoBack',
      desc: '',
      args: [],
    );
  }

  /// `Continue Waiting`
  String get continueWaiting {
    return Intl.message(
      'Continue Waiting',
      name: 'continueWaiting',
      desc: '',
      args: [],
    );
  }

  /// `No Drivers Available Right Now`
  String get noDriversFoundTitle {
    return Intl.message(
      'No Drivers Available Right Now',
      name: 'noDriversFoundTitle',
      desc: '',
      args: [],
    );
  }

  /// `No driver has responded to the shared trip request yet. Would you like to continue waiting or return later?`
  String get noDriversFoundSharedMessage {
    return Intl.message(
      'No driver has responded to the shared trip request yet. Would you like to continue waiting or return later?',
      name: 'noDriversFoundSharedMessage',
      desc: '',
      args: [],
    );
  }

  /// `No driver has responded to the private trip request yet. Would you like to continue waiting or return later?`
  String get noDriversFoundPrivateMessage {
    return Intl.message(
      'No driver has responded to the private trip request yet. Would you like to continue waiting or return later?',
      name: 'noDriversFoundPrivateMessage',
      desc: '',
      args: [],
    );
  }

  /// `Proposed fare updated to {price} {currency}`
  String proposedFareUpdated(Object price, Object currency) {
    return Intl.message(
      'Proposed fare updated to $price $currency',
      name: 'proposedFareUpdated',
      desc: '',
      args: [price, currency],
    );
  }

  /// `Additional notes for driver (optional)...`
  String get notesHint {
    return Intl.message(
      'Additional notes for driver (optional)...',
      name: 'notesHint',
      desc: '',
      args: [],
    );
  }

  /// `Departure Time`
  String get departureTimeLabel {
    return Intl.message(
      'Departure Time',
      name: 'departureTimeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Trip Date`
  String get tripDateLabel {
    return Intl.message('Trip Date', name: 'tripDateLabel', desc: '', args: []);
  }

  /// `All`
  String get genderAll {
    return Intl.message('All', name: 'genderAll', desc: '', args: []);
  }

  /// `Male Only`
  String get genderMaleOnly {
    return Intl.message(
      'Male Only',
      name: 'genderMaleOnly',
      desc: '',
      args: [],
    );
  }

  /// `Female Only`
  String get genderFemaleOnly {
    return Intl.message(
      'Female Only',
      name: 'genderFemaleOnly',
      desc: '',
      args: [],
    );
  }

  /// `Number of Seats Requested`
  String get seatsCountLabel {
    return Intl.message(
      'Number of Seats Requested',
      name: 'seatsCountLabel',
      desc: '',
      args: [],
    );
  }

  /// `Available Seats`
  String get availableSeats {
    return Intl.message(
      'Available Seats',
      name: 'availableSeats',
      desc: '',
      args: [],
    );
  }

  /// `Search for Offers`
  String get searchForOffersBtn {
    return Intl.message(
      'Search for Offers',
      name: 'searchForOffersBtn',
      desc: '',
      args: [],
    );
  }

  /// `My Current Location`
  String get currentLocationFallback {
    return Intl.message(
      'My Current Location',
      name: 'currentLocationFallback',
      desc: '',
      args: [],
    );
  }

  /// `Selected Destination`
  String get selectedDestinationFallback {
    return Intl.message(
      'Selected Destination',
      name: 'selectedDestinationFallback',
      desc: '',
      args: [],
    );
  }

  /// `Time Conflict`
  String get timeConflictTitle {
    return Intl.message(
      'Time Conflict',
      name: 'timeConflictTitle',
      desc: '',
      args: [],
    );
  }

  /// `You have another trip around this time (or an ongoing trip).\nPlease choose a time at least 1 hour apart.`
  String get timeConflictMessage {
    return Intl.message(
      'You have another trip around this time (or an ongoing trip).\nPlease choose a time at least 1 hour apart.',
      name: 'timeConflictMessage',
      desc: '',
      args: [],
    );
  }

  /// `{seconds}s`
  String secondsAbbr(Object seconds) {
    return Intl.message(
      '${seconds}s',
      name: 'secondsAbbr',
      desc: '',
      args: [seconds],
    );
  }

  /// `Accept ({seconds}s)`
  String acceptWithSeconds(Object seconds) {
    return Intl.message(
      'Accept (${seconds}s)',
      name: 'acceptWithSeconds',
      desc: '',
      args: [seconds],
    );
  }

  /// `For every {count} seats`
  String perSeatsCount(Object count) {
    return Intl.message(
      'For every $count seats',
      name: 'perSeatsCount',
      desc: '',
      args: [count],
    );
  }

  /// `Proposed Trip Fare`
  String get proposedTripFare {
    return Intl.message(
      'Proposed Trip Fare',
      name: 'proposedTripFare',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message('Retry', name: 'retry', desc: '', args: []);
  }

  /// `All Trips`
  String get allTrips {
    return Intl.message('All Trips', name: 'allTrips', desc: '', args: []);
  }

  /// `Available Trips ({count})`
  String availableTrips(Object count) {
    return Intl.message(
      'Available Trips ($count)',
      name: 'availableTrips',
      desc: '',
      args: [count],
    );
  }

  /// `Refresh Results`
  String get refreshResults {
    return Intl.message(
      'Refresh Results',
      name: 'refreshResults',
      desc: '',
      args: [],
    );
  }

  /// `No shared trips available to "{query}"`
  String noMatchingSharedTrips(Object query) {
    return Intl.message(
      'No shared trips available to "$query"',
      name: 'noMatchingSharedTrips',
      desc: '',
      args: [query],
    );
  }

  /// `No shared trips currently available`
  String get noSharedTripsAvailable {
    return Intl.message(
      'No shared trips currently available',
      name: 'noSharedTripsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `View All Trips`
  String get viewAllTrips {
    return Intl.message(
      'View All Trips',
      name: 'viewAllTrips',
      desc: '',
      args: [],
    );
  }

  /// `Search for destination (place, street...)`
  String get searchDestinationHint {
    return Intl.message(
      'Search for destination (place, street...)',
      name: 'searchDestinationHint',
      desc: '',
      args: [],
    );
  }

  /// `Select your destination to search matching trips:`
  String get selectDestinationToSearch {
    return Intl.message(
      'Select your destination to search matching trips:',
      name: 'selectDestinationToSearch',
      desc: '',
      args: [],
    );
  }

  /// `Search for Shared Trip`
  String get searchSharedTripTitle {
    return Intl.message(
      'Search for Shared Trip',
      name: 'searchSharedTripTitle',
      desc: '',
      args: [],
    );
  }

  /// `Top-Rated Driver`
  String get topRatedDriver {
    return Intl.message(
      'Top-Rated Driver',
      name: 'topRatedDriver',
      desc: '',
      args: [],
    );
  }

  /// `By Offer`
  String get byOffer {
    return Intl.message('By Offer', name: 'byOffer', desc: '', args: []);
  }

  /// `Details & Booking`
  String get detailsAndBooking {
    return Intl.message(
      'Details & Booking',
      name: 'detailsAndBooking',
      desc: '',
      args: [],
    );
  }

  /// `Trip Rating`
  String get tripRatingTitle {
    return Intl.message(
      'Trip Rating',
      name: 'tripRatingTitle',
      desc: '',
      args: [],
    );
  }

  /// `How was your experience on trip #{tripId}?`
  String rateYourExperience(Object tripId) {
    return Intl.message(
      'How was your experience on trip #$tripId?',
      name: 'rateYourExperience',
      desc: '',
      args: [tripId],
    );
  }

  /// `Write your feedback and rating (optional)...`
  String get ratingFeedbackHint {
    return Intl.message(
      'Write your feedback and rating (optional)...',
      name: 'ratingFeedbackHint',
      desc: '',
      args: [],
    );
  }

  /// `Submit Rating`
  String get submitRating {
    return Intl.message(
      'Submit Rating',
      name: 'submitRating',
      desc: '',
      args: [],
    );
  }

  /// `This trip has ended or was canceled. Chat is closed.`
  String get chatClosedTripEnded {
    return Intl.message(
      'This trip has ended or was canceled. Chat is closed.',
      name: 'chatClosedTripEnded',
      desc: '',
      args: [],
    );
  }

  /// `Chat is closed because the trip has ended.`
  String get chatClosedToast {
    return Intl.message(
      'Chat is closed because the trip has ended.',
      name: 'chatClosedToast',
      desc: '',
      args: [],
    );
  }

  /// `Trip Member`
  String get tripMember {
    return Intl.message('Trip Member', name: 'tripMember', desc: '', args: []);
  }

  /// `Search for Shared Trip`
  String get searchSharedTripHome {
    return Intl.message(
      'Search for Shared Trip',
      name: 'searchSharedTripHome',
      desc: '',
      args: [],
    );
  }

  /// `Enter destination and browse available trips on your route`
  String get searchSharedTripSub {
    return Intl.message(
      'Enter destination and browse available trips on your route',
      name: 'searchSharedTripSub',
      desc: '',
      args: [],
    );
  }

  /// `Live tracking in progress 📍`
  String get liveTrackingInProgress {
    return Intl.message(
      'Live tracking in progress 📍',
      name: 'liveTrackingInProgress',
      desc: '',
      args: [],
    );
  }

  /// `Open driver live tracking map`
  String get openLiveTrackingMap {
    return Intl.message(
      'Open driver live tracking map',
      name: 'openLiveTrackingMap',
      desc: '',
      args: [],
    );
  }

  /// `Location permission was denied.`
  String get locationPermissionDenied {
    return Intl.message(
      'Location permission was denied.',
      name: 'locationPermissionDenied',
      desc: '',
      args: [],
    );
  }

  /// `Your account is under administrative review (KYC). Browsing and accepting trips is temporarily disabled pending approval.`
  String get kycUnderReview {
    return Intl.message(
      'Your account is under administrative review (KYC). Browsing and accepting trips is temporarily disabled pending approval.',
      name: 'kycUnderReview',
      desc: '',
      args: [],
    );
  }

  /// `Driver account activation was rejected. Please review and update your documents and license from the edit page.`
  String get kycRejected {
    return Intl.message(
      'Driver account activation was rejected. Please review and update your documents and license from the edit page.',
      name: 'kycRejected',
      desc: '',
      args: [],
    );
  }

  /// `Account Under Review (KYC)`
  String get kycUnderReviewTitle {
    return Intl.message(
      'Account Under Review (KYC)',
      name: 'kycUnderReviewTitle',
      desc: '',
      args: [],
    );
  }

  /// `Account Rejected`
  String get kycRejectedTitle {
    return Intl.message(
      'Account Rejected',
      name: 'kycRejectedTitle',
      desc: '',
      args: [],
    );
  }

  /// `Update Data & Documents >`
  String get updateDataAndDocs {
    return Intl.message(
      'Update Data & Documents >',
      name: 'updateDataAndDocs',
      desc: '',
      args: [],
    );
  }

  /// `No internet connection. Live tracking is paused.`
  String get noInternetOffline {
    return Intl.message(
      'No internet connection. Live tracking is paused.',
      name: 'noInternetOffline',
      desc: '',
      args: [],
    );
  }

  /// `Notes`
  String get notes {
    return Intl.message('Notes', name: 'notes', desc: '', args: []);
  }

  /// `Update`
  String get update {
    return Intl.message('Update', name: 'update', desc: '', args: []);
  }

  /// `Location`
  String get location {
    return Intl.message('Location', name: 'location', desc: '', args: []);
  }

  /// `Driver`
  String get driver {
    return Intl.message('Driver', name: 'driver', desc: '', args: []);
  }

  /// `Arabic`
  String get arabic {
    return Intl.message('Arabic', name: 'arabic', desc: '', args: []);
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `New Notification`
  String get newNotification {
    return Intl.message(
      'New Notification',
      name: 'newNotification',
      desc: '',
      args: [],
    );
  }

  /// `Start moving to passengers`
  String get startMovingToPassengers {
    return Intl.message(
      'Start moving to passengers',
      name: 'startMovingToPassengers',
      desc: '',
      args: [],
    );
  }

  /// `Start moving to client`
  String get startMovingToClient {
    return Intl.message(
      'Start moving to client',
      name: 'startMovingToClient',
      desc: '',
      args: [],
    );
  }

  /// `Near passenger location (< 500m)`
  String get nearPassengerLocation {
    return Intl.message(
      'Near passenger location (< 500m)',
      name: 'nearPassengerLocation',
      desc: '',
      args: [],
    );
  }

  /// `Near client location (< 500m)`
  String get nearClientLocation {
    return Intl.message(
      'Near client location (< 500m)',
      name: 'nearClientLocation',
      desc: '',
      args: [],
    );
  }

  /// `Confirm arrival at passengers (Arrived)`
  String get confirmArrivalAtPassengers {
    return Intl.message(
      'Confirm arrival at passengers (Arrived)',
      name: 'confirmArrivalAtPassengers',
      desc: '',
      args: [],
    );
  }

  /// `Confirm arrival at client (Arrived)`
  String get confirmArrivalAtClient {
    return Intl.message(
      'Confirm arrival at client (Arrived)',
      name: 'confirmArrivalAtClient',
      desc: '',
      args: [],
    );
  }

  /// `Start Shared Trip`
  String get startSharedTripAction {
    return Intl.message(
      'Start Shared Trip',
      name: 'startSharedTripAction',
      desc: '',
      args: [],
    );
  }

  /// `Start Trip`
  String get startPrivateTripAction {
    return Intl.message(
      'Start Trip',
      name: 'startPrivateTripAction',
      desc: '',
      args: [],
    );
  }

  /// `End Shared Trip`
  String get endSharedTripAction {
    return Intl.message(
      'End Shared Trip',
      name: 'endSharedTripAction',
      desc: '',
      args: [],
    );
  }

  /// `End Trip`
  String get endPrivateTripAction {
    return Intl.message(
      'End Trip',
      name: 'endPrivateTripAction',
      desc: '',
      args: [],
    );
  }

  /// `Shared trip completed`
  String get sharedTripCompleted {
    return Intl.message(
      'Shared trip completed',
      name: 'sharedTripCompleted',
      desc: '',
      args: [],
    );
  }

  /// `This trip is completed`
  String get tripCompleted {
    return Intl.message(
      'This trip is completed',
      name: 'tripCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Track Private Trip`
  String get trackPrivateTrip {
    return Intl.message(
      'Track Private Trip',
      name: 'trackPrivateTrip',
      desc: '',
      args: [],
    );
  }

  /// `Price per seat (JOD)`
  String get pricePerSeatLabel {
    return Intl.message(
      'Price per seat (JOD)',
      name: 'pricePerSeatLabel',
      desc: '',
      args: [],
    );
  }

  /// `Shared trip announced successfully`
  String get tripAnnouncedSuccess {
    return Intl.message(
      'Shared trip announced successfully',
      name: 'tripAnnouncedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `You are {dist}m away from pickup location. Please get closer (< 200m) to confirm arrival.`
  String distanceToPickupNotice(Object dist) {
    return Intl.message(
      'You are ${dist}m away from pickup location. Please get closer (< 200m) to confirm arrival.',
      name: 'distanceToPickupNotice',
      desc: '',
      args: [dist],
    );
  }

  /// `Trip ended successfully`
  String get tripEndedSuccess {
    return Intl.message(
      'Trip ended successfully',
      name: 'tripEndedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Shared trip ended successfully`
  String get tripEndedSharedSuccess {
    return Intl.message(
      'Shared trip ended successfully',
      name: 'tripEndedSharedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Search for location`
  String get searchLocationHint {
    return Intl.message(
      'Search for location',
      name: 'searchLocationHint',
      desc: '',
      args: [],
    );
  }

  /// `No location found`
  String get noLocationFound {
    return Intl.message(
      'No location found',
      name: 'noLocationFound',
      desc: '',
      args: [],
    );
  }

  /// `Expected trip price (JOD)`
  String get tripPriceExpected {
    return Intl.message(
      'Expected trip price (JOD)',
      name: 'tripPriceExpected',
      desc: '',
      args: [],
    );
  }

  /// `Private trip announced successfully`
  String get privateTripAnnouncedSuccess {
    return Intl.message(
      'Private trip announced successfully',
      name: 'privateTripAnnouncedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Search Shared Trips`
  String get searchSharedTrips {
    return Intl.message(
      'Search Shared Trips',
      name: 'searchSharedTrips',
      desc: '',
      args: [],
    );
  }

  /// `Select on Map`
  String get pickOnMap {
    return Intl.message('Select on Map', name: 'pickOnMap', desc: '', args: []);
  }

  /// `Change Pickup Location`
  String get changePickupLocation {
    return Intl.message(
      'Change Pickup Location',
      name: 'changePickupLocation',
      desc: '',
      args: [],
    );
  }

  /// `Choose Pickup Location`
  String get choosePickupLocation {
    return Intl.message(
      'Choose Pickup Location',
      name: 'choosePickupLocation',
      desc: '',
      args: [],
    );
  }

  /// `Where to?`
  String get whereTo {
    return Intl.message('Where to?', name: 'whereTo', desc: '', args: []);
  }

  /// `Earliest Departure Time`
  String get earliestDepartureTime {
    return Intl.message(
      'Earliest Departure Time',
      name: 'earliestDepartureTime',
      desc: '',
      args: [],
    );
  }

  /// `Choose departure time (optional)`
  String get chooseDepartureTimeOptional {
    return Intl.message(
      'Choose departure time (optional)',
      name: 'chooseDepartureTimeOptional',
      desc: '',
      args: [],
    );
  }

  /// `Clear time`
  String get clearTime {
    return Intl.message('Clear time', name: 'clearTime', desc: '', args: []);
  }

  /// `Search Radius: {km} km`
  String searchRadiusKm(Object km) {
    return Intl.message(
      'Search Radius: $km km',
      name: 'searchRadiusKm',
      desc: '',
      args: [km],
    );
  }

  /// `You are joined in this trip`
  String get youAreJoinedInTrip {
    return Intl.message(
      'You are joined in this trip',
      name: 'youAreJoinedInTrip',
      desc: '',
      args: [],
    );
  }

  /// `(Your booking: {count} seats)`
  String yourBookingSeats(Object count) {
    return Intl.message(
      '(Your booking: $count seats)',
      name: 'yourBookingSeats',
      desc: '',
      args: [count],
    );
  }

  /// `Starts {dist} km away from you`
  String startsDistanceKm(Object dist) {
    return Intl.message(
      'Starts $dist km away from you',
      name: 'startsDistanceKm',
      desc: '',
      args: [dist],
    );
  }

  /// `Destination {dist} km`
  String destinationDistanceKm(Object dist) {
    return Intl.message(
      'Destination $dist km',
      name: 'destinationDistanceKm',
      desc: '',
      args: [dist],
    );
  }

  /// `{count} seats remaining`
  String seatsRemaining(Object count) {
    return Intl.message(
      '$count seats remaining',
      name: 'seatsRemaining',
      desc: '',
      args: [count],
    );
  }

  /// `Full`
  String get tripFull {
    return Intl.message('Full', name: 'tripFull', desc: '', args: []);
  }

  /// `Currently {participants} participant(s) · {booked} of {total} seats booked`
  String tripParticipantsSummary(
    Object participants,
    Object booked,
    Object total,
  ) {
    return Intl.message(
      'Currently $participants participant(s) · $booked of $total seats booked',
      name: 'tripParticipantsSummary',
      desc: '',
      args: [participants, booked, total],
    );
  }

  /// `/ per seat currently`
  String get perSeatCurrently {
    return Intl.message(
      '/ per seat currently',
      name: 'perSeatCurrently',
      desc: '',
      args: [],
    );
  }

  /// `Total trip fare {price} JOD`
  String totalTripFare(Object price) {
    return Intl.message(
      'Total trip fare $price JOD',
      name: 'totalTripFare',
      desc: '',
      args: [price],
    );
  }

  /// `Total fare {price} JOD split by seat ratio (Vehicle full)`
  String splitBySeatsRatioFull(Object price) {
    return Intl.message(
      'Total fare $price JOD split by seat ratio (Vehicle full)',
      name: 'splitBySeatsRatioFull',
      desc: '',
      args: [price],
    );
  }

  /// `Total fare {price} JOD (Drops to {minPrice} JOD when full)`
  String reachesPriceWhenFull(Object price, Object minPrice) {
    return Intl.message(
      'Total fare $price JOD (Drops to $minPrice JOD when full)',
      name: 'reachesPriceWhenFull',
      desc: '',
      args: [price, minPrice],
    );
  }

  /// `Add Seats`
  String get increaseSeats {
    return Intl.message('Add Seats', name: 'increaseSeats', desc: '', args: []);
  }

  /// `Chat`
  String get chatAction {
    return Intl.message('Chat', name: 'chatAction', desc: '', args: []);
  }

  /// `Details`
  String get details {
    return Intl.message('Details', name: 'details', desc: '', args: []);
  }

  /// `Verified Driver`
  String get verifiedDriver {
    return Intl.message(
      'Verified Driver',
      name: 'verifiedDriver',
      desc: '',
      args: [],
    );
  }

  /// `Searching for nearby trips...`
  String get searchingNearbyTrips {
    return Intl.message(
      'Searching for nearby trips...',
      name: 'searchingNearbyTrips',
      desc: '',
      args: [],
    );
  }

  /// `No matching shared trips found currently`
  String get noMatchingSharedTripsFound {
    return Intl.message(
      'No matching shared trips found currently',
      name: 'noMatchingSharedTripsFound',
      desc: '',
      args: [],
    );
  }

  /// `Try increasing the search radius or adjusting pickup and destination`
  String get tryIncreasingRadius {
    return Intl.message(
      'Try increasing the search radius or adjusting pickup and destination',
      name: 'tryIncreasingRadius',
      desc: '',
      args: [],
    );
  }

  /// `Create New Shared Trip`
  String get createNewSharedTrip {
    return Intl.message(
      'Create New Shared Trip',
      name: 'createNewSharedTrip',
      desc: '',
      args: [],
    );
  }

  /// `Search Trips`
  String get searchTripButton {
    return Intl.message(
      'Search Trips',
      name: 'searchTripButton',
      desc: '',
      args: [],
    );
  }

  /// `Shared Trip Details`
  String get sharedTripDetailsTitle {
    return Intl.message(
      'Shared Trip Details',
      name: 'sharedTripDetailsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Booking confirmed! Redirecting to trip chat...`
  String get bookingConfirmedRedirecting {
    return Intl.message(
      'Booking confirmed! Redirecting to trip chat...',
      name: 'bookingConfirmedRedirecting',
      desc: '',
      args: [],
    );
  }

  /// `Trip Details & Booking`
  String get tabTripDetailsBooking {
    return Intl.message(
      'Trip Details & Booking',
      name: 'tabTripDetailsBooking',
      desc: '',
      args: [],
    );
  }

  /// `Driver & Vehicle Info`
  String get tabDriverVehicleDetails {
    return Intl.message(
      'Driver & Vehicle Info',
      name: 'tabDriverVehicleDetails',
      desc: '',
      args: [],
    );
  }

  /// `You are joined in this trip`
  String get youAreJoinedBannerTitle {
    return Intl.message(
      'You are joined in this trip',
      name: 'youAreJoinedBannerTitle',
      desc: '',
      args: [],
    );
  }

  /// `Seats currently reserved for you: {count} seats`
  String yourReservedSeatsCount(Object count) {
    return Intl.message(
      'Seats currently reserved for you: $count seats',
      name: 'yourReservedSeatsCount',
      desc: '',
      args: [count],
    );
  }

  /// `Participant in this trip`
  String get joinedInThisTrip {
    return Intl.message(
      'Participant in this trip',
      name: 'joinedInThisTrip',
      desc: '',
      args: [],
    );
  }

  /// `Seats & Fare Distribution:`
  String get seatsAndFareDistribution {
    return Intl.message(
      'Seats & Fare Distribution:',
      name: 'seatsAndFareDistribution',
      desc: '',
      args: [],
    );
  }

  /// `Participants`
  String get participantsCountLabel {
    return Intl.message(
      'Participants',
      name: 'participantsCountLabel',
      desc: '',
      args: [],
    );
  }

  /// `Booked`
  String get bookedSeatsLabel {
    return Intl.message('Booked', name: 'bookedSeatsLabel', desc: '', args: []);
  }

  /// `Remaining`
  String get remainingSeatsLabel {
    return Intl.message(
      'Remaining',
      name: 'remainingSeatsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Total trip fare agreed with driver:`
  String get totalAgreedFareWithDriver {
    return Intl.message(
      'Total trip fare agreed with driver:',
      name: 'totalAgreedFareWithDriver',
      desc: '',
      args: [],
    );
  }

  /// `Seats currently booked in the trip:`
  String get seatsCurrentlyBookedInTrip {
    return Intl.message(
      'Seats currently booked in the trip:',
      name: 'seatsCurrentlyBookedInTrip',
      desc: '',
      args: [],
    );
  }

  /// `{occupied} of {total} seats`
  String seatsOutOfTotal(Object occupied, Object total) {
    return Intl.message(
      '$occupied of $total seats',
      name: 'seatsOutOfTotal',
      desc: '',
      args: [occupied, total],
    );
  }

  /// `Your share now ({seats} seats at {ratio}%):`
  String yourShareNowWithRatio(Object seats, Object ratio) {
    return Intl.message(
      'Your share now ($seats seats at $ratio%):',
      name: 'yourShareNowWithRatio',
      desc: '',
      args: [seats, ratio],
    );
  }

  /// `When the vehicle is full ({total} seats), your share drops to {price} JOD.`
  String noticePriceDropsWhenFull(Object total, Object price) {
    return Intl.message(
      'When the vehicle is full ($total seats), your share drops to $price JOD.',
      name: 'noticePriceDropsWhenFull',
      desc: '',
      args: [total, price],
    );
  }

  /// `Vehicle is full. Fare is split by seat ratio at the lowest possible cost.`
  String get noticeCarIsFull {
    return Intl.message(
      'Vehicle is full. Fare is split by seat ratio at the lowest possible cost.',
      name: 'noticeCarIsFull',
      desc: '',
      args: [],
    );
  }

  /// `Request additional seats:`
  String get requestAdditionalSeats {
    return Intl.message(
      'Request additional seats:',
      name: 'requestAdditionalSeats',
      desc: '',
      args: [],
    );
  }

  /// `Choose number of seats to book:`
  String get chooseSeatsToBook {
    return Intl.message(
      'Choose number of seats to book:',
      name: 'chooseSeatsToBook',
      desc: '',
      args: [],
    );
  }

  /// `{count} seats available`
  String availableSeatsCount(Object count) {
    return Intl.message(
      '$count seats available',
      name: 'availableSeatsCount',
      desc: '',
      args: [count],
    );
  }

  /// `seat`
  String get seatSingle {
    return Intl.message('seat', name: 'seatSingle', desc: '', args: []);
  }

  /// `seats`
  String get multipleSeats {
    return Intl.message('seats', name: 'multipleSeats', desc: '', args: []);
  }

  /// `Total cost for your booking ({count} seats):`
  String totalCostYourBooking(Object count) {
    return Intl.message(
      'Total cost for your booking ($count seats):',
      name: 'totalCostYourBooking',
      desc: '',
      args: [count],
    );
  }

  /// `Amount to pay for your booking ({count} seats):`
  String amountToPayForBooking(Object count) {
    return Intl.message(
      'Amount to pay for your booking ($count seats):',
      name: 'amountToPayForBooking',
      desc: '',
      args: [count],
    );
  }

  /// `No available seats in the vehicle currently (Trip full)`
  String get noAvailableSeatsCarFull {
    return Intl.message(
      'No available seats in the vehicle currently (Trip full)',
      name: 'noAvailableSeatsCarFull',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Extra Seats & Enter Chat`
  String get confirmExtraSeatsAndChat {
    return Intl.message(
      'Confirm Extra Seats & Enter Chat',
      name: 'confirmExtraSeatsAndChat',
      desc: '',
      args: [],
    );
  }

  /// `Confirm & Book ({count} seats) & Enter Chat`
  String confirmSeatsAndChat(Object count) {
    return Intl.message(
      'Confirm & Book ($count seats) & Enter Chat',
      name: 'confirmSeatsAndChat',
      desc: '',
      args: [count],
    );
  }

  /// `Enter Trip Chat Directly`
  String get enterTripChatDirectly {
    return Intl.message(
      'Enter Trip Chat Directly',
      name: 'enterTripChatDirectly',
      desc: '',
      args: [],
    );
  }

  /// `Vehicle Information:`
  String get vehicleData {
    return Intl.message(
      'Vehicle Information:',
      name: 'vehicleData',
      desc: '',
      args: [],
    );
  }

  /// `Car Type & Model`
  String get carTypeAndModel {
    return Intl.message(
      'Car Type & Model',
      name: 'carTypeAndModel',
      desc: '',
      args: [],
    );
  }

  /// `Car Color`
  String get carColor {
    return Intl.message('Car Color', name: 'carColor', desc: '', args: []);
  }

  /// `Total Seats`
  String get totalSeatsCount {
    return Intl.message(
      'Total Seats',
      name: 'totalSeatsCount',
      desc: '',
      args: [],
    );
  }

  /// `Passenger Preference`
  String get passengerGenderPreference {
    return Intl.message(
      'Passenger Preference',
      name: 'passengerGenderPreference',
      desc: '',
      args: [],
    );
  }

  /// `Males only`
  String get malesOnly {
    return Intl.message('Males only', name: 'malesOnly', desc: '', args: []);
  }

  /// `Females only`
  String get femalesOnly {
    return Intl.message(
      'Females only',
      name: 'femalesOnly',
      desc: '',
      args: [],
    );
  }

  /// `Everyone`
  String get allGenders {
    return Intl.message('Everyone', name: 'allGenders', desc: '', args: []);
  }

  /// `Contact Driver`
  String get contactDriver {
    return Intl.message(
      'Contact Driver',
      name: 'contactDriver',
      desc: '',
      args: [],
    );
  }

  /// `Select Route on Map`
  String get pickRouteOnMap {
    return Intl.message(
      'Select Route on Map',
      name: 'pickRouteOnMap',
      desc: '',
      args: [],
    );
  }

  /// `Select Pickup Location`
  String get pickPickupLocationOnMap {
    return Intl.message(
      'Select Pickup Location',
      name: 'pickPickupLocationOnMap',
      desc: '',
      args: [],
    );
  }

  /// `Select Destination`
  String get pickDestinationOnMap {
    return Intl.message(
      'Select Destination',
      name: 'pickDestinationOnMap',
      desc: '',
      args: [],
    );
  }

  /// `Preview Route`
  String get previewRoute {
    return Intl.message(
      'Preview Route',
      name: 'previewRoute',
      desc: '',
      args: [],
    );
  }

  /// `Search for place name or address...`
  String get searchPlaceOrAddressHint {
    return Intl.message(
      'Search for place name or address...',
      name: 'searchPlaceOrAddressHint',
      desc: '',
      args: [],
    );
  }

  /// `Determining address...`
  String get resolvingAddress {
    return Intl.message(
      'Determining address...',
      name: 'resolvingAddress',
      desc: '',
      args: [],
    );
  }

  /// `Selected Pickup Location:`
  String get selectedPickupLocation {
    return Intl.message(
      'Selected Pickup Location:',
      name: 'selectedPickupLocation',
      desc: '',
      args: [],
    );
  }

  /// `Selected Destination:`
  String get selectedDestinationLocation {
    return Intl.message(
      'Selected Destination:',
      name: 'selectedDestinationLocation',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Pickup & Search`
  String get confirmPickupAndSearch {
    return Intl.message(
      'Confirm Pickup & Search',
      name: 'confirmPickupAndSearch',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Destination & Search`
  String get confirmDestinationAndSearch {
    return Intl.message(
      'Confirm Destination & Search',
      name: 'confirmDestinationAndSearch',
      desc: '',
      args: [],
    );
  }

  /// `Confirm & Search Trips`
  String get confirmAndSearchTrips {
    return Intl.message(
      'Confirm & Search Trips',
      name: 'confirmAndSearchTrips',
      desc: '',
      args: [],
    );
  }

  /// `Estimated Distance`
  String get estimatedDistance {
    return Intl.message(
      'Estimated Distance',
      name: 'estimatedDistance',
      desc: '',
      args: [],
    );
  }

  /// `Estimated Duration`
  String get estimatedDuration {
    return Intl.message(
      'Estimated Duration',
      name: 'estimatedDuration',
      desc: '',
      args: [],
    );
  }

  /// `min`
  String get minutesUnit {
    return Intl.message('min', name: 'minutesUnit', desc: '', args: []);
  }

  /// `{count} km`
  String kmUnit(Object count) {
    return Intl.message('$count km', name: 'kmUnit', desc: '', args: [count]);
  }

  /// `Change Origin`
  String get changeOrigin {
    return Intl.message(
      'Change Origin',
      name: 'changeOrigin',
      desc: '',
      args: [],
    );
  }

  /// `Change Destination`
  String get changeDestination {
    return Intl.message(
      'Change Destination',
      name: 'changeDestination',
      desc: '',
      args: [],
    );
  }

  /// `Route Map`
  String get routeMapButton {
    return Intl.message(
      'Route Map',
      name: 'routeMapButton',
      desc: '',
      args: [],
    );
  }

  /// `Time (optional)`
  String get timeOptional {
    return Intl.message(
      'Time (optional)',
      name: 'timeOptional',
      desc: '',
      args: [],
    );
  }

  /// `My Current Location (GPS)`
  String get currentGpsLocation {
    return Intl.message(
      'My Current Location (GPS)',
      name: 'currentGpsLocation',
      desc: '',
      args: [],
    );
  }

  /// `Clear Filters`
  String get clearFilters {
    return Intl.message(
      'Clear Filters',
      name: 'clearFilters',
      desc: '',
      args: [],
    );
  }

  /// `Suggested Pickup:`
  String get suggestedPickup {
    return Intl.message(
      'Suggested Pickup:',
      name: 'suggestedPickup',
      desc: '',
      args: [],
    );
  }

  /// `Suggested Destination:`
  String get suggestedDestination {
    return Intl.message(
      'Suggested Destination:',
      name: 'suggestedDestination',
      desc: '',
      args: [],
    );
  }

  /// `Enable Location & Retry`
  String get enableLocationAndRetry {
    return Intl.message(
      'Enable Location & Retry',
      name: 'enableLocationAndRetry',
      desc: '',
      args: [],
    );
  }

  /// `Search by destination...`
  String get searchByPlaceOrDestination {
    return Intl.message(
      'Search by destination...',
      name: 'searchByPlaceOrDestination',
      desc: '',
      args: [],
    );
  }

  /// `Search by pickup location...`
  String get searchByPickupLocation {
    return Intl.message(
      'Search by pickup location...',
      name: 'searchByPickupLocation',
      desc: '',
      args: [],
    );
  }

  /// `{dist} km from your location`
  String distanceToLocation(Object dist) {
    return Intl.message(
      '$dist km from your location',
      name: 'distanceToLocation',
      desc: '',
      args: [dist],
    );
  }

  /// `Choose Departure Time`
  String get chooseDepartureTime {
    return Intl.message(
      'Choose Departure Time',
      name: 'chooseDepartureTime',
      desc: '',
      args: [],
    );
  }

  /// `Trips close to this time will be shown`
  String get optionalTimeHint {
    return Intl.message(
      'Trips close to this time will be shown',
      name: 'optionalTimeHint',
      desc: '',
      args: [],
    );
  }

  /// `Choose Time`
  String get chooseTime {
    return Intl.message('Choose Time', name: 'chooseTime', desc: '', args: []);
  }

  /// `1. Origin`
  String get stepOrigin {
    return Intl.message('1. Origin', name: 'stepOrigin', desc: '', args: []);
  }

  /// `2. Destination`
  String get stepDestination {
    return Intl.message(
      '2. Destination',
      name: 'stepDestination',
      desc: '',
      args: [],
    );
  }

  /// `3. Route`
  String get stepRoute {
    return Intl.message('3. Route', name: 'stepRoute', desc: '', args: []);
  }

  /// `Search for origin (place, street...)`
  String get searchPickupHint {
    return Intl.message(
      'Search for origin (place, street...)',
      name: 'searchPickupHint',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Route & Search Trips`
  String get confirmRouteAndSearch {
    return Intl.message(
      'Confirm Route & Search Trips',
      name: 'confirmRouteAndSearch',
      desc: '',
      args: [],
    );
  }

  /// `Set Origin & Pick Destination`
  String get setPickupAndPickDestination {
    return Intl.message(
      'Set Origin & Pick Destination',
      name: 'setPickupAndPickDestination',
      desc: '',
      args: [],
    );
  }

  /// `Set Destination & Review Route`
  String get setDestinationAndReviewRoute {
    return Intl.message(
      'Set Destination & Review Route',
      name: 'setDestinationAndReviewRoute',
      desc: '',
      args: [],
    );
  }

  /// `📍 Pickup Location`
  String get pinOriginTag {
    return Intl.message(
      '📍 Pickup Location',
      name: 'pinOriginTag',
      desc: '',
      args: [],
    );
  }

  /// `🏁 Destination`
  String get pinDestinationTag {
    return Intl.message(
      '🏁 Destination',
      name: 'pinDestinationTag',
      desc: '',
      args: [],
    );
  }

  /// `Trip request canceled successfully`
  String get orderCanceledSuccessfully {
    return Intl.message(
      'Trip request canceled successfully',
      name: 'orderCanceledSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to cancel this request?`
  String get cancelOrderConfirmMessage {
    return Intl.message(
      'Are you sure you want to cancel this request?',
      name: 'cancelOrderConfirmMessage',
      desc: '',
      args: [],
    );
  }

  /// `Searching for drivers...`
  String get searchingForCaptains {
    return Intl.message(
      'Searching for drivers...',
      name: 'searchingForCaptains',
      desc: '',
      args: [],
    );
  }

  /// `Driver Car`
  String get driverCar {
    return Intl.message('Driver Car', name: 'driverCar', desc: '', args: []);
  }

  /// `Phone number is currently unavailable`
  String get driverPhoneNotAvailable {
    return Intl.message(
      'Phone number is currently unavailable',
      name: 'driverPhoneNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Passenger`
  String get passengerDefaultName {
    return Intl.message(
      'Passenger',
      name: 'passengerDefaultName',
      desc: '',
      args: [],
    );
  }

  /// `This trip was canceled by the driver.`
  String get tripCanceledByDriver {
    return Intl.message(
      'This trip was canceled by the driver.',
      name: 'tripCanceledByDriver',
      desc: '',
      args: [],
    );
  }

  /// `Waiting for the driver to start moving`
  String get waitingDriverStartMoving {
    return Intl.message(
      'Waiting for the driver to start moving',
      name: 'waitingDriverStartMoving',
      desc: '',
      args: [],
    );
  }

  /// `Driver accepted and waiting to move towards you`
  String get driverApprovedWaitingMovement {
    return Intl.message(
      'Driver accepted and waiting to move towards you',
      name: 'driverApprovedWaitingMovement',
      desc: '',
      args: [],
    );
  }

  /// `Successfully subscribed to trip! 🚀`
  String get tripSubscriptionSuccess {
    return Intl.message(
      'Successfully subscribed to trip! 🚀',
      name: 'tripSubscriptionSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Joining...`
  String get joining {
    return Intl.message('Joining...', name: 'joining', desc: '', args: []);
  }

  /// `Join this shared trip 🚀`
  String get joinThisSharedTrip {
    return Intl.message(
      'Join this shared trip 🚀',
      name: 'joinThisSharedTrip',
      desc: '',
      args: [],
    );
  }

  /// `Waiting to move`
  String get waitingMovement {
    return Intl.message(
      'Waiting to move',
      name: 'waitingMovement',
      desc: '',
      args: [],
    );
  }

  /// `Current Passengers`
  String get currentPassengers {
    return Intl.message(
      'Current Passengers',
      name: 'currentPassengers',
      desc: '',
      args: [],
    );
  }

  /// `{count} / {total} seats`
  String seatsCountDisplay(Object count, Object total) {
    return Intl.message(
      '$count / $total seats',
      name: 'seatsCountDisplay',
      desc: '',
      args: [count, total],
    );
  }

  /// `No other passengers currently.`
  String get noOtherPassengers {
    return Intl.message(
      'No other passengers currently.',
      name: 'noOtherPassengers',
      desc: '',
      args: [],
    );
  }

  /// `Trip created successfully`
  String get tripCreatedSuccess {
    return Intl.message(
      'Trip created successfully',
      name: 'tripCreatedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Search for offers`
  String get searchOffers {
    return Intl.message(
      'Search for offers',
      name: 'searchOffers',
      desc: '',
      args: [],
    );
  }

  /// `Search for pickup location...`
  String get searchPickupLocationHint {
    return Intl.message(
      'Search for pickup location...',
      name: 'searchPickupLocationHint',
      desc: '',
      args: [],
    );
  }

  /// `Search for destination...`
  String get searchDestinationLocationHint {
    return Intl.message(
      'Search for destination...',
      name: 'searchDestinationLocationHint',
      desc: '',
      args: [],
    );
  }

  /// `trip`
  String get trip {
    return Intl.message('trip', name: 'trip', desc: '', args: []);
  }

  /// `trips`
  String get trips {
    return Intl.message('trips', name: 'trips', desc: '', args: []);
  }

  /// `Not specified`
  String get notSpecified {
    return Intl.message(
      'Not specified',
      name: 'notSpecified',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get all {
    return Intl.message('All', name: 'all', desc: '', args: []);
  }

  /// `Invalid mobile number or password, please try again`
  String get invalidLoginCredentials {
    return Intl.message(
      'Invalid mobile number or password, please try again',
      name: 'invalidLoginCredentials',
      desc: '',
      args: [],
    );
  }

  /// `Please select a driver profile image`
  String get noDriverImageSelected {
    return Intl.message(
      'Please select a driver profile image',
      name: 'noDriverImageSelected',
      desc: '',
      args: [],
    );
  }

  /// `No image selected`
  String get noImageSelected {
    return Intl.message(
      'No image selected',
      name: 'noImageSelected',
      desc: '',
      args: [],
    );
  }

  /// `Mobile number is required to continue`
  String get mobileNumberRequired {
    return Intl.message(
      'Mobile number is required to continue',
      name: 'mobileNumberRequired',
      desc: '',
      args: [],
    );
  }

  /// `Back to Forgot Password`
  String get backToForgetPassword {
    return Intl.message(
      'Back to Forgot Password',
      name: 'backToForgetPassword',
      desc: '',
      args: [],
    );
  }

  /// `Password has been reset successfully`
  String get passwordResetSuccessfully {
    return Intl.message(
      'Password has been reset successfully',
      name: 'passwordResetSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Account verified successfully`
  String get accountVerifiedSuccessfully {
    return Intl.message(
      'Account verified successfully',
      name: 'accountVerifiedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `User not found`
  String get userNotFound {
    return Intl.message(
      'User not found',
      name: 'userNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Verification code is invalid or expired`
  String get otpCodeInvalidOrExpired {
    return Intl.message(
      'Verification code is invalid or expired',
      name: 'otpCodeInvalidOrExpired',
      desc: '',
      args: [],
    );
  }

  /// `07xxxxxxxx`
  String get mobileNumberPlaceholder {
    return Intl.message(
      '07xxxxxxxx',
      name: 'mobileNumberPlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Server error occurred, please try again later`
  String get serverError {
    return Intl.message(
      'Server error occurred, please try again later',
      name: 'serverError',
      desc: '',
      args: [],
    );
  }

  /// `Please check your internet connection`
  String get networkError {
    return Intl.message(
      'Please check your internet connection',
      name: 'networkError',
      desc: '',
      args: [],
    );
  }

  /// `Unauthorized access`
  String get unauthorizedError {
    return Intl.message(
      'Unauthorized access',
      name: 'unauthorizedError',
      desc: '',
      args: [],
    );
  }

  /// `My Official Documents`
  String get myDocuments {
    return Intl.message(
      'My Official Documents',
      name: 'myDocuments',
      desc: '',
      args: [],
    );
  }

  /// `Account Active & Verified`
  String get accountStatusActive {
    return Intl.message(
      'Account Active & Verified',
      name: 'accountStatusActive',
      desc: '',
      args: [],
    );
  }

  /// `Account Under Review`
  String get accountStatusUnderReview {
    return Intl.message(
      'Account Under Review',
      name: 'accountStatusUnderReview',
      desc: '',
      args: [],
    );
  }

  /// `Uploaded`
  String get documentUploaded {
    return Intl.message(
      'Uploaded',
      name: 'documentUploaded',
      desc: '',
      args: [],
    );
  }

  /// `Required`
  String get documentMissing {
    return Intl.message(
      'Required',
      name: 'documentMissing',
      desc: '',
      args: [],
    );
  }

  /// `Expired`
  String get documentExpired {
    return Intl.message('Expired', name: 'documentExpired', desc: '', args: []);
  }

  /// `Upload Document`
  String get uploadDocument {
    return Intl.message(
      'Upload Document',
      name: 'uploadDocument',
      desc: '',
      args: [],
    );
  }

  /// `Replace Document`
  String get replaceDocument {
    return Intl.message(
      'Replace Document',
      name: 'replaceDocument',
      desc: '',
      args: [],
    );
  }

  /// `Expiry Date`
  String get expiryDate {
    return Intl.message('Expiry Date', name: 'expiryDate', desc: '', args: []);
  }

  /// `Expiry Date (optional)`
  String get expiryDateOptional {
    return Intl.message(
      'Expiry Date (optional)',
      name: 'expiryDateOptional',
      desc: '',
      args: [],
    );
  }

  /// `Upload Selected Documents`
  String get uploadSelectedDocuments {
    return Intl.message(
      'Upload Selected Documents',
      name: 'uploadSelectedDocuments',
      desc: '',
      args: [],
    );
  }

  /// `No file selected`
  String get noDocumentSelected {
    return Intl.message(
      'No file selected',
      name: 'noDocumentSelected',
      desc: '',
      args: [],
    );
  }

  /// `Documents uploaded successfully`
  String get documentUploadSuccess {
    return Intl.message(
      'Documents uploaded successfully',
      name: 'documentUploadSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Select at least one document to upload`
  String get atLeastOneDocumentRequired {
    return Intl.message(
      'Select at least one document to upload',
      name: 'atLeastOneDocumentRequired',
      desc: '',
      args: [],
    );
  }

  /// `Tap to upload file`
  String get tapToUploadFile {
    return Intl.message(
      'Tap to upload file',
      name: 'tapToUploadFile',
      desc: '',
      args: [],
    );
  }

  /// `Uploaded on`
  String get uploadedAt {
    return Intl.message('Uploaded on', name: 'uploadedAt', desc: '', args: []);
  }

  /// `File selected`
  String get fileSelected {
    return Intl.message(
      'File selected',
      name: 'fileSelected',
      desc: '',
      args: [],
    );
  }

  /// `Account Under Review`
  String get kycRequiredTitle {
    return Intl.message(
      'Account Under Review',
      name: 'kycRequiredTitle',
      desc: '',
      args: [],
    );
  }

  /// `You cannot create trips or make offers until your account is activated by admin. Upload your documents and wait for activation.`
  String get kycRequiredMessage {
    return Intl.message(
      'You cannot create trips or make offers until your account is activated by admin. Upload your documents and wait for activation.',
      name: 'kycRequiredMessage',
      desc: '',
      args: [],
    );
  }

  /// `Go to My Documents`
  String get goToDocuments {
    return Intl.message(
      'Go to My Documents',
      name: 'goToDocuments',
      desc: '',
      args: [],
    );
  }

  /// `Invalid plate format (NN - digits)`
  String get plateNumberInvalidFormat {
    return Intl.message(
      'Invalid plate format (NN - digits)',
      name: 'plateNumberInvalidFormat',
      desc: '',
      args: [],
    );
  }

  /// `Account Under Review`
  String get accountUnderReviewBannerTitle {
    return Intl.message(
      'Account Under Review',
      name: 'accountUnderReviewBannerTitle',
      desc: '',
      args: [],
    );
  }

  /// `My Documents`
  String get accountUnderReviewBannerAction {
    return Intl.message(
      'My Documents',
      name: 'accountUnderReviewBannerAction',
      desc: '',
      args: [],
    );
  }

  /// `Official Documents & Verification`
  String get officialDocuments {
    return Intl.message(
      'Official Documents & Verification',
      name: 'officialDocuments',
      desc: '',
      args: [],
    );
  }

  /// `National ID`
  String get nationalIdDocument {
    return Intl.message(
      'National ID',
      name: 'nationalIdDocument',
      desc: '',
      args: [],
    );
  }

  /// `Certificate of No Criminal Record`
  String get criminalRecordDocument {
    return Intl.message(
      'Certificate of No Criminal Record',
      name: 'criminalRecordDocument',
      desc: '',
      args: [],
    );
  }

  /// `Vehicle License`
  String get vehicleLicenseDocument {
    return Intl.message(
      'Vehicle License',
      name: 'vehicleLicenseDocument',
      desc: '',
      args: [],
    );
  }

  /// `Personal ID document is required`
  String get nationalIdCantBeEmpty {
    return Intl.message(
      'Personal ID document is required',
      name: 'nationalIdCantBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Criminal record certificate is required`
  String get criminalRecordCantBeEmpty {
    return Intl.message(
      'Criminal record certificate is required',
      name: 'criminalRecordCantBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Vehicle license document is required`
  String get vehicleLicenseCantBeEmpty {
    return Intl.message(
      'Vehicle license document is required',
      name: 'vehicleLicenseCantBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Please select criminal record expiry date`
  String get criminalRecordExpiryCantBeEmpty {
    return Intl.message(
      'Please select criminal record expiry date',
      name: 'criminalRecordExpiryCantBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Image or PDF file (max 8MB)`
  String get pdfOrImageAllowed {
    return Intl.message(
      'Image or PDF file (max 8MB)',
      name: 'pdfOrImageAllowed',
      desc: '',
      args: [],
    );
  }

  /// `Select Expiry Date`
  String get selectExpiryDate {
    return Intl.message(
      'Select Expiry Date',
      name: 'selectExpiryDate',
      desc: '',
      args: [],
    );
  }

  /// `Remove file`
  String get removeFile {
    return Intl.message('Remove file', name: 'removeFile', desc: '', args: []);
  }

  /// `Approved & Locked 🔒`
  String get documentApprovedLocked {
    return Intl.message(
      'Approved & Locked 🔒',
      name: 'documentApprovedLocked',
      desc: '',
      args: [],
    );
  }

  /// `This document has been verified. To update it, please contact support.`
  String get lockedDocumentNotice {
    return Intl.message(
      'This document has been verified. To update it, please contact support.',
      name: 'lockedDocumentNotice',
      desc: '',
      args: [],
    );
  }

  /// `All your documents have been verified and your account is active. To update any document, please contact support.`
  String get accountActiveDocsLockedMessage {
    return Intl.message(
      'All your documents have been verified and your account is active. To update any document, please contact support.',
      name: 'accountActiveDocsLockedMessage',
      desc: '',
      args: [],
    );
  }

  /// `You are Online & Ready for Orders`
  String get youAreOnline {
    return Intl.message(
      'You are Online & Ready for Orders',
      name: 'youAreOnline',
      desc: '',
      args: [],
    );
  }

  /// `You are Offline (On Break)`
  String get youAreOffline {
    return Intl.message(
      'You are Offline (On Break)',
      name: 'youAreOffline',
      desc: '',
      args: [],
    );
  }

  /// `Radar active, searching for nearby passengers...`
  String get radarSearchingNewTrips {
    return Intl.message(
      'Radar active, searching for nearby passengers...',
      name: 'radarSearchingNewTrips',
      desc: '',
      args: [],
    );
  }

  /// `New requests available now!`
  String get liveRequestsAvailable {
    return Intl.message(
      'New requests available now!',
      name: 'liveRequestsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Review Requests & Make Offer`
  String get reviewAndMakeOffer {
    return Intl.message(
      'Review Requests & Make Offer',
      name: 'reviewAndMakeOffer',
      desc: '',
      args: [],
    );
  }

  /// `You have an active ongoing trip`
  String get hasActiveTripNotice {
    return Intl.message(
      'You have an active ongoing trip',
      name: 'hasActiveTripNotice',
      desc: '',
      args: [],
    );
  }

  /// `Continue Trip Route`
  String get continueActiveTrip {
    return Intl.message(
      'Continue Trip Route',
      name: 'continueActiveTrip',
      desc: '',
      args: [],
    );
  }

  /// `Adjust Working Radius`
  String get adjustWorkingRadius {
    return Intl.message(
      'Adjust Working Radius',
      name: 'adjustWorkingRadius',
      desc: '',
      args: [],
    );
  }

  /// `Working Radius`
  String get workingDistance {
    return Intl.message(
      'Working Radius',
      name: 'workingDistance',
      desc: '',
      args: [],
    );
  }

  /// `Tap to change distance`
  String get tapToChangeDistance {
    return Intl.message(
      'Tap to change distance',
      name: 'tapToChangeDistance',
      desc: '',
      args: [],
    );
  }

  /// `Refresh Radar`
  String get refreshRadar {
    return Intl.message(
      'Refresh Radar',
      name: 'refreshRadar',
      desc: '',
      args: [],
    );
  }

  /// `{count} New Requests`
  String newRequestsCount(Object count) {
    return Intl.message(
      '$count New Requests',
      name: 'newRequestsCount',
      desc: '',
      args: [count],
    );
  }

  /// `Search Radius Range`
  String get searchRadiusScope {
    return Intl.message(
      'Search Radius Range',
      name: 'searchRadiusScope',
      desc: '',
      args: [],
    );
  }

  /// `Trips within {radius} km around your location will be fetched.`
  String searchRadiusDesc(Object radius) {
    return Intl.message(
      'Trips within $radius km around your location will be fetched.',
      name: 'searchRadiusDesc',
      desc: '',
      args: [radius],
    );
  }

  /// `Apply Radius`
  String get applyRadius {
    return Intl.message(
      'Apply Radius',
      name: 'applyRadius',
      desc: '',
      args: [],
    );
  }

  /// `km`
  String get kmOnly {
    return Intl.message('km', name: 'kmOnly', desc: '', args: []);
  }

  /// `Search Radius: {radius} km`
  String searchRadiusLabel(Object radius) {
    return Intl.message(
      'Search Radius: $radius km',
      name: 'searchRadiusLabel',
      desc: '',
      args: [radius],
    );
  }

  /// `Edit`
  String get editAction {
    return Intl.message('Edit', name: 'editAction', desc: '', args: []);
  }

  /// `My Trips Statistics`
  String get myTripsStats {
    return Intl.message(
      'My Trips Statistics',
      name: 'myTripsStats',
      desc: '',
      args: [],
    );
  }

  /// `New Requests`
  String get newTripsStat {
    return Intl.message(
      'New Requests',
      name: 'newTripsStat',
      desc: '',
      args: [],
    );
  }

  /// `Current Trips`
  String get currentTripsStat {
    return Intl.message(
      'Current Trips',
      name: 'currentTripsStat',
      desc: '',
      args: [],
    );
  }

  /// `Completed Trips`
  String get completedTripsStat {
    return Intl.message(
      'Completed Trips',
      name: 'completedTripsStat',
      desc: '',
      args: [],
    );
  }

  /// `Suspended Trips`
  String get suspendedTripsStat {
    return Intl.message(
      'Suspended Trips',
      name: 'suspendedTripsStat',
      desc: '',
      args: [],
    );
  }

  /// `New requests waiting in your current radius — review details and make offers now.`
  String get heroTripsSubtitle {
    return Intl.message(
      'New requests waiting in your current radius — review details and make offers now.',
      name: 'heroTripsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `View Requests & Make Offers`
  String get viewRequestsAndMakeOffer {
    return Intl.message(
      'View Requests & Make Offers',
      name: 'viewRequestsAndMakeOffer',
      desc: '',
      args: [],
    );
  }

  /// `Captain`
  String get captainName {
    return Intl.message('Captain', name: 'captainName', desc: '', args: []);
  }

  /// `Radar active & searching 🔍`
  String get radarActiveSearching {
    return Intl.message(
      'Radar active & searching 🔍',
      name: 'radarActiveSearching',
      desc: '',
      args: [],
    );
  }

  /// `Try Again`
  String get retryAction {
    return Intl.message('Try Again', name: 'retryAction', desc: '', args: []);
  }

  /// `Ready to receive new trips`
  String get readyForNewTrips {
    return Intl.message(
      'Ready to receive new trips',
      name: 'readyForNewTrips',
      desc: '',
      args: [],
    );
  }

  /// `Turn on connection to receive requests`
  String get activateConnectionToReceive {
    return Intl.message(
      'Turn on connection to receive requests',
      name: 'activateConnectionToReceive',
      desc: '',
      args: [],
    );
  }

  /// `You are Online`
  String get youAreOnlineShort {
    return Intl.message(
      'You are Online',
      name: 'youAreOnlineShort',
      desc: '',
      args: [],
    );
  }

  /// `You are Offline`
  String get youAreOfflineShort {
    return Intl.message(
      'You are Offline',
      name: 'youAreOfflineShort',
      desc: '',
      args: [],
    );
  }

  /// `Missing documents required for activation:`
  String get missingDocumentsRequired {
    return Intl.message(
      'Missing documents required for activation:',
      name: 'missingDocumentsRequired',
      desc: '',
      args: [],
    );
  }

  /// `All documents uploaded, currently under admin review for activation.`
  String get allDocumentsUploadedReview {
    return Intl.message(
      'All documents uploaded, currently under admin review for activation.',
      name: 'allDocumentsUploadedReview',
      desc: '',
      args: [],
    );
  }

  /// `Trip Rating`
  String get ratingScreenTitle {
    return Intl.message(
      'Trip Rating',
      name: 'ratingScreenTitle',
      desc: '',
      args: [],
    );
  }

  /// `How was your experience with {name}?`
  String rateYourExperienceWith(Object name) {
    return Intl.message(
      'How was your experience with $name?',
      name: 'rateYourExperienceWith',
      desc: '',
      args: [name],
    );
  }

  /// `Add your comment (optional)...`
  String get ratingCommentHint {
    return Intl.message(
      'Add your comment (optional)...',
      name: 'ratingCommentHint',
      desc: '',
      args: [],
    );
  }

  /// `Submit Rating`
  String get submitRatingBtn {
    return Intl.message(
      'Submit Rating',
      name: 'submitRatingBtn',
      desc: '',
      args: [],
    );
  }

  /// `Update Rating`
  String get updateRatingBtn {
    return Intl.message(
      'Update Rating',
      name: 'updateRatingBtn',
      desc: '',
      args: [],
    );
  }

  /// `Your rating was submitted successfully!`
  String get ratingSubmitSuccess {
    return Intl.message(
      'Your rating was submitted successfully!',
      name: 'ratingSubmitSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Your rating was updated successfully!`
  String get ratingUpdateSuccess {
    return Intl.message(
      'Your rating was updated successfully!',
      name: 'ratingUpdateSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get skipRating {
    return Intl.message('Skip', name: 'skipRating', desc: '', args: []);
  }

  /// `Trips Pending Rating`
  String get pendingRatingsTitle {
    return Intl.message(
      'Trips Pending Rating',
      name: 'pendingRatingsTitle',
      desc: '',
      args: [],
    );
  }

  /// `No trips pending rating`
  String get pendingRatingsEmpty {
    return Intl.message(
      'No trips pending rating',
      name: 'pendingRatingsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Rate your completed trips to support drivers and improve service quality`
  String get pendingRatingsSubtitle {
    return Intl.message(
      'Rate your completed trips to support drivers and improve service quality',
      name: 'pendingRatingsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Rate Trip`
  String get rateTripAction {
    return Intl.message(
      'Rate Trip',
      name: 'rateTripAction',
      desc: '',
      args: [],
    );
  }

  /// `My Ratings`
  String get myRatingsTitle {
    return Intl.message(
      'My Ratings',
      name: 'myRatingsTitle',
      desc: '',
      args: [],
    );
  }

  /// `You haven't submitted any ratings yet`
  String get myRatingsEmpty {
    return Intl.message(
      'You haven\'t submitted any ratings yet',
      name: 'myRatingsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Edit Rating`
  String get editRatingBtn {
    return Intl.message(
      'Edit Rating',
      name: 'editRatingBtn',
      desc: '',
      args: [],
    );
  }

  /// `You can edit your rating within 24 hours of submission`
  String get ratingEditWindowNote {
    return Intl.message(
      'You can edit your rating within 24 hours of submission',
      name: 'ratingEditWindowNote',
      desc: '',
      args: [],
    );
  }

  /// `Rating is locked (more than 24 hours passed)`
  String get ratingLockedNote {
    return Intl.message(
      'Rating is locked (more than 24 hours passed)',
      name: 'ratingLockedNote',
      desc: '',
      args: [],
    );
  }

  /// `Driver Ratings`
  String get driverRatingsTitle {
    return Intl.message(
      'Driver Ratings',
      name: 'driverRatingsTitle',
      desc: '',
      args: [],
    );
  }

  /// `No ratings for this driver yet`
  String get driverRatingsEmpty {
    return Intl.message(
      'No ratings for this driver yet',
      name: 'driverRatingsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `{count} Ratings`
  String ratingCountLabel(Object count) {
    return Intl.message(
      '$count Ratings',
      name: 'ratingCountLabel',
      desc: '',
      args: [count],
    );
  }

  /// `{count} Stars`
  String starsLabel(Object count) {
    return Intl.message(
      '$count Stars',
      name: 'starsLabel',
      desc: '',
      args: [count],
    );
  }

  /// `Overall Rating`
  String get ratingSummaryOverall {
    return Intl.message(
      'Overall Rating',
      name: 'ratingSummaryOverall',
      desc: '',
      args: [],
    );
  }

  /// `Rating passengers is not available at this time`
  String get driverRatesPassengerNotSupported {
    return Intl.message(
      'Rating passengers is not available at this time',
      name: 'driverRatesPassengerNotSupported',
      desc: '',
      args: [],
    );
  }

  /// `The trip has not ended yet and cannot be rated`
  String get errorTripNotFinished {
    return Intl.message(
      'The trip has not ended yet and cannot be rated',
      name: 'errorTripNotFinished',
      desc: '',
      args: [],
    );
  }

  /// `No driver assigned to this trip`
  String get errorDriverNotAssigned {
    return Intl.message(
      'No driver assigned to this trip',
      name: 'errorDriverNotAssigned',
      desc: '',
      args: [],
    );
  }

  /// `You cannot rate yourself`
  String get errorCannotRateSelf {
    return Intl.message(
      'You cannot rate yourself',
      name: 'errorCannotRateSelf',
      desc: '',
      args: [],
    );
  }

  /// `You were not a passenger on this trip`
  String get errorNotTripPassenger {
    return Intl.message(
      'You were not a passenger on this trip',
      name: 'errorNotTripPassenger',
      desc: '',
      args: [],
    );
  }

  /// `The 24-hour edit window has expired — rating is locked`
  String get errorRatingLocked {
    return Intl.message(
      'The 24-hour edit window has expired — rating is locked',
      name: 'errorRatingLocked',
      desc: '',
      args: [],
    );
  }

  /// `Trip not found`
  String get errorTripNotFound {
    return Intl.message(
      'Trip not found',
      name: 'errorTripNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Failed to submit rating, please try again`
  String get errorRatingFailed {
    return Intl.message(
      'Failed to submit rating, please try again',
      name: 'errorRatingFailed',
      desc: '',
      args: [],
    );
  }

  /// `This offer has expired`
  String get offerExpired {
    return Intl.message(
      'This offer has expired',
      name: 'offerExpired',
      desc: '',
      args: [],
    );
  }

  /// `This trip or offer has already been accepted`
  String get tripAlreadyAccepted {
    return Intl.message(
      'This trip or offer has already been accepted',
      name: 'tripAlreadyAccepted',
      desc: '',
      args: [],
    );
  }

  /// `You have already submitted an offer for this trip`
  String get offerAlreadySubmitted {
    return Intl.message(
      'You have already submitted an offer for this trip',
      name: 'offerAlreadySubmitted',
      desc: '',
      args: [],
    );
  }

  /// `Not enough available seats`
  String get insufficientSeats {
    return Intl.message(
      'Not enough available seats',
      name: 'insufficientSeats',
      desc: '',
      args: [],
    );
  }

  /// `This trip has been cancelled`
  String get tripCancelled {
    return Intl.message(
      'This trip has been cancelled',
      name: 'tripCancelled',
      desc: '',
      args: [],
    );
  }

  /// `Connection timed out`
  String get connectionTimeout {
    return Intl.message(
      'Connection timed out',
      name: 'connectionTimeout',
      desc: '',
      args: [],
    );
  }

  /// `No internet connection, please check your network`
  String get noInternetConnection {
    return Intl.message(
      'No internet connection, please check your network',
      name: 'noInternetConnection',
      desc: '',
      args: [],
    );
  }

  /// `Unexpected error occurred, please try again`
  String get unexpectedError {
    return Intl.message(
      'Unexpected error occurred, please try again',
      name: 'unexpectedError',
      desc: '',
      args: [],
    );
  }

  /// `Accepting offer and confirming booking...`
  String get confirmAcceptOfferLoading {
    return Intl.message(
      'Accepting offer and confirming booking...',
      name: 'confirmAcceptOfferLoading',
      desc: '',
      args: [],
    );
  }

  /// `Trip Route`
  String get routePath {
    return Intl.message('Trip Route', name: 'routePath', desc: '', args: []);
  }

  /// `Pickup Location`
  String get originLocation {
    return Intl.message(
      'Pickup Location',
      name: 'originLocation',
      desc: '',
      args: [],
    );
  }

  /// `Trip Date`
  String get tripDate {
    return Intl.message('Trip Date', name: 'tripDate', desc: '', args: []);
  }

  /// `Trip Time`
  String get tripTime {
    return Intl.message('Trip Time', name: 'tripTime', desc: '', args: []);
  }

  /// `{count} Seats`
  String seatsCount(Object count) {
    return Intl.message(
      '$count Seats',
      name: 'seatsCount',
      desc: '',
      args: [count],
    );
  }

  /// `{count} Seat`
  String seatsCountSingle(Object count) {
    return Intl.message(
      '$count Seat',
      name: 'seatsCountSingle',
      desc: '',
      args: [count],
    );
  }

  /// `{count} Reserved Seats`
  String reservedSeatsCount(Object count) {
    return Intl.message(
      '$count Reserved Seats',
      name: 'reservedSeatsCount',
      desc: '',
      args: [count],
    );
  }

  /// `Additional Notes`
  String get additionalNotes {
    return Intl.message(
      'Additional Notes',
      name: 'additionalNotes',
      desc: '',
      args: [],
    );
  }

  /// `Driver`
  String get driverLabel {
    return Intl.message('Driver', name: 'driverLabel', desc: '', args: []);
  }

  /// `Passenger / Trip Creator`
  String get passengerCreatorLabel {
    return Intl.message(
      'Passenger / Trip Creator',
      name: 'passengerCreatorLabel',
      desc: '',
      args: [],
    );
  }

  /// `Joined Passengers ({count})`
  String joinedPassengersTitle(Object count) {
    return Intl.message(
      'Joined Passengers ($count)',
      name: 'joinedPassengersTitle',
      desc: '',
      args: [count],
    );
  }

  /// `Trip Price`
  String get tripPrice {
    return Intl.message('Trip Price', name: 'tripPrice', desc: '', args: []);
  }

  /// `Captain & Offer Details`
  String get captainDetails {
    return Intl.message(
      'Captain & Offer Details',
      name: 'captainDetails',
      desc: '',
      args: [],
    );
  }

  /// `({count} ratings)`
  String ratingsCountLabel(Object count) {
    return Intl.message(
      '($count ratings)',
      name: 'ratingsCountLabel',
      desc: '',
      args: [count],
    );
  }

  /// `Vehicle Details`
  String get vehicleDetails {
    return Intl.message(
      'Vehicle Details',
      name: 'vehicleDetails',
      desc: '',
      args: [],
    );
  }

  /// `Car Type & Model`
  String get carModelLabel {
    return Intl.message(
      'Car Type & Model',
      name: 'carModelLabel',
      desc: '',
      args: [],
    );
  }

  /// `Plate Number`
  String get plateNumberLabel {
    return Intl.message(
      'Plate Number',
      name: 'plateNumberLabel',
      desc: '',
      args: [],
    );
  }

  /// `Car Color`
  String get carColorLabel {
    return Intl.message('Car Color', name: 'carColorLabel', desc: '', args: []);
  }

  /// `Price Offered by Captain`
  String get offeredPriceByCaptain {
    return Intl.message(
      'Price Offered by Captain',
      name: 'offeredPriceByCaptain',
      desc: '',
      args: [],
    );
  }

  /// `Call`
  String get callAction {
    return Intl.message('Call', name: 'callAction', desc: '', args: []);
  }

  /// `Driver's Car`
  String get driverCarLabel {
    return Intl.message(
      'Driver\'s Car',
      name: 'driverCarLabel',
      desc: '',
      args: [],
    );
  }

  /// `Phone number is currently unavailable`
  String get phoneNotAvailable {
    return Intl.message(
      'Phone number is currently unavailable',
      name: 'phoneNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Waiting for driver to start moving`
  String get waitingDriverMove {
    return Intl.message(
      'Waiting for driver to start moving',
      name: 'waitingDriverMove',
      desc: '',
      args: [],
    );
  }

  /// `Driver accepted and is preparing to move to your location`
  String get driverAcceptedWaitingMove {
    return Intl.message(
      'Driver accepted and is preparing to move to your location',
      name: 'driverAcceptedWaitingMove',
      desc: '',
      args: [],
    );
  }

  /// `Waiting to move`
  String get waitingDriverMoveShort {
    return Intl.message(
      'Waiting to move',
      name: 'waitingDriverMoveShort',
      desc: '',
      args: [],
    );
  }

  /// `Driver arrived at pickup point`
  String get driverArrivedPickup {
    return Intl.message(
      'Driver arrived at pickup point',
      name: 'driverArrivedPickup',
      desc: '',
      args: [],
    );
  }

  /// `Trip in progress to destination`
  String get tripStartedOnWay {
    return Intl.message(
      'Trip in progress to destination',
      name: 'tripStartedOnWay',
      desc: '',
      args: [],
    );
  }

  /// `{count} min (approx)`
  String minutesApprox(Object count) {
    return Intl.message(
      '$count min (approx)',
      name: 'minutesApprox',
      desc: '',
      args: [count],
    );
  }

  /// `{count} km`
  String kmDistance(Object count) {
    return Intl.message(
      '$count km',
      name: 'kmDistance',
      desc: '',
      args: [count],
    );
  }

  /// `Search pickup point...`
  String get searchOriginHint {
    return Intl.message(
      'Search pickup point...',
      name: 'searchOriginHint',
      desc: '',
      args: [],
    );
  }

  /// `Search destination...`
  String get searchDestHint {
    return Intl.message(
      'Search destination...',
      name: 'searchDestHint',
      desc: '',
      args: [],
    );
  }

  /// `Pickup Point`
  String get originPoint {
    return Intl.message(
      'Pickup Point',
      name: 'originPoint',
      desc: '',
      args: [],
    );
  }

  /// `No driver assigned yet`
  String get noDriverAssignedYet {
    return Intl.message(
      'No driver assigned yet',
      name: 'noDriverAssignedYet',
      desc: '',
      args: [],
    );
  }

  /// `Start Trip`
  String get startTripAction {
    return Intl.message(
      'Start Trip',
      name: 'startTripAction',
      desc: '',
      args: [],
    );
  }

  /// `End Trip`
  String get endTripAction {
    return Intl.message('End Trip', name: 'endTripAction', desc: '', args: []);
  }

  /// `Cancel Trip`
  String get cancelTripAction {
    return Intl.message(
      'Cancel Trip',
      name: 'cancelTripAction',
      desc: '',
      args: [],
    );
  }

  /// `Suspend Trip`
  String get suspendTripAction {
    return Intl.message(
      'Suspend Trip',
      name: 'suspendTripAction',
      desc: '',
      args: [],
    );
  }

  /// `Resume Trip`
  String get resumeTripAction {
    return Intl.message(
      'Resume Trip',
      name: 'resumeTripAction',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to start the trip?`
  String get confirmStartTrip {
    return Intl.message(
      'Are you sure you want to start the trip?',
      name: 'confirmStartTrip',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to end the trip?`
  String get confirmEndTrip {
    return Intl.message(
      'Are you sure you want to end the trip?',
      name: 'confirmEndTrip',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Trip`
  String get confirmCancelTrip {
    return Intl.message(
      'Cancel Trip',
      name: 'confirmCancelTrip',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to suspend the trip?`
  String get confirmSuspendTrip {
    return Intl.message(
      'Are you sure you want to suspend the trip?',
      name: 'confirmSuspendTrip',
      desc: '',
      args: [],
    );
  }

  /// `Enter proposed fare`
  String get enterProposedFare {
    return Intl.message(
      'Enter proposed fare',
      name: 'enterProposedFare',
      desc: '',
      args: [],
    );
  }

  /// `Send Offer`
  String get sendOfferAction {
    return Intl.message(
      'Send Offer',
      name: 'sendOfferAction',
      desc: '',
      args: [],
    );
  }

  /// `Offer sent successfully`
  String get offerSentSuccess {
    return Intl.message(
      'Offer sent successfully',
      name: 'offerSentSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Please select pickup and destination points on map`
  String get pleaseSelectPickupAndDest {
    return Intl.message(
      'Please select pickup and destination points on map',
      name: 'pleaseSelectPickupAndDest',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid price`
  String get pleaseEnterValidPrice {
    return Intl.message(
      'Please enter a valid price',
      name: 'pleaseEnterValidPrice',
      desc: '',
      args: [],
    );
  }

  /// `Joining shared trip...`
  String get joiningSharedTrip {
    return Intl.message(
      'Joining shared trip...',
      name: 'joiningSharedTrip',
      desc: '',
      args: [],
    );
  }

  /// `Successfully joined shared trip`
  String get joinedSharedTripSuccess {
    return Intl.message(
      'Successfully joined shared trip',
      name: 'joinedSharedTripSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Automatically calculated based on your vehicle capacity`
  String get autoCalculatedVehicleCapacity {
    return Intl.message(
      'Automatically calculated based on your vehicle capacity',
      name: 'autoCalculatedVehicleCapacity',
      desc: '',
      args: [],
    );
  }

  /// `Set the total trip price to enter chat and waiting room`
  String get setTotalTripPriceNotice {
    return Intl.message(
      'Set the total trip price to enter chat and waiting room',
      name: 'setTotalTripPriceNotice',
      desc: '',
      args: [],
    );
  }

  /// `Capacity: {count} seats`
  String capacitySeats(Object count) {
    return Intl.message(
      'Capacity: $count seats',
      name: 'capacitySeats',
      desc: '',
      args: [count],
    );
  }

  /// `Minimum Price`
  String get minimumPriceLabel {
    return Intl.message(
      'Minimum Price',
      name: 'minimumPriceLabel',
      desc: '',
      args: [],
    );
  }

  /// `Suggested Price`
  String get suggestedPriceLabel {
    return Intl.message(
      'Suggested Price',
      name: 'suggestedPriceLabel',
      desc: '',
      args: [],
    );
  }

  /// `Maximum Price`
  String get maximumPriceLabel {
    return Intl.message(
      'Maximum Price',
      name: 'maximumPriceLabel',
      desc: '',
      args: [],
    );
  }

  /// `Set total required price:`
  String get setTotalRequiredPrice {
    return Intl.message(
      'Set total required price:',
      name: 'setTotalRequiredPrice',
      desc: '',
      args: [],
    );
  }

  /// `Passenger share upon completion of {count} seats:`
  String passengerShareOnComplete(Object count) {
    return Intl.message(
      'Passenger share upon completion of $count seats:',
      name: 'passengerShareOnComplete',
      desc: '',
      args: [count],
    );
  }

  /// `{price} per seat`
  String perSeatPriceLabel(Object price) {
    return Intl.message(
      '$price per seat',
      name: 'perSeatPriceLabel',
      desc: '',
      args: [price],
    );
  }

  /// `This total price will be split equally among joining passengers based on their booked seats upon trip completion.`
  String get splitFareExplanation {
    return Intl.message(
      'This total price will be split equally among joining passengers based on their booked seats upon trip completion.',
      name: 'splitFareExplanation',
      desc: '',
      args: [],
    );
  }

  /// `Price set, entering chat...`
  String get priceSetEnteringChat {
    return Intl.message(
      'Price set, entering chat...',
      name: 'priceSetEnteringChat',
      desc: '',
      args: [],
    );
  }

  /// `Failed to send price offer, please try again`
  String get failedToSendPriceOffer {
    return Intl.message(
      'Failed to send price offer, please try again',
      name: 'failedToSendPriceOffer',
      desc: '',
      args: [],
    );
  }

  /// `Trip not found or has been canceled`
  String get tripNotFound {
    return Intl.message(
      'Trip not found or has been canceled',
      name: 'tripNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Or enter a custom value:`
  String get orEnterCustomValue {
    return Intl.message(
      'Or enter a custom value:',
      name: 'orEnterCustomValue',
      desc: '',
      args: [],
    );
  }

  /// `Offer cannot exceed maximum limit ({maxPrice})`
  String offerCannotExceedMax(Object maxPrice) {
    return Intl.message(
      'Offer cannot exceed maximum limit ($maxPrice)',
      name: 'offerCannotExceedMax',
      desc: '',
      args: [maxPrice],
    );
  }

  /// `Offer cannot be less than minimum limit ({minPrice})`
  String offerCannotBeLessThanMin(Object minPrice) {
    return Intl.message(
      'Offer cannot be less than minimum limit ($minPrice)',
      name: 'offerCannotBeLessThanMin',
      desc: '',
      args: [minPrice],
    );
  }

  /// `All Dates`
  String get allDates {
    return Intl.message('All Dates', name: 'allDates', desc: '', args: []);
  }

  /// `Today's Trips`
  String get todayTrips {
    return Intl.message(
      'Today\'s Trips',
      name: 'todayTrips',
      desc: '',
      args: [],
    );
  }

  /// `Tomorrow's Trips`
  String get tomorrowTrips {
    return Intl.message(
      'Tomorrow\'s Trips',
      name: 'tomorrowTrips',
      desc: '',
      args: [],
    );
  }

  /// `Radius: {radius} km`
  String radiusKm(Object radius) {
    return Intl.message(
      'Radius: $radius km',
      name: 'radiusKm',
      desc: '',
      args: [radius],
    );
  }

  /// `Specific Date 📅`
  String get specificDate {
    return Intl.message(
      'Specific Date 📅',
      name: 'specificDate',
      desc: '',
      args: [],
    );
  }

  /// `Geographic Search Radius`
  String get searchRadiusTitle {
    return Intl.message(
      'Geographic Search Radius',
      name: 'searchRadiusTitle',
      desc: '',
      args: [],
    );
  }

  /// `{count} min`
  String minutesCount(Object count) {
    return Intl.message(
      '$count min',
      name: 'minutesCount',
      desc: '',
      args: [count],
    );
  }

  /// `Trip Options`
  String get tripOptions {
    return Intl.message(
      'Trip Options',
      name: 'tripOptions',
      desc: '',
      args: [],
    );
  }

  /// `Change driver & search for new offers`
  String get changeDriverAndSearchOffers {
    return Intl.message(
      'Change driver & search for new offers',
      name: 'changeDriverAndSearchOffers',
      desc: '',
      args: [],
    );
  }

  /// `Cancel current driver and receive offers from other drivers`
  String get changeDriverAndSearchOffersDesc {
    return Intl.message(
      'Cancel current driver and receive offers from other drivers',
      name: 'changeDriverAndSearchOffersDesc',
      desc: '',
      args: [],
    );
  }

  /// `Change Driver`
  String get changeDriverConfirmTitle {
    return Intl.message(
      'Change Driver',
      name: 'changeDriverConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to cancel the current driver and search for new offers?`
  String get changeDriverConfirmMessage {
    return Intl.message(
      'Are you sure you want to cancel the current driver and search for new offers?',
      name: 'changeDriverConfirmMessage',
      desc: '',
      args: [],
    );
  }

  /// `Yes, search for offers`
  String get yesSearchOffers {
    return Intl.message(
      'Yes, search for offers',
      name: 'yesSearchOffers',
      desc: '',
      args: [],
    );
  }

  /// `Driver cancelled, receiving new offers`
  String get driverCancelledReceivingOffers {
    return Intl.message(
      'Driver cancelled, receiving new offers',
      name: 'driverCancelledReceivingOffers',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Trip Permanently`
  String get cancelTripPermanently {
    return Intl.message(
      'Cancel Trip Permanently',
      name: 'cancelTripPermanently',
      desc: '',
      args: [],
    );
  }

  /// `Cancel and delete the trip request completely`
  String get cancelTripPermanentlyDesc {
    return Intl.message(
      'Cancel and delete the trip request completely',
      name: 'cancelTripPermanentlyDesc',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to cancel the entire trip?`
  String get cancelTripConfirmMessage {
    return Intl.message(
      'Are you sure you want to cancel the entire trip?',
      name: 'cancelTripConfirmMessage',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Trip Acceptance`
  String get cancelTripAcceptance {
    return Intl.message(
      'Cancel Trip Acceptance',
      name: 'cancelTripAcceptance',
      desc: '',
      args: [],
    );
  }

  /// `Cancel performing this trip and return it to search`
  String get cancelTripAcceptanceDesc {
    return Intl.message(
      'Cancel performing this trip and return it to search',
      name: 'cancelTripAcceptanceDesc',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to cancel acceptance of this trip?`
  String get cancelTripAcceptanceConfirm {
    return Intl.message(
      'Are you sure you want to cancel acceptance of this trip?',
      name: 'cancelTripAcceptanceConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Acceptance`
  String get cancelAcceptance {
    return Intl.message(
      'Cancel Acceptance',
      name: 'cancelAcceptance',
      desc: '',
      args: [],
    );
  }

  /// `Change driver & search for another driver`
  String get changeDriverSearchAnotherShared {
    return Intl.message(
      'Change driver & search for another driver',
      name: 'changeDriverSearchAnotherShared',
      desc: '',
      args: [],
    );
  }

  /// `Cancel current driver and reopen the trip to drivers`
  String get changeDriverSearchAnotherSharedDesc {
    return Intl.message(
      'Cancel current driver and reopen the trip to drivers',
      name: 'changeDriverSearchAnotherSharedDesc',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to cancel the current driver and search for another driver for this shared trip?`
  String get changeDriverSharedConfirmMessage {
    return Intl.message(
      'Do you want to cancel the current driver and search for another driver for this shared trip?',
      name: 'changeDriverSharedConfirmMessage',
      desc: '',
      args: [],
    );
  }

  /// `Yes, search for driver`
  String get yesSearchDriver {
    return Intl.message(
      'Yes, search for driver',
      name: 'yesSearchDriver',
      desc: '',
      args: [],
    );
  }

  /// `Driver cancelled, searching for a new driver`
  String get driverCancelledSearchingNewDriver {
    return Intl.message(
      'Driver cancelled, searching for a new driver',
      name: 'driverCancelledSearchingNewDriver',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Shared Trip Completely`
  String get cancelSharedTripCompletely {
    return Intl.message(
      'Cancel Shared Trip Completely',
      name: 'cancelSharedTripCompletely',
      desc: '',
      args: [],
    );
  }

  /// `You are the only passenger on this trip, you can cancel it permanently`
  String get cancelSharedTripOnlyPassengerDesc {
    return Intl.message(
      'You are the only passenger on this trip, you can cancel it permanently',
      name: 'cancelSharedTripOnlyPassengerDesc',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to cancel the shared trip permanently?`
  String get cancelSharedTripConfirmMessage {
    return Intl.message(
      'Are you sure you want to cancel the shared trip permanently?',
      name: 'cancelSharedTripConfirmMessage',
      desc: '',
      args: [],
    );
  }

  /// `Shared trip cancelled`
  String get sharedTripCancelled {
    return Intl.message(
      'Shared trip cancelled',
      name: 'sharedTripCancelled',
      desc: '',
      args: [],
    );
  }

  /// `Withdraw from Shared Trip`
  String get withdrawFromSharedTrip {
    return Intl.message(
      'Withdraw from Shared Trip',
      name: 'withdrawFromSharedTrip',
      desc: '',
      args: [],
    );
  }

  /// `There are other passengers; you will withdraw and the trip continues for them`
  String get withdrawFromSharedTripCreatorDesc {
    return Intl.message(
      'There are other passengers; you will withdraw and the trip continues for them',
      name: 'withdrawFromSharedTripCreatorDesc',
      desc: '',
      args: [],
    );
  }

  /// `Withdraw from Trip`
  String get withdrawFromTrip {
    return Intl.message(
      'Withdraw from Trip',
      name: 'withdrawFromTrip',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to withdraw? The trip will continue for remaining passengers.`
  String get withdrawFromTripConfirmMessage {
    return Intl.message(
      'Are you sure you want to withdraw? The trip will continue for remaining passengers.',
      name: 'withdrawFromTripConfirmMessage',
      desc: '',
      args: [],
    );
  }

  /// `Yes, withdraw`
  String get yesWithdraw {
    return Intl.message(
      'Yes, withdraw',
      name: 'yesWithdraw',
      desc: '',
      args: [],
    );
  }

  /// `Withdrawn from trip successfully`
  String get withdrawnSuccessfully {
    return Intl.message(
      'Withdrawn from trip successfully',
      name: 'withdrawnSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Cancel your booking and seat in this shared trip`
  String get withdrawSharedPassengerDesc {
    return Intl.message(
      'Cancel your booking and seat in this shared trip',
      name: 'withdrawSharedPassengerDesc',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to cancel your booking and withdraw from the trip?`
  String get withdrawSharedPassengerConfirmMessage {
    return Intl.message(
      'Are you sure you want to cancel your booking and withdraw from the trip?',
      name: 'withdrawSharedPassengerConfirmMessage',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Withdrawal`
  String get confirmWithdraw {
    return Intl.message(
      'Confirm Withdrawal',
      name: 'confirmWithdraw',
      desc: '',
      args: [],
    );
  }

  /// `Cancel trip and remove all passengers from it`
  String get cancelSharedTripEjectAll {
    return Intl.message(
      'Cancel trip and remove all passengers from it',
      name: 'cancelSharedTripEjectAll',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to cancel the shared trip? All passengers will be notified and removed.`
  String get cancelSharedTripEjectAllConfirmMessage {
    return Intl.message(
      'Are you sure you want to cancel the shared trip? All passengers will be notified and removed.',
      name: 'cancelSharedTripEjectAllConfirmMessage',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Entire Trip`
  String get cancelTripEntirely {
    return Intl.message(
      'Cancel Entire Trip',
      name: 'cancelTripEntirely',
      desc: '',
      args: [],
    );
  }

  /// `Cancellation reason (optional)...`
  String get cancellationReasonOptional {
    return Intl.message(
      'Cancellation reason (optional)...',
      name: 'cancellationReasonOptional',
      desc: '',
      args: [],
    );
  }

  /// `Dismiss`
  String get backOrDismiss {
    return Intl.message('Dismiss', name: 'backOrDismiss', desc: '', args: []);
  }

  /// `members`
  String get membersCount {
    return Intl.message('members', name: 'membersCount', desc: '', args: []);
  }

  /// `Trip Owner`
  String get tripOwner {
    return Intl.message('Trip Owner', name: 'tripOwner', desc: '', args: []);
  }

  /// `🚗 I'm on my way to you`
  String get chatQuickOnMyWay {
    return Intl.message(
      '🚗 I\'m on my way to you',
      name: 'chatQuickOnMyWay',
      desc: '',
      args: [],
    );
  }

  /// `📍 I have arrived at pickup location`
  String get chatQuickArrivedPickup {
    return Intl.message(
      '📍 I have arrived at pickup location',
      name: 'chatQuickArrivedPickup',
      desc: '',
      args: [],
    );
  }

  /// `⏱️ 2 minutes and I'll be there`
  String get chatQuickTwoMinutes {
    return Intl.message(
      '⏱️ 2 minutes and I\'ll be there',
      name: 'chatQuickTwoMinutes',
      desc: '',
      args: [],
    );
  }

  /// `🗺️ Are you at the exact map location?`
  String get chatQuickSameMapLocation {
    return Intl.message(
      '🗺️ Are you at the exact map location?',
      name: 'chatQuickSameMapLocation',
      desc: '',
      args: [],
    );
  }

  /// `🚦 I'm in a slight traffic jam`
  String get chatQuickTraffic {
    return Intl.message(
      '🚦 I\'m in a slight traffic jam',
      name: 'chatQuickTraffic',
      desc: '',
      args: [],
    );
  }

  /// `👍 Alright, thanks`
  String get chatQuickThanks {
    return Intl.message(
      '👍 Alright, thanks',
      name: 'chatQuickThanks',
      desc: '',
      args: [],
    );
  }

  /// `Agreed price:`
  String get acceptedPriceLabel {
    return Intl.message(
      'Agreed price:',
      name: 'acceptedPriceLabel',
      desc: '',
      args: [],
    );
  }

  /// `Map`
  String get mapLabel {
    return Intl.message('Map', name: 'mapLabel', desc: '', args: []);
  }

  /// `Trip Captain`
  String get tripCaptain {
    return Intl.message(
      'Trip Captain',
      name: 'tripCaptain',
      desc: '',
      args: [],
    );
  }

  /// `You (Captain)`
  String get youCaptain {
    return Intl.message(
      'You (Captain)',
      name: 'youCaptain',
      desc: '',
      args: [],
    );
  }

  /// `You`
  String get youLabel {
    return Intl.message('You', name: 'youLabel', desc: '', args: []);
  }

  /// `Waiting to move ⏳`
  String get waitingToMove {
    return Intl.message(
      'Waiting to move ⏳',
      name: 'waitingToMove',
      desc: '',
      args: [],
    );
  }

  /// `On the way to passenger 🚗`
  String get onWayToPassenger {
    return Intl.message(
      'On the way to passenger 🚗',
      name: 'onWayToPassenger',
      desc: '',
      args: [],
    );
  }

  /// `Near the passenger ⏳`
  String get nearPassenger {
    return Intl.message(
      'Near the passenger ⏳',
      name: 'nearPassenger',
      desc: '',
      args: [],
    );
  }

  /// `Arrived at pickup location 📍`
  String get arrivedPickupLocation {
    return Intl.message(
      'Arrived at pickup location 📍',
      name: 'arrivedPickupLocation',
      desc: '',
      args: [],
    );
  }

  /// `Trip in progress 🏁`
  String get tripInProgressStatus {
    return Intl.message(
      'Trip in progress 🏁',
      name: 'tripInProgressStatus',
      desc: '',
      args: [],
    );
  }

  /// `No active trip chats`
  String get noActiveChatsForTrips {
    return Intl.message(
      'No active trip chats',
      name: 'noActiveChatsForTrips',
      desc: '',
      args: [],
    );
  }

  /// `When a new trip is booked, live chat will appear here immediately.`
  String get noActiveChatsDesc {
    return Intl.message(
      'When a new trip is booked, live chat will appear here immediately.',
      name: 'noActiveChatsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Refresh List`
  String get refreshList {
    return Intl.message(
      'Refresh List',
      name: 'refreshList',
      desc: '',
      args: [],
    );
  }

  /// `No messages yet, tap to chat with passenger`
  String get noMessagesYetTapToChat {
    return Intl.message(
      'No messages yet, tap to chat with passenger',
      name: 'noMessagesYetTapToChat',
      desc: '',
      args: [],
    );
  }

  /// `Chat`
  String get chatTabLabel {
    return Intl.message('Chat', name: 'chatTabLabel', desc: '', args: []);
  }

  /// `Tracking`
  String get trackingTabLabel {
    return Intl.message(
      'Tracking',
      name: 'trackingTabLabel',
      desc: '',
      args: [],
    );
  }

  /// `Your Favorite & Saved Locations`
  String get savedLocationsFavoriteTitle {
    return Intl.message(
      'Your Favorite & Saved Locations',
      name: 'savedLocationsFavoriteTitle',
      desc: '',
      args: [],
    );
  }

  /// `You can request an instant trip with one tap to any saved location.`
  String get savedLocationsFavoriteDesc {
    return Intl.message(
      'You can request an instant trip with one tap to any saved location.',
      name: 'savedLocationsFavoriteDesc',
      desc: '',
      args: [],
    );
  }

  /// `Delete saved location?`
  String get deleteSavedLocationTitle {
    return Intl.message(
      'Delete saved location?',
      name: 'deleteSavedLocationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this location from your saved list?`
  String get deleteSavedLocationConfirm {
    return Intl.message(
      'Are you sure you want to delete this location from your saved list?',
      name: 'deleteSavedLocationConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Location deleted successfully`
  String get locationDeletedSuccess {
    return Intl.message(
      'Location deleted successfully',
      name: 'locationDeletedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Delete`
  String get confirmDelete {
    return Intl.message(
      'Confirm Delete',
      name: 'confirmDelete',
      desc: '',
      args: [],
    );
  }

  /// `No saved locations yet`
  String get noSavedLocationsYet {
    return Intl.message(
      'No saved locations yet',
      name: 'noSavedLocationsYet',
      desc: '',
      args: [],
    );
  }

  /// `Save your frequent places like home or work to book future trips with one tap.`
  String get noSavedLocationsDesc {
    return Intl.message(
      'Save your frequent places like home or work to book future trips with one tap.',
      name: 'noSavedLocationsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Saved Location`
  String get savedLocationDefault {
    return Intl.message(
      'Saved Location',
      name: 'savedLocationDefault',
      desc: '',
      args: [],
    );
  }

  /// `Saved Geographic Location`
  String get savedGeographicLocation {
    return Intl.message(
      'Saved Geographic Location',
      name: 'savedGeographicLocation',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get presetHome {
    return Intl.message('Home', name: 'presetHome', desc: '', args: []);
  }

  /// `Work`
  String get presetWork {
    return Intl.message('Work', name: 'presetWork', desc: '', args: []);
  }

  /// `Study`
  String get presetStudy {
    return Intl.message('Study', name: 'presetStudy', desc: '', args: []);
  }

  /// `Shopping`
  String get presetShopping {
    return Intl.message('Shopping', name: 'presetShopping', desc: '', args: []);
  }

  /// `University`
  String get presetUniversity {
    return Intl.message(
      'University',
      name: 'presetUniversity',
      desc: '',
      args: [],
    );
  }

  /// `Custom`
  String get presetCustom {
    return Intl.message('Custom', name: 'presetCustom', desc: '', args: []);
  }

  /// `Location Name`
  String get locationLabelText {
    return Intl.message(
      'Location Name',
      name: 'locationLabelText',
      desc: '',
      args: [],
    );
  }

  /// `e.g., Family home, Office...`
  String get locationHintText {
    return Intl.message(
      'e.g., Family home, Office...',
      name: 'locationHintText',
      desc: '',
      args: [],
    );
  }

  /// `Determining address...`
  String get determiningAddress {
    return Intl.message(
      'Determining address...',
      name: 'determiningAddress',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a name for the location`
  String get pleaseEnterLocationName {
    return Intl.message(
      'Please enter a name for the location',
      name: 'pleaseEnterLocationName',
      desc: '',
      args: [],
    );
  }

  /// `Save Location`
  String get saveLocationButton {
    return Intl.message(
      'Save Location',
      name: 'saveLocationButton',
      desc: '',
      args: [],
    );
  }

  /// `Account details are verified and protected. To update your info, please contact support.`
  String get profileDataProtected {
    return Intl.message(
      'Account details are verified and protected. To update your info, please contact support.',
      name: 'profileDataProtected',
      desc: '',
      args: [],
    );
  }

  /// `Vehicle details and documents are verified and protected. To update, please contact support.`
  String get vehicleDataProtected {
    return Intl.message(
      'Vehicle details and documents are verified and protected. To update, please contact support.',
      name: 'vehicleDataProtected',
      desc: '',
      args: [],
    );
  }

  /// `Min price:`
  String get minPriceLabel {
    return Intl.message(
      'Min price:',
      name: 'minPriceLabel',
      desc: '',
      args: [],
    );
  }

  /// `Max price:`
  String get maxPriceLabel {
    return Intl.message(
      'Max price:',
      name: 'maxPriceLabel',
      desc: '',
      args: [],
    );
  }

  /// `Offer already sent, waiting for passenger approval ⏳`
  String get offerSentWaitingPassenger {
    return Intl.message(
      'Offer already sent, waiting for passenger approval ⏳',
      name: 'offerSentWaitingPassenger',
      desc: '',
      args: [],
    );
  }

  /// `Waiting for acceptance ⏳`
  String get waitingAcceptance {
    return Intl.message(
      'Waiting for acceptance ⏳',
      name: 'waitingAcceptance',
      desc: '',
      args: [],
    );
  }

  /// `Rejected - Send a new offer 🔄`
  String get offerRejectedSendNew {
    return Intl.message(
      'Rejected - Send a new offer 🔄',
      name: 'offerRejectedSendNew',
      desc: '',
      args: [],
    );
  }

  /// `Offer accepted! Transitioning to active trip...`
  String get offerAcceptedTransitioning {
    return Intl.message(
      'Offer accepted! Transitioning to active trip...',
      name: 'offerAcceptedTransitioning',
      desc: '',
      args: [],
    );
  }

  /// `Your offer was accepted! ✅`
  String get offerAcceptedSuccess {
    return Intl.message(
      'Your offer was accepted! ✅',
      name: 'offerAcceptedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Another captain was selected for this trip 🔒`
  String get anotherDriverSelected {
    return Intl.message(
      'Another captain was selected for this trip 🔒',
      name: 'anotherDriverSelected',
      desc: '',
      args: [],
    );
  }

  /// `Apply Search Radius 🚀`
  String get applySearchRadius {
    return Intl.message(
      'Apply Search Radius 🚀',
      name: 'applySearchRadius',
      desc: '',
      args: [],
    );
  }

  /// `No new private trips`
  String get noNewPrivateTrips {
    return Intl.message(
      'No new private trips',
      name: 'noNewPrivateTrips',
      desc: '',
      args: [],
    );
  }

  /// `No new shared trips`
  String get noNewSharedTrips {
    return Intl.message(
      'No new shared trips',
      name: 'noNewSharedTrips',
      desc: '',
      args: [],
    );
  }

  /// `Try expanding the search radius or selecting another date from the filter`
  String get expandSearchRadiusHint {
    return Intl.message(
      'Try expanding the search radius or selecting another date from the filter',
      name: 'expandSearchRadiusHint',
      desc: '',
      args: [],
    );
  }

  /// `Departure Date & Time`
  String get departureDateTime {
    return Intl.message(
      'Departure Date & Time',
      name: 'departureDateTime',
      desc: '',
      args: [],
    );
  }

  /// `Full Car`
  String get fullCarSeats {
    return Intl.message('Full Car', name: 'fullCarSeats', desc: '', args: []);
  }

  /// `seats requested`
  String get seatsRequestedCount {
    return Intl.message(
      'seats requested',
      name: 'seatsRequestedCount',
      desc: '',
      args: [],
    );
  }

  /// `Women only`
  String get womenOnly {
    return Intl.message('Women only', name: 'womenOnly', desc: '', args: []);
  }

  /// `Men only`
  String get menOnly {
    return Intl.message('Men only', name: 'menOnly', desc: '', args: []);
  }

  /// `Driver cancelled the trip, now receiving new offers...`
  String get driverCancelledLookingForOffers {
    return Intl.message(
      'Driver cancelled the trip, now receiving new offers...',
      name: 'driverCancelledLookingForOffers',
      desc: '',
      args: [],
    );
  }

  /// `Driver cancelled the trip, searching for a new driver...`
  String get driverCancelledLookingForDriver {
    return Intl.message(
      'Driver cancelled the trip, searching for a new driver...',
      name: 'driverCancelledLookingForDriver',
      desc: '',
      args: [],
    );
  }

  /// `We found a nearby shared trip!`
  String get foundNearbySharedTrip {
    return Intl.message(
      'We found a nearby shared trip!',
      name: 'foundNearbySharedTrip',
      desc: '',
      args: [],
    );
  }

  /// `Heading to the same destination around the same time. You can join now!`
  String get foundNearbySharedTripDesc {
    return Intl.message(
      'Heading to the same destination around the same time. You can join now!',
      name: 'foundNearbySharedTripDesc',
      desc: '',
      args: [],
    );
  }

  /// `Trip total price`
  String get tripTotalPrice {
    return Intl.message(
      'Trip total price',
      name: 'tripTotalPrice',
      desc: '',
      args: [],
    );
  }

  /// `Join trip and view details`
  String get joinTripAndViewDetails {
    return Intl.message(
      'Join trip and view details',
      name: 'joinTripAndViewDetails',
      desc: '',
      args: [],
    );
  }

  /// `Continue creating my new trip`
  String get continueCreatingMyNewTrip {
    return Intl.message(
      'Continue creating my new trip',
      name: 'continueCreatingMyNewTrip',
      desc: '',
      args: [],
    );
  }

  /// `Automatically calculated based on your vehicle capacity`
  String get calculatedBasedOnCapacity {
    return Intl.message(
      'Automatically calculated based on your vehicle capacity',
      name: 'calculatedBasedOnCapacity',
      desc: '',
      args: [],
    );
  }

  /// `Confirm price and start waiting`
  String get confirmPriceAndStartWaiting {
    return Intl.message(
      'Confirm price and start waiting',
      name: 'confirmPriceAndStartWaiting',
      desc: '',
      args: [],
    );
  }

  /// `Confirm price and activate trip 🚀`
  String get confirmPriceAndActivateTrip {
    return Intl.message(
      'Confirm price and activate trip 🚀',
      name: 'confirmPriceAndActivateTrip',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Pending Trip`
  String get cancelPendingTrip {
    return Intl.message(
      'Cancel Pending Trip',
      name: 'cancelPendingTrip',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to cancel this pending trip?`
  String get cancelPendingTripConfirm {
    return Intl.message(
      'Are you sure you want to cancel this pending trip?',
      name: 'cancelPendingTripConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Yes, cancel`
  String get yesCancel {
    return Intl.message('Yes, cancel', name: 'yesCancel', desc: '', args: []);
  }

  /// `Stay to set price`
  String get stayToSetPrice {
    return Intl.message(
      'Stay to set price',
      name: 'stayToSetPrice',
      desc: '',
      args: [],
    );
  }

  /// `Cancel trip by driver`
  String get tripCancelledByDriver {
    return Intl.message(
      'Cancel trip by driver',
      name: 'tripCancelledByDriver',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to cancel this trip? It will return to the passenger to search for offers again.`
  String get tripCancelledByDriverConfirm {
    return Intl.message(
      'Are you sure you want to cancel this trip? It will return to the passenger to search for offers again.',
      name: 'tripCancelledByDriverConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Trip cancelled and returned to passenger for offers`
  String get tripCancelledAndReturnedToPassenger {
    return Intl.message(
      'Trip cancelled and returned to passenger for offers',
      name: 'tripCancelledAndReturnedToPassenger',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to cancel the trip? Passengers will be notified.`
  String get sharedTripCancelConfirmDriver {
    return Intl.message(
      'Are you sure you want to cancel the trip? Passengers will be notified.',
      name: 'sharedTripCancelConfirmDriver',
      desc: '',
      args: [],
    );
  }

  /// `Trip price:`
  String get tripPricePerSeat {
    return Intl.message(
      'Trip price:',
      name: 'tripPricePerSeat',
      desc: '',
      args: [],
    );
  }

  /// `seats`
  String get seatsUnit {
    return Intl.message('seats', name: 'seatsUnit', desc: '', args: []);
  }

  /// `My current location`
  String get myCurrentLocation {
    return Intl.message(
      'My current location',
      name: 'myCurrentLocation',
      desc: '',
      args: [],
    );
  }

  /// `Selected destination`
  String get selectedDestination {
    return Intl.message(
      'Selected destination',
      name: 'selectedDestination',
      desc: '',
      args: [],
    );
  }

  /// `Search for offers`
  String get searchForOffers {
    return Intl.message(
      'Search for offers',
      name: 'searchForOffers',
      desc: '',
      args: [],
    );
  }

  /// `This trip has been cancelled`
  String get tripIsCancelled {
    return Intl.message(
      'This trip has been cancelled',
      name: 'tripIsCancelled',
      desc: '',
      args: [],
    );
  }

  /// `This trip is completed`
  String get tripIsCompleted {
    return Intl.message(
      'This trip is completed',
      name: 'tripIsCompleted',
      desc: '',
      args: [],
    );
  }

  /// `This trip is unavailable or has been deleted`
  String get tripUnavailableOrDeleted {
    return Intl.message(
      'This trip is unavailable or has been deleted',
      name: 'tripUnavailableOrDeleted',
      desc: '',
      args: [],
    );
  }

  /// `All notifications marked as read`
  String get allNotificationsMarkedRead {
    return Intl.message(
      'All notifications marked as read',
      name: 'allNotificationsMarkedRead',
      desc: '',
      args: [],
    );
  }

  /// `Mark all as read`
  String get markAllAsRead {
    return Intl.message(
      'Mark all as read',
      name: 'markAllAsRead',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get filterAll {
    return Intl.message('All', name: 'filterAll', desc: '', args: []);
  }

  /// `Unread`
  String get filterUnread {
    return Intl.message('Unread', name: 'filterUnread', desc: '', args: []);
  }

  /// `Offers`
  String get filterOffers {
    return Intl.message('Offers', name: 'filterOffers', desc: '', args: []);
  }

  /// `Trips`
  String get filterTrips {
    return Intl.message('Trips', name: 'filterTrips', desc: '', args: []);
  }

  /// `No matching notifications`
  String get noMatchingNotifications {
    return Intl.message(
      'No matching notifications',
      name: 'noMatchingNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Try choosing another filter category to view notifications`
  String get tryAnotherFilterCategory {
    return Intl.message(
      'Try choosing another filter category to view notifications',
      name: 'tryAnotherFilterCategory',
      desc: '',
      args: [],
    );
  }

  /// `We will notify you as soon as updates on your trips or new price offers arrive.`
  String get notificationsStayTuned {
    return Intl.message(
      'We will notify you as soon as updates on your trips or new price offers arrive.',
      name: 'notificationsStayTuned',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get refreshButton {
    return Intl.message('Refresh', name: 'refreshButton', desc: '', args: []);
  }

  /// `New Notification`
  String get newNotificationTitle {
    return Intl.message(
      'New Notification',
      name: 'newNotificationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Price Offer`
  String get badgeOffer {
    return Intl.message('Price Offer', name: 'badgeOffer', desc: '', args: []);
  }

  /// `Trip Update`
  String get badgeTripUpdate {
    return Intl.message(
      'Trip Update',
      name: 'badgeTripUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Trip Completed`
  String get badgeTripCompleted {
    return Intl.message(
      'Trip Completed',
      name: 'badgeTripCompleted',
      desc: '',
      args: [],
    );
  }

  /// `New Message`
  String get badgeNewMessage {
    return Intl.message(
      'New Message',
      name: 'badgeNewMessage',
      desc: '',
      args: [],
    );
  }

  /// `Notification`
  String get badgeNotification {
    return Intl.message(
      'Notification',
      name: 'badgeNotification',
      desc: '',
      args: [],
    );
  }

  /// `View 👈`
  String get viewDetailsAction {
    return Intl.message(
      'View 👈',
      name: 'viewDetailsAction',
      desc: '',
      args: [],
    );
  }

  /// `Just now`
  String get timeJustNow {
    return Intl.message('Just now', name: 'timeJustNow', desc: '', args: []);
  }

  /// `min ago`
  String get timeMinutesAgo {
    return Intl.message('min ago', name: 'timeMinutesAgo', desc: '', args: []);
  }

  /// `Today`
  String get timeToday {
    return Intl.message('Today', name: 'timeToday', desc: '', args: []);
  }

  /// `Yesterday`
  String get timeYesterday {
    return Intl.message('Yesterday', name: 'timeYesterday', desc: '', args: []);
  }

  /// `Pending trip awaiting pricing`
  String get pendingTripAwaitingPricing {
    return Intl.message(
      'Pending trip awaiting pricing',
      name: 'pendingTripAwaitingPricing',
      desc: '',
      args: [],
    );
  }

  /// `Please set the total price for the trip to activate or cancel it`
  String get setPriceOrCancelPendingTrip {
    return Intl.message(
      'Please set the total price for the trip to activate or cancel it',
      name: 'setPriceOrCancelPendingTrip',
      desc: '',
      args: [],
    );
  }

  /// `Trip price confirmed successfully`
  String get tripPriceConfirmedSuccess {
    return Intl.message(
      'Trip price confirmed successfully',
      name: 'tripPriceConfirmedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `National ID`
  String get docNationalId {
    return Intl.message(
      'National ID',
      name: 'docNationalId',
      desc: '',
      args: [],
    );
  }

  /// `Non-Criminal Record Certificate`
  String get docNonCriminal {
    return Intl.message(
      'Non-Criminal Record Certificate',
      name: 'docNonCriminal',
      desc: '',
      args: [],
    );
  }

  /// `Vehicle License`
  String get docVehicleLicense {
    return Intl.message(
      'Vehicle License',
      name: 'docVehicleLicense',
      desc: '',
      args: [],
    );
  }

  /// `Exit Application`
  String get exitAppTitle {
    return Intl.message(
      'Exit Application',
      name: 'exitAppTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to close the app?`
  String get exitAppMessage {
    return Intl.message(
      'Are you sure you want to close the app?',
      name: 'exitAppMessage',
      desc: '',
      args: [],
    );
  }

  /// `Exit`
  String get exitButton {
    return Intl.message('Exit', name: 'exitButton', desc: '', args: []);
  }

  /// `Location services are disabled. Please enable GPS to continue.`
  String get locationServiceDisabled {
    return Intl.message(
      'Location services are disabled. Please enable GPS to continue.',
      name: 'locationServiceDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Location permission is permanently denied. Please enable it in device settings.`
  String get locationPermissionPermanentlyDenied {
    return Intl.message(
      'Location permission is permanently denied. Please enable it in device settings.',
      name: 'locationPermissionPermanentlyDenied',
      desc: '',
      args: [],
    );
  }

  /// `Failed to get current location.`
  String get failedToGetCurrentLocation {
    return Intl.message(
      'Failed to get current location.',
      name: 'failedToGetCurrentLocation',
      desc: '',
      args: [],
    );
  }

  /// `You cannot cancel the trip after it has started. Please contact support.`
  String get cannotCancelTripAfterStart {
    return Intl.message(
      'You cannot cancel the trip after it has started. Please contact support.',
      name: 'cannotCancelTripAfterStart',
      desc: '',
      args: [],
    );
  }

  /// `The trip is full and cannot be booked.`
  String get tripFullCannotBook {
    return Intl.message(
      'The trip is full and cannot be booked.',
      name: 'tripFullCannotBook',
      desc: '',
      args: [],
    );
  }

  /// `Available seats on this trip are insufficient`
  String get notEnoughSeatsAvailable {
    return Intl.message(
      'Available seats on this trip are insufficient',
      name: 'notEnoughSeatsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Terms & Conditions:\n\n`
  String get termsTitle {
    return Intl.message(
      'Terms & Conditions:\n\n',
      name: 'termsTitle',
      desc: '',
      args: [],
    );
  }

  /// `1. Use of Service: The user agrees to comply with local laws and conduct rules during trips.\n\n`
  String get termsContent1 {
    return Intl.message(
      '1. Use of Service: The user agrees to comply with local laws and conduct rules during trips.\n\n',
      name: 'termsContent1',
      desc: '',
      args: [],
    );
  }

  /// `2. Bookings & Offers: The agreed fare is binding upon acceptance of the offer or trip request.\n\n`
  String get termsContent2 {
    return Intl.message(
      '2. Bookings & Offers: The agreed fare is binding upon acceptance of the offer or trip request.\n\n',
      name: 'termsContent2',
      desc: '',
      args: [],
    );
  }

  /// `3. Safety & Security: Using the service for illegal purposes is prohibited. Management may suspend violating accounts.\n\n`
  String get termsContent3 {
    return Intl.message(
      '3. Safety & Security: Using the service for illegal purposes is prohibited. Management may suspend violating accounts.\n\n',
      name: 'termsContent3',
      desc: '',
      args: [],
    );
  }

  /// `4. Cancellation & Changes: Cancellation policy and fees are governed by the established app rules.`
  String get termsContent4 {
    return Intl.message(
      '4. Cancellation & Changes: Cancellation policy and fees are governed by the established app rules.',
      name: 'termsContent4',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy:\n\n`
  String get privacyTitle {
    return Intl.message(
      'Privacy Policy:\n\n',
      name: 'privacyTitle',
      desc: '',
      args: [],
    );
  }

  /// `1. Data Collection: We collect registration info, phone number, and location to provide transit services and facilitate communication.\n\n`
  String get privacyContent1 {
    return Intl.message(
      '1. Data Collection: We collect registration info, phone number, and location to provide transit services and facilitate communication.\n\n',
      name: 'privacyContent1',
      desc: '',
      args: [],
    );
  }

  /// `2. Location Usage: Location is tracked during active trips only to ensure safety, accuracy, and fare calculation.\n\n`
  String get privacyContent2 {
    return Intl.message(
      '2. Location Usage: Location is tracked during active trips only to ensure safety, accuracy, and fare calculation.\n\n',
      name: 'privacyContent2',
      desc: '',
      args: [],
    );
  }

  /// `3. Data Protection: We are committed to protecting your privacy and encrypting your data without unauthorized sharing.\n\n`
  String get privacyContent3 {
    return Intl.message(
      '3. Data Protection: We are committed to protecting your privacy and encrypting your data without unauthorized sharing.\n\n',
      name: 'privacyContent3',
      desc: '',
      args: [],
    );
  }

  /// `4. Alerts: We send notifications related to trip statuses and important updates.`
  String get privacyContent4 {
    return Intl.message(
      '4. Alerts: We send notifications related to trip statuses and important updates.',
      name: 'privacyContent4',
      desc: '',
      args: [],
    );
  }

  /// `Driver App - Tracking Current Trip`
  String get driverTrackingLiveNotificationTitle {
    return Intl.message(
      'Driver App - Tracking Current Trip',
      name: 'driverTrackingLiveNotificationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Sending your live location to passenger`
  String get driverTrackingLiveNotificationText {
    return Intl.message(
      'Sending your live location to passenger',
      name: 'driverTrackingLiveNotificationText',
      desc: '',
      args: [],
    );
  }

  /// `Today  •  {time}`
  String timeTodayAt(Object time) {
    return Intl.message(
      'Today  •  $time',
      name: 'timeTodayAt',
      desc: '',
      args: [time],
    );
  }

  /// `Tomorrow  •  {time}`
  String timeTomorrowAt(Object time) {
    return Intl.message(
      'Tomorrow  •  $time',
      name: 'timeTomorrowAt',
      desc: '',
      args: [time],
    );
  }

  /// `{date}  •  {time}`
  String dateTimeAt(Object date, Object time) {
    return Intl.message(
      '$date  •  $time',
      name: 'dateTimeAt',
      desc: '',
      args: [date, time],
    );
  }

  /// `New message from {senderName}`
  String newMsgFrom(Object senderName) {
    return Intl.message(
      'New message from $senderName',
      name: 'newMsgFrom',
      desc: '',
      args: [senderName],
    );
  }

  /// `Add a new option`
  String get addNewOption {
    return Intl.message(
      'Add a new option',
      name: 'addNewOption',
      desc: '',
      args: [],
    );
  }

  /// `Driver`
  String get driverRole {
    return Intl.message('Driver', name: 'driverRole', desc: '', args: []);
  }

  /// `Passenger`
  String get passengerRole {
    return Intl.message('Passenger', name: 'passengerRole', desc: '', args: []);
  }

  /// `Location permission denied.`
  String get locPermissionDenied {
    return Intl.message(
      'Location permission denied.',
      name: 'locPermissionDenied',
      desc: '',
      args: [],
    );
  }

  /// `No search results found.`
  String get locNoSearchResults {
    return Intl.message(
      'No search results found.',
      name: 'locNoSearchResults',
      desc: '',
      args: [],
    );
  }

  /// `Selected location`
  String get locSpecificLocation {
    return Intl.message(
      'Selected location',
      name: 'locSpecificLocation',
      desc: '',
      args: [],
    );
  }

  /// `Failed to get place details.`
  String get locFailedPlaceDetails {
    return Intl.message(
      'Failed to get place details.',
      name: 'locFailedPlaceDetails',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load place details.`
  String get locFailedPlaceLoad {
    return Intl.message(
      'Failed to load place details.',
      name: 'locFailedPlaceLoad',
      desc: '',
      args: [],
    );
  }

  /// `Failed to get street route.`
  String get locFailedRoutePolyline {
    return Intl.message(
      'Failed to get street route.',
      name: 'locFailedRoutePolyline',
      desc: '',
      args: [],
    );
  }

  /// `Error: {status}`
  String locErrorStatus(Object status) {
    return Intl.message(
      'Error: $status',
      name: 'locErrorStatus',
      desc: '',
      args: [status],
    );
  }

  /// `Failed to submit offer`
  String get failedToSubmitOffer {
    return Intl.message(
      'Failed to submit offer',
      name: 'failedToSubmitOffer',
      desc: '',
      args: [],
    );
  }

  /// `Failed to create trip: unexpected server response`
  String get failedToCreateTripUnexpected {
    return Intl.message(
      'Failed to create trip: unexpected server response',
      name: 'failedToCreateTripUnexpected',
      desc: '',
      args: [],
    );
  }

  /// `This trip has been cancelled`
  String get tripCancelledAlready {
    return Intl.message(
      'This trip has been cancelled',
      name: 'tripCancelledAlready',
      desc: '',
      args: [],
    );
  }

  /// `This trip is completed and finished`
  String get tripCompletedAndFinished {
    return Intl.message(
      'This trip is completed and finished',
      name: 'tripCompletedAndFinished',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to exit the app?`
  String get exitAppConfirm {
    return Intl.message(
      'Are you sure you want to exit the app?',
      name: 'exitAppConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Exit`
  String get exitAppButton {
    return Intl.message('Exit', name: 'exitAppButton', desc: '', args: []);
  }

  /// `Offers`
  String get offersFilter {
    return Intl.message('Offers', name: 'offersFilter', desc: '', args: []);
  }

  /// `Trips`
  String get tripsFilter {
    return Intl.message('Trips', name: 'tripsFilter', desc: '', args: []);
  }

  /// `Trip Completed`
  String get tripStatusCompleted {
    return Intl.message(
      'Trip Completed',
      name: 'tripStatusCompleted',
      desc: '',
      args: [],
    );
  }

  /// `New Message`
  String get newMessageBanner {
    return Intl.message(
      'New Message',
      name: 'newMessageBanner',
      desc: '',
      args: [],
    );
  }

  /// `Just now`
  String get justNow {
    return Intl.message('Just now', name: 'justNow', desc: '', args: []);
  }

  /// `View 👈`
  String get viewNotificationAction {
    return Intl.message(
      'View 👈',
      name: 'viewNotificationAction',
      desc: '',
      args: [],
    );
  }

  /// `Unexpected server response`
  String get unexpectedServerResponse {
    return Intl.message(
      'Unexpected server response',
      name: 'unexpectedServerResponse',
      desc: '',
      args: [],
    );
  }

  /// `Invalid phone number or password, please try again.`
  String get invalidCredentialsDetailed {
    return Intl.message(
      'Invalid phone number or password, please try again.',
      name: 'invalidCredentialsDetailed',
      desc: '',
      args: [],
    );
  }

  /// `Server error during login`
  String get serverErrorDuringLogin {
    return Intl.message(
      'Server error during login',
      name: 'serverErrorDuringLogin',
      desc: '',
      args: [],
    );
  }

  /// `Location permission denied.`
  String get locationPermissionDeniedWarning {
    return Intl.message(
      'Location permission denied.',
      name: 'locationPermissionDeniedWarning',
      desc: '',
      args: [],
    );
  }

  /// `Pending trip awaiting pricing`
  String get pendingPricingTripTitle {
    return Intl.message(
      'Pending trip awaiting pricing',
      name: 'pendingPricingTripTitle',
      desc: '',
      args: [],
    );
  }

  /// `Please set the total price to activate the trip or cancel it`
  String get pendingPricingTripSubtitle {
    return Intl.message(
      'Please set the total price to activate the trip or cancel it',
      name: 'pendingPricingTripSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred`
  String get errorOccurred {
    return Intl.message(
      'An error occurred',
      name: 'errorOccurred',
      desc: '',
      args: [],
    );
  }

  /// `Trip cancelled successfully`
  String get tripCancelledSuccessfully {
    return Intl.message(
      'Trip cancelled successfully',
      name: 'tripCancelledSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Terms and Conditions:\n\n1. Service Usage: Users agree to comply with local laws and conduct standards during trips.\n\n2. Bookings and Offers: Agreed fare becomes binding upon acceptance.\n\n3. Safety and Security: Illegal use is prohibited and accounts may be suspended.\n\n4. Cancellation Policy: Cancellations are subject to platform policies.`
  String get fullTermsText {
    return Intl.message(
      'Terms and Conditions:\n\n1. Service Usage: Users agree to comply with local laws and conduct standards during trips.\n\n2. Bookings and Offers: Agreed fare becomes binding upon acceptance.\n\n3. Safety and Security: Illegal use is prohibited and accounts may be suspended.\n\n4. Cancellation Policy: Cancellations are subject to platform policies.',
      name: 'fullTermsText',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy:\n\n1. Data Collection: We collect registration details, phone number, and location data to deliver transport services.\n\n2. Location Usage: Location is tracked only during active trips for safety, navigation, and fare calculation.\n\n3. Data Protection: We protect and encrypt your data, never sharing with unauthorized parties.\n\n4. Notifications: Important trip status updates are sent via notifications.`
  String get fullPrivacyText {
    return Intl.message(
      'Privacy Policy:\n\n1. Data Collection: We collect registration details, phone number, and location data to deliver transport services.\n\n2. Location Usage: Location is tracked only during active trips for safety, navigation, and fare calculation.\n\n3. Data Protection: We protect and encrypt your data, never sharing with unauthorized parties.\n\n4. Notifications: Important trip status updates are sent via notifications.',
      name: 'fullPrivacyText',
      desc: '',
      args: [],
    );
  }

  /// `All notifications marked as read`
  String get allNotificationsMarkedAsRead {
    return Intl.message(
      'All notifications marked as read',
      name: 'allNotificationsMarkedAsRead',
      desc: '',
      args: [],
    );
  }

  /// `{count} minutes ago`
  String minutesAgo(Object count) {
    return Intl.message(
      '$count minutes ago',
      name: 'minutesAgo',
      desc: '',
      args: [count],
    );
  }

  /// `Today  •  {time}`
  String todayAt(Object time) {
    return Intl.message(
      'Today  •  $time',
      name: 'todayAt',
      desc: '',
      args: [time],
    );
  }

  /// `Yesterday  •  {time}`
  String yesterdayAt(Object time) {
    return Intl.message(
      'Yesterday  •  $time',
      name: 'yesterdayAt',
      desc: '',
      args: [time],
    );
  }

  /// `All`
  String get allNotificationsFilter {
    return Intl.message(
      'All',
      name: 'allNotificationsFilter',
      desc: '',
      args: [],
    );
  }

  /// `Unread`
  String get unreadNotificationsFilter {
    return Intl.message(
      'Unread',
      name: 'unreadNotificationsFilter',
      desc: '',
      args: [],
    );
  }

  /// `Try selecting another category to view notifications`
  String get tryAnotherCategory {
    return Intl.message(
      'Try selecting another category to view notifications',
      name: 'tryAnotherCategory',
      desc: '',
      args: [],
    );
  }

  /// `We'll notify you as soon as there are updates regarding your trips or new offers.`
  String get notificationsUpdatesHint {
    return Intl.message(
      'We\'ll notify you as soon as there are updates regarding your trips or new offers.',
      name: 'notificationsUpdatesHint',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get refreshAction {
    return Intl.message('Refresh', name: 'refreshAction', desc: '', args: []);
  }

  /// `Specified location on map`
  String get specifiedMapLocation {
    return Intl.message(
      'Specified location on map',
      name: 'specifiedMapLocation',
      desc: '',
      args: [],
    );
  }

  /// `Specified Destination`
  String get specifiedDestinationFallback {
    return Intl.message(
      'Specified Destination',
      name: 'specifiedDestinationFallback',
      desc: '',
      args: [],
    );
  }

  /// `Driver identity verification failed`
  String get driverIdentityFailed {
    return Intl.message(
      'Driver identity verification failed',
      name: 'driverIdentityFailed',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Cancellation`
  String get confirmCancel {
    return Intl.message(
      'Confirm Cancellation',
      name: 'confirmCancel',
      desc: '',
      args: [],
    );
  }

  /// `Failed to determine your current location`
  String get cannotDetermineCurrentLocation {
    return Intl.message(
      'Failed to determine your current location',
      name: 'cannotDetermineCurrentLocation',
      desc: '',
      args: [],
    );
  }

  /// `You cannot cancel the trip after it has started. Please contact support.`
  String get cannotCancelAfterTripStart {
    return Intl.message(
      'You cannot cancel the trip after it has started. Please contact support.',
      name: 'cannotCancelAfterTripStart',
      desc: '',
      args: [],
    );
  }

  /// `The trip is fully booked and cannot accept more reservations.`
  String get tripSeatsFullCannotBook {
    return Intl.message(
      'The trip is fully booked and cannot accept more reservations.',
      name: 'tripSeatsFullCannotBook',
      desc: '',
      args: [],
    );
  }

  /// `Insufficient available seats on this trip.`
  String get insufficientAvailableSeats {
    return Intl.message(
      'Insufficient available seats on this trip.',
      name: 'insufficientAvailableSeats',
      desc: '',
      args: [],
    );
  }

  /// `Search for offers`
  String get searchForOffersButton {
    return Intl.message(
      'Search for offers',
      name: 'searchForOffersButton',
      desc: '',
      args: [],
    );
  }

  /// `Verified Driver`
  String get certifiedDriver {
    return Intl.message(
      'Verified Driver',
      name: 'certifiedDriver',
      desc: '',
      args: [],
    );
  }

  /// `Available seats`
  String get availableSeatsUnit {
    return Intl.message(
      'Available seats',
      name: 'availableSeatsUnit',
      desc: '',
      args: [],
    );
  }

  /// `Trip Total`
  String get tripTotalLabel {
    return Intl.message(
      'Trip Total',
      name: 'tripTotalLabel',
      desc: '',
      args: [],
    );
  }

  /// `{price} per passenger when all {seats} seats are full`
  String perSeatWhenFull(Object price, Object seats) {
    return Intl.message(
      '$price per passenger when all $seats seats are full',
      name: 'perSeatWhenFull',
      desc: '',
      args: [price, seats],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Location services are disabled. Please enable GPS to continue.`
  String get locationServicesDisabled {
    return Intl.message(
      'Location services are disabled. Please enable GPS to continue.',
      name: 'locationServicesDisabled',
      desc: '',
      args: [],
    );
  }

  /// `No search results found.`
  String get noSearchResultsFound {
    return Intl.message(
      'No search results found.',
      name: 'noSearchResultsFound',
      desc: '',
      args: [],
    );
  }

  /// `Specified Location`
  String get specifiedLocation {
    return Intl.message(
      'Specified Location',
      name: 'specifiedLocation',
      desc: '',
      args: [],
    );
  }

  /// `Failed to get place details.`
  String get failedToGetPlaceDetails {
    return Intl.message(
      'Failed to get place details.',
      name: 'failedToGetPlaceDetails',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load place details.`
  String get failedToLoadPlaceDetails {
    return Intl.message(
      'Failed to load place details.',
      name: 'failedToLoadPlaceDetails',
      desc: '',
      args: [],
    );
  }

  /// `Failed to get route.`
  String get failedToGetRoute {
    return Intl.message(
      'Failed to get route.',
      name: 'failedToGetRoute',
      desc: '',
      args: [],
    );
  }

  /// `Failed to create trip: Unexpected server response`
  String get failedToCreateTripUnexpectedResponse {
    return Intl.message(
      'Failed to create trip: Unexpected server response',
      name: 'failedToCreateTripUnexpectedResponse',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
