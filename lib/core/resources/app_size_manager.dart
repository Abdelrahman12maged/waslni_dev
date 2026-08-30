// ignore_for_file: file_names, unnecessary_null_comparison

import 'package:flutter/material.dart';

class AppSizeManager {
  BuildContext context;
  AppSizeManager(this.context) : assert(context != null);
  // Todo : Width Phone
  double get width => MediaQuery.of(context).size.width;
  // Todo : height Phone
  double get height =>
      (MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top);
  // Todo : Padding Page
  EdgeInsetsGeometry get appPadding =>
      EdgeInsets.symmetric(vertical: height * 0.05, horizontal: width * 0.03);
  // Todo : Text Size
  // * Larg Size * //
  double get largText1 => MediaQuery.of(context).size.width * 0.065;
  double get largText2 => MediaQuery.of(context).size.width * 0.06;
  double get largText3 => MediaQuery.of(context).size.width * 0.055;
  // * Medium Size * //
  double get mediumText1 => MediaQuery.of(context).size.width * 0.053;
  double get mediumText2 => MediaQuery.of(context).size.width * 0.05;
  double get mediumText3 => MediaQuery.of(context).size.width * 0.043;
  // * Small Size * //
  double get smallText1 => MediaQuery.of(context).size.width * 0.038;
  double get smallText2 => MediaQuery.of(context).size.width * 0.035;
  double get smallText3 => MediaQuery.of(context).size.width * 0.032;
  double get smallText4 => MediaQuery.of(context).size.width * 0.028;
  // * Button Size * //
  double get buttonText1 => MediaQuery.of(context).size.width * 0.05;
  double get buttonText2 => MediaQuery.of(context).size.width * 0.043;
  double get buttonText3 => MediaQuery.of(context).size.width * 0.038;
}
