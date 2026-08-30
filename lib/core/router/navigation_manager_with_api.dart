import 'package:flutter/material.dart';

class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Function() apiCall;

  CustomPageRoute({required this.page, required this.apiCall})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
        );

  @override
  bool didPop(T? result) {
    // Here, you can trigger the API call again when the screen is exited
    // and the user goes back to it.
    // Call your BLoC method to refresh the data here.
    return super.didPop(result);
  }
}
