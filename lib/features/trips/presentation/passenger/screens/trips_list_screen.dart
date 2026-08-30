import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_trips_cubit.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_trips_state.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/private/current_private_trip_screen.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/private/private_canceled_trips_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/private/private_completed_trips_screen.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/private/private_current_screen_offers.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/shared/shared_canceled_trips_screen.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/shared/shared_completed_trips_screen.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/shared/shared_suspended_screen.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/shared/shared_current_trips_screen.dart';
import 'package:car_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:car_app/core/router/navigation_manager.dart';
import 'package:car_app/features/trips/presentation/shared_widgets/trips_list_shimmer.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PassengerTripsListScreenClean extends StatefulWidget {
  const PassengerTripsListScreenClean({super.key});

  @override
  State<PassengerTripsListScreenClean> createState() =>
      _PassengerTripsListScreenCleanState();
}

class _PassengerTripsListScreenCleanState
    extends State<PassengerTripsListScreenClean> {
  int currentIndexPrivet = 0;

  int currentIndexShared = 0;

  int currentIndex = 0;

  bool isLoading = true;

  var userData;

  getStates() async {
    var box = await Hive.openBox('hive_box');
    var user_data = box.get('user_data');
    if (mounted) {
      setState(() {
        userData = user_data;
      });
    }
  }

  stoploading() async {
    await getStates();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget build(BuildContext context) {
    return BlocProvider<PassengerTripsCubit>(
      create: (context) => di.sl<PassengerTripsCubit>()
        ..getUserTrips(stoploading: stoploading, isLoading: isLoading),
      child: BlocConsumer<PassengerTripsCubit, PassengerTripsState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
            appBar: isLoading
                ? AppBar(toolbarOpacity: 0)
                : AppBar(
                    backgroundColor: Colors.grey[200],
                    title: Text(
                      'My Trips',
                    ),
                    actions: [
                      IconButton(
                        onPressed: () {
                          navigateTo(context, const CleanNotificationsScreen());
                        },
                        icon: FaIcon(
                          FontAwesomeIcons.bell,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
            body: isLoading
                ? const TripsListShimmer()
                : Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 50,
                            child: TabBar(
                              physics: const NeverScrollableScrollPhysics(),
                              onTap: (value) {
                                setState(() {
                                  currentIndex = value;
                                });
                              },
                              isScrollable: false,
                              splashBorderRadius: BorderRadius.circular(5),
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicator: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.black,
                              tabs: [
                                Tab(
                                  child: defaultText(
                                    text: S.of(context).privateTrip,
                                    textColor: currentIndex == 0
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                Tab(
                                  child: defaultText(
                                    text: S.of(context).sharedTrip,
                                    textColor: currentIndex == 1
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Container(
                            // height: 580,
                            // color: Colors.red,

                            child: Expanded(
                              child: TabBarView(
                                physics: NeverScrollableScrollPhysics(),
                                children: [
                                  DefaultTabController(
                                    length: 3,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          height: 40.0,
                                          child: TabBar(
                                            onTap: (value) {
                                              setState(() {
                                                currentIndexPrivet = value;
                                              });
                                            },
                                            indicatorColor: currentIndexPrivet ==
                                                    0
                                                ? AppColors.accent
                                                : currentIndexPrivet == 1
                                                    ? Colors.green
                                                    : currentIndexPrivet == 2
                                                        ? Colors.red
                                                        : currentIndexPrivet ==
                                                                3
                                                            ? Colors.orange
                                                            : AppColors.accent,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            labelPadding: EdgeInsets.all(0),
                                            labelColor: AppColors.primary,
                                            unselectedLabelColor: Colors.grey,
                                            tabs: [
                                              Tab(
                                                child: defaultText(
                                                  text: S
                                                      .of(context)
                                                      .currentTrips,
                                                ),
                                              ),
                                              Tab(
                                                child: defaultText(
                                                  text: S.of(context).completed,
                                                ),
                                              ),
                                              Tab(
                                                child: defaultText(
                                                  text: S.of(context).canceled,
                                                ),
                                              ),
                                              // Tab(
                                              //   child: defaultText(
                                              //     text: S.of(context).suspended,
                                              //   ),
                                              // ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        Container(
                                          // height: 540.0,
                                          // color: Colors.red,
                                          child: Expanded(
                                            child: TabBarView(
                                               physics:
                                                   const NeverScrollableScrollPhysics(),
                                               children: [
                                                 // Current Private Trips
                                                 Container(
                                                   child: ListView.separated(
                                                     itemCount: PassengerTripsCubit.get(context).TripsListByTypeCurrentPrivete.length,
                                                     shrinkWrap: true,
                                                     itemBuilder: (context, index) {
                                                       final Trip trip = PassengerTripsCubit.get(context).TripsListByTypeCurrentPrivete[index];
                                                       final isAccepted = trip.driverId != null && trip.status == TripStatus.accepted;
                                                       final isClosed = trip.status == TripStatus.closed;
                                                       final borderColor = isAccepted ? Colors.green : (isClosed ? Colors.red : Colors.yellow);

                                                       return privateTripContainer(
                                                         context: context,
                                                         borderColor: borderColor,
                                                          onTap: () {
                                                            if (trip.driverId == null || trip.status != TripStatus.accepted) {
                                                              navigateTo(
                                                                context,
                                                                PrivateCurrentScreenCleanoffers(
                                                                  trip: trip,
                                                                  id: trip.id,
                                                                ),
                                                              );
                                                            } else {
                                                             navigateTo(
                                                               context,
                                                               PassengerCurrentPrivateTripScreenClean(
                                                                 trip: trip,
                                                                 userData: userData,
                                                               ),
                                                             );
                                                           }
                                                         },
                                                          timeText: trip.tripDatetime,
                                                          dateText: trip.tripDatetime,
                                                          locationText: (trip.driverId == null || trip.status != TripStatus.accepted) ? S.of(context).noDriversYet : trip.toLocationName,
                                                        );
                                                      },
                                                      separatorBuilder: (context, index) => const SizedBox(height: 15.0),
                                                    ),
                                                  ),

                                                 // Completed Private Trips
                                                 Container(
                                                   child: ListView.separated(
                                                     itemCount: PassengerTripsCubit.get(context).TripsListByTypeCompletedPrivete.length,
                                                     shrinkWrap: true,
                                                     itemBuilder: (context, index) {
                                                       final Trip trip = PassengerTripsCubit.get(context).TripsListByTypeCompletedPrivete[index];
                                                       return privateTripContainer(
                                                         borderColor: Colors.green,
                                                         context: context,
                                                         onTap: () {
                                                           navigateTo(
                                                             context,
                                                             PassengerPrivateCompletedScreenClean(
                                                               trip: trip,
                                                             ),
                                                           );
                                                         },
                                                          timeText: trip.tripDatetime,
                                                          dateText: trip.tripDatetime,
                                                          locationText: trip.toLocationName,
                                                        );
                                                      },
                                                      separatorBuilder: (context, index) => const SizedBox(height: 15.0),
                                                    ),
                                                  ),

                                                 // Canceled Private Trips
                                                 Container(
                                                   child: ListView.separated(
                                                     itemCount: PassengerTripsCubit.get(context).TripsListByTypeCanceledPrivete.length,
                                                     shrinkWrap: true,
                                                     itemBuilder: (context, index) {
                                                       final Trip trip = PassengerTripsCubit.get(context).TripsListByTypeCanceledPrivete[index];
                                                       return privateTripContainer(
                                                         context: context,
                                                         borderColor: Colors.red,
                                                         onTap: () {
                                                           navigateTo(
                                                             context,
                                                             PassengerPrivateCanceledScreenClean(
                                                               trip: trip,
                                                             ),
                                                           );
                                                         },
                                                          timeText: trip.tripDatetime,
                                                          dateText: trip.tripDatetime,
                                                          locationText: trip.toLocationName,
                                                       );
                                                     },
                                                     separatorBuilder: (context, index) => const SizedBox(height: 15.0),
                                                   ),
                                                 ),
                                               ],
                                             ),
                                           ),
                                         ),
                                       ],
                                     ),
                                   ),

                                  // shared trips
                                  DefaultTabController(
                                    length: 4,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          height: 40.0,
                                          child: TabBar(
                                            onTap: (value) {
                                              setState(() {
                                                currentIndexShared = value;
                                              });
                                            },
                                            indicatorColor: currentIndexShared ==
                                                    0
                                                ? AppColors.accent
                                                : currentIndexShared == 1
                                                    ? Colors.green
                                                    : currentIndexShared == 2
                                                        ? Colors.red
                                                        : currentIndexShared ==
                                                                3
                                                            ? Colors.orange
                                                            : AppColors.accent,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            labelPadding: EdgeInsets.all(0),
                                            labelColor: AppColors.primary,
                                            unselectedLabelColor: Colors.grey,
                                            tabs: [
                                              Tab(
                                                child: defaultText(
                                                  text: S
                                                      .of(context)
                                                      .currentTrips,
                                                ),
                                              ),
                                              Tab(
                                                child: defaultText(
                                                  text: S.of(context).completed,
                                                ),
                                              ),
                                              Tab(
                                                child: defaultText(
                                                  text: S.of(context).canceled,
                                                ),
                                              ),
                                              Tab(
                                                child: defaultText(
                                                  text: S.of(context).suspended,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        Container(
                                          // height: 540.0,
                                          // color: Colors.red,
                                           //shared trips
                                           child: Expanded(
                                             child: TabBarView(
                                               physics:
                                                   const NeverScrollableScrollPhysics(),
                                               children: [
                                                 // Current Shared Trips
                                                 Container(
                                                   child: ListView.separated(
                                                     itemCount: PassengerTripsCubit.get(context).TripsListByTypeCurrentShared.length,
                                                     shrinkWrap: true,
                                                     itemBuilder: (context, index) {
                                                       final Trip trip = PassengerTripsCubit.get(context).TripsListByTypeCurrentShared[index];
                                                       final isAccepted = trip.driverId != null && trip.status == TripStatus.accepted;
                                                       final isClosed = trip.status == TripStatus.closed;
                                                       final borderColor = isAccepted ? Colors.green : (isClosed ? Colors.red : AppColors.accent);

                                                       return sharedTripContainer(
                                                         context: context,
                                                         borderColor: borderColor,
                                                         onTap: () {
                                                           if (trip.driverId == null || trip.status != TripStatus.accepted) {
                                                             navigateTo(
                                                               context,
                                                               SharedCurrentTripsScreenClean(
                                                                 trip: trip,
                                                                 id: trip.id,
                                                               ),
                                                             );
                                                           } else {
                                                             context.push(
                                                               AppRoutes.passengerOngoingSharedTrip,
                                                               extra: trip,
                                                             );
                                                           }
                                                         },
                                                         timeText: trip.tripDatetime.contains('T')
                                                             ? trip.tripDatetime.split('T')[1].substring(0, 5)
                                                             : (trip.tripDatetime.contains(' ') ? trip.tripDatetime.split(' ')[1] : trip.tripDatetime),
                                                         dateText: S.of(context).outAt + trip.tripDatetime,
                                                         locationText: (trip.driverId == null || trip.status != TripStatus.accepted) ? S.of(context).noDriversYet : trip.toLocationName,
                                                       );
                                                     },
                                                     separatorBuilder: (context, index) => const SizedBox(height: 15.0),
                                                   ),
                                                 ),

                                                 // Completed Shared Trips
                                                 Container(
                                                   child: ListView.separated(
                                                     shrinkWrap: true,
                                                     itemCount: PassengerTripsCubit.get(context).TripsListByTypeCompletedShared.length,
                                                     itemBuilder: (context, index) {
                                                       final Trip trip = PassengerTripsCubit.get(context).TripsListByTypeCompletedShared[index];
                                                       return sharedTripContainer(
                                                         context: context,
                                                         borderColor: Colors.green,
                                                         onTap: () {
                                                           navigateTo(
                                                             context,
                                                             PassengerSharedCompletedScreenClean(
                                                               trip: trip,
                                                             ),
                                                           );
                                                         },
                                                         timeText: trip.tripDatetime.contains('T')
                                                             ? trip.tripDatetime.split('T')[1].substring(0, 5)
                                                             : (trip.tripDatetime.contains(' ') ? trip.tripDatetime.split(' ')[1] : trip.tripDatetime),
                                                         dateText: S.of(context).outAt + trip.tripDatetime,
                                                         locationText: trip.toLocationName,
                                                       );
                                                     },
                                                     separatorBuilder: (context, index) => const SizedBox(height: 15.0),
                                                   ),
                                                 ),

                                                 // Canceled Shared Trips
                                                 Container(
                                                   child: ListView.separated(
                                                     itemCount: PassengerTripsCubit.get(context).TripsListByTypeCanceledShared.length,
                                                     shrinkWrap: true,
                                                     itemBuilder: (context, index) {
                                                       final Trip trip = PassengerTripsCubit.get(context).TripsListByTypeCanceledShared[index];
                                                       return sharedTripContainer(
                                                         context: context,
                                                         borderColor: Colors.red,
                                                         onTap: () {
                                                           navigateTo(
                                                             context,
                                                             PassengerSharedCanceledScreenClean(
                                                               trip: trip,
                                                             ),
                                                           );
                                                         },
                                                         timeText: trip.tripDatetime.contains('T')
                                                             ? trip.tripDatetime.split('T')[1].substring(0, 5)
                                                             : (trip.tripDatetime.contains(' ') ? trip.tripDatetime.split(' ')[1] : trip.tripDatetime),
                                                         dateText: S.of(context).outAt + trip.tripDatetime,
                                                         locationText: trip.toLocationName,
                                                       );
                                                     },
                                                     separatorBuilder: (context, index) => const SizedBox(height: 15.0),
                                                   ),
                                                 ),

                                                 // Suspended Shared Trips
                                                 Container(
                                                   child: ListView.separated(
                                                     itemCount: PassengerTripsCubit.get(context).TripsListByTypeSuspendedShared.length,
                                                     shrinkWrap: true,
                                                     itemBuilder: (context, index) {
                                                       final Trip trip = PassengerTripsCubit.get(context).TripsListByTypeSuspendedShared[index];
                                                       return sharedTripContainer(
                                                         borderColor: Colors.orange,
                                                         onTap: () {
                                                           navigateTo(
                                                             context,
                                                             PassengerSharedSuspendedScreenClean(
                                                               trip: trip,
                                                             ),
                                                           );
                                                         },
                                                         timeText: trip.tripDatetime,
                                                         dateText: trip.tripDatetime,
                                                         locationText: subEnd(trip.toLocationName),
                                                       );
                                                     },
                                                     separatorBuilder: (context, index) => const SizedBox(height: 15.0),
                                                   ),
                                                 ),
                                               ],
                                             ),
                                           ),
                                         ),
                                       ],
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                           ),
                         ],
                       ),
                     ),
                   ),
           );
         },
       ),
     );
   }
 }

bool checkIfTimeIsInPast(DateTime inputTime) {
  final currentTime = DateTime.now();
  return inputTime.isBefore(currentTime);
}

String subEnd(String string) {
  return string.length > 45 ? string.substring(0, 45) : string;
}
