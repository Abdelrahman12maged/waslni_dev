import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/router/navigation_manager.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_trips_cubit.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_trips_state.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/private/current_private_trip_screen.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/private/private_canceled_trips_screen.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/private/private_completed_trips_screen.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/private/private_current_screen_offers.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/shared/shared_canceled_trips_screen.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/shared/shared_completed_trips_screen.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/shared/shared_current_trips_screen.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/shared/shared_suspended_screen.dart';
import 'package:car_app/features/trips/presentation/shared_widgets/trips_list_shimmer.dart';
import 'package:car_app/generated/l10n.dart';

class PassengerTripsListView extends StatefulWidget {
  const PassengerTripsListView({super.key});

  @override
  State<PassengerTripsListView> createState() => _PassengerTripsListViewState();
}

class _PassengerTripsListViewState extends State<PassengerTripsListView> {
  int currentIndexPrivet = 0;
  int currentIndexShared = 0;
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PassengerTripsCubit, PassengerTripsState>(
      listener: (context, state) {},
      builder: (context, state) {
        final cubit = PassengerTripsCubit.get(context);
        final isLoading = state is PassengerTripsLoading;

        return Scaffold(
          appBar: isLoading
              ? AppBar(toolbarOpacity: 0)
              : AppBar(
                  backgroundColor: Colors.grey[200],
                  title: const Text('My Trips'),
                  actions: [
                    IconButton(
                      onPressed: () {
                        navigateTo(context, const CleanNotificationsScreen());
                      },
                      icon: const FaIcon(
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
                        SizedBox(
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
                        const SizedBox(height: 10.0),
                        Expanded(
                          child: TabBarView(
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              DefaultTabController(
                                length: 3,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: 40.0,
                                      child: TabBar(
                                        onTap: (value) {
                                          setState(() {
                                            currentIndexPrivet = value;
                                          });
                                        },
                                        indicatorColor: currentIndexPrivet == 0
                                            ? AppColors.accent
                                            : currentIndexPrivet == 1
                                                ? Colors.green
                                                : Colors.red,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        labelPadding: EdgeInsets.zero,
                                        labelColor: AppColors.primary,
                                        unselectedLabelColor: Colors.grey,
                                        tabs: [
                                          Tab(
                                            child: defaultText(
                                              text: S.of(context).currentTrips,
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
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10.0),
                                    Expanded(
                                      child: TabBarView(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        children: [
                                          ListView.separated(
                                            itemCount: cubit
                                                .TripsListByTypeCurrentPrivete
                                                .length,
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) {
                                              final Trip trip = cubit
                                                      .TripsListByTypeCurrentPrivete[
                                                  index];
                                              final isAccepted =
                                                  trip.driverId != null &&
                                                      trip.status ==
                                                          TripStatus.accepted;
                                              final isClosed = trip.status ==
                                                  TripStatus.closed;
                                              final borderColor = isAccepted
                                                  ? Colors.green
                                                  : (isClosed
                                                      ? Colors.red
                                                      : Colors.yellow);

                                              return privateTripContainer(
                                                context: context,
                                                borderColor: borderColor,
                                                onTap: () {
                                                  if (trip.driverId == null ||
                                                      trip.status !=
                                                          TripStatus.accepted) {
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
                                                      ),
                                                    );
                                                  }
                                                },
                                                timeText: trip.tripDatetime,
                                                dateText: trip.tripDatetime,
                                                locationText: (trip.driverId ==
                                                            null ||
                                                        trip.status !=
                                                            TripStatus.accepted)
                                                    ? S.of(context).noDriversYet
                                                    : trip.toLocationName,
                                              );
                                            },
                                            separatorBuilder:
                                                (context, index) =>
                                                    const SizedBox(
                                                        height: 15.0),
                                          ),
                                          ListView.separated(
                                            itemCount: cubit
                                                .TripsListByTypeCompletedPrivete
                                                .length,
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) {
                                              final Trip trip = cubit
                                                      .TripsListByTypeCompletedPrivete[
                                                  index];
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
                                                locationText:
                                                    trip.toLocationName,
                                              );
                                            },
                                            separatorBuilder:
                                                (context, index) =>
                                                    const SizedBox(
                                                        height: 15.0),
                                          ),
                                          ListView.separated(
                                            itemCount: cubit
                                                .TripsListByTypeCanceledPrivete
                                                .length,
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) {
                                              final Trip trip = cubit
                                                      .TripsListByTypeCanceledPrivete[
                                                  index];
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
                                                locationText:
                                                    trip.toLocationName,
                                              );
                                            },
                                            separatorBuilder:
                                                (context, index) =>
                                                    const SizedBox(
                                                        height: 15.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DefaultTabController(
                                length: 4,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: 40.0,
                                      child: TabBar(
                                        onTap: (value) {
                                          setState(() {
                                            currentIndexShared = value;
                                          });
                                        },
                                        indicatorColor: currentIndexShared == 0
                                            ? AppColors.accent
                                            : currentIndexShared == 1
                                                ? Colors.green
                                                : currentIndexShared == 2
                                                    ? Colors.red
                                                    : currentIndexShared == 3
                                                        ? Colors.orange
                                                        : AppColors.accent,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        labelPadding: EdgeInsets.zero,
                                        labelColor: AppColors.primary,
                                        unselectedLabelColor: Colors.grey,
                                        tabs: [
                                          Tab(
                                            child: defaultText(
                                              text: S.of(context).currentTrips,
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
                                    const SizedBox(height: 10.0),
                                    Expanded(
                                      child: TabBarView(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        children: [
                                          ListView.separated(
                                            itemCount: cubit
                                                .TripsListByTypeCurrentShared
                                                .length,
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) {
                                              final Trip trip = cubit
                                                      .TripsListByTypeCurrentShared[
                                                  index];
                                              final isAccepted =
                                                  trip.driverId != null &&
                                                      trip.status ==
                                                          TripStatus.accepted;
                                              final isClosed = trip.status ==
                                                  TripStatus.closed;
                                              final borderColor = isAccepted
                                                  ? Colors.green
                                                  : (isClosed
                                                      ? Colors.red
                                                      : AppColors.accent);

                                              return sharedTripContainer(
                                                context: context,
                                                borderColor: borderColor,
                                                onTap: () {
                                                  if (trip.driverId == null ||
                                                      trip.status !=
                                                          TripStatus.accepted) {
                                                    navigateTo(
                                                      context,
                                                      SharedCurrentTripsScreenClean(
                                                        trip: trip,
                                                        id: trip.id,
                                                      ),
                                                    );
                                                  } else {
                                                    context.push(
                                                      AppRoutes
                                                          .passengerOngoingSharedTrip,
                                                      extra: trip,
                                                    );
                                                  }
                                                },
                                                timeText: trip
                                                        .tripDatetime
                                                        .contains('T')
                                                    ? trip.tripDatetime
                                                        .split('T')[1]
                                                        .substring(0, 5)
                                                    : (trip.tripDatetime
                                                            .contains(' ')
                                                        ? trip.tripDatetime
                                                            .split(' ')[1]
                                                        : trip.tripDatetime),
                                                dateText:
                                                    S.of(context).outAt +
                                                        trip.tripDatetime,
                                                locationText: (trip.driverId ==
                                                            null ||
                                                        trip.status !=
                                                            TripStatus.accepted)
                                                    ? S.of(context).noDriversYet
                                                    : trip.toLocationName,
                                              );
                                            },
                                            separatorBuilder:
                                                (context, index) =>
                                                    const SizedBox(
                                                        height: 15.0),
                                          ),
                                          ListView.separated(
                                            shrinkWrap: true,
                                            itemCount: cubit
                                                .TripsListByTypeCompletedShared
                                                .length,
                                            itemBuilder: (context, index) {
                                              final Trip trip = cubit
                                                      .TripsListByTypeCompletedShared[
                                                  index];
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
                                                timeText: trip
                                                        .tripDatetime
                                                        .contains('T')
                                                    ? trip.tripDatetime
                                                        .split('T')[1]
                                                        .substring(0, 5)
                                                    : (trip.tripDatetime
                                                            .contains(' ')
                                                        ? trip.tripDatetime
                                                            .split(' ')[1]
                                                        : trip.tripDatetime),
                                                dateText:
                                                    S.of(context).outAt +
                                                        trip.tripDatetime,
                                                locationText:
                                                    trip.toLocationName,
                                              );
                                            },
                                            separatorBuilder:
                                                (context, index) =>
                                                    const SizedBox(
                                                        height: 15.0),
                                          ),
                                          ListView.separated(
                                            itemCount: cubit
                                                .TripsListByTypeCanceledShared
                                                .length,
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) {
                                              final Trip trip = cubit
                                                      .TripsListByTypeCanceledShared[
                                                  index];
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
                                                timeText: trip
                                                        .tripDatetime
                                                        .contains('T')
                                                    ? trip.tripDatetime
                                                        .split('T')[1]
                                                        .substring(0, 5)
                                                    : (trip.tripDatetime
                                                            .contains(' ')
                                                        ? trip.tripDatetime
                                                            .split(' ')[1]
                                                        : trip.tripDatetime),
                                                dateText:
                                                    S.of(context).outAt +
                                                        trip.tripDatetime,
                                                locationText:
                                                    trip.toLocationName,
                                              );
                                            },
                                            separatorBuilder:
                                                (context, index) =>
                                                    const SizedBox(
                                                        height: 15.0),
                                          ),
                                          ListView.separated(
                                            itemCount: cubit
                                                .TripsListByTypeSuspendedShared
                                                .length,
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) {
                                              final Trip trip = cubit
                                                      .TripsListByTypeSuspendedShared[
                                                  index];
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
                                                locationText:
                                                    subEnd(trip.toLocationName),
                                              );
                                            },
                                            separatorBuilder:
                                                (context, index) =>
                                                    const SizedBox(
                                                        height: 15.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
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
