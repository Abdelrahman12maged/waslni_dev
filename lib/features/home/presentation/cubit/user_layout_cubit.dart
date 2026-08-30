import 'package:car_app/features/home/presentation/cubit/user_layout_states.dart';
import 'package:car_app/features/home/presentation/screens/passenger/passenger_home_screen.dart';
import 'package:car_app/features/home/presentation/screens/passenger/passenger_settings_tab_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserLayoutCubit extends Cubit<UserLayoutStates> {
  UserLayoutCubit() : super(UserLayoutInitialState());

  static UserLayoutCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  List<Widget> userLayoutBottomScreens = [
    const PassengerHomeScreen(),
    const PassengerSettingsTabScreen(),
  ];

  List<dynamic> userLayoutBottomIcons = [
    FontAwesomeIcons.house,
    FontAwesomeIcons.gear,
  ];

  void changeBottomScreen(int index) {
    currentIndex = index;
    emit(UserLayoutChangeBottomNavState());
  }
}
