// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(seconds) => "Accept (${seconds}s)";

  static String m1(count) => "Amount to pay for your booking (${count} seats):";

  static String m2(price, currency) =>
      "Auto-accept nearest driver for ${price} ${currency}";

  static String m3(count) => "${count} seats available";

  static String m4(count) => "Available Trips (${count})";

  static String m5(count) => "Capacity: ${count} seats";

  static String m6(price, currency) => "${price} ${currency} Cash";

  static String m7(name, price) =>
      "✅ Driver offer accepted: ${name}\nAgreed price: ${price} JOD";

  static String m8(price) => "Your offer of ${price} JOD has been sent";

  static String m9(price) => "Offered price: ${price} JOD";

  static String m10(count) => "Choose Driver (${count})";

  static String m11(price, currency) =>
      "Are you sure you want to accept this offer for ${price} ${currency}?";

  static String m12(count) => "Confirm & Book (${count} seats) & Enter Chat";

  static String m13(date, time) => "${date}  •  ${time}";

  static String m14(dist) => "Destination ${dist} km";

  static String m15(dist) => "${dist} km from your location";

  static String m16(dist) =>
      "You are ${dist}m away from pickup location. Please get closer (< 200m) to confirm arrival.";

  static String m17(minutes) => "${minutes} min";

  static String m18(currency) => "Increase Fare (+5 ${currency})";

  static String m19(count) => "Joined Passengers (${count})";

  static String m20(count) => "${count} km";

  static String m21(count) => "${count} km";

  static String m22(status) => "Error: ${status}";

  static String m23(count) => "${count} minutes ago";

  static String m24(count) => "${count} min (approx)";

  static String m25(count) => "${count} min";

  static String m26(senderName) => "New message from ${senderName}";

  static String m27(count) => "${count} New Requests";

  static String m28(query) => "No shared trips available to \"${query}\"";

  static String m29(total, price) =>
      "When the vehicle is full (${total} seats), your share drops to ${price} JOD.";

  static String m30(minPrice) =>
      "Offer cannot be less than minimum limit (${minPrice})";

  static String m31(maxPrice) =>
      "Offer cannot exceed maximum limit (${maxPrice})";

  static String m32(count) => "Offers (${count})";

  static String m33(count) =>
      "Passenger share upon completion of ${count} seats:";

  static String m34(price) => "${price} per seat";

  static String m35(price, seats) =>
      "${price} per passenger when all ${seats} seats are full";

  static String m36(count) => "For every ${count} seats";

  static String m37(price, currency) =>
      "Proposed fare updated to ${price} ${currency}";

  static String m38(radius) => "Radius: ${radius} km";

  static String m39(tripId) => "How was your experience on trip #${tripId}?";

  static String m40(name) => "How was your experience with ${name}?";

  static String m41(count) => "${count} Ratings";

  static String m42(count) => "(${count} ratings)";

  static String m43(price, minPrice) =>
      "Total fare ${price} JOD (Drops to ${minPrice} JOD when full)";

  static String m44(count) => "${count} Reserved Seats";

  static String m45(radius) =>
      "Trips within ${radius} km around your location will be fetched.";

  static String m46(km) => "Search Radius: ${km} km";

  static String m47(radius) => "Search Radius: ${radius} km";

  static String m48(count) => "${count} Seats";

  static String m49(count, total) => "${count} / ${total} seats";

  static String m50(count) => "${count} Seat";

  static String m51(occupied, total) => "${occupied} of ${total} seats";

  static String m52(count) => "${count} seats remaining";

  static String m53(count) => "${count} seats requested";

  static String m54(seconds) => "${seconds}s";

  static String m55(price) =>
      "Total fare ${price} JOD split by seat ratio (Vehicle full)";

  static String m56(count) => "${count} Stars";

  static String m57(dist) => "Starts ${dist} km away from you";

  static String m58(time) => "Today  •  ${time}";

  static String m59(time) => "Tomorrow  •  ${time}";

  static String m60(time) => "Today  •  ${time}";

  static String m61(count) => "Total cost for your booking (${count} seats):";

  static String m62(seats) => "Total fare for ${seats} seats";

  static String m63(price) => "Total trip fare ${price} JOD";

  static String m64(participants, booked, total) =>
      "Currently ${participants} participant(s) · ${booked} of ${total} seats booked";

  static String m65(count) => "• ${count} trips";

  static String m66(time) => "Yesterday  •  ${time}";

  static String m67(count) => "(Your booking: ${count} seats)";

  static String m68(count) =>
      "Seats currently reserved for you: ${count} seats";

  static String m69(seats, ratio) =>
      "Your share now (${seats} seats at ${ratio}%):";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "ArrivedCar": MessageLookupByLibrary.simpleMessage("Arrived Car"),
    "EnterYourPasswordConfirm": MessageLookupByLibrary.simpleMessage(
      "Enter Your Password Confirm",
    ),
    "Loading": MessageLookupByLibrary.simpleMessage("Loading..."),
    "NewAddress": MessageLookupByLibrary.simpleMessage("New Address"),
    "SuccessfullySent": MessageLookupByLibrary.simpleMessage(
      "Successfully Sent",
    ),
    "accept": MessageLookupByLibrary.simpleMessage("Accept"),
    "acceptOffer": MessageLookupByLibrary.simpleMessage("Accept Offer"),
    "acceptWithSeconds": m0,
    "acceptedPriceLabel": MessageLookupByLibrary.simpleMessage("Agreed price:"),
    "accountActiveDocsLockedMessage": MessageLookupByLibrary.simpleMessage(
      "All your documents have been verified and your account is active. To update any document, please contact support.",
    ),
    "accountConfirmation": MessageLookupByLibrary.simpleMessage(
      "Account Confirmation",
    ),
    "accountStatusActive": MessageLookupByLibrary.simpleMessage(
      "Account Active & Verified",
    ),
    "accountStatusUnderReview": MessageLookupByLibrary.simpleMessage(
      "Account Under Review",
    ),
    "accountUnderReviewBannerAction": MessageLookupByLibrary.simpleMessage(
      "My Documents",
    ),
    "accountUnderReviewBannerTitle": MessageLookupByLibrary.simpleMessage(
      "Account Under Review",
    ),
    "accountVerifiedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Account verified successfully",
    ),
    "activateConnectionToReceive": MessageLookupByLibrary.simpleMessage(
      "Turn on connection to receive requests",
    ),
    "add": MessageLookupByLibrary.simpleMessage("Add"),
    "addCarModel": MessageLookupByLibrary.simpleMessage("Add New Model"),
    "addCarType": MessageLookupByLibrary.simpleMessage("Add New Car Type"),
    "addCustomOption": MessageLookupByLibrary.simpleMessage("Add new option"),
    "addNewLocation": MessageLookupByLibrary.simpleMessage("Add New Location"),
    "addNewOption": MessageLookupByLibrary.simpleMessage("Add a new option"),
    "addNewTrip": MessageLookupByLibrary.simpleMessage("Add New Trip"),
    "addSharedTrip": MessageLookupByLibrary.simpleMessage("Add Shared Trip"),
    "addTrip": MessageLookupByLibrary.simpleMessage("Add Trip"),
    "additionalNotes": MessageLookupByLibrary.simpleMessage("Additional Notes"),
    "addressAddedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "A New Address Has Been Added Successfully",
    ),
    "adjustWorkingRadius": MessageLookupByLibrary.simpleMessage(
      "Adjust Working Radius",
    ),
    "agree": MessageLookupByLibrary.simpleMessage("Agree"),
    "all": MessageLookupByLibrary.simpleMessage("All"),
    "allDates": MessageLookupByLibrary.simpleMessage("All Dates"),
    "allDocumentsUploadedReview": MessageLookupByLibrary.simpleMessage(
      "All documents uploaded, currently under admin review for activation.",
    ),
    "allGenders": MessageLookupByLibrary.simpleMessage("Everyone"),
    "allNotificationsFilter": MessageLookupByLibrary.simpleMessage("All"),
    "allNotificationsMarkedAsRead": MessageLookupByLibrary.simpleMessage(
      "All notifications marked as read",
    ),
    "allNotificationsMarkedRead": MessageLookupByLibrary.simpleMessage(
      "All notifications marked as read",
    ),
    "allTrips": MessageLookupByLibrary.simpleMessage("All Trips"),
    "amountToPayForBooking": m1,
    "anotherDriverSelected": MessageLookupByLibrary.simpleMessage(
      "Another captain was selected for this trip 🔒",
    ),
    "applyRadius": MessageLookupByLibrary.simpleMessage("Apply Radius"),
    "applySearchRadius": MessageLookupByLibrary.simpleMessage(
      "Apply Search Radius 🚀",
    ),
    "approvedByDriver": MessageLookupByLibrary.simpleMessage(
      "Approved By the driver",
    ),
    "arabic": MessageLookupByLibrary.simpleMessage("Arabic"),
    "areYouSure": MessageLookupByLibrary.simpleMessage("Are You Sure?"),
    "arrivedCustomer": MessageLookupByLibrary.simpleMessage("Arrived Customer"),
    "arrivedPickupLocation": MessageLookupByLibrary.simpleMessage(
      "Arrived at pickup location 📍",
    ),
    "atLeastOneDocumentRequired": MessageLookupByLibrary.simpleMessage(
      "Select at least one document to upload",
    ),
    "attachPhoto": MessageLookupByLibrary.simpleMessage("Attach Photo"),
    "autoAcceptNearestDriver": m2,
    "autoCalculatedVehicleCapacity": MessageLookupByLibrary.simpleMessage(
      "Automatically calculated based on your vehicle capacity",
    ),
    "available": MessageLookupByLibrary.simpleMessage("Available"),
    "availableSeats": MessageLookupByLibrary.simpleMessage("Available Seats"),
    "availableSeatsCount": m3,
    "availableSeatsUnit": MessageLookupByLibrary.simpleMessage(
      "Available seats",
    ),
    "availableTrips": m4,
    "averagePrice": MessageLookupByLibrary.simpleMessage("Average Price"),
    "backOrDismiss": MessageLookupByLibrary.simpleMessage("Dismiss"),
    "backToForgetPassword": MessageLookupByLibrary.simpleMessage(
      "Back to Forgot Password",
    ),
    "badgeNewMessage": MessageLookupByLibrary.simpleMessage("New Message"),
    "badgeNotification": MessageLookupByLibrary.simpleMessage("Notification"),
    "badgeOffer": MessageLookupByLibrary.simpleMessage("Price Offer"),
    "badgeTripCompleted": MessageLookupByLibrary.simpleMessage(
      "Trip Completed",
    ),
    "badgeTripUpdate": MessageLookupByLibrary.simpleMessage("Trip Update"),
    "bannedReasonWarning": MessageLookupByLibrary.simpleMessage(
      "The Reason May Not Be Convincing And You Will Be Banned",
    ),
    "bookedSeatsLabel": MessageLookupByLibrary.simpleMessage("Booked"),
    "bookingConfirmedRedirecting": MessageLookupByLibrary.simpleMessage(
      "Booking confirmed! Redirecting to trip chat...",
    ),
    "byOffer": MessageLookupByLibrary.simpleMessage("By Offer"),
    "calculatedBasedOnCapacity": MessageLookupByLibrary.simpleMessage(
      "Automatically calculated based on your vehicle capacity",
    ),
    "callAction": MessageLookupByLibrary.simpleMessage("Call"),
    "camera": MessageLookupByLibrary.simpleMessage("Camera"),
    "cameraOnly": MessageLookupByLibrary.simpleMessage("Camera only"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cancelAcceptance": MessageLookupByLibrary.simpleMessage(
      "Cancel Acceptance",
    ),
    "cancelAndGoBack": MessageLookupByLibrary.simpleMessage(
      "Cancel and Return",
    ),
    "cancelDueToNoShow": MessageLookupByLibrary.simpleMessage(
      "Cancel due to passenger no-show",
    ),
    "cancelOrder": MessageLookupByLibrary.simpleMessage("Cancel Request"),
    "cancelOrderConfirmMessage": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to cancel this request?",
    ),
    "cancelPendingTrip": MessageLookupByLibrary.simpleMessage(
      "Cancel Pending Trip",
    ),
    "cancelPendingTripConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to cancel this pending trip?",
    ),
    "cancelSharedTripCompletely": MessageLookupByLibrary.simpleMessage(
      "Cancel Shared Trip Completely",
    ),
    "cancelSharedTripConfirmMessage": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to cancel the shared trip permanently?",
    ),
    "cancelSharedTripEjectAll": MessageLookupByLibrary.simpleMessage(
      "Cancel trip and remove all passengers from it",
    ),
    "cancelSharedTripEjectAllConfirmMessage": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to cancel the shared trip? All passengers will be notified and removed.",
    ),
    "cancelSharedTripOnlyPassengerDesc": MessageLookupByLibrary.simpleMessage(
      "You are the only passenger on this trip, you can cancel it permanently",
    ),
    "cancelTrip": MessageLookupByLibrary.simpleMessage("Cancel Trip"),
    "cancelTripAcceptance": MessageLookupByLibrary.simpleMessage(
      "Cancel Trip Acceptance",
    ),
    "cancelTripAcceptanceConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to cancel acceptance of this trip?",
    ),
    "cancelTripAcceptanceDesc": MessageLookupByLibrary.simpleMessage(
      "Cancel performing this trip and return it to search",
    ),
    "cancelTripAction": MessageLookupByLibrary.simpleMessage("Cancel Trip"),
    "cancelTripConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to cancel this trip?",
    ),
    "cancelTripConfirmMessage": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to cancel the entire trip?",
    ),
    "cancelTripEntirely": MessageLookupByLibrary.simpleMessage(
      "Cancel Entire Trip",
    ),
    "cancelTripPermanently": MessageLookupByLibrary.simpleMessage(
      "Cancel Trip Permanently",
    ),
    "cancelTripPermanentlyDesc": MessageLookupByLibrary.simpleMessage(
      "Cancel and delete the trip request completely",
    ),
    "canceled": MessageLookupByLibrary.simpleMessage("Canceled"),
    "canceledTrips": MessageLookupByLibrary.simpleMessage("Canceled"),
    "cancelingReasonPrompt": MessageLookupByLibrary.simpleMessage(
      "What Is The Reason For Canceling The Trip?",
    ),
    "cancellationReasonOptional": MessageLookupByLibrary.simpleMessage(
      "Cancellation reason (optional)...",
    ),
    "cannotCancelAfterTripStart": MessageLookupByLibrary.simpleMessage(
      "You cannot cancel the trip after it has started. Please contact support.",
    ),
    "cannotCancelTripAfterStart": MessageLookupByLibrary.simpleMessage(
      "You cannot cancel the trip after it has started. Please contact support.",
    ),
    "cannotDetermineCurrentLocation": MessageLookupByLibrary.simpleMessage(
      "Failed to determine your current location",
    ),
    "capacitySeats": m5,
    "captainDetails": MessageLookupByLibrary.simpleMessage(
      "Captain & Offer Details",
    ),
    "captainName": MessageLookupByLibrary.simpleMessage("Captain"),
    "carColor": MessageLookupByLibrary.simpleMessage("Car Color"),
    "carColorLabel": MessageLookupByLibrary.simpleMessage("Car Color"),
    "carExterior": MessageLookupByLibrary.simpleMessage("The Car From Outside"),
    "carInsideImageCantBeEmpty": MessageLookupByLibrary.simpleMessage(
      "Car From Inside Image Can\'t Be Empty",
    ),
    "carInterior": MessageLookupByLibrary.simpleMessage("The Car From Inside"),
    "carModelCantBeEmpty": MessageLookupByLibrary.simpleMessage(
      "Car Model Can\'t Be Empty!!",
    ),
    "carModelCantBeLessThan2Char": MessageLookupByLibrary.simpleMessage(
      "Car Model Can\'t Be Less Than 2 Characters",
    ),
    "carModelLabel": MessageLookupByLibrary.simpleMessage("Car Type & Model"),
    "carOutsideImageCantBeEmpty": MessageLookupByLibrary.simpleMessage(
      "Car From Outside Image Can\'t Be Empty",
    ),
    "carTypeAndModel": MessageLookupByLibrary.simpleMessage("Car Type & Model"),
    "carTypeCantBeEmpty": MessageLookupByLibrary.simpleMessage(
      "Car type can\'t be empty",
    ),
    "carTypeCantBeLessThan2Char": MessageLookupByLibrary.simpleMessage(
      "Car type must be at least 2 characters",
    ),
    "cashPayment": m6,
    "certifiedDriver": MessageLookupByLibrary.simpleMessage("Verified Driver"),
    "changeDestination": MessageLookupByLibrary.simpleMessage(
      "Change Destination",
    ),
    "changeDriverAndSearchOffers": MessageLookupByLibrary.simpleMessage(
      "Change driver & search for new offers",
    ),
    "changeDriverAndSearchOffersDesc": MessageLookupByLibrary.simpleMessage(
      "Cancel current driver and receive offers from other drivers",
    ),
    "changeDriverConfirmMessage": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to cancel the current driver and search for new offers?",
    ),
    "changeDriverConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Change Driver",
    ),
    "changeDriverSearchAnotherShared": MessageLookupByLibrary.simpleMessage(
      "Change driver & search for another driver",
    ),
    "changeDriverSearchAnotherSharedDesc": MessageLookupByLibrary.simpleMessage(
      "Cancel current driver and reopen the trip to drivers",
    ),
    "changeDriverSharedConfirmMessage": MessageLookupByLibrary.simpleMessage(
      "Do you want to cancel the current driver and search for another driver for this shared trip?",
    ),
    "changeOrigin": MessageLookupByLibrary.simpleMessage("Change Origin"),
    "changePickupLocation": MessageLookupByLibrary.simpleMessage(
      "Change Pickup Location",
    ),
    "chat": MessageLookupByLibrary.simpleMessage("Chat"),
    "chatAction": MessageLookupByLibrary.simpleMessage("Chat"),
    "chatAgreedPrice": MessageLookupByLibrary.simpleMessage("Agreed Price"),
    "chatClosedToast": MessageLookupByLibrary.simpleMessage(
      "Chat is closed because the trip has ended.",
    ),
    "chatClosedTripEnded": MessageLookupByLibrary.simpleMessage(
      "This trip has ended or was canceled. Chat is closed.",
    ),
    "chatCounterOffer": MessageLookupByLibrary.simpleMessage("Counter Offer"),
    "chatDriver": MessageLookupByLibrary.simpleMessage("Driver"),
    "chatEnterValidPrice": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid price",
    ),
    "chatFrom": MessageLookupByLibrary.simpleMessage("From"),
    "chatOfferAcceptedMsg": m7,
    "chatOfferSentMsg": m8,
    "chatOfferedPrice": m9,
    "chatOnlineNow": MessageLookupByLibrary.simpleMessage("Online now"),
    "chatPhone": MessageLookupByLibrary.simpleMessage("Phone"),
    "chatQuickArrivedPickup": MessageLookupByLibrary.simpleMessage(
      "📍 I have arrived at pickup location",
    ),
    "chatQuickOnMyWay": MessageLookupByLibrary.simpleMessage(
      "🚗 I\'m on my way to you",
    ),
    "chatQuickSameMapLocation": MessageLookupByLibrary.simpleMessage(
      "🗺️ Are you at the exact map location?",
    ),
    "chatQuickThanks": MessageLookupByLibrary.simpleMessage(
      "👍 Alright, thanks",
    ),
    "chatQuickTraffic": MessageLookupByLibrary.simpleMessage(
      "🚦 I\'m in a slight traffic jam",
    ),
    "chatQuickTwoMinutes": MessageLookupByLibrary.simpleMessage(
      "⏱️ 2 minutes and I\'ll be there",
    ),
    "chatSendOffer": MessageLookupByLibrary.simpleMessage("Send Offer"),
    "chatTabLabel": MessageLookupByLibrary.simpleMessage("Chat"),
    "chatTime": MessageLookupByLibrary.simpleMessage("Time"),
    "chatTo": MessageLookupByLibrary.simpleMessage("To"),
    "chatTypeMessage": MessageLookupByLibrary.simpleMessage(
      "Type a message...",
    ),
    "chooseDepartureTime": MessageLookupByLibrary.simpleMessage(
      "Choose Departure Time",
    ),
    "chooseDepartureTimeOptional": MessageLookupByLibrary.simpleMessage(
      "Choose departure time (optional)",
    ),
    "chooseDriverWithCount": m10,
    "chooseImageSource": MessageLookupByLibrary.simpleMessage(
      "Choose Image Source",
    ),
    "choosePickupLocation": MessageLookupByLibrary.simpleMessage(
      "Choose Pickup Location",
    ),
    "chooseSeatsToBook": MessageLookupByLibrary.simpleMessage(
      "Choose number of seats to book:",
    ),
    "chooseTime": MessageLookupByLibrary.simpleMessage("Choose Time"),
    "clearFilters": MessageLookupByLibrary.simpleMessage("Clear Filters"),
    "clearTime": MessageLookupByLibrary.simpleMessage("Clear time"),
    "completeTrip": MessageLookupByLibrary.simpleMessage("Complete Trip"),
    "completed": MessageLookupByLibrary.simpleMessage("Completed"),
    "completedTrips": MessageLookupByLibrary.simpleMessage("Completed"),
    "completedTripsStat": MessageLookupByLibrary.simpleMessage(
      "Completed Trips",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "confirmAccept": MessageLookupByLibrary.simpleMessage("Confirm Acceptance"),
    "confirmAcceptOffer": MessageLookupByLibrary.simpleMessage(
      "Confirm Offer Acceptance",
    ),
    "confirmAcceptOfferLoading": MessageLookupByLibrary.simpleMessage(
      "Accepting offer and confirming booking...",
    ),
    "confirmAndSearchTrips": MessageLookupByLibrary.simpleMessage(
      "Confirm & Search Trips",
    ),
    "confirmArrivalAtClient": MessageLookupByLibrary.simpleMessage(
      "Confirm arrival at client (Arrived)",
    ),
    "confirmArrivalAtPassengers": MessageLookupByLibrary.simpleMessage(
      "Confirm arrival at passengers (Arrived)",
    ),
    "confirmCancel": MessageLookupByLibrary.simpleMessage(
      "Confirm Cancellation",
    ),
    "confirmCancelTrip": MessageLookupByLibrary.simpleMessage("Cancel Trip"),
    "confirmDelete": MessageLookupByLibrary.simpleMessage("Confirm Delete"),
    "confirmDestination": MessageLookupByLibrary.simpleMessage(
      "Confirm Destination",
    ),
    "confirmDestinationAndSearch": MessageLookupByLibrary.simpleMessage(
      "Confirm Destination & Search",
    ),
    "confirmDestinationLocation": MessageLookupByLibrary.simpleMessage(
      "Confirm Destination",
    ),
    "confirmEndTrip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to end the trip?",
    ),
    "confirmExtraSeatsAndChat": MessageLookupByLibrary.simpleMessage(
      "Confirm Extra Seats & Enter Chat",
    ),
    "confirmOfferQuestion": m11,
    "confirmPassword": MessageLookupByLibrary.simpleMessage("Confirm Password"),
    "confirmPickupAndSearch": MessageLookupByLibrary.simpleMessage(
      "Confirm Pickup & Search",
    ),
    "confirmPickupLocation": MessageLookupByLibrary.simpleMessage(
      "Confirm Pickup Location",
    ),
    "confirmPriceAndActivateTrip": MessageLookupByLibrary.simpleMessage(
      "Confirm price and activate trip 🚀",
    ),
    "confirmPriceAndStartWaiting": MessageLookupByLibrary.simpleMessage(
      "Confirm price and start waiting",
    ),
    "confirmRouteAndSearch": MessageLookupByLibrary.simpleMessage(
      "Confirm Route & Search Trips",
    ),
    "confirmSeatsAndChat": m12,
    "confirmStartLocation": MessageLookupByLibrary.simpleMessage(
      "Confirm Start Location",
    ),
    "confirmStartTrip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to start the trip?",
    ),
    "confirmSuspendTrip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to suspend the trip?",
    ),
    "confirmTripRequest": MessageLookupByLibrary.simpleMessage(
      "Confirm Trip Request",
    ),
    "confirmWithdraw": MessageLookupByLibrary.simpleMessage(
      "Confirm Withdrawal",
    ),
    "connectionTimeout": MessageLookupByLibrary.simpleMessage(
      "Connection timed out",
    ),
    "contactDriver": MessageLookupByLibrary.simpleMessage("Contact Driver"),
    "contactNow": MessageLookupByLibrary.simpleMessage("Contact Now"),
    "contactUs": MessageLookupByLibrary.simpleMessage("Contact Us"),
    "continueAction": MessageLookupByLibrary.simpleMessage("Continue"),
    "continueActiveTrip": MessageLookupByLibrary.simpleMessage(
      "Continue Trip Route",
    ),
    "continueCreatingMyNewTrip": MessageLookupByLibrary.simpleMessage(
      "Continue creating my new trip",
    ),
    "continueTrip": MessageLookupByLibrary.simpleMessage("Continue"),
    "continueWaiting": MessageLookupByLibrary.simpleMessage("Continue Waiting"),
    "counterOfferSent": MessageLookupByLibrary.simpleMessage(
      "Counter offer sent",
    ),
    "createNewSharedTrip": MessageLookupByLibrary.simpleMessage(
      "Create New Shared Trip",
    ),
    "createTripButton": MessageLookupByLibrary.simpleMessage("Create Trip"),
    "create_new_dialog_welcome": MessageLookupByLibrary.simpleMessage(
      "Welcome, please choose trip type",
    ),
    "criminalRecordCantBeEmpty": MessageLookupByLibrary.simpleMessage(
      "Criminal record certificate is required",
    ),
    "criminalRecordDocument": MessageLookupByLibrary.simpleMessage(
      "Certificate of No Criminal Record",
    ),
    "criminalRecordExpiryCantBeEmpty": MessageLookupByLibrary.simpleMessage(
      "Please select criminal record expiry date",
    ),
    "currentGpsLocation": MessageLookupByLibrary.simpleMessage(
      "My Current Location (GPS)",
    ),
    "currentLocationFallback": MessageLookupByLibrary.simpleMessage(
      "My Current Location",
    ),
    "currentOngoingTrip": MessageLookupByLibrary.simpleMessage(
      "Your Current Trip",
    ),
    "currentPassengers": MessageLookupByLibrary.simpleMessage(
      "Current Passengers",
    ),
    "currentTrips": MessageLookupByLibrary.simpleMessage("Current"),
    "currentTripsStat": MessageLookupByLibrary.simpleMessage("Current Trips"),
    "currentW": MessageLookupByLibrary.simpleMessage("Current"),
    "dateTimeAt": m13,
    "dateTimeLabel": MessageLookupByLibrary.simpleMessage("Date & Time"),
    "defaultTextChangeable": MessageLookupByLibrary.simpleMessage(
      "This Default Text Is Subject To Change And Modification",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteSavedLocationConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this location from your saved list?",
    ),
    "deleteSavedLocationTitle": MessageLookupByLibrary.simpleMessage(
      "Delete saved location?",
    ),
    "departureDateTime": MessageLookupByLibrary.simpleMessage(
      "Departure Date & Time",
    ),
    "departureTimeLabel": MessageLookupByLibrary.simpleMessage(
      "Departure Time",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("Destination"),
    "destinationDistanceKm": m14,
    "destinationLocation": MessageLookupByLibrary.simpleMessage(
      "Destination Location",
    ),
    "destinationPoint": MessageLookupByLibrary.simpleMessage("Destination"),
    "destinationSelected": MessageLookupByLibrary.simpleMessage(
      "Destination selected",
    ),
    "details": MessageLookupByLibrary.simpleMessage("Details"),
    "detailsAndBooking": MessageLookupByLibrary.simpleMessage(
      "Details & Booking",
    ),
    "determiningAddress": MessageLookupByLibrary.simpleMessage(
      "Determining address...",
    ),
    "disagree": MessageLookupByLibrary.simpleMessage("Disagree"),
    "dismiss": MessageLookupByLibrary.simpleMessage("Dismiss"),
    "distanceToLocation": m15,
    "distanceToPickupNotice": m16,
    "doYouWantToLogout": MessageLookupByLibrary.simpleMessage(
      "Do you want to logout?",
    ),
    "docNationalId": MessageLookupByLibrary.simpleMessage("National ID"),
    "docNonCriminal": MessageLookupByLibrary.simpleMessage(
      "Non-Criminal Record Certificate",
    ),
    "docVehicleLicense": MessageLookupByLibrary.simpleMessage(
      "Vehicle License",
    ),
    "documentApprovedLocked": MessageLookupByLibrary.simpleMessage(
      "Approved & Locked 🔒",
    ),
    "documentExpired": MessageLookupByLibrary.simpleMessage("Expired"),
    "documentMissing": MessageLookupByLibrary.simpleMessage("Required"),
    "documentUploadSuccess": MessageLookupByLibrary.simpleMessage(
      "Documents uploaded successfully",
    ),
    "documentUploaded": MessageLookupByLibrary.simpleMessage("Uploaded"),
    "done": MessageLookupByLibrary.simpleMessage("done"),
    "driver": MessageLookupByLibrary.simpleMessage("Driver"),
    "driverAcceptedWaitingMove": MessageLookupByLibrary.simpleMessage(
      "Driver accepted and is preparing to move to your location",
    ),
    "driverAlmostThere": MessageLookupByLibrary.simpleMessage(
      "Your driver is almost there!",
    ),
    "driverApprovedWaitingMovement": MessageLookupByLibrary.simpleMessage(
      "Driver accepted and waiting to move towards you",
    ),
    "driverArrived": MessageLookupByLibrary.simpleMessage("Driver Has Arrived"),
    "driverArrivedPickup": MessageLookupByLibrary.simpleMessage(
      "Driver arrived at pickup point",
    ),
    "driverCancelledLookingForDriver": MessageLookupByLibrary.simpleMessage(
      "Driver cancelled the trip, searching for a new driver...",
    ),
    "driverCancelledLookingForOffers": MessageLookupByLibrary.simpleMessage(
      "Driver cancelled the trip, now receiving new offers...",
    ),
    "driverCancelledReceivingOffers": MessageLookupByLibrary.simpleMessage(
      "Driver cancelled, receiving new offers",
    ),
    "driverCancelledSearchingNewDriver": MessageLookupByLibrary.simpleMessage(
      "Driver cancelled, searching for a new driver",
    ),
    "driverCar": MessageLookupByLibrary.simpleMessage("Driver Car"),
    "driverCarLabel": MessageLookupByLibrary.simpleMessage("Driver\'s Car"),
    "driverComingToPickYouUp": MessageLookupByLibrary.simpleMessage(
      "Your driver is heading to your location",
    ),
    "driverDefaultName": MessageLookupByLibrary.simpleMessage("Driver"),
    "driverDetails": MessageLookupByLibrary.simpleMessage("Driver Details"),
    "driverIdentityFailed": MessageLookupByLibrary.simpleMessage(
      "Driver identity verification failed",
    ),
    "driverInfo": MessageLookupByLibrary.simpleMessage("Driver Info"),
    "driverIsNear": MessageLookupByLibrary.simpleMessage("Driver Is Nearby"),
    "driverLabel": MessageLookupByLibrary.simpleMessage("Driver"),
    "driverOnTheWay": MessageLookupByLibrary.simpleMessage(
      "Driver is on the way",
    ),
    "driverPhoneNotAvailable": MessageLookupByLibrary.simpleMessage(
      "Phone number is currently unavailable",
    ),
    "driverPriceNotice": MessageLookupByLibrary.simpleMessage(
      "Price will be set by driver and you can review before confirmation",
    ),
    "driverRatesPassengerNotSupported": MessageLookupByLibrary.simpleMessage(
      "Rating passengers is not available at this time",
    ),
    "driverRatingsEmpty": MessageLookupByLibrary.simpleMessage(
      "No ratings for this driver yet",
    ),
    "driverRatingsTitle": MessageLookupByLibrary.simpleMessage(
      "Driver Ratings",
    ),
    "driverRole": MessageLookupByLibrary.simpleMessage("Driver"),
    "driverTrackingLiveNotificationText": MessageLookupByLibrary.simpleMessage(
      "Sending your live location to passenger",
    ),
    "driverTrackingLiveNotificationTitle": MessageLookupByLibrary.simpleMessage(
      "Driver App - Tracking Current Trip",
    ),
    "driverWaitingForYou": MessageLookupByLibrary.simpleMessage(
      "Your driver is waiting for you",
    ),
    "drivingLicense": MessageLookupByLibrary.simpleMessage("Driving License"),
    "earliestDepartureTime": MessageLookupByLibrary.simpleMessage(
      "Earliest Departure Time",
    ),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "editAction": MessageLookupByLibrary.simpleMessage("Edit"),
    "editProfile": MessageLookupByLibrary.simpleMessage("Edit Profile"),
    "editRatingBtn": MessageLookupByLibrary.simpleMessage("Edit Rating"),
    "email": MessageLookupByLibrary.simpleMessage("Email"),
    "enableLocationAndRetry": MessageLookupByLibrary.simpleMessage(
      "Enable Location & Retry",
    ),
    "endPrivateTripAction": MessageLookupByLibrary.simpleMessage("End Trip"),
    "endSharedTripAction": MessageLookupByLibrary.simpleMessage(
      "End Shared Trip",
    ),
    "endTrip": MessageLookupByLibrary.simpleMessage("End Trip"),
    "endTripAction": MessageLookupByLibrary.simpleMessage("End Trip"),
    "english": MessageLookupByLibrary.simpleMessage("English"),
    "enjoyYourTrip": MessageLookupByLibrary.simpleMessage(
      "Sit back and enjoy your ride",
    ),
    "enterCarModel": MessageLookupByLibrary.simpleMessage(
      "Enter Your Car Model",
    ),
    "enterCarType": MessageLookupByLibrary.simpleMessage("Enter Your Car Type"),
    "enterCodeSentToMobile": MessageLookupByLibrary.simpleMessage(
      "Enter The Code Sent To The Mobile Number",
    ),
    "enterDestinationLocation": MessageLookupByLibrary.simpleMessage(
      "Enter Destination Location",
    ),
    "enterEmail": MessageLookupByLibrary.simpleMessage("Enter email"),
    "enterNewPassword": MessageLookupByLibrary.simpleMessage(
      "Enter Your New Password",
    ),
    "enterNumberOfSeats": MessageLookupByLibrary.simpleMessage(
      "Enter Number Of Seats",
    ),
    "enterPasswordConfirm": MessageLookupByLibrary.simpleMessage(
      "Enter Your Password Confirm",
    ),
    "enterPlateNumber": MessageLookupByLibrary.simpleMessage(
      "Enter Plate Number",
    ),
    "enterProposedFare": MessageLookupByLibrary.simpleMessage(
      "Enter proposed fare",
    ),
    "enterStartingLocation": MessageLookupByLibrary.simpleMessage(
      "Enter Starting Location",
    ),
    "enterTheMobileNumberForAccess": MessageLookupByLibrary.simpleMessage(
      "Enter The Mobile Number, To Be Able To Enter The Application",
    ),
    "enterTripChatDirectly": MessageLookupByLibrary.simpleMessage(
      "Enter Trip Chat Directly",
    ),
    "enterYourMobileNumber": MessageLookupByLibrary.simpleMessage(
      "Enter Your Mobile Number",
    ),
    "enterYourName": MessageLookupByLibrary.simpleMessage("Enter Your Name"),
    "enterYourPassword": MessageLookupByLibrary.simpleMessage(
      "Enter Your Password",
    ),
    "enterYourReason": MessageLookupByLibrary.simpleMessage(
      "Enter Your Reason",
    ),
    "error": MessageLookupByLibrary.simpleMessage("Error"),
    "errorCannotRateSelf": MessageLookupByLibrary.simpleMessage(
      "You cannot rate yourself",
    ),
    "errorDriverNotAssigned": MessageLookupByLibrary.simpleMessage(
      "No driver assigned to this trip",
    ),
    "errorNotTripPassenger": MessageLookupByLibrary.simpleMessage(
      "You were not a passenger on this trip",
    ),
    "errorOccurred": MessageLookupByLibrary.simpleMessage("An error occurred"),
    "errorRatingFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to submit rating, please try again",
    ),
    "errorRatingLocked": MessageLookupByLibrary.simpleMessage(
      "The 24-hour edit window has expired — rating is locked",
    ),
    "errorTripNotFinished": MessageLookupByLibrary.simpleMessage(
      "The trip has not ended yet and cannot be rated",
    ),
    "errorTripNotFound": MessageLookupByLibrary.simpleMessage("Trip not found"),
    "estimatedDistance": MessageLookupByLibrary.simpleMessage(
      "Estimated Distance",
    ),
    "estimatedDuration": MessageLookupByLibrary.simpleMessage(
      "Estimated Duration",
    ),
    "etaMinutes": m17,
    "everyone": MessageLookupByLibrary.simpleMessage("Everyone"),
    "exitAppButton": MessageLookupByLibrary.simpleMessage("Exit"),
    "exitAppConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to exit the app?",
    ),
    "exitAppMessage": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to close the app?",
    ),
    "exitAppTitle": MessageLookupByLibrary.simpleMessage("Exit Application"),
    "exitButton": MessageLookupByLibrary.simpleMessage("Exit"),
    "expandSearchRadiusHint": MessageLookupByLibrary.simpleMessage(
      "Try expanding the search radius or selecting another date from the filter",
    ),
    "experienceFuture": MessageLookupByLibrary.simpleMessage(
      "Experience the Future",
    ),
    "expiryDate": MessageLookupByLibrary.simpleMessage("Expiry Date"),
    "expiryDateOptional": MessageLookupByLibrary.simpleMessage(
      "Expiry Date (optional)",
    ),
    "failedToCreateTripUnexpected": MessageLookupByLibrary.simpleMessage(
      "Failed to create trip: unexpected server response",
    ),
    "failedToCreateTripUnexpectedResponse":
        MessageLookupByLibrary.simpleMessage(
          "Failed to create trip: Unexpected server response",
        ),
    "failedToGetCurrentLocation": MessageLookupByLibrary.simpleMessage(
      "Failed to get current location.",
    ),
    "failedToGetPlaceDetails": MessageLookupByLibrary.simpleMessage(
      "Failed to get place details.",
    ),
    "failedToGetRoute": MessageLookupByLibrary.simpleMessage(
      "Failed to get route.",
    ),
    "failedToLoadPlaceDetails": MessageLookupByLibrary.simpleMessage(
      "Failed to load place details.",
    ),
    "failedToSendMessage": MessageLookupByLibrary.simpleMessage(
      "Failed to send message. Please try again.",
    ),
    "failedToSendPriceOffer": MessageLookupByLibrary.simpleMessage(
      "Failed to send price offer, please try again",
    ),
    "failedToSubmitOffer": MessageLookupByLibrary.simpleMessage(
      "Failed to submit offer",
    ),
    "female": MessageLookupByLibrary.simpleMessage("Female"),
    "femaleOnly": MessageLookupByLibrary.simpleMessage("Female Only"),
    "females": MessageLookupByLibrary.simpleMessage("Females"),
    "femalesOnly": MessageLookupByLibrary.simpleMessage("Females only"),
    "fileSelected": MessageLookupByLibrary.simpleMessage("File selected"),
    "filterAll": MessageLookupByLibrary.simpleMessage("All"),
    "filterOffers": MessageLookupByLibrary.simpleMessage("Offers"),
    "filterTrips": MessageLookupByLibrary.simpleMessage("Trips"),
    "filterUnread": MessageLookupByLibrary.simpleMessage("Unread"),
    "forgetPassword": MessageLookupByLibrary.simpleMessage("Forget Password"),
    "foundNearbySharedTrip": MessageLookupByLibrary.simpleMessage(
      "We found a nearby shared trip!",
    ),
    "foundNearbySharedTripDesc": MessageLookupByLibrary.simpleMessage(
      "Heading to the same destination around the same time. You can join now!",
    ),
    "fourSeats": MessageLookupByLibrary.simpleMessage("4 Seats"),
    "fullCarSeats": MessageLookupByLibrary.simpleMessage("Full Car"),
    "fullName": MessageLookupByLibrary.simpleMessage("Full Name"),
    "fullPrivacyText": MessageLookupByLibrary.simpleMessage(
      "Privacy Policy:\n\n1. Data Collection: We collect registration details, phone number, and location data to deliver transport services.\n\n2. Location Usage: Location is tracked only during active trips for safety, navigation, and fare calculation.\n\n3. Data Protection: We protect and encrypt your data, never sharing with unauthorized parties.\n\n4. Notifications: Important trip status updates are sent via notifications.",
    ),
    "fullTermsText": MessageLookupByLibrary.simpleMessage(
      "Terms and Conditions:\n\n1. Service Usage: Users agree to comply with local laws and conduct standards during trips.\n\n2. Bookings and Offers: Agreed fare becomes binding upon acceptance.\n\n3. Safety and Security: Illegal use is prohibited and accounts may be suspended.\n\n4. Cancellation Policy: Cancellations are subject to platform policies.",
    ),
    "gallery": MessageLookupByLibrary.simpleMessage("Gallery"),
    "gender": MessageLookupByLibrary.simpleMessage("Gender"),
    "genderAll": MessageLookupByLibrary.simpleMessage("All"),
    "genderFemaleOnly": MessageLookupByLibrary.simpleMessage("Female Only"),
    "genderMaleOnly": MessageLookupByLibrary.simpleMessage("Male Only"),
    "genderPreference": MessageLookupByLibrary.simpleMessage(
      "Gender Preference",
    ),
    "genderPreferenceLabel": MessageLookupByLibrary.simpleMessage(
      "Gender Preference",
    ),
    "goToDocuments": MessageLookupByLibrary.simpleMessage("Go to My Documents"),
    "hasActiveTripNotice": MessageLookupByLibrary.simpleMessage(
      "You have an active ongoing trip",
    ),
    "heroTripsSubtitle": MessageLookupByLibrary.simpleMessage(
      "New requests waiting in your current radius — review details and make offers now.",
    ),
    "iAgree": MessageLookupByLibrary.simpleMessage("I Agree"),
    "iAmClose": MessageLookupByLibrary.simpleMessage("I\'m Close"),
    "inTrip": MessageLookupByLibrary.simpleMessage("In Trip"),
    "increaseFarePlus5": m18,
    "increaseSeats": MessageLookupByLibrary.simpleMessage("Add Seats"),
    "insufficientAvailableSeats": MessageLookupByLibrary.simpleMessage(
      "Insufficient available seats on this trip.",
    ),
    "insufficientSeats": MessageLookupByLibrary.simpleMessage(
      "Not enough available seats",
    ),
    "introMessage": MessageLookupByLibrary.simpleMessage(
      "Simplifying your digital experience with seamless integration and powerful tools at your fingertips.",
    ),
    "invalidCredentialsDetailed": MessageLookupByLibrary.simpleMessage(
      "Invalid phone number or password, please try again.",
    ),
    "invalidLoginCredentials": MessageLookupByLibrary.simpleMessage(
      "Invalid mobile number or password, please try again",
    ),
    "jod": MessageLookupByLibrary.simpleMessage("JOD"),
    "joinInnovation": MessageLookupByLibrary.simpleMessage(
      "Join us as we bring you the latest in technology, designed to empower and inspire your day-to-day.",
    ),
    "joinThisSharedTrip": MessageLookupByLibrary.simpleMessage(
      "Join this shared trip 🚀",
    ),
    "joinTripAndViewDetails": MessageLookupByLibrary.simpleMessage(
      "Join trip and view details",
    ),
    "joinedInThisTrip": MessageLookupByLibrary.simpleMessage(
      "Participant in this trip",
    ),
    "joinedPassengersTitle": m19,
    "joinedSharedTripSuccess": MessageLookupByLibrary.simpleMessage(
      "Successfully joined shared trip",
    ),
    "joining": MessageLookupByLibrary.simpleMessage("Joining..."),
    "joiningSharedTrip": MessageLookupByLibrary.simpleMessage(
      "Joining shared trip...",
    ),
    "journeyStartsHere": MessageLookupByLibrary.simpleMessage(
      "Your Journey Starts Here",
    ),
    "justNow": MessageLookupByLibrary.simpleMessage("Just now"),
    "kmDistance": m20,
    "kmOnly": MessageLookupByLibrary.simpleMessage("km"),
    "kmUnit": m21,
    "kycRejected": MessageLookupByLibrary.simpleMessage(
      "Driver account activation was rejected. Please review and update your documents and license from the edit page.",
    ),
    "kycRejectedTitle": MessageLookupByLibrary.simpleMessage(
      "Account Rejected",
    ),
    "kycRequiredMessage": MessageLookupByLibrary.simpleMessage(
      "You cannot create trips or make offers until your account is activated by admin. Upload your documents and wait for activation.",
    ),
    "kycRequiredTitle": MessageLookupByLibrary.simpleMessage(
      "Account Under Review",
    ),
    "kycUnderReview": MessageLookupByLibrary.simpleMessage(
      "Your account is under administrative review (KYC). Browsing and accepting trips is temporarily disabled pending approval.",
    ),
    "kycUnderReviewTitle": MessageLookupByLibrary.simpleMessage(
      "Account Under Review (KYC)",
    ),
    "legendaryDriver": MessageLookupByLibrary.simpleMessage("Legendary Driver"),
    "licenseImageCantBeEmpty": MessageLookupByLibrary.simpleMessage(
      "License Image Can\'t Be Empty",
    ),
    "liveRequestsAvailable": MessageLookupByLibrary.simpleMessage(
      "New requests available now!",
    ),
    "liveTrackingInProgress": MessageLookupByLibrary.simpleMessage(
      "Live tracking in progress 📍",
    ),
    "locErrorStatus": m22,
    "locFailedPlaceDetails": MessageLookupByLibrary.simpleMessage(
      "Failed to get place details.",
    ),
    "locFailedPlaceLoad": MessageLookupByLibrary.simpleMessage(
      "Failed to load place details.",
    ),
    "locFailedRoutePolyline": MessageLookupByLibrary.simpleMessage(
      "Failed to get street route.",
    ),
    "locNoSearchResults": MessageLookupByLibrary.simpleMessage(
      "No search results found.",
    ),
    "locPermissionDenied": MessageLookupByLibrary.simpleMessage(
      "Location permission denied.",
    ),
    "locSpecificLocation": MessageLookupByLibrary.simpleMessage(
      "Selected location",
    ),
    "location": MessageLookupByLibrary.simpleMessage("Location"),
    "locationDeletedSuccess": MessageLookupByLibrary.simpleMessage(
      "Location deleted successfully",
    ),
    "locationHintText": MessageLookupByLibrary.simpleMessage(
      "e.g., Family home, Office...",
    ),
    "locationLabelText": MessageLookupByLibrary.simpleMessage("Location Name"),
    "locationPermissionDenied": MessageLookupByLibrary.simpleMessage(
      "Location permission was denied.",
    ),
    "locationPermissionDeniedWarning": MessageLookupByLibrary.simpleMessage(
      "Location permission denied.",
    ),
    "locationPermissionPermanentlyDenied": MessageLookupByLibrary.simpleMessage(
      "Location permission is permanently denied. Please enable it in device settings.",
    ),
    "locationServiceDisabled": MessageLookupByLibrary.simpleMessage(
      "Location services are disabled. Please enable GPS to continue.",
    ),
    "locationServicesDisabled": MessageLookupByLibrary.simpleMessage(
      "Location services are disabled. Please enable GPS to continue.",
    ),
    "lockedDocumentNotice": MessageLookupByLibrary.simpleMessage(
      "This document has been verified. To update it, please contact support.",
    ),
    "loginSuccessful": MessageLookupByLibrary.simpleMessage("Login Successful"),
    "loginbutton": MessageLookupByLibrary.simpleMessage("Login"),
    "logindialogbutton": MessageLookupByLibrary.simpleMessage("Continue"),
    "logindialogdriver": MessageLookupByLibrary.simpleMessage("Driver"),
    "logindialogpassenger": MessageLookupByLibrary.simpleMessage("Passenger"),
    "logindialogwelcome": MessageLookupByLibrary.simpleMessage(
      "Welcome, You Have To Choose The Type Of Account",
    ),
    "logindonthaveaccount": MessageLookupByLibrary.simpleMessage(
      "Don\'t Have An Account?",
    ),
    "loginforgetpassword": MessageLookupByLibrary.simpleMessage(
      "Forget Password?",
    ),
    "logingenderdialogfemale": MessageLookupByLibrary.simpleMessage("Female"),
    "logingenderdialogmale": MessageLookupByLibrary.simpleMessage("Male"),
    "logingenderdialogwelcome": MessageLookupByLibrary.simpleMessage(
      "Welcome, You Have To Choose The Gender",
    ),
    "loginmobilelabel": MessageLookupByLibrary.simpleMessage(
      "Enter Your Mobile Number",
    ),
    "loginmobiletitle": MessageLookupByLibrary.simpleMessage("Mobile Number"),
    "loginpasswordlabel": MessageLookupByLibrary.simpleMessage(
      "Enter Your password",
    ),
    "loginpasswordtitle": MessageLookupByLibrary.simpleMessage("password"),
    "loginrememberme": MessageLookupByLibrary.simpleMessage("Remember Me"),
    "loginsignupbutton": MessageLookupByLibrary.simpleMessage("Sign Up"),
    "logout": MessageLookupByLibrary.simpleMessage("Logout"),
    "male": MessageLookupByLibrary.simpleMessage("Male"),
    "maleOnly": MessageLookupByLibrary.simpleMessage("Male Only"),
    "males": MessageLookupByLibrary.simpleMessage("Males"),
    "malesOnly": MessageLookupByLibrary.simpleMessage("Males only"),
    "mapLabel": MessageLookupByLibrary.simpleMessage("Map"),
    "markAllAsRead": MessageLookupByLibrary.simpleMessage("Mark all as read"),
    "maxPriceLabel": MessageLookupByLibrary.simpleMessage("Max price:"),
    "maximumPriceLabel": MessageLookupByLibrary.simpleMessage("Maximum Price"),
    "me": MessageLookupByLibrary.simpleMessage("( Me )"),
    "membersCount": MessageLookupByLibrary.simpleMessage("members"),
    "menOnly": MessageLookupByLibrary.simpleMessage("Men only"),
    "minPriceLabel": MessageLookupByLibrary.simpleMessage("Min price:"),
    "minimumPriceLabel": MessageLookupByLibrary.simpleMessage("Minimum Price"),
    "minutesAgo": m23,
    "minutesApprox": m24,
    "minutesCount": m25,
    "minutesUnit": MessageLookupByLibrary.simpleMessage("min"),
    "missingDocumentsRequired": MessageLookupByLibrary.simpleMessage(
      "Missing documents required for activation:",
    ),
    "mobileNumber": MessageLookupByLibrary.simpleMessage("Mobile Number"),
    "mobileNumberPlaceholder": MessageLookupByLibrary.simpleMessage(
      "07xxxxxxxx",
    ),
    "mobileNumberRequired": MessageLookupByLibrary.simpleMessage(
      "Mobile number is required to continue",
    ),
    "modelOfCar": MessageLookupByLibrary.simpleMessage("Model Of Car:"),
    "moveMapAndConfirm": MessageLookupByLibrary.simpleMessage(
      "Move map and tap confirm",
    ),
    "moveMapAndSelectDestination": MessageLookupByLibrary.simpleMessage(
      "Move map and select destination",
    ),
    "multipleSeats": MessageLookupByLibrary.simpleMessage("seats"),
    "myCurrentLocation": MessageLookupByLibrary.simpleMessage(
      "My current location",
    ),
    "myDocuments": MessageLookupByLibrary.simpleMessage(
      "My Official Documents",
    ),
    "myRatingsEmpty": MessageLookupByLibrary.simpleMessage(
      "You haven\'t submitted any ratings yet",
    ),
    "myRatingsTitle": MessageLookupByLibrary.simpleMessage("My Ratings"),
    "myTrips": MessageLookupByLibrary.simpleMessage("My Trips"),
    "myTripsStats": MessageLookupByLibrary.simpleMessage("My Trips Statistics"),
    "nameCantBeEmpty": MessageLookupByLibrary.simpleMessage(
      "Your Name Can\'t Be Empty!!",
    ),
    "nameShouldBe6Chars": MessageLookupByLibrary.simpleMessage(
      "Name Should Be At Least 6 Characters",
    ),
    "nationalIdCantBeEmpty": MessageLookupByLibrary.simpleMessage(
      "Personal ID document is required",
    ),
    "nationalIdDocument": MessageLookupByLibrary.simpleMessage("National ID"),
    "nearClientLocation": MessageLookupByLibrary.simpleMessage(
      "Near client location (< 500m)",
    ),
    "nearPassenger": MessageLookupByLibrary.simpleMessage(
      "Near the passenger ⏳",
    ),
    "nearPassengerLocation": MessageLookupByLibrary.simpleMessage(
      "Near passenger location (< 500m)",
    ),
    "nearby": MessageLookupByLibrary.simpleMessage("Nearby"),
    "nearbyTrips": MessageLookupByLibrary.simpleMessage("Near by Trips"),
    "networkError": MessageLookupByLibrary.simpleMessage(
      "Please check your internet connection",
    ),
    "newMessageBanner": MessageLookupByLibrary.simpleMessage("New Message"),
    "newMsgFrom": m26,
    "newNotification": MessageLookupByLibrary.simpleMessage("New Notification"),
    "newNotificationTitle": MessageLookupByLibrary.simpleMessage(
      "New Notification",
    ),
    "newPassword": MessageLookupByLibrary.simpleMessage("New Password"),
    "newRequestsCount": m27,
    "newTrip": MessageLookupByLibrary.simpleMessage("New Trip"),
    "newTrips": MessageLookupByLibrary.simpleMessage("New Trips"),
    "newTripsStat": MessageLookupByLibrary.simpleMessage("New Requests"),
    "newUserPercentage": MessageLookupByLibrary.simpleMessage(
      "The Percentage Of Each New User",
    ),
    "no": MessageLookupByLibrary.simpleMessage("No"),
    "noActiveChatsDesc": MessageLookupByLibrary.simpleMessage(
      "When a new trip is booked, live chat will appear here immediately.",
    ),
    "noActiveChatsForTrips": MessageLookupByLibrary.simpleMessage(
      "No active trip chats",
    ),
    "noAvailableSeatsCarFull": MessageLookupByLibrary.simpleMessage(
      "No available seats in the vehicle currently (Trip full)",
    ),
    "noData": MessageLookupByLibrary.simpleMessage("No Data"),
    "noDealFound": MessageLookupByLibrary.simpleMessage(
      "Sorry We Can\'t Find A Deal",
    ),
    "noDocumentSelected": MessageLookupByLibrary.simpleMessage(
      "No file selected",
    ),
    "noDriverAssignedYet": MessageLookupByLibrary.simpleMessage(
      "No driver assigned yet",
    ),
    "noDriverFound": MessageLookupByLibrary.simpleMessage(
      "Sorry you can\'t get a driver",
    ),
    "noDriverImageSelected": MessageLookupByLibrary.simpleMessage(
      "Please select a driver profile image",
    ),
    "noDriversFoundPrivateMessage": MessageLookupByLibrary.simpleMessage(
      "No driver has responded to the private trip request yet. Would you like to continue waiting or return later?",
    ),
    "noDriversFoundSharedMessage": MessageLookupByLibrary.simpleMessage(
      "No driver has responded to the shared trip request yet. Would you like to continue waiting or return later?",
    ),
    "noDriversFoundTitle": MessageLookupByLibrary.simpleMessage(
      "No Drivers Available Right Now",
    ),
    "noDriversYet": MessageLookupByLibrary.simpleMessage("No Drivers Yet"),
    "noImageExteriorSelected": MessageLookupByLibrary.simpleMessage(
      "No Image Car Outside Selected",
    ),
    "noImageInteriorSelected": MessageLookupByLibrary.simpleMessage(
      "No Image Inside Selected",
    ),
    "noImageLicenseSelected": MessageLookupByLibrary.simpleMessage(
      "No Image License Selected",
    ),
    "noImageSelected": MessageLookupByLibrary.simpleMessage(
      "No image selected",
    ),
    "noInternetConnection": MessageLookupByLibrary.simpleMessage(
      "No internet connection, please check your network",
    ),
    "noInternetOffline": MessageLookupByLibrary.simpleMessage(
      "No internet connection. Live tracking is paused.",
    ),
    "noLocationFound": MessageLookupByLibrary.simpleMessage(
      "No location found",
    ),
    "noMatchingNotifications": MessageLookupByLibrary.simpleMessage(
      "No matching notifications",
    ),
    "noMatchingSharedTrips": m28,
    "noMatchingSharedTripsFound": MessageLookupByLibrary.simpleMessage(
      "No matching shared trips found currently",
    ),
    "noMessagesYetTapToChat": MessageLookupByLibrary.simpleMessage(
      "No messages yet, tap to chat with passenger",
    ),
    "noNewPrivateTrips": MessageLookupByLibrary.simpleMessage(
      "No new private trips",
    ),
    "noNewSharedTrips": MessageLookupByLibrary.simpleMessage(
      "No new shared trips",
    ),
    "noNotificationsYet": MessageLookupByLibrary.simpleMessage(
      "No Notifications Yet!",
    ),
    "noOffers": MessageLookupByLibrary.simpleMessage("No offers yet"),
    "noOffersYet": MessageLookupByLibrary.simpleMessage("No offers yet"),
    "noOtherPassengers": MessageLookupByLibrary.simpleMessage(
      "No other passengers currently.",
    ),
    "noPassengers": MessageLookupByLibrary.simpleMessage("No Passengers"),
    "noPreference": MessageLookupByLibrary.simpleMessage("No Preference"),
    "noProfileImageSelected": MessageLookupByLibrary.simpleMessage(
      "No profile image selected",
    ),
    "noSavedLocationsDesc": MessageLookupByLibrary.simpleMessage(
      "Save your frequent places like home or work to book future trips with one tap.",
    ),
    "noSavedLocationsYet": MessageLookupByLibrary.simpleMessage(
      "No saved locations yet",
    ),
    "noSearchResultsFound": MessageLookupByLibrary.simpleMessage(
      "No search results found.",
    ),
    "noSharedTripsAvailable": MessageLookupByLibrary.simpleMessage(
      "No shared trips currently available",
    ),
    "noTrips": MessageLookupByLibrary.simpleMessage("No Trips Found"),
    "noTripsNearby": MessageLookupByLibrary.simpleMessage(
      "No Trips Near By Your Current Location!",
    ),
    "notAcceptedByDriver": MessageLookupByLibrary.simpleMessage(
      "Not Accepted By Driver Yet",
    ),
    "notAllPassengersArrived": MessageLookupByLibrary.simpleMessage(
      "Not All Passengers Arrived!",
    ),
    "notEnoughSeatsAvailable": MessageLookupByLibrary.simpleMessage(
      "Available seats on this trip are insufficient",
    ),
    "notSpecified": MessageLookupByLibrary.simpleMessage("Not specified"),
    "noteForDriverOptional": MessageLookupByLibrary.simpleMessage(
      "Note for Driver (Optional)",
    ),
    "notes": MessageLookupByLibrary.simpleMessage("Notes"),
    "notesHint": MessageLookupByLibrary.simpleMessage(
      "Additional notes for driver (optional)...",
    ),
    "notesOptional": MessageLookupByLibrary.simpleMessage("Notes (Optional)"),
    "noticeCarIsFull": MessageLookupByLibrary.simpleMessage(
      "Vehicle is full. Fare is split by seat ratio at the lowest possible cost.",
    ),
    "noticePriceDropsWhenFull": m29,
    "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
    "notificationsStayTuned": MessageLookupByLibrary.simpleMessage(
      "We will notify you as soon as updates on your trips or new price offers arrive.",
    ),
    "notificationsUpdatesHint": MessageLookupByLibrary.simpleMessage(
      "We\'ll notify you as soon as there are updates regarding your trips or new offers.",
    ),
    "numberOfSeats": MessageLookupByLibrary.simpleMessage("Number of Seats"),
    "numberOfSeatsCantBeEmpty": MessageLookupByLibrary.simpleMessage(
      "Number Of Seats Can\'t Be Empty!!",
    ),
    "numberOfSeatsLabel": MessageLookupByLibrary.simpleMessage(
      "Number of Seats",
    ),
    "numberShouldBe9To14Digits": MessageLookupByLibrary.simpleMessage(
      "Number should be 9 to 14 digits",
    ),
    "offerAcceptedSuccess": MessageLookupByLibrary.simpleMessage(
      "Your offer was accepted! ✅",
    ),
    "offerAcceptedTransitioning": MessageLookupByLibrary.simpleMessage(
      "Offer accepted! Transitioning to active trip...",
    ),
    "offerAlreadySubmitted": MessageLookupByLibrary.simpleMessage(
      "You have already submitted an offer for this trip",
    ),
    "offerCannotBeLessThanMin": m30,
    "offerCannotExceedMax": m31,
    "offerExpired": MessageLookupByLibrary.simpleMessage(
      "This offer has expired",
    ),
    "offerNow": MessageLookupByLibrary.simpleMessage("Offer Now"),
    "offerPrice": MessageLookupByLibrary.simpleMessage("Offer Price:"),
    "offerRejectedSendNew": MessageLookupByLibrary.simpleMessage(
      "Rejected - Send a new offer 🔄",
    ),
    "offerSentSuccess": MessageLookupByLibrary.simpleMessage(
      "Offer sent successfully",
    ),
    "offerSentWaitingPassenger": MessageLookupByLibrary.simpleMessage(
      "Offer already sent, waiting for passenger approval ⏳",
    ),
    "offerStatus": MessageLookupByLibrary.simpleMessage("Offer Status"),
    "offerStatusAccepted": MessageLookupByLibrary.simpleMessage("Accepted"),
    "offerStatusPending": MessageLookupByLibrary.simpleMessage("Pending"),
    "offerStatusRejected": MessageLookupByLibrary.simpleMessage("Rejected"),
    "offeredPriceByCaptain": MessageLookupByLibrary.simpleMessage(
      "Price Offered by Captain",
    ),
    "offersClosed": MessageLookupByLibrary.simpleMessage(
      "Offers closed: Passenger accepted another driver\'s offer",
    ),
    "offersCount": m32,
    "offersFilter": MessageLookupByLibrary.simpleMessage("Offers"),
    "offersList": MessageLookupByLibrary.simpleMessage("Offers List"),
    "offersWillArriveSoon": MessageLookupByLibrary.simpleMessage(
      "Drivers will contact you soon",
    ),
    "officialDocuments": MessageLookupByLibrary.simpleMessage(
      "Official Documents & Verification",
    ),
    "ok": MessageLookupByLibrary.simpleMessage("Ok"),
    "onMyWay": MessageLookupByLibrary.simpleMessage("On My Way"),
    "onTheWay": MessageLookupByLibrary.simpleMessage("On the Way"),
    "onWayToPassenger": MessageLookupByLibrary.simpleMessage(
      "On the way to passenger 🚗",
    ),
    "oneSeat": MessageLookupByLibrary.simpleMessage("1 Seat"),
    "ongoingTrip": MessageLookupByLibrary.simpleMessage("Ongoing Trip"),
    "openLiveTrackingMap": MessageLookupByLibrary.simpleMessage(
      "Open driver live tracking map",
    ),
    "openTrip": MessageLookupByLibrary.simpleMessage("Open"),
    "optionalReasonPrompt": MessageLookupByLibrary.simpleMessage(
      "Enter Your Reason (optional)",
    ),
    "optionalTimeHint": MessageLookupByLibrary.simpleMessage(
      "Trips close to this time will be shown",
    ),
    "orEnterCustomValue": MessageLookupByLibrary.simpleMessage(
      "Or enter a custom value:",
    ),
    "orderCanceledSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Trip request canceled successfully",
    ),
    "originAndDestinationCannotBeSame": MessageLookupByLibrary.simpleMessage(
      "Pickup and destination cannot be the same location",
    ),
    "originLocation": MessageLookupByLibrary.simpleMessage("Pickup Location"),
    "originPoint": MessageLookupByLibrary.simpleMessage("Pickup Point"),
    "otpCodeInvalidOrExpired": MessageLookupByLibrary.simpleMessage(
      "Verification code is invalid or expired",
    ),
    "outAt": MessageLookupByLibrary.simpleMessage("Out At: "),
    "outOfRange": MessageLookupByLibrary.simpleMessage("Out Of Range!"),
    "participantsCountLabel": MessageLookupByLibrary.simpleMessage(
      "Participants",
    ),
    "passenger": MessageLookupByLibrary.simpleMessage("Passenger"),
    "passengerCreatorLabel": MessageLookupByLibrary.simpleMessage(
      "Passenger / Trip Creator",
    ),
    "passengerDefaultName": MessageLookupByLibrary.simpleMessage("Passenger"),
    "passengerGenderPreference": MessageLookupByLibrary.simpleMessage(
      "Passenger Preference",
    ),
    "passengerRole": MessageLookupByLibrary.simpleMessage("Passenger"),
    "passengerShareOnComplete": m33,
    "passengerWaitTime": MessageLookupByLibrary.simpleMessage(
      "Passenger wait time",
    ),
    "passengers": MessageLookupByLibrary.simpleMessage("Passengers"),
    "passengersNames": MessageLookupByLibrary.simpleMessage("Passengers Names"),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "passwordCantBeEmpty": MessageLookupByLibrary.simpleMessage(
      "Password Can\'t Be Empty",
    ),
    "passwordResetSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Password has been reset successfully",
    ),
    "passwordShouldBe6Chars": MessageLookupByLibrary.simpleMessage(
      "Your Password Should Be At Least 6 Characters",
    ),
    "passwordShouldBeAtLeast6Chars": MessageLookupByLibrary.simpleMessage(
      "Your Password Should Be At Least 6 Characters",
    ),
    "passwordShouldContainCapital": MessageLookupByLibrary.simpleMessage(
      "Your Password Should Contain At Least 1 Capital Character",
    ),
    "passwordShouldContainNumber": MessageLookupByLibrary.simpleMessage(
      "Your Password Should Contain At Least 1 Number",
    ),
    "passwordShouldContainSmall": MessageLookupByLibrary.simpleMessage(
      "Your Password Should Contain At Least 1 Small Character",
    ),
    "passwordShouldContainSmallChar": MessageLookupByLibrary.simpleMessage(
      "Your Password Should Contain At Least 1 Small Character",
    ),
    "passwordsMustMatch": MessageLookupByLibrary.simpleMessage(
      "Your Passwords Must Be Matched",
    ),
    "pdfOrImageAllowed": MessageLookupByLibrary.simpleMessage(
      "Image or PDF file (max 8MB)",
    ),
    "pending": MessageLookupByLibrary.simpleMessage("Pending"),
    "pendingPricingTripSubtitle": MessageLookupByLibrary.simpleMessage(
      "Please set the total price to activate the trip or cancel it",
    ),
    "pendingPricingTripTitle": MessageLookupByLibrary.simpleMessage(
      "Pending trip awaiting pricing",
    ),
    "pendingRatingsEmpty": MessageLookupByLibrary.simpleMessage(
      "No trips pending rating",
    ),
    "pendingRatingsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Rate your completed trips to support drivers and improve service quality",
    ),
    "pendingRatingsTitle": MessageLookupByLibrary.simpleMessage(
      "Trips Pending Rating",
    ),
    "pendingTripAwaitingPricing": MessageLookupByLibrary.simpleMessage(
      "Pending trip awaiting pricing",
    ),
    "perSeatCurrently": MessageLookupByLibrary.simpleMessage(
      "/ per seat currently",
    ),
    "perSeatPriceLabel": m34,
    "perSeatWhenFull": m35,
    "perSeatsCount": m36,
    "personalInformation": MessageLookupByLibrary.simpleMessage(
      "Personal Information",
    ),
    "phoneNotAvailable": MessageLookupByLibrary.simpleMessage(
      "Phone number is currently unavailable",
    ),
    "pickDestinationOnMap": MessageLookupByLibrary.simpleMessage(
      "Select Destination",
    ),
    "pickOnMap": MessageLookupByLibrary.simpleMessage("Select on Map"),
    "pickPickupLocationOnMap": MessageLookupByLibrary.simpleMessage(
      "Select Pickup Location",
    ),
    "pickRouteOnMap": MessageLookupByLibrary.simpleMessage(
      "Select Route on Map",
    ),
    "pickupLocation": MessageLookupByLibrary.simpleMessage("Pickup"),
    "pickupPoint": MessageLookupByLibrary.simpleMessage("Pickup Location"),
    "pickupSelected": MessageLookupByLibrary.simpleMessage(
      "Pickup location selected",
    ),
    "pinDestinationTag": MessageLookupByLibrary.simpleMessage("🏁 Destination"),
    "pinOriginTag": MessageLookupByLibrary.simpleMessage("📍 Pickup Location"),
    "plateNumber": MessageLookupByLibrary.simpleMessage("Plate Number"),
    "plateNumberCantBeEmpty": MessageLookupByLibrary.simpleMessage(
      "Plate Number Can\'t Be Empty!!",
    ),
    "plateNumberInvalidFormat": MessageLookupByLibrary.simpleMessage(
      "Invalid plate format (NN - digits)",
    ),
    "plateNumberLabel": MessageLookupByLibrary.simpleMessage("Plate Number"),
    "pleaseAgreeToTerms": MessageLookupByLibrary.simpleMessage(
      "Please agree to our terms and conditions",
    ),
    "pleaseEnterFull6DigitCode": MessageLookupByLibrary.simpleMessage(
      "Please enter the full 6-digit code",
    ),
    "pleaseEnterLocationName": MessageLookupByLibrary.simpleMessage(
      "Please enter a name for the location",
    ),
    "pleaseEnterValidPrice": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid price",
    ),
    "pleaseEnterValue": MessageLookupByLibrary.simpleMessage(
      "Please enter a value within the range!",
    ),
    "pleaseRateDriver": MessageLookupByLibrary.simpleMessage(
      "Please rate the driver",
    ),
    "pleaseSelectDateTime": MessageLookupByLibrary.simpleMessage(
      "Please select trip date and time",
    ),
    "pleaseSelectPickupAndDest": MessageLookupByLibrary.simpleMessage(
      "Please select pickup and destination points on map",
    ),
    "pleaseUploadProfileImage": MessageLookupByLibrary.simpleMessage(
      "Please upload your profile image",
    ),
    "pleaseWaitForDriver": MessageLookupByLibrary.simpleMessage(
      "Please wait for driver",
    ),
    "pleaseWaitForUserApproval": MessageLookupByLibrary.simpleMessage(
      "Please wait for user approval",
    ),
    "preferredLanguage": MessageLookupByLibrary.simpleMessage(
      "Preferred Language",
    ),
    "presetCustom": MessageLookupByLibrary.simpleMessage("Custom"),
    "presetHome": MessageLookupByLibrary.simpleMessage("Home"),
    "presetShopping": MessageLookupByLibrary.simpleMessage("Shopping"),
    "presetStudy": MessageLookupByLibrary.simpleMessage("Study"),
    "presetUniversity": MessageLookupByLibrary.simpleMessage("University"),
    "presetWork": MessageLookupByLibrary.simpleMessage("Work"),
    "previewRoute": MessageLookupByLibrary.simpleMessage("Preview Route"),
    "price": MessageLookupByLibrary.simpleMessage("Price"),
    "priceAccepted": MessageLookupByLibrary.simpleMessage("Price accepted"),
    "pricePerSeatLabel": MessageLookupByLibrary.simpleMessage(
      "Price per seat (JOD)",
    ),
    "priceSetEnteringChat": MessageLookupByLibrary.simpleMessage(
      "Price set, entering chat...",
    ),
    "pricing": MessageLookupByLibrary.simpleMessage("Pricing"),
    "privacyContent1": MessageLookupByLibrary.simpleMessage(
      "1. Data Collection: We collect registration info, phone number, and location to provide transit services and facilitate communication.\n\n",
    ),
    "privacyContent2": MessageLookupByLibrary.simpleMessage(
      "2. Location Usage: Location is tracked during active trips only to ensure safety, accuracy, and fare calculation.\n\n",
    ),
    "privacyContent3": MessageLookupByLibrary.simpleMessage(
      "3. Data Protection: We are committed to protecting your privacy and encrypting your data without unauthorized sharing.\n\n",
    ),
    "privacyContent4": MessageLookupByLibrary.simpleMessage(
      "4. Alerts: We send notifications related to trip statuses and important updates.",
    ),
    "privacyTitle": MessageLookupByLibrary.simpleMessage("Privacy Policy:\n\n"),
    "privateTrip": MessageLookupByLibrary.simpleMessage("Private Trips"),
    "privateTripAnnouncedSuccess": MessageLookupByLibrary.simpleMessage(
      "Private trip announced successfully",
    ),
    "privateTripPriorityBanner": MessageLookupByLibrary.simpleMessage(
      "Private trip. Your request has priority",
    ),
    "profileDataProtected": MessageLookupByLibrary.simpleMessage(
      "Account details are verified and protected. To update your info, please contact support.",
    ),
    "proposedFareUpdated": m37,
    "proposedPrice": MessageLookupByLibrary.simpleMessage("Proposed Price"),
    "proposedTripFare": MessageLookupByLibrary.simpleMessage(
      "Proposed Trip Fare",
    ),
    "radarActiveSearching": MessageLookupByLibrary.simpleMessage(
      "Radar active & searching 🔍",
    ),
    "radarSearchingNewTrips": MessageLookupByLibrary.simpleMessage(
      "Radar active, searching for nearby passengers...",
    ),
    "radiusKm": m38,
    "rateTripAction": MessageLookupByLibrary.simpleMessage("Rate Trip"),
    "rateYourExperience": m39,
    "rateYourExperienceWith": m40,
    "ratingCommentHint": MessageLookupByLibrary.simpleMessage(
      "Add your comment (optional)...",
    ),
    "ratingCountLabel": m41,
    "ratingEditWindowNote": MessageLookupByLibrary.simpleMessage(
      "You can edit your rating within 24 hours of submission",
    ),
    "ratingFeedbackHint": MessageLookupByLibrary.simpleMessage(
      "Write your feedback and rating (optional)...",
    ),
    "ratingLockedNote": MessageLookupByLibrary.simpleMessage(
      "Rating is locked (more than 24 hours passed)",
    ),
    "ratingScreenTitle": MessageLookupByLibrary.simpleMessage("Trip Rating"),
    "ratingSubmitSuccess": MessageLookupByLibrary.simpleMessage(
      "Your rating was submitted successfully!",
    ),
    "ratingSummaryOverall": MessageLookupByLibrary.simpleMessage(
      "Overall Rating",
    ),
    "ratingUpdateSuccess": MessageLookupByLibrary.simpleMessage(
      "Your rating was updated successfully!",
    ),
    "ratingsCountLabel": m42,
    "reachesPriceWhenFull": m43,
    "ready": MessageLookupByLibrary.simpleMessage("Ready"),
    "readyForNewTrips": MessageLookupByLibrary.simpleMessage(
      "Ready to receive new trips",
    ),
    "readyToReceiveOrders": MessageLookupByLibrary.simpleMessage(
      "Ready To Receive Orders",
    ),
    "reasonForCanceling": MessageLookupByLibrary.simpleMessage(
      "What is the reason for canceling the trip?",
    ),
    "refreshAction": MessageLookupByLibrary.simpleMessage("Refresh"),
    "refreshButton": MessageLookupByLibrary.simpleMessage("Refresh"),
    "refreshList": MessageLookupByLibrary.simpleMessage("Refresh List"),
    "refreshRadar": MessageLookupByLibrary.simpleMessage("Refresh Radar"),
    "refreshResults": MessageLookupByLibrary.simpleMessage("Refresh Results"),
    "registrationSuccessful": MessageLookupByLibrary.simpleMessage(
      "Registration Successful",
    ),
    "reject": MessageLookupByLibrary.simpleMessage("Reject"),
    "rejectOffer": MessageLookupByLibrary.simpleMessage("Reject Offer"),
    "rejectingReasonPrompt": MessageLookupByLibrary.simpleMessage(
      "What Is The Reason For Rejecting The Trip?",
    ),
    "remainingSeatsLabel": MessageLookupByLibrary.simpleMessage("Remaining"),
    "removeFile": MessageLookupByLibrary.simpleMessage("Remove file"),
    "replaceDocument": MessageLookupByLibrary.simpleMessage("Replace Document"),
    "requestAdditionalSeats": MessageLookupByLibrary.simpleMessage(
      "Request additional seats:",
    ),
    "requestTripAgain": MessageLookupByLibrary.simpleMessage(
      "Request Trip Again",
    ),
    "requestedNumberOfSeats": MessageLookupByLibrary.simpleMessage(
      "Requested Number of Seats",
    ),
    "requiredLocations": MessageLookupByLibrary.simpleMessage(
      "Please select start and destination locations",
    ),
    "resendCodeAvailableNow": MessageLookupByLibrary.simpleMessage(
      "Resend code is available now",
    ),
    "resendCodeWithin": MessageLookupByLibrary.simpleMessage(
      "resend code within",
    ),
    "resendCodeWithin30": MessageLookupByLibrary.simpleMessage(
      "resend code within 00:30",
    ),
    "reservedSeatsCount": m44,
    "resolvingAddress": MessageLookupByLibrary.simpleMessage(
      "Determining address...",
    ),
    "resumeTripAction": MessageLookupByLibrary.simpleMessage("Resume Trip"),
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "retryAction": MessageLookupByLibrary.simpleMessage("Try Again"),
    "reviewAndMakeOffer": MessageLookupByLibrary.simpleMessage(
      "Review Requests & Make Offer",
    ),
    "routeMapButton": MessageLookupByLibrary.simpleMessage("Route Map"),
    "routePath": MessageLookupByLibrary.simpleMessage("Trip Route"),
    "sar": MessageLookupByLibrary.simpleMessage("SAR"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveLocationButton": MessageLookupByLibrary.simpleMessage("Save Location"),
    "savedGeographicLocation": MessageLookupByLibrary.simpleMessage(
      "Saved Geographic Location",
    ),
    "savedLocationDefault": MessageLookupByLibrary.simpleMessage(
      "Saved Location",
    ),
    "savedLocationsFavoriteDesc": MessageLookupByLibrary.simpleMessage(
      "You can request an instant trip with one tap to any saved location.",
    ),
    "savedLocationsFavoriteTitle": MessageLookupByLibrary.simpleMessage(
      "Your Favorite & Saved Locations",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "searchByPickupLocation": MessageLookupByLibrary.simpleMessage(
      "Search by pickup location...",
    ),
    "searchByPlaceOrDestination": MessageLookupByLibrary.simpleMessage(
      "Search by destination...",
    ),
    "searchDestHint": MessageLookupByLibrary.simpleMessage(
      "Search destination...",
    ),
    "searchDestinationHint": MessageLookupByLibrary.simpleMessage(
      "Search for destination (place, street...)",
    ),
    "searchDestinationLocationHint": MessageLookupByLibrary.simpleMessage(
      "Search for destination...",
    ),
    "searchForChat": MessageLookupByLibrary.simpleMessage("Search For Chat"),
    "searchForLocation": MessageLookupByLibrary.simpleMessage(
      "Search for a location...",
    ),
    "searchForOffers": MessageLookupByLibrary.simpleMessage(
      "Search for offers",
    ),
    "searchForOffersBtn": MessageLookupByLibrary.simpleMessage(
      "Search for Offers",
    ),
    "searchForOffersButton": MessageLookupByLibrary.simpleMessage(
      "Search for offers",
    ),
    "searchForTrip": MessageLookupByLibrary.simpleMessage(
      "Search For Trip Near By Your Current Location!",
    ),
    "searchHint": MessageLookupByLibrary.simpleMessage("Search..."),
    "searchLocationHint": MessageLookupByLibrary.simpleMessage(
      "Search for location",
    ),
    "searchOffers": MessageLookupByLibrary.simpleMessage("Search for offers"),
    "searchOriginHint": MessageLookupByLibrary.simpleMessage(
      "Search pickup point...",
    ),
    "searchPickupHint": MessageLookupByLibrary.simpleMessage(
      "Search for origin (place, street...)",
    ),
    "searchPickupLocationHint": MessageLookupByLibrary.simpleMessage(
      "Search for pickup location...",
    ),
    "searchPlaceOrAddressHint": MessageLookupByLibrary.simpleMessage(
      "Search for place name or address...",
    ),
    "searchRadiusDesc": m45,
    "searchRadiusKm": m46,
    "searchRadiusLabel": m47,
    "searchRadiusScope": MessageLookupByLibrary.simpleMessage(
      "Search Radius Range",
    ),
    "searchRadiusTitle": MessageLookupByLibrary.simpleMessage(
      "Geographic Search Radius",
    ),
    "searchSharedTripHome": MessageLookupByLibrary.simpleMessage(
      "Search for Shared Trip",
    ),
    "searchSharedTripSub": MessageLookupByLibrary.simpleMessage(
      "Enter destination and browse available trips on your route",
    ),
    "searchSharedTripTitle": MessageLookupByLibrary.simpleMessage(
      "Search for Shared Trip",
    ),
    "searchSharedTrips": MessageLookupByLibrary.simpleMessage(
      "Search Shared Trips",
    ),
    "searchTripButton": MessageLookupByLibrary.simpleMessage("Search Trips"),
    "searchingForCaptains": MessageLookupByLibrary.simpleMessage(
      "Searching for drivers...",
    ),
    "searchingNearbyTrips": MessageLookupByLibrary.simpleMessage(
      "Searching for nearby trips...",
    ),
    "seatSingle": MessageLookupByLibrary.simpleMessage("seat"),
    "seats": MessageLookupByLibrary.simpleMessage("Seats"),
    "seatsAndFareDistribution": MessageLookupByLibrary.simpleMessage(
      "Seats & Fare Distribution:",
    ),
    "seatsCount": m48,
    "seatsCountDisplay": m49,
    "seatsCountLabel": MessageLookupByLibrary.simpleMessage(
      "Number of Seats Requested",
    ),
    "seatsCountSingle": m50,
    "seatsCurrentlyBookedInTrip": MessageLookupByLibrary.simpleMessage(
      "Seats currently booked in the trip:",
    ),
    "seatsOutOfTotal": m51,
    "seatsRemaining": m52,
    "seatsRequestedBadge": m53,
    "seatsRequestedCount": MessageLookupByLibrary.simpleMessage(
      "seats requested",
    ),
    "seatsUnit": MessageLookupByLibrary.simpleMessage("seats"),
    "secondsAbbr": m54,
    "selectCarTypeFirst": MessageLookupByLibrary.simpleMessage(
      "Select car type first",
    ),
    "selectDate": MessageLookupByLibrary.simpleMessage("Select Date"),
    "selectDestination": MessageLookupByLibrary.simpleMessage(
      "Select Destination",
    ),
    "selectDestinationToSearch": MessageLookupByLibrary.simpleMessage(
      "Select your destination to search matching trips:",
    ),
    "selectExpiryDate": MessageLookupByLibrary.simpleMessage(
      "Select Expiry Date",
    ),
    "selectStartLocation": MessageLookupByLibrary.simpleMessage(
      "Select Start Location",
    ),
    "selectTime": MessageLookupByLibrary.simpleMessage("Select Time"),
    "selectTripDate": MessageLookupByLibrary.simpleMessage("Select Trip Date"),
    "selectedDestination": MessageLookupByLibrary.simpleMessage(
      "Selected destination",
    ),
    "selectedDestinationFallback": MessageLookupByLibrary.simpleMessage(
      "Selected Destination",
    ),
    "selectedDestinationLocation": MessageLookupByLibrary.simpleMessage(
      "Selected Destination:",
    ),
    "selectedPickupLocation": MessageLookupByLibrary.simpleMessage(
      "Selected Pickup Location:",
    ),
    "send": MessageLookupByLibrary.simpleMessage("Send"),
    "sendOfferAction": MessageLookupByLibrary.simpleMessage("Send Offer"),
    "serverError": MessageLookupByLibrary.simpleMessage(
      "Server error occurred, please try again later",
    ),
    "serverErrorDuringLogin": MessageLookupByLibrary.simpleMessage(
      "Server error during login",
    ),
    "setDestinationAndReviewRoute": MessageLookupByLibrary.simpleMessage(
      "Set Destination & Review Route",
    ),
    "setPickupAndPickDestination": MessageLookupByLibrary.simpleMessage(
      "Set Origin & Pick Destination",
    ),
    "setPriceOrCancelPendingTrip": MessageLookupByLibrary.simpleMessage(
      "Please set the total price for the trip to activate or cancel it",
    ),
    "setTotalRequiredPrice": MessageLookupByLibrary.simpleMessage(
      "Set total required price:",
    ),
    "setTotalTripPriceNotice": MessageLookupByLibrary.simpleMessage(
      "Set the total trip price to enter chat and waiting room",
    ),
    "settingsLanguage": MessageLookupByLibrary.simpleMessage("Language"),
    "sharedTrip": MessageLookupByLibrary.simpleMessage("Shared Trips"),
    "sharedTripCancelConfirmDriver": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to cancel the trip? Passengers will be notified.",
    ),
    "sharedTripCancelled": MessageLookupByLibrary.simpleMessage(
      "Shared trip cancelled",
    ),
    "sharedTripCompleted": MessageLookupByLibrary.simpleMessage(
      "Shared trip completed",
    ),
    "sharedTripDetailsTitle": MessageLookupByLibrary.simpleMessage(
      "Shared Trip Details",
    ),
    "sharedTripEndedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Shared trip ended successfully",
    ),
    "sharedTripPriorityBanner": MessageLookupByLibrary.simpleMessage(
      "Shared trip. Your request has priority",
    ),
    "skip": MessageLookupByLibrary.simpleMessage("Skip"),
    "skipRating": MessageLookupByLibrary.simpleMessage("Skip"),
    "somethingWrong": MessageLookupByLibrary.simpleMessage("Something wrong"),
    "specificDate": MessageLookupByLibrary.simpleMessage("Specific Date 📅"),
    "specifiedDestinationFallback": MessageLookupByLibrary.simpleMessage(
      "Specified Destination",
    ),
    "specifiedLocation": MessageLookupByLibrary.simpleMessage(
      "Specified Location",
    ),
    "specifiedMapLocation": MessageLookupByLibrary.simpleMessage(
      "Specified location on map",
    ),
    "specifiedWorkingDistance": MessageLookupByLibrary.simpleMessage(
      "The Specified Working Distance:",
    ),
    "splitBySeatsRatioFull": m55,
    "splitFareExplanation": MessageLookupByLibrary.simpleMessage(
      "This total price will be split equally among joining passengers based on their booked seats upon trip completion.",
    ),
    "starsLabel": m56,
    "start": MessageLookupByLibrary.simpleMessage("Start"),
    "startLocation": MessageLookupByLibrary.simpleMessage("Start Location"),
    "startMovingToClient": MessageLookupByLibrary.simpleMessage(
      "Start moving to client",
    ),
    "startMovingToPassengers": MessageLookupByLibrary.simpleMessage(
      "Start moving to passengers",
    ),
    "startPrivateTripAction": MessageLookupByLibrary.simpleMessage(
      "Start Trip",
    ),
    "startSharedTripAction": MessageLookupByLibrary.simpleMessage(
      "Start Shared Trip",
    ),
    "startTripAction": MessageLookupByLibrary.simpleMessage("Start Trip"),
    "startingLocation": MessageLookupByLibrary.simpleMessage(
      "Starting Location",
    ),
    "startsDistanceKm": m57,
    "statusAccepted": MessageLookupByLibrary.simpleMessage("Accepted"),
    "statusCanceled": MessageLookupByLibrary.simpleMessage("Canceled"),
    "statusClosed": MessageLookupByLibrary.simpleMessage("Closed"),
    "statusCompleted": MessageLookupByLibrary.simpleMessage("Completed"),
    "statusOpen": MessageLookupByLibrary.simpleMessage("Open"),
    "statusSuspended": MessageLookupByLibrary.simpleMessage("Suspended"),
    "stayToSetPrice": MessageLookupByLibrary.simpleMessage("Stay to set price"),
    "stepDestination": MessageLookupByLibrary.simpleMessage("2. Destination"),
    "stepOrigin": MessageLookupByLibrary.simpleMessage("1. Origin"),
    "stepRoute": MessageLookupByLibrary.simpleMessage("3. Route"),
    "submitRating": MessageLookupByLibrary.simpleMessage("Submit Rating"),
    "submitRatingBtn": MessageLookupByLibrary.simpleMessage("Submit Rating"),
    "subscribeNow": MessageLookupByLibrary.simpleMessage("Subscribe Now"),
    "successfullyAccepted": MessageLookupByLibrary.simpleMessage(
      "Successfully Accepted",
    ),
    "successfullyCanceled": MessageLookupByLibrary.simpleMessage(
      "Successfully Canceled!",
    ),
    "successfullyRated": MessageLookupByLibrary.simpleMessage(
      "Successfully Rated!",
    ),
    "successfullyRejected": MessageLookupByLibrary.simpleMessage(
      "Successfully Rejected!",
    ),
    "suggestedDestination": MessageLookupByLibrary.simpleMessage(
      "Suggested Destination:",
    ),
    "suggestedPickup": MessageLookupByLibrary.simpleMessage(
      "Suggested Pickup:",
    ),
    "suggestedPriceLabel": MessageLookupByLibrary.simpleMessage(
      "Suggested Price",
    ),
    "suspendTripAction": MessageLookupByLibrary.simpleMessage("Suspend Trip"),
    "suspended": MessageLookupByLibrary.simpleMessage("Suspended"),
    "suspendedTrip": MessageLookupByLibrary.simpleMessage("Suspended Trip"),
    "suspendedTrips": MessageLookupByLibrary.simpleMessage("Suspended Trips"),
    "suspendedTripsStat": MessageLookupByLibrary.simpleMessage(
      "Suspended Trips",
    ),
    "tabDriverVehicleDetails": MessageLookupByLibrary.simpleMessage(
      "Driver & Vehicle Info",
    ),
    "tabTripDetailsBooking": MessageLookupByLibrary.simpleMessage(
      "Trip Details & Booking",
    ),
    "tapToChangeDistance": MessageLookupByLibrary.simpleMessage(
      "Tap to change distance",
    ),
    "tapToUploadFile": MessageLookupByLibrary.simpleMessage(
      "Tap to upload file",
    ),
    "tapTripDetailsToContinue": MessageLookupByLibrary.simpleMessage(
      "Tap \'Trip Details\' to continue",
    ),
    "termsContent1": MessageLookupByLibrary.simpleMessage(
      "1. Use of Service: The user agrees to comply with local laws and conduct rules during trips.\n\n",
    ),
    "termsContent2": MessageLookupByLibrary.simpleMessage(
      "2. Bookings & Offers: The agreed fare is binding upon acceptance of the offer or trip request.\n\n",
    ),
    "termsContent3": MessageLookupByLibrary.simpleMessage(
      "3. Safety & Security: Using the service for illegal purposes is prohibited. Management may suspend violating accounts.\n\n",
    ),
    "termsContent4": MessageLookupByLibrary.simpleMessage(
      "4. Cancellation & Changes: Cancellation policy and fees are governed by the established app rules.",
    ),
    "termsTitle": MessageLookupByLibrary.simpleMessage(
      "Terms & Conditions:\n\n",
    ),
    "threeSeats": MessageLookupByLibrary.simpleMessage("3 Seats"),
    "timeConflictMessage": MessageLookupByLibrary.simpleMessage(
      "You have another trip around this time (or an ongoing trip).\nPlease choose a time at least 1 hour apart.",
    ),
    "timeConflictTitle": MessageLookupByLibrary.simpleMessage("Time Conflict"),
    "timeJustNow": MessageLookupByLibrary.simpleMessage("Just now"),
    "timeMinutesAgo": MessageLookupByLibrary.simpleMessage("min ago"),
    "timeOptional": MessageLookupByLibrary.simpleMessage("Time (optional)"),
    "timeToday": MessageLookupByLibrary.simpleMessage("Today"),
    "timeTodayAt": m58,
    "timeTomorrowAt": m59,
    "timeYesterday": MessageLookupByLibrary.simpleMessage("Yesterday"),
    "toReject": MessageLookupByLibrary.simpleMessage("To Reject"),
    "today": MessageLookupByLibrary.simpleMessage("Today"),
    "todayAt": m60,
    "todayTrips": MessageLookupByLibrary.simpleMessage("Today\'s Trips"),
    "tomorrowTrips": MessageLookupByLibrary.simpleMessage("Tomorrow\'s Trips"),
    "topDriversBadge": MessageLookupByLibrary.simpleMessage(
      "Top 3% of Drivers",
    ),
    "topRatedDriver": MessageLookupByLibrary.simpleMessage("Top-Rated Driver"),
    "total": MessageLookupByLibrary.simpleMessage("Total:"),
    "totalAgreedFareWithDriver": MessageLookupByLibrary.simpleMessage(
      "Total trip fare agreed with driver:",
    ),
    "totalCostYourBooking": m61,
    "totalFareForSeats": m62,
    "totalFareForSeatsPrivate": MessageLookupByLibrary.simpleMessage(
      "Total fare for all seats",
    ),
    "totalPerSeat": MessageLookupByLibrary.simpleMessage("Total Per Seat:"),
    "totalSeatsCount": MessageLookupByLibrary.simpleMessage("Total Seats"),
    "totalTripFare": m63,
    "totalUntilNow": MessageLookupByLibrary.simpleMessage("Total Until Now:"),
    "trackPrivateTrip": MessageLookupByLibrary.simpleMessage(
      "Track Private Trip",
    ),
    "trackSharedTrip": MessageLookupByLibrary.simpleMessage(
      "Track Shared Trip",
    ),
    "trackingTabLabel": MessageLookupByLibrary.simpleMessage("Tracking"),
    "trip": MessageLookupByLibrary.simpleMessage("trip"),
    "tripAlreadyAccepted": MessageLookupByLibrary.simpleMessage(
      "This trip or offer has already been accepted",
    ),
    "tripAnnouncedSuccess": MessageLookupByLibrary.simpleMessage(
      "Shared trip announced successfully",
    ),
    "tripCanceledByDriver": MessageLookupByLibrary.simpleMessage(
      "This trip was canceled by the driver.",
    ),
    "tripCanceledSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Trip canceled successfully",
    ),
    "tripCancellation": MessageLookupByLibrary.simpleMessage(
      "Trip Cancellation",
    ),
    "tripCancelled": MessageLookupByLibrary.simpleMessage(
      "This trip has been cancelled",
    ),
    "tripCancelledAlready": MessageLookupByLibrary.simpleMessage(
      "This trip has been cancelled",
    ),
    "tripCancelledAndReturnedToPassenger": MessageLookupByLibrary.simpleMessage(
      "Trip cancelled and returned to passenger for offers",
    ),
    "tripCancelledByDriver": MessageLookupByLibrary.simpleMessage(
      "Cancel trip by driver",
    ),
    "tripCancelledByDriverConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to cancel this trip? It will return to the passenger to search for offers again.",
    ),
    "tripCancelledSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Trip cancelled successfully",
    ),
    "tripCaptain": MessageLookupByLibrary.simpleMessage("Trip Captain"),
    "tripCompleted": MessageLookupByLibrary.simpleMessage(
      "This trip is completed",
    ),
    "tripCompletedAndFinished": MessageLookupByLibrary.simpleMessage(
      "This trip is completed and finished",
    ),
    "tripCreatedSuccess": MessageLookupByLibrary.simpleMessage(
      "Trip created successfully",
    ),
    "tripDate": MessageLookupByLibrary.simpleMessage("Trip Date"),
    "tripDateLabel": MessageLookupByLibrary.simpleMessage("Trip Date"),
    "tripDatetime": MessageLookupByLibrary.simpleMessage("Trip datetime"),
    "tripDetails": MessageLookupByLibrary.simpleMessage("Trip Details"),
    "tripEndedSharedSuccess": MessageLookupByLibrary.simpleMessage(
      "Shared trip ended successfully",
    ),
    "tripEndedSuccess": MessageLookupByLibrary.simpleMessage(
      "Trip ended successfully",
    ),
    "tripEndedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Trip completed successfully",
    ),
    "tripFull": MessageLookupByLibrary.simpleMessage("Full"),
    "tripFullCannotBook": MessageLookupByLibrary.simpleMessage(
      "The trip is full and cannot be booked.",
    ),
    "tripInProgress": MessageLookupByLibrary.simpleMessage("Trip In Progress"),
    "tripInProgressStatus": MessageLookupByLibrary.simpleMessage(
      "Trip in progress 🏁",
    ),
    "tripIsCancelled": MessageLookupByLibrary.simpleMessage(
      "This trip has been cancelled",
    ),
    "tripIsCompleted": MessageLookupByLibrary.simpleMessage(
      "This trip is completed",
    ),
    "tripMember": MessageLookupByLibrary.simpleMessage("Trip Member"),
    "tripMembers": MessageLookupByLibrary.simpleMessage("Trip Members"),
    "tripNotFound": MessageLookupByLibrary.simpleMessage(
      "Trip not found or has been canceled",
    ),
    "tripOptions": MessageLookupByLibrary.simpleMessage("Trip Options"),
    "tripOwner": MessageLookupByLibrary.simpleMessage("Trip Owner"),
    "tripParticipantsSummary": m64,
    "tripPassengers": MessageLookupByLibrary.simpleMessage("Trip Passengers"),
    "tripPrice": MessageLookupByLibrary.simpleMessage("Trip Price"),
    "tripPriceConfirmedSuccess": MessageLookupByLibrary.simpleMessage(
      "Trip price confirmed successfully",
    ),
    "tripPriceExpected": MessageLookupByLibrary.simpleMessage(
      "Expected trip price (JOD)",
    ),
    "tripPricePerSeat": MessageLookupByLibrary.simpleMessage("Trip price:"),
    "tripRatingTitle": MessageLookupByLibrary.simpleMessage("Trip Rating"),
    "tripSeatsFullCannotBook": MessageLookupByLibrary.simpleMessage(
      "The trip is fully booked and cannot accept more reservations.",
    ),
    "tripStartedOnWay": MessageLookupByLibrary.simpleMessage(
      "Trip in progress to destination",
    ),
    "tripStatus": MessageLookupByLibrary.simpleMessage("trip Status"),
    "tripStatusCompleted": MessageLookupByLibrary.simpleMessage(
      "Trip Completed",
    ),
    "tripSubscriptionSuccess": MessageLookupByLibrary.simpleMessage(
      "Successfully subscribed to trip! 🚀",
    ),
    "tripTime": MessageLookupByLibrary.simpleMessage("Trip Time"),
    "tripTotalLabel": MessageLookupByLibrary.simpleMessage("Trip Total"),
    "tripTotalPrice": MessageLookupByLibrary.simpleMessage("Trip total price"),
    "tripUnavailableOrDeleted": MessageLookupByLibrary.simpleMessage(
      "This trip is unavailable or has been deleted",
    ),
    "trips": MessageLookupByLibrary.simpleMessage("trips"),
    "tripsCountLabel": m65,
    "tripsFilter": MessageLookupByLibrary.simpleMessage("Trips"),
    "tryAnotherCategory": MessageLookupByLibrary.simpleMessage(
      "Try selecting another category to view notifications",
    ),
    "tryAnotherFilterCategory": MessageLookupByLibrary.simpleMessage(
      "Try choosing another filter category to view notifications",
    ),
    "tryIncreasingRadius": MessageLookupByLibrary.simpleMessage(
      "Try increasing the search radius or adjusting pickup and destination",
    ),
    "twoSeats": MessageLookupByLibrary.simpleMessage("2 seats"),
    "typeHere": MessageLookupByLibrary.simpleMessage("Type here..."),
    "typeMessage": MessageLookupByLibrary.simpleMessage("Type a message"),
    "typeOfCar": MessageLookupByLibrary.simpleMessage("Type Of Car:"),
    "unauthorizedError": MessageLookupByLibrary.simpleMessage(
      "Unauthorized access",
    ),
    "unexpectedError": MessageLookupByLibrary.simpleMessage(
      "Unexpected error occurred, please try again",
    ),
    "unexpectedServerResponse": MessageLookupByLibrary.simpleMessage(
      "Unexpected server response",
    ),
    "unlockPossibilities": MessageLookupByLibrary.simpleMessage(
      "Unlock endless possibilities and innovative solutions designed to make life easier, smarter, and more connected.",
    ),
    "unreadNotificationsFilter": MessageLookupByLibrary.simpleMessage("Unread"),
    "update": MessageLookupByLibrary.simpleMessage("Update"),
    "updateDataAndDocs": MessageLookupByLibrary.simpleMessage(
      "Update Data & Documents >",
    ),
    "updateRatingBtn": MessageLookupByLibrary.simpleMessage("Update Rating"),
    "updatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Updated Successfully",
    ),
    "updatesEvery10Sec": MessageLookupByLibrary.simpleMessage(
      "Updates every 10 seconds",
    ),
    "uploadDocument": MessageLookupByLibrary.simpleMessage("Upload Document"),
    "uploadSelectedDocuments": MessageLookupByLibrary.simpleMessage(
      "Upload Selected Documents",
    ),
    "uploadedAt": MessageLookupByLibrary.simpleMessage("Uploaded on"),
    "userNotFound": MessageLookupByLibrary.simpleMessage("User not found"),
    "userlayouthomeprivatetrip": MessageLookupByLibrary.simpleMessage(
      "Private Trip",
    ),
    "userlayouthomesceduledtrip": MessageLookupByLibrary.simpleMessage(
      "Scheduled Trip",
    ),
    "userlayouthomesharedtrip": MessageLookupByLibrary.simpleMessage(
      "Shared Trip",
    ),
    "userlayouthomestarttrip": MessageLookupByLibrary.simpleMessage(
      "Start New Trip",
    ),
    "userlayouthometitle": MessageLookupByLibrary.simpleMessage("Home"),
    "userlayouthometripsnearyourlocation": MessageLookupByLibrary.simpleMessage(
      "Trips Near Your Location",
    ),
    "userlayouthomeviewall": MessageLookupByLibrary.simpleMessage("View All"),
    "userlayoutsettingsLanguage": MessageLookupByLibrary.simpleMessage(
      "Language",
    ),
    "userlayoutsettingsLanguagearabic": MessageLookupByLibrary.simpleMessage(
      "Arabic",
    ),
    "userlayoutsettingsLanguageenglish": MessageLookupByLibrary.simpleMessage(
      "English",
    ),
    "userlayoutsettingscontactus": MessageLookupByLibrary.simpleMessage(
      "Contact Us",
    ),
    "userlayoutsettingsdeleteaccount": MessageLookupByLibrary.simpleMessage(
      "Delete Account",
    ),
    "userlayoutsettingslogout": MessageLookupByLibrary.simpleMessage("Logout"),
    "userlayoutsettingsmyprofile": MessageLookupByLibrary.simpleMessage(
      "My Profile",
    ),
    "userlayoutsettingspolicy": MessageLookupByLibrary.simpleMessage(
      "Privacy Policy",
    ),
    "userlayoutsettingssavelocations": MessageLookupByLibrary.simpleMessage(
      "Saved Locations",
    ),
    "userlayoutsettingsterms": MessageLookupByLibrary.simpleMessage(
      "Terms & Conditions",
    ),
    "userlayoutsettingstitle": MessageLookupByLibrary.simpleMessage("Settings"),
    "usersignupagree": MessageLookupByLibrary.simpleMessage("I Have Agree"),
    "usersignupbutton": MessageLookupByLibrary.simpleMessage("Sign Up"),
    "usersignuphaveaccount": MessageLookupByLibrary.simpleMessage(
      "Do You Have An Account?",
    ),
    "usersignuploginbutton": MessageLookupByLibrary.simpleMessage("Login"),
    "usersignupmobilelabel": MessageLookupByLibrary.simpleMessage(
      "Enter Your Mobile Number",
    ),
    "usersignupmobiletitle": MessageLookupByLibrary.simpleMessage(
      "Mobile Number",
    ),
    "usersignupnamelabel": MessageLookupByLibrary.simpleMessage(
      "Enter Your Name",
    ),
    "usersignupnametitle": MessageLookupByLibrary.simpleMessage("Full Name"),
    "usersignuppasswordlabel": MessageLookupByLibrary.simpleMessage(
      "Enter Your password",
    ),
    "usersignuppasswordtitle": MessageLookupByLibrary.simpleMessage("password"),
    "usersignupterms": MessageLookupByLibrary.simpleMessage(
      "Terms And Conditions",
    ),
    "vehicleData": MessageLookupByLibrary.simpleMessage("Vehicle Information:"),
    "vehicleDataProtected": MessageLookupByLibrary.simpleMessage(
      "Vehicle details and documents are verified and protected. To update, please contact support.",
    ),
    "vehicleDetails": MessageLookupByLibrary.simpleMessage("Vehicle Details"),
    "vehicleLicenseCantBeEmpty": MessageLookupByLibrary.simpleMessage(
      "Vehicle license document is required",
    ),
    "vehicleLicenseDocument": MessageLookupByLibrary.simpleMessage(
      "Vehicle License",
    ),
    "verificationCodeSent": MessageLookupByLibrary.simpleMessage(
      "Verification code sent successfully",
    ),
    "verifiedDriver": MessageLookupByLibrary.simpleMessage("Verified Driver"),
    "viewAllTrips": MessageLookupByLibrary.simpleMessage("View All Trips"),
    "viewDetailsAction": MessageLookupByLibrary.simpleMessage("View 👈"),
    "viewNotificationAction": MessageLookupByLibrary.simpleMessage("View 👈"),
    "viewRequestsAndMakeOffer": MessageLookupByLibrary.simpleMessage(
      "View Requests & Make Offers",
    ),
    "waitingAcceptance": MessageLookupByLibrary.simpleMessage(
      "Waiting for acceptance ⏳",
    ),
    "waitingDriverMove": MessageLookupByLibrary.simpleMessage(
      "Waiting for driver to start moving",
    ),
    "waitingDriverMoveShort": MessageLookupByLibrary.simpleMessage(
      "Waiting to move",
    ),
    "waitingDriverStartMoving": MessageLookupByLibrary.simpleMessage(
      "Waiting for the driver to start moving",
    ),
    "waitingForDriver": MessageLookupByLibrary.simpleMessage(
      "Waiting for driver...",
    ),
    "waitingForOffers": MessageLookupByLibrary.simpleMessage(
      "Waiting for offers...",
    ),
    "waitingMovement": MessageLookupByLibrary.simpleMessage("Waiting to move"),
    "waitingToMove": MessageLookupByLibrary.simpleMessage("Waiting to move ⏳"),
    "warning": MessageLookupByLibrary.simpleMessage("Warning"),
    "website": MessageLookupByLibrary.simpleMessage("Website"),
    "welcome": MessageLookupByLibrary.simpleMessage("Welcome"),
    "welcomeChooseLanguage": MessageLookupByLibrary.simpleMessage(
      "Welcome, Please Choose The Appropriate Language",
    ),
    "welcomeToCarApp": MessageLookupByLibrary.simpleMessage(
      "Welcome to Car App",
    ),
    "whatIsReasonForCancelingTrip": MessageLookupByLibrary.simpleMessage(
      "What Is The Reason For Canceling The Trip?",
    ),
    "whereTo": MessageLookupByLibrary.simpleMessage("Where to?"),
    "withdrawFromSharedTrip": MessageLookupByLibrary.simpleMessage(
      "Withdraw from Shared Trip",
    ),
    "withdrawFromSharedTripCreatorDesc": MessageLookupByLibrary.simpleMessage(
      "There are other passengers; you will withdraw and the trip continues for them",
    ),
    "withdrawFromTrip": MessageLookupByLibrary.simpleMessage(
      "Withdraw from Trip",
    ),
    "withdrawFromTripConfirmMessage": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to withdraw? The trip will continue for remaining passengers.",
    ),
    "withdrawSharedPassengerConfirmMessage": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to cancel your booking and withdraw from the trip?",
    ),
    "withdrawSharedPassengerDesc": MessageLookupByLibrary.simpleMessage(
      "Cancel your booking and seat in this shared trip",
    ),
    "withdrawnSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Withdrawn from trip successfully",
    ),
    "womenOnly": MessageLookupByLibrary.simpleMessage("Women only"),
    "workInformation": MessageLookupByLibrary.simpleMessage("Work Information"),
    "workingDistance": MessageLookupByLibrary.simpleMessage("Working Radius"),
    "writeMessageHint": MessageLookupByLibrary.simpleMessage("Aa"),
    "yes": MessageLookupByLibrary.simpleMessage("Yes"),
    "yesCancel": MessageLookupByLibrary.simpleMessage("Yes, cancel"),
    "yesSearchDriver": MessageLookupByLibrary.simpleMessage(
      "Yes, search for driver",
    ),
    "yesSearchOffers": MessageLookupByLibrary.simpleMessage(
      "Yes, search for offers",
    ),
    "yesWithdraw": MessageLookupByLibrary.simpleMessage("Yes, withdraw"),
    "yesterday": MessageLookupByLibrary.simpleMessage("Yesterday"),
    "yesterdayAt": m66,
    "youAreInTheCar": MessageLookupByLibrary.simpleMessage(
      "You\'re In The Car!",
    ),
    "youAreJoinedBannerTitle": MessageLookupByLibrary.simpleMessage(
      "You are joined in this trip",
    ),
    "youAreJoinedInTrip": MessageLookupByLibrary.simpleMessage(
      "You are joined in this trip",
    ),
    "youAreOffline": MessageLookupByLibrary.simpleMessage(
      "You are Offline (On Break)",
    ),
    "youAreOfflineShort": MessageLookupByLibrary.simpleMessage(
      "You are Offline",
    ),
    "youAreOnline": MessageLookupByLibrary.simpleMessage(
      "You are Online & Ready for Orders",
    ),
    "youAreOnlineShort": MessageLookupByLibrary.simpleMessage("You are Online"),
    "youCaptain": MessageLookupByLibrary.simpleMessage("You (Captain)"),
    "youLabel": MessageLookupByLibrary.simpleMessage("You"),
    "yourBookingSeats": m67,
    "yourMobileNumberCantBeEmpty": MessageLookupByLibrary.simpleMessage(
      "Your Mobile Number Can\'t Be Empty!!",
    ),
    "yourNameCantBeEmpty": MessageLookupByLibrary.simpleMessage(
      "Your Name Can\'t Be Empty!!",
    ),
    "yourNumberShouldBe10Digits": MessageLookupByLibrary.simpleMessage(
      "Your Number Should Be 10 Digits",
    ),
    "yourPasswordCantBeEmpty": MessageLookupByLibrary.simpleMessage(
      "Your Password Can\'t Be Empty!!",
    ),
    "yourPrivateTrip": MessageLookupByLibrary.simpleMessage(
      "Your Private Trip",
    ),
    "yourReservedSeatsCount": m68,
    "yourShareNowWithRatio": m69,
    "yourTotalBalance": MessageLookupByLibrary.simpleMessage(
      "Your Total Balance:",
    ),
    "yourTripFare": MessageLookupByLibrary.simpleMessage("Your Trip Fare"),
  };
}
