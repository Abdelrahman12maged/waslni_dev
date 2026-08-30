import 'package:car_app/features/home/presentation/cubit/driver_layout_cubit_state.dart';
import 'package:car_app/features/trips/presentation/driver/screens/driver_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:car_app/features/trips/presentation/driver/screens/trips_list_screen.dart';

import 'package:car_app/features/home/presentation/screens/driver/driver_home_screen.dart';
import 'package:car_app/features/home/presentation/screens/driver/driver_settings_tab_screen.dart';

class DriverLayoutCubit extends Cubit<DriverLayoutStates> {
  DriverLayoutCubit() : super(DriverLayoutInitialState());

  static DriverLayoutCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  List<Widget> driverLayoutBottomScreens = [
    DriverHomeScreen(),
    const DriverTripsListScreenClean(),
    const DriverChatScreenClean(),
    const DriverSettingsTabScreen(),
  ];

  List<String> driverLayoutTitles = [
    'Home',
    'Trips',
    'Chats',
    'Settings',
  ];

  List<dynamic> driverLayoutBottomIcons = [
    FontAwesomeIcons.house,
    FontAwesomeIcons.fileLines,
    FontAwesomeIcons.commentDots,
    FontAwesomeIcons.gear,
  ];

  void changeBottomScreen(int index) {
    currentIndex = index;
    emit(DriverLayoutChangeBottomNavState());
  }
}
