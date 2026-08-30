import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:car_app/generated/l10n.dart';
import 'package:car_app/features/home/presentation/screens/passenger/user_layout.dart';
import 'package:car_app/features/trips/data/models/trip_model.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_trips_cubit.dart';
import 'package:car_app/features/trips/presentation/driver/screens/private/driver_private_chat_screen.dart';
import 'package:car_app/features/home/presentation/screens/driver/driver_layout.dart';
import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/resources/app_size_manager.dart';
import 'package:flutter/services.dart';

import 'package:car_app/core/router/navigation_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pannable_rating_bar/flutter_pannable_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:car_app/core/theme/colors.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/widgets/app_cached_image.dart';
import 'package:google_fonts/google_fonts.dart';

// class TextFeild extends StatelessWidget {
//     TextFeild({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField();
//   }
// }

Widget mySpinKit() => SpinKitPulsingGrid(
      color: mainColor,
    );

// TEXT FORM FIELD
Widget defaultFormField({
  required TextEditingController controller,
  final TextInputType? inputType,
  final void Function(String)? onSubmit,
  final void Function(String)? onChange,
  bool isPassword = false,
  bool isReadOnly = false,
  String? Function(String? value)? validate,
  final String label = '',
  var errorText = null,
  required dynamic prefix,
  final dynamic suffix,
  final Function()? suffixPressed,
  final Color? prefixColor,
  final Color? suffixColor,
  final bool isFilled = false,
  final Color fillColor = Colors.white,
  final TextDirection? textDirection,
  final TextAlign textAlign = TextAlign.start,
}) =>
    TextFormField(
      controller: controller,
      keyboardType: inputType,
      obscureText: isPassword,
      textDirection: textDirection,
      textAlign: textAlign,
      onFieldSubmitted: onSubmit,
      onChanged: onChange,
      validator: validate,
      readOnly: isReadOnly,
      decoration: InputDecoration(
        filled: isFilled,
        fillColor: fillColor,
        labelText: label,
        hintText: label,
        errorText: errorText,
        prefixIcon: prefix is IconData
            ? Icon(prefix, color: prefixColor)
            : FaIcon(prefix, color: prefixColor),
        suffixIcon: suffix != null
            ? IconButton(
                icon: suffix is IconData
                    ? Icon(suffix, color: suffixColor)
                    : FaIcon(suffix, color: suffixColor),
                onPressed: suffixPressed,
              )
            : null,
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
      ),
    );

// TEXT FORM FIELD
Widget defaultGetLocationField({
  required TextEditingController controller,
  final TextInputType? inputType,
  final void Function(String)? onSubmit,
  final void Function(String)? onChange,
  bool isPassword = false,
  bool isReadOnly = true,
  bool canFocus = true,
  String? Function(String? value)? validate,
  required String label,
  required IconData? prefix,
  final IconData? suffix,
  final Function()? suffixPressed,
  final Function()? onTap,
  final Color? prefixColor,
  final Color? suffixColor,
  final bool isFilled = false,
  final Color fillColor = Colors.white,
  final Color labelFontColor = Colors.black,
  final Color valueTextColor = Colors.black,
  final double textFontSize = 16,
}) =>
    Container(
      height: 50,
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        obscureText: isPassword,
        onFieldSubmitted: onSubmit,
        onChanged: onChange,
        validator: validate,
        // canRequestFocus: canFocus,
        readOnly: isReadOnly,
        onTap: onTap,
        style: TextStyle(
          color: valueTextColor,
          fontSize: textFontSize,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 12,
          ),
          filled: isFilled,
          fillColor: fillColor,
          labelText: label,
          labelStyle: TextStyle(
            color: labelFontColor,
          ),
          prefixIcon: Icon(prefix, color: prefixColor),
          suffixIcon: suffix != null
              ? IconButton(
                  icon: Icon(
                    suffix,
                    color: suffixColor,
                  ),
                  onPressed: suffixPressed,
                )
              : null,
          border: OutlineInputBorder(
            borderSide: BorderSide(),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );

// BUTTON
Widget defaultButton({
  double width = double.infinity,
  double height = 60.0,
  double radius = 5,
  Color background = Colors.blue,
  bool isUpperCase = false,
  final double? fontSize,
  required Function() onPressed,
  required String text,
  final Color textColor = Colors.white,
  final Color borderColor = Colors.transparent,
  final double borderWidth = 0.0,
  final FontWeight fontWeight = FontWeight.normal,
}) =>
    Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: background,
        border: Border.all(
          width: borderWidth,
          color: borderColor,
        ),
      ),
      child: MaterialButton(
        onPressed: onPressed,
        child: Text(
          isUpperCase ? text.toUpperCase() : text,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );

//TEXT BUTTON
Widget defaultTextButton({
  required Function() onPressed,
  required String text,
  final Color? textColor,
  final TextDecoration textDecoration = TextDecoration.none,
}) =>
    TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          decoration: textDecoration,
        ),
      ),
    );

emptyFunction() {}
cancelUserDialouge({context, passedFunction = emptyFunction}) {
  showDialog(
      context: context,
      builder: (BuildContext usertypedialogcontext) =>
          StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              iconPadding: EdgeInsets.all(0),
              content: Container(
                  height: MediaQuery.of(context).size.height / 3.5,
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        S.of(context).reasonForCanceling,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 20),
                          width: MediaQuery.of(context).size.width / 1.5,
                          // height: MediaQuery.of(context).size.height / 4,
                          child: TextFormField(
                            minLines: 5,
                            maxLines: 6,
                            decoration: InputDecoration(
                                hintText: S.of(context).enterYourReason),
                            keyboardType: TextInputType.multiline,
                          )),
                    ],
                  )),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      style: ButtonStyle(
                          textStyle: MaterialStatePropertyAll(
                              TextStyle(color: Colors.black))),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        S.of(context).cancel,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    TextButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(mainColor)),
                      onPressed: () async {
                        passedFunction();
                      },
                      child: Text(
                        S.of(context).ok,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }));
}

RejectTripDialouge(context, {id, setNewLoading}) {
  showDialog(
      context: context,
      builder: (BuildContext usertypedialogcontext) =>
          StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              iconPadding: EdgeInsets.all(0),
              content: Container(
                  height: MediaQuery.of(context).size.height / 3.5,
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        S.of(context).rejectingReasonPrompt,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 20),
                          width: MediaQuery.of(context).size.width / 1.5,
                          // height: MediaQuery.of(context).size.height / 4,
                          child: TextFormField(
                            minLines: 5,
                            maxLines: 6,
                            decoration: InputDecoration(
                                hintText: S.of(context).enterYourReason),
                            keyboardType: TextInputType.multiline,
                          )),
                    ],
                  )),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      style: ButtonStyle(
                          textStyle: MaterialStatePropertyAll(
                              TextStyle(color: Colors.black))),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        S.of(context).cancel,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    TextButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(mainColor)),
                        onPressed: () async {
                          final rejectedTrips = di
                              .sl<LocalStorage>()
                              .readStringList(key: 'driver_rejected_trips');
                          if (kDebugMode) {
                            log("driver_rejected_trips: $rejectedTrips",
                                name: 'Trips');
                          }
                          if (rejectedTrips != null) {
                            var driver_rejected_trips =
                                List<String>.from(rejectedTrips);
                            ;

                            // driver_rejected_trips.toList(growable: true);
                            // driver_rejected_trips =
                            // List<String>.of(driver_rejected_trips);
                            // List<String> driver_rejected_trips2 =
                            //     List<String>.of(driver_rejected_trips
                            //         .map((e) => e.toString())
                            //         .cast()
                            //         .toList());
                            List<String> driver_rejected_trips2 =
                                List.of(driver_rejected_trips.cast<String>());

                            driver_rejected_trips2.add(id.toString());
                            di.sl<LocalStorage>().saveStringList(
                                key: 'driver_rejected_trips',
                                value: driver_rejected_trips2);
                          } else {
                            di.sl<LocalStorage>().saveStringList(
                                key: 'driver_rejected_trips',
                                value: [id.toString()]);
                          }

                          successDialoug(
                              context, S.of(context).successfullyRejected);
                          setNewLoading(true);
                          Future.delayed(Duration(seconds: 3), () {
                            pop(context);
                            pop(context);
                            // navigateToReplacement(
                            //     context, DriverNewTripsAcceptScreen());
                            // navigateToAndRemoveUntil(context, DriverLayout());
                          });
                        },
                        child: Text(
                          S.of(context).ok,
                          style: TextStyle(color: Colors.white),
                        )),
                  ],
                ),
              ],
            );
          }));
}

// pricing Dialoug(),
double _safeDoubleParse(dynamic value, [double defaultValue = 0.0]) {
  if (value == null) return defaultValue;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? defaultValue;
}

sharedDriverOfferPricingDialoge(
    context, tripId, maxPrice, minPrice, tripDetails) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        var percentage = 0;
        double parsedMin = _safeDoubleParse(minPrice);
        double parsedMax = _safeDoubleParse(maxPrice);
        if (parsedMax <= parsedMin) {
          parsedMax = parsedMin + 1.0;
        }
        RangeValues _currentRangeValues = RangeValues(parsedMin, parsedMax);
        if (kDebugMode) {
          log('$context, $tripId, $maxPrice, $minPrice', name: 'OfferDialog');
        }
        int trip_id = int.tryParse(tripId?.toString() ?? '') ?? 0;
        var note = null;

        double price = parsedMin;
        var percentage_added = null;
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
              backgroundColor: Colors.white,
              elevation: 0.0,
              child: SingleChildScrollView(
                reverse: true,
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.2,
                  height: MediaQuery.of(context).size.height / 2.2,
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        S.of(context).averagePrice,
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      RangeSlider(
                        activeColor: Color.fromRGBO(255, 221, 82, 1),
                        values: _currentRangeValues,
                        max: parsedMax,
                        min: parsedMin,
                        divisions: 50,
                        labels: RangeLabels(
                          _currentRangeValues.start.toString() +
                              S.of(context).jod,
                          _currentRangeValues.end.toString() +
                              S.of(context).jod,
                        ),
                        onChanged: (RangeValues values) {
                          // setState(() {
                          //   _currentRangeValues = values;
                          // });
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_currentRangeValues.start.toString() +
                              S.of(context).jod),
                          Text(_currentRangeValues.end.toString() +
                              S.of(context).jod),
                        ],
                      ),
                      Text(
                        S.of(context).price,
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      Container(
                          margin: EdgeInsets.only(left: 20, right: 20),
                          height: MediaQuery.of(context).size.height / 10,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 5,
                                height: MediaQuery.of(context).size.height / 20,
                                child: TextFormField(
                                  style: TextStyle(fontSize: 10),
                                  decoration: InputDecoration(
                                    // hintTextDirection: TextDirection.ltr,
                                    hintStyle: TextStyle(color: mainColor),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 1, color: mainColor)),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 1, color: mainColor)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 1, color: mainColor)),

                                    // errorText: errorPassText,
                                    // errorStyle: TextStyle(fontSize: 9)
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      price = _safeDoubleParse(value);
                                    });
                                  },
                                ),
                              ),
                              Container(
                                height: MediaQuery.of(context).size.height / 20,
                                alignment: Alignment.center,
                                color: mainColor,
                                padding: EdgeInsets.all(5),
                                child: Text(
                                  S.of(context).jod,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          )),
                      Container(
                        // width: MediaQuery.of(context).size.width,
                        // margin: EdgeInsets.all(5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            defaultText(
                                text: S.of(context).newUserPercentage,
                                textFontWeight: FontWeight.bold),
                            Row(
                              children: [
                                //check box row start
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Checkbox.adaptive(
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      side: BorderSide(color: Colors.grey),
                                      value: percentage == 0,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          percentage = 0;
                                        });
                                      },
                                    ),
                                    Text(
                                      '0%',
                                    )
                                  ],
                                ),
                                //check box row end
                                //check box row start
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                      side: BorderSide(color: Colors.grey),
                                      value: percentage == 5,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          percentage = 5;
                                        });
                                      },
                                    ),
                                    defaultText(
                                      text: '5%',
                                    ),
                                  ],
                                ),
                                //check box row end
                                //check box row start
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                      side: BorderSide(color: Colors.grey),
                                      value: percentage == 10,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          percentage = 10;
                                        });
                                      },
                                    ),
                                    defaultText(
                                      text: '10%',
                                    ),
                                  ],
                                ),
                                //check box row end
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStatePropertyAll(mainColor)),
                              onPressed: () {
                                // loadingPricingdriverDialouge(context);

                                if (price < _currentRangeValues.start) {
                                  showToast(
                                      text: S.of(context).pleaseEnterValue,
                                      state: ToastStates.WARNING);
                                  return;
                                }
                                DriverTripsCubit.get(context).createOffer(
                                    context,
                                    trip_id: trip_id,
                                    note: note,
                                    price: price,
                                    percentage_added: percentage.toDouble(),
                                    trip: tripDetails is Map<String, dynamic>
                                        ? TripModel.fromJson(tripDetails)
                                        : TripModel.fromJson({}));
                                Navigator.pop(context);
                              },
                              child: Text(
                                S.of(context).send,
                                style: TextStyle(color: Colors.white),
                              )),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(S.of(context).cancel)),
                        ],
                      ),
                    ],
                  ),
                ),
              ));
        });
      });
}

// pricing Dialoug(),
sharedDriverPricingDialoge(context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        var errorPassText = null;
        var errorConfPassText = null;
        var percentage = 0;
        RangeValues _currentRangeValues = const RangeValues(40, 80);
        var note = null;
        var price = null;
        var percentage_added = null;
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
              backgroundColor: Colors.white,
              elevation: 0.0,
              child: SingleChildScrollView(
                reverse: true,
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.2,
                  height: MediaQuery.of(context).size.height / 2.5,
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        S.of(context).averagePrice,
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      RangeSlider(
                        activeColor: Color.fromRGBO(255, 221, 82, 1),
                        values: _currentRangeValues,
                        max: 100,
                        divisions: 5,
                        labels: RangeLabels(
                          _currentRangeValues.start.round().toString() +
                              S.of(context).jod,
                          _currentRangeValues.end.round().toString() +
                              S.of(context).jod,
                        ),
                        onChanged: (RangeValues values) {
                          setState(() {
                            _currentRangeValues = values;
                          });
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_currentRangeValues.start.toString() +
                              S.of(context).jod),
                          Text(_currentRangeValues.end.toString() +
                              S.of(context).jod),
                        ],
                      ),
                      Text(
                        S.of(context).price,
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      Container(
                          margin: EdgeInsets.only(left: 20, right: 20),
                          height: MediaQuery.of(context).size.height / 10,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 5,
                                height: MediaQuery.of(context).size.height / 20,
                                child: TextFormField(
                                    style: TextStyle(fontSize: 10),
                                    decoration: InputDecoration(
                                      // hintTextDirection: TextDirection.ltr,
                                      hintStyle: TextStyle(color: mainColor),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1, color: mainColor)),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1, color: mainColor)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1, color: mainColor)),

                                      // errorText: errorPassText,
                                      // errorStyle: TextStyle(fontSize: 9)
                                    ),
                                    keyboardType: TextInputType.number,
                                    controller: TextEditingController()),
                              ),
                              Container(
                                height: MediaQuery.of(context).size.height / 20,
                                alignment: Alignment.center,
                                color: mainColor,
                                padding: EdgeInsets.all(5),
                                child: Text(
                                  S.of(context).jod,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          )),
                      Container(
                        // width: MediaQuery.of(context).size.width,
                        // margin: EdgeInsets.all(5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            defaultText(
                                text: S.of(context).newUserPercentage,
                                textFontWeight: FontWeight.bold),
                            Row(
                              children: [
                                //check box row start
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Checkbox.adaptive(
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      side: BorderSide(color: Colors.grey),
                                      value: percentage == 0,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          percentage = 0;
                                        });
                                      },
                                    ),
                                    Text(
                                      '0%',
                                    )
                                  ],
                                ),
                                //check box row end
                                //check box row start
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                      side: BorderSide(color: Colors.grey),
                                      value: percentage == 5,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          percentage = 5;
                                        });
                                      },
                                    ),
                                    defaultText(
                                      text: '5%',
                                    ),
                                  ],
                                ),
                                //check box row end
                                //check box row start
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                      side: BorderSide(color: Colors.grey),
                                      value: percentage == 10,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          percentage = 10;
                                        });
                                      },
                                    ),
                                    defaultText(
                                      text: '10%',
                                    ),
                                  ],
                                ),
                                //check box row end
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStatePropertyAll(mainColor)),
                              onPressed: () {
                                loadingPricingdriverDialouge(context);
                              },
                              child: Text(
                                S.of(context).send,
                                style: TextStyle(color: Colors.white),
                              )),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(S.of(context).cancel)),
                        ],
                      ),
                    ],
                  ),
                ),
              ));
        });
      });
}

driverCancelationWarning(context, setdisableChat, id, {ischat = true}) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          iconPadding: EdgeInsets.all(0),
          content: Container(
              height: MediaQuery.of(context).size.height / 3,
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 1.5,
                    height: MediaQuery.of(context).size.height / 4.2,
                    child: Image.asset('assets/images/warning.png'),
                  ),
                  Text(
                    S.of(context).bannedReasonWarning,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                ],
              )),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  style: ButtonStyle(
                      textStyle: MaterialStatePropertyAll(
                          TextStyle(color: Colors.black))),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    S.of(context).cancel,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(mainColor)),
                  onPressed: () async {
                    successDialoug(context, S.of(context).successfullyCanceled);
                    ischat
                        ? Future.delayed(Duration(seconds: 5), () {
                            setdisableChat();
                            DriverTripsCubit.get(context).changeStatus(
                              int.tryParse(id.toString()) ?? 0,
                              'canceled',
                            );
                            // navigateToAndRemoveUntil(context, DriverLayout());
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          })
                        : Future.delayed(Duration(seconds: 5), () {
                            navigateToAndRemoveUntil(context, DriverLayout());
                          });
                  },
                  child: Text(
                    S.of(context).ok,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        );
      });
}

cancelDriverDialouge(context, setdisableChat, id, {ischat = true}) {
  showDialog(
    context: context,
    builder: (BuildContext usertypedialogcontext) =>
        StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        iconPadding: EdgeInsets.all(0),
        content: Container(
            height: MediaQuery.of(context).size.height / 3.5,
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  S.of(context).reasonForCanceling,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                    margin: EdgeInsets.only(top: 20),
                    width: MediaQuery.of(context).size.width / 1.5,
                    // height: MediaQuery.of(context).size.height / 4,
                    child: TextFormField(
                      minLines: 5,
                      maxLines: 6,
                      decoration: InputDecoration(
                          hintText: S.of(context).enterYourReason),
                      keyboardType: TextInputType.multiline,
                    )),
              ],
            )),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                style: ButtonStyle(
                    textStyle: MaterialStatePropertyAll(
                        TextStyle(color: Colors.black))),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  S.of(context).cancel,
                  style: TextStyle(color: Colors.black),
                ),
              ),
              TextButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(mainColor)),
                onPressed: () async {
                  driverCancelationWarning(context, setdisableChat, id,
                      ischat: ischat);
                },
                child: Text(
                  S.of(context).ok,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      );
    }),
  );
}

successDialoug(context, text) {
  showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        // Set a timer to auto-dismiss the dialog after 3 seconds
        Timer(Duration(seconds: 3), () {
          Navigator.of(context).pop();
        });
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            // icon: Icon(
            //   Icons.check_circle_outline_outlined,
            //   color: Colors.green,
            //   size: 50,
            // ),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            iconPadding: EdgeInsets.all(0),
            content: Container(
                height: MediaQuery.of(context).size.height / 3,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      margin: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width / 1.5,
                      height: MediaQuery.of(context).size.height / 7,
                      child: Icon(
                        Icons.check_circle_outline_outlined,
                        color: Colors.green,
                        size: 100,
                      ),
                    ),
                    Text(
                      text,
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )),
            // actions: [
            //   TextButton(
            //     onPressed: () {
            //       Navigator.pop(context);
            //     },
            //     child: Text(S.of(context).cancel),
            //   ),
            //   TextButton(
            //     onPressed: () async {
            //      navigateToAndRemoveUntil(
            //               context, UserLayout());
            //     },
            //     child: Text(S.of(context).ok),
            //   ),
            // ],
          );
        });
      });
}

Widget defaultLabeledCheckBox({
  required Function() onTap,
  required bool value,
  required void Function(bool? value)? onChanged,
  final String label = '',
  final Color? labelColor,
  final Color? activeColor = Colors.white,
  final Color borderColor = Colors.white,
}) =>
    InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor,
            shape: RoundedRectangleBorder(
              side: const BorderSide(),
              borderRadius: BorderRadius.circular(4),
            ),
            side: BorderSide(
              color: borderColor,
            ),
          ),
          Text(
            label.toString(),
            style: TextStyle(
              color: labelColor,
            ),
          ),
        ],
      ),
    );

driverFoundDialouge(context) {
  showDialog(
      barrierDismissible: false, // Prevents dialog from closing on tap outside

      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          iconPadding: EdgeInsets.all(0),
          content: Container(
              height: MediaQuery.of(context).size.height / 3.5,
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 1.5,
                    height: MediaQuery.of(context).size.height / 4,
                    // child: Image.asset('assets/images/sad.png'),
                  ),
                  Text(
                    S.of(context).approvedByDriver,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              )),
          // actions: [
          //   TextButton(
          //     onPressed: () {
          //       Navigator.pop(context);
          //     },
          //     child: Text(S.of(context).cancel),
          //   ),
          //   TextButton(
          //     onPressed: () async {
          //      navigateToAndRemoveUntil(
          //               context, UserLayout());
          //     },
          //     child: Text(S.of(context).ok),
          //   ),
          // ],
        );
      });
}

cantfinddriverDialouge(context) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          iconPadding: EdgeInsets.all(0),
          content: Container(
              height: MediaQuery.of(context).size.height / 3.5,
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 1.5,
                    height: MediaQuery.of(context).size.height / 4,
                    child: Image.asset('assets/images/sad.png'),
                  ),
                  Text(
                    S.of(context).noDriverFound,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              )),
          // actions: [
          //   TextButton(
          //     onPressed: () {
          //       Navigator.pop(context);
          //     },
          //     child: Text(S.of(context).cancel),
          //   ),
          //   TextButton(
          //     onPressed: () async {
          //      navigateToAndRemoveUntil(
          //               context, UserLayout());
          //     },
          //     child: Text(S.of(context).ok),
          //   ),
          // ],
        );
      });
}

cantfinddealDialouge(context) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          iconPadding: EdgeInsets.all(0),
          content: Container(
              height: MediaQuery.of(context).size.height / 3.5,
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 1.5,
                    height: MediaQuery.of(context).size.height / 4,
                    child: Image.asset('assets/images/sad.png'),
                  ),
                  Text(
                    S.of(context).noDealFound,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              )),
          // actions: [
          //   TextButton(
          //     onPressed: () {
          //       Navigator.pop(context);
          //     },
          //     child: Text(S.of(context).cancel),
          //   ),
          //   TextButton(
          //     onPressed: () async {
          //      navigateToAndRemoveUntil(
          //               context, UserLayout());
          //     },
          //     child: Text(S.of(context).ok),
          //   ),
          // ],
        );
      });
}

driverRateDialouge(context) {
  showDialog(
    barrierDismissible: false, // Prevents dialog from closing on tap outside
    context: context,
    builder: (BuildContext usertypedialogcontext) =>
        StatefulBuilder(builder: (context, setState) {
      double rating = 0.0;
      return AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        iconPadding: EdgeInsets.all(0),
        content: Container(
            height: MediaQuery.of(context).size.height / 3.5,
            color: Colors.white,
            child: Column(
              children: [
                Container(
                    width: MediaQuery.of(context).size.width / 1.5,
                    height: MediaQuery.of(context).size.height / 4,
                    child: PannableRatingBar(
                      rate: rating,
                      items: List.generate(
                          5,
                          (index) => const RatingWidget(
                                selectedColor: Colors.yellow,
                                unSelectedColor: Colors.grey,
                                child: Icon(
                                  Icons.star,
                                  size: 48,
                                ),
                              )),
                      onChanged: (value) {
                        // the rating value is updated on tap or drag.
                        setState(() {
                          rating = value;
                        });
                        Future.delayed(Duration(seconds: 10), () {
                          navigateTo(context, UserLayout());
                        });
                      },
                      onCompleted: (value) {
                        // the rating value is updated on tap or drag.
                        successDialoug(
                            context, S.of(context).successfullyRated);

                        Future.delayed(Duration(seconds: 10), () {
                          navigateTo(context, UserLayout());
                        });
                      },
                    )),
                Text(
                  S.of(context).pleaseRateDriver,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            )),
        // actions: [
        //   TextButton(
        //     onPressed: () {
        //       Navigator.pop(context);
        //     },
        //     child: Text(S.of(context).cancel),
        //   ),
        //   TextButton(
        //     onPressed: () async {
        //      navigateToAndRemoveUntil(
        //               context, UserLayout());
        //     },
        //     child: Text(S.of(context).ok),
        //   ),
        // ],
      );
    }),
  );
}

confirmDialugeFunction(
    context, confirmFunction, DialougeText, DialougeAssetImage,
    {id = 0}) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          iconPadding: EdgeInsets.all(0),
          content: Container(
              height: MediaQuery.of(context).size.height / 3.5,
              alignment: Alignment.center,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DialougeText,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  DialougeAssetImage == ''
                      ? Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width / 1.5,
                          height: MediaQuery.of(context).size.height / 5,
                          // child: Image.asset('assets/images/sad.png'),
                          child: Image.asset(DialougeAssetImage),
                        )
                      : Container()
                ],
              )),
          actions: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                defaultButton(
                    width: MediaQuery.of(context).size.width / 4,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    text: S.of(context).no,
                    fontSize: 20.0,
                    radius: 5,
                    textColor: Colors.black,
                    background: Colors.white,
                    isUpperCase: false,
                    borderColor: Colors.black,
                    borderWidth: 1),
                defaultButton(
                  width: MediaQuery.of(context).size.width / 4,
                  onPressed: () async {
                    confirmFunction(id);
                    Navigator.pop(context);
                  },
                  text: S.of(context).yes,
                  fontSize: 20.0,
                  background: mainColor,
                  radius: 5,
                  isUpperCase: false,
                ),
              ],
            ),
          ],
        );
      });
}

loadingfinddriverDialouge(context) {
  showDialog(
      barrierDismissible: false, // Prevents dialog from closing on tap outside
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            iconPadding: EdgeInsets.all(0),
            content: Container(
                height: MediaQuery.of(context).size.height / 3,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      margin: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width / 1.5,
                      height: MediaQuery.of(context).size.height / 7,
                      child: Image.asset(
                        "assets/images/loading.gif",
                        // height: 200.0,
                        // width: 200.0,
                      ),
                    ),
                    Text(
                      S.of(context).pleaseWaitForDriver,
                      style: TextStyle(),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )),
            // actions: [
            //   TextButton(
            //     onPressed: () {
            //       Navigator.pop(context);
            //     },
            //     child: Text(S.of(context).cancel),
            //   ),
            //   TextButton(
            //     onPressed: () async {
            //      navigateToAndRemoveUntil(
            //               context, UserLayout());
            //     },
            //     child: Text(S.of(context).ok),
            //   ),
            // ],
          );
        });
      });
  Future.delayed(Duration(seconds: 15), () {
    if (int.parse(DateTime.now().millisecondsSinceEpoch.toString()) % 2 == 0) {
      Future.delayed(Duration(seconds: 10), () {
        driverFoundDialouge(context);
      });
      Future.delayed(Duration(seconds: 15), () {
        driverRateDialouge(context);
      });
    } else {
      cantfinddriverDialouge(context);
      Future.delayed(Duration(seconds: 10), () {
        navigateTo(context, UserLayout());
      });
    }
  });
}

loadingfinddriverWithCheckDialouge(context, checkStatus) {
  showDialog(
      barrierDismissible: false, // Prevents dialog from closing on tap outside
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            iconPadding: EdgeInsets.all(0),
            content: Container(
                height: MediaQuery.of(context).size.height / 3,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      margin: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width / 1.5,
                      height: MediaQuery.of(context).size.height / 7,
                      child: Image.asset(
                        "assets/images/loading.gif",
                        // height: 200.0,
                        // width: 200.0,
                      ),
                    ),
                    Text(
                      S.of(context).pleaseWaitForDriver,
                      style: TextStyle(),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )),
          );
        });
      });
}

loadingPricingdriverDialouge(context) {
  showDialog(
      barrierDismissible: false, // Prevents dialog from closing on tap outside
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            iconPadding: EdgeInsets.all(0),
            content: Container(
                height: MediaQuery.of(context).size.height / 3,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      margin: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width / 1.5,
                      height: MediaQuery.of(context).size.height / 7,
                      child: Image.asset(
                        "assets/images/loading.gif",
                        // height: 200.0,
                        // width: 200.0,
                      ),
                    ),
                    Text(
                      S.of(context).pleaseWaitForUserApproval,
                      style: TextStyle(),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )),
            // actions: [
            //   TextButton(
            //     onPressed: () {
            //       Navigator.pop(context);
            //     },
            //     child: Text(S.of(context).cancel),
            //   ),
            //   TextButton(
            //     onPressed: () async {
            //      navigateToAndRemoveUntil(
            //               context, UserLayout());
            //     },
            //     child: Text(S.of(context).ok),
            //   ),
            // ],
          );
        });
      });
  Future.delayed(Duration(seconds: 15), () {
    if (int.parse(DateTime.now().millisecondsSinceEpoch.toString()) % 2 == 0) {
      Future.delayed(Duration(seconds: 10), () {
        // driverFoundDialouge(context);
        successDialoug(context, S.of(context).priceAccepted);
        navigateTo(context, DriverPrivateChatScreenClean());
      });
      // Future.delayed(Duration(seconds: 15), () {
      //   driverRateDialouge(context);
      // });
    } else {
      cantfinddealDialouge(context);
      Future.delayed(Duration(seconds: 10), () {
        pop(context);
        pop(context);
        // pop(context);
        // navigateTo(context, DriverLayout());
      });
    }
  });
}

Widget defaultText(
        {required String text,
        final Color textColor = Colors.black,
        final double? textFontSize,
        FontWeight textFontWeight = FontWeight.normal,
        final TextAlign? textAlign,
        final TextDecoration textDecoration = TextDecoration.none,
        final double? spaceBetweenLines,
        final double? letterSpacing,
        final TextOverflow textOverflow = TextOverflow.clip,
        final bool softWrap = true,
        final int? maxLines}) =>
    Text(
      text,
      textAlign: textAlign,
      softWrap: softWrap,
      maxLines: maxLines,
      style: TextStyle(
        color: textColor,
        letterSpacing: letterSpacing,
        fontSize: textFontSize,
        fontWeight: textFontWeight,
        decoration: textDecoration,
        height: spaceBetweenLines,
        overflow: textOverflow,
      ),
    );

Widget defaultSingleSmallTextField({
  required TextEditingController textController,
  String? Function(String? value)? validate,
  final Function()? onTap,
}) =>
    SizedBox(
      width: 40,
      height: 40,
      child: TextFormField(
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey.shade300,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(0),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
        ),
        // canRequestFocus: false,
        readOnly: true,
        validator: validate,
        controller: textController,
        onTap: onTap,
      ),
    );

// DYNAMIC TEXT FORM FIELD
Widget dynamicFormField({
  required TextEditingController controller,
  final TextInputType? inputType,
  final void Function(String)? onSubmit,
  final void Function(String)? onChange,
  bool isPassword = false,
  final String? errorText,
  String? Function(String? value)? validate,
  required String label,
  final prefix,
  final suffix,
}) =>
    TextFormField(
      controller: controller,
      keyboardType: inputType,
      obscureText: isPassword,
      onFieldSubmitted: onSubmit,
      onChanged: onChange,
      validator: validate,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        // prefixIcon: prefix,
        prefixIcon: Padding(
          padding: EdgeInsets.all(15),
          child: prefix,
        ),
        suffixIcon: suffix,
        border: OutlineInputBorder(),
      ),
    );

Widget personCard({
  required String imgPath,
  required String cardName,
  required Function() onTap,
  final Color? backgroundColor = Colors.white,
}) =>
    Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: backgroundColor,
            border: Border.all(
              color: Colors.grey,
              width: 0.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 13.0,
              vertical: 20.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  imgPath,
                ),
                SizedBox(
                  height: 15.0,
                ),
                defaultText(
                  text: cardName,
                  textFontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        ),
      ),
    );

//Trip Card
Widget tripCard({
  required String svgPath,
  required String cardName,
  required Function() onTap,
  final Color? backgroundColor = Colors.white,
  final Color textColor = Colors.black,
  required BuildContext context,
}) =>
    Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          // height: 140.0,
          height: AppSizeManager(context).height * 0.2,
          // width: 25.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: backgroundColor,
            border: Border.all(
              color: Colors.grey,
              width: 0.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 20.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SvgPicture.asset(
                        svgPath,
                        // width: AppSizeManager(context).width * 0.2,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: defaultText(
                        text: cardName,
                        textColor: textColor,
                        textFontWeight: FontWeight.w500,
                        textFontSize: 12,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

//Large Image Picker
Widget largeImagePicker(
    {required Function() onTap, dynamic image, BuildContext? context}) {
  final imgStr = image?.toString().trim() ?? '';
  final bool hasImage = imgStr.isNotEmpty && imgStr != 'null';

  Widget buildChild() {
    if (!hasImage) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.image,
            color: Colors.grey,
          ),
          defaultText(
            text: context != null ? S.of(context).attachPhoto : S.current.attachPhoto,
            textColor: Colors.grey,
          ),
        ],
      );
    }

    if (imgStr.startsWith('http://') || imgStr.startsWith('https://')) {
      return AppCachedNetworkImage(
        imageUrl: imgStr,
        height: 140,
        width: double.infinity,
        borderRadius: BorderRadius.circular(5.0),
        fit: BoxFit.cover,
        errorWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.broken_image, color: Colors.grey),
            defaultText(
              text: context != null ? S.of(context).attachPhoto : S.current.attachPhoto,
              textColor: Colors.grey,
            ),
          ],
        ),
      );
    }

    final file = File(imgStr);
    if (file.existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: Image.file(
          file,
          fit: BoxFit.cover,
          height: 140,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.broken_image, color: Colors.grey),
              defaultText(
                text: S.of(context).attachPhoto,
                textColor: Colors.grey,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.image,
          color: Colors.grey,
        ),
        defaultText(
          text: context != null ? S.of(context).attachPhoto : S.current.attachPhoto,
          textColor: Colors.grey,
        ),
      ],
    );
  }

  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: buildChild(),
    ),
  );
}

//
Widget iconAndText({
  required String text,
  required IconData icon,
  required Color iconColor,
  final FontWeight textFontWeight = FontWeight.normal,
  final TextOverflow textOverFlow = TextOverflow.ellipsis,
  final bool softWrap = true,
  final double? textFontSize,
  final TextAlign textAlign = TextAlign.start,
  final MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
  final bool isExpanded = false,
}) =>
    Row(
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: iconColor,
        ),
        const SizedBox(
          width: 5.0,
        ),
        Flexible(
          fit: isExpanded ? FlexFit.tight : FlexFit.loose,
          child: defaultText(
            text: text,
            textFontWeight: textFontWeight,
            textOverflow: textOverFlow,
            softWrap: softWrap,
            textFontSize: textFontSize,
            textAlign: textAlign,
          ),
        ),
      ],
    );

// Notification Tile

Widget notificationTile({
  required String titleText,
  required String subtitleTextLeading,
  required String subtitleTextTrailing,
  required Color? tileColor,
  required Function() onTap,
}) =>
    ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
        side: BorderSide(
          width: 0.5,
          color: Colors.grey,
        ),
      ),
      title: defaultText(
        text: titleText,
        textFontSize: 20.0,
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 4,
            child: defaultText(
              text: subtitleTextLeading,
              textFontSize: 12.0,
              textOverflow: TextOverflow.ellipsis,
              textFontWeight: FontWeight.w300,
            ),
          ),
          Expanded(
            flex: 1,
            child: defaultText(
              text: subtitleTextTrailing,
              textFontSize: 12.0,
              textOverflow: TextOverflow.ellipsis,
              textFontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
      tileColor: tileColor,
      onTap: onTap,
    );

//Settings Tile
Widget settingsTile({
  required IconData leadingIcon,
  final Color leadingIconColor = Colors.white,
  required String titleText,
  final IconData? trailingIcon,
  final Color trailingIconColor = Colors.black54,
  final Color? trailingIconBackColor,
  required Color tileColor,
  final Function()? onTap,
  final Color titleTextColor = Colors.black,
}) =>
    ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
        side: BorderSide(
          width: 0.5,
          color: Colors.grey,
        ),
      ),
      leading: Icon(
        leadingIcon,
        color: leadingIconColor,
      ),
      title: defaultText(
        text: titleText,
        textColor: titleTextColor,
      ),
      trailing: Container(
        decoration: BoxDecoration(
          color: trailingIconBackColor ?? Colors.grey[300],
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Icon(
          trailingIcon,
          size: 25.0,
          color: trailingIconColor,
        ),
      ),
      tileColor: tileColor,
      onTap: onTap,
    );

PreferredSizeWidget? defaultAppBar({
  final Color? backgroundColor,
  required Function() leadingOnPressed,
  final dynamic leadingIcon = Icons.arrow_back_ios_outlined,
  required String titleText,
  final dynamic actionsIcon = Icons.notifications_none_rounded,
  final Function()? actionsOnPressed,
  final Color? actionsIconColor,
}) =>
    AppBar(
      backgroundColor: backgroundColor,
      leading: IconButton(
        onPressed: leadingOnPressed,
        icon: leadingIcon is FaIconData
            ? FaIcon(leadingIcon)
            : Icon(
                leadingIcon is IconData
                    ? leadingIcon
                    : Icons.arrow_back_ios_outlined,
              ),
      ),
      title: defaultText(
        text: titleText,
      ),
      actions: [
        if (actionsIcon != null)
          IconButton(
            onPressed: actionsOnPressed,
            icon: actionsIcon is FaIconData
                ? FaIcon(
                    actionsIcon,
                    color: actionsIconColor,
                  )
                : Icon(
                    actionsIcon is IconData
                        ? actionsIcon
                        : Icons.notifications_none_rounded,
                    color: actionsIconColor,
                  ),
          ),
      ],
    );

Widget contactListTile({
  final IconData? leadingIcon,
  required String titleText,
  required String subtitleText,
}) =>
    ListTile(
      leading: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(3.0),
        ),
        child: Icon(
          leadingIcon,
          color: mainColor,
        ),
      ),
      title: defaultText(
        text: titleText,
      ),
      subtitle: defaultText(
        text: subtitleText,
        textColor: mainColor,
      ),
    );

Widget driverHomeCard({
  required String cardTripsText,
  required int carTripsNumber,
  final Function()? onTap,
}) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        // height: 80.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.grey[50],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Spacer(),
            defaultText(
              text: carTripsNumber.toString(),
              textColor: mainColor,
            ),
            Spacer(),
            defaultText(
              text: cardTripsText,
            ),
            Spacer(),
            Container(
              height: 10.0,
              decoration: BoxDecoration(
                color: mainColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(5.0),
                  bottomRight: Radius.circular(5.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );

  // ─── Trip Date & Time Formatting Helpers ─────────────────────────────────────

String formatTripDateHelper(String dateStr) {
  if (dateStr.trim().isEmpty) return '';
  String cleanStr = dateStr.trim();
  String prefix = '';

  // Handle cases where a label prefix is attached, e.g. "الخروج في: "
  if (cleanStr.contains(':') && !cleanStr.startsWith('http')) {
    final colonIdx = cleanStr.indexOf(':');
    final beforeColon = cleanStr.substring(0, colonIdx + 1);
    final afterColon = cleanStr.substring(colonIdx + 1).trim();
    if (afterColon.contains('-') || afterColon.contains('/') || RegExp(r'\d').hasMatch(afterColon)) {
      prefix = '$beforeColon ';
      cleanStr = afterColon;
    }
  }

  try {
    final parsed = DateTime.parse(cleanStr.contains('T') ? cleanStr : cleanStr.replaceAll(' ', 'T')).toLocal();
    final formatted = DateFormat('yyyy/MM/dd', 'ar').format(parsed);
    return '$prefix$formatted';
  } catch (_) {
    if (cleanStr.contains('T')) {
      return '$prefix${cleanStr.split('T')[0]}';
    }
    return dateStr;
  }
}

String formatTripTimeHelper(String timeStr) {
  if (timeStr.trim().isEmpty) return '';
  final cleanStr = timeStr.trim();
  try {
    final parsed = DateTime.parse(cleanStr.contains('T') ? cleanStr : cleanStr.replaceAll(' ', 'T')).toLocal();
    return DateFormat('hh:mm a', 'ar').format(parsed);
  } catch (_) {
    if (cleanStr.contains('T')) {
      final t = cleanStr.split('T')[1];
      return t.length >= 5 ? t.substring(0, 5) : t;
    }
    if (cleanStr.contains(' ')) {
      final parts = cleanStr.split(' ');
      if (parts.length > 1 && parts[1].contains(':')) {
        return parts[1].length >= 5 ? parts[1].substring(0, 5) : parts[1];
      }
    }
    return timeStr;
  }
}

// Private Trip Container

Widget privateTripContainer({
  context,
  required Function() onTap,
  required String timeText,
  required String dateText,
  required String locationText,
  final Color borderColor = Colors.black,
}) {
  final displayTime = formatTripTimeHelper(timeText);
  final displayDate = formatTripDateHelper(dateText);

  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: borderColor.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (displayTime.isNotEmpty)
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 15,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          displayTime,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              if (displayDate.isNotEmpty) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          displayDate,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 18,
                color: borderColor != Colors.black ? borderColor : AppColors.primary,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  locationText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// Shared Trip Container

Widget sharedTripContainer({
  context,
  required Function() onTap,
  required String timeText,
  required String dateText,
  required String locationText,
  final Color? borderColor,
}) {
  final displayTime = formatTripTimeHelper(timeText);
  final displayDate = formatTripDateHelper(dateText);

  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: (borderColor ?? AppColors.primary).withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (borderColor ?? AppColors.primary).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (displayTime.isNotEmpty)
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 15,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          displayTime,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              if (displayDate.isNotEmpty) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          displayDate,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              Icon(
                Icons.directions_car_rounded,
                size: 18,
                color: borderColor ?? AppColors.primary,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  locationText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// Chat My Message Container
Widget myMessageContainer({
  required BuildContext context,
  required String messageText,
  required DateTime messageDate,
}) {
  return Align(
    alignment: Alignment.centerRight,
    child: Container(
      margin: EdgeInsets.symmetric(
        vertical: 5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
        color: Colors.grey.shade200,
      ),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width - 100,
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.end, // Aligns everything to the right
          children: [
            defaultText(
              text: messageText,
              textColor: Colors.grey.shade700,
            ),
            SizedBox(height: 4), // Adding some spacing between message and time
            defaultText(
              text: DateFormat('h:mm a').format(messageDate),
              textFontSize: 9.0,
              textColor: Colors.grey.shade500,
            ),
          ],
        ),
      ),
    ),
  );
}

// Chat other Message Container
Widget otherMessageContainer({
  required BuildContext context,
  required String messageText,
  required DateTime messageDate,
}) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Container(
      margin: EdgeInsets.symmetric(
        vertical: 5,
      ),
      decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10),
          )),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width - 100,
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Aligns everything to the right
          children: [
            defaultText(
              text: messageText,
              textColor: Colors.grey.shade700,
            ),
            SizedBox(height: 4), // Adding some spacing between message and time
            defaultText(
              text: DateFormat('h:mm a').format(messageDate),
              textFontSize: 9.0,
              textColor: Colors.grey.shade500,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget chatTextFeildContainer({
  required Function() sendButtonOnpressed,
}) =>
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: IconButton(
              onPressed: sendButtonOnpressed,
              icon: Icon(
                Icons.send,
                color: iconsColor,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 10.0,
        ),
        Expanded(
          flex: 4,
          child: TextFormField(
            decoration: InputDecoration(
              hintText: 'Aa',
              border: OutlineInputBorder(
                borderSide: BorderSide(),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.transparent,
                  // width: 0.0,
                ),
              ),
              filled: true,
              fillColor: Colors.grey.shade200,
            ),
          ),
        ),
        SizedBox(
          width: 10.0,
        ),
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.mic_none_rounded,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );

Future<void> showToast({
  required String text,
  required ToastStates state,
  final toastPlace = ToastGravity.BOTTOM,
}) =>
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_LONG,
      gravity: toastPlace,
      timeInSecForIosWeb: 5,
      backgroundColor: chooseToastColor(state),
      textColor: Colors.white,
      fontSize: 16.0,
    );

// enum
enum ToastStates { SUCESS, ERROR, WARNING }

Color chooseToastColor(ToastStates state) {
  Color color;
  switch (state) {
    case ToastStates.SUCESS:
      color = Colors.green;
      break;
    case ToastStates.ERROR:
      color = Colors.red;
      break;
    case ToastStates.WARNING:
      color = Colors.amber;
      break;
  }
  return color;
}
