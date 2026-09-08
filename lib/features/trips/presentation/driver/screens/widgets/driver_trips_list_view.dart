import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/core/router/navigation_manager.dart';
import 'package:car_app/core/theme/colors.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_add_private_trip_cubit.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_trips_cubit.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_trips_state.dart';
import 'package:car_app/features/trips/presentation/driver/screens/private/ongoing_private_trip_screen.dart';
import 'package:car_app/features/trips/presentation/driver/screens/private/private_canceled_trips_screen.dart';
import 'package:car_app/features/trips/presentation/driver/screens/private/private_completed_trips_screen.dart';
import 'package:car_app/features/trips/presentation/driver/screens/private/private_suspended_screen.dart';
import 'package:car_app/features/trips/presentation/driver/screens/shared/ongoing_shared_trip.dart';
import 'package:car_app/features/trips/presentation/driver/screens/shared/shared_canceled_trips_screen.dart';
import 'package:car_app/features/trips/presentation/driver/screens/shared/shared_completed_trips_screen.dart';
import 'package:car_app/features/trips/presentation/driver/screens/shared/shared_suspended_trips_screen.dart';
import 'package:car_app/features/trips/presentation/shared_widgets/trips_list_shimmer.dart';
import 'package:car_app/generated/l10n.dart';

class DriverTripsListView extends StatefulWidget {
  const DriverTripsListView({super.key});

  @override
  State<DriverTripsListView> createState() => _DriverTripsListViewState();
}

class _DriverTripsListViewState extends State<DriverTripsListView> {
  int currentIndex = 0;
  int currentIndexPrivet = 0;
  int currentIndexShared = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DriverTripsCubit>().loadDriverTrips();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverTripsCubit, DriverTripsState>(
      listener: (context, state) {
        if (state is DriverTripsError) {
          showToast(text: state.message, state: ToastStates.ERROR);
        }
      },
      builder: (context, state) {
        final cubit = DriverTripsCubit.get(context);
        final isLoading = state is DriverTripsLoading;

        return Scaffold(
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
                              color: mainColor,
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
                              _buildSubTabs(
                                context: context,
                                isPrivate: true,
                                currentIndexSub: currentIndexPrivet,
                                onTabChanged: (value) {
                                  setState(() {
                                    currentIndexPrivet = value;
                                  });
                                },
                                currentList:
                                    cubit.TripsListByTypeCurrentPrivete,
                                completedList:
                                    cubit.TripsListByTypeCompletedPrivete,
                                canceledList:
                                    cubit.TripsListByTypeCanceledPrivete,
                                suspendedList:
                                    cubit.TripsListByTypeSuspendedPrivete,
                                onCurrentTap: (trip) {
                                  navigateTo(
                                    context,
                                    BlocProvider(
                                      create: (_) =>
                                          sl<DriverAddPrivateTripCubit>(),
                                      child:
                                          DriverOngoingPrivateTripScreenClean(
                                        trip: trip,
                                      ),
                                    ),
                                  );
                                },
                                onCompletedTap: (trip) {
                                  navigateTo(
                                    context,
                                    DriverPrivateCompletedTripsScreenClean(
                                      trip: trip,
                                    ),
                                  );
                                },
                                onCanceledTap: (trip) {
                                  navigateTo(
                                    context,
                                    DriverPrivateCanceledTripsScreenClean(
                                      trip: trip,
                                    ),
                                  );
                                },
                                onSuspendedTap: (trip) {
                                  navigateTo(
                                    context,
                                    DriverPrivateSuspendedScreenClean(
                                      trip: trip,
                                    ),
                                  );
                                },
                              ),
                              _buildSubTabs(
                                context: context,
                                isPrivate: false,
                                currentIndexSub: currentIndexShared,
                                onTabChanged: (value) {
                                  setState(() {
                                    currentIndexShared = value;
                                  });
                                },
                                currentList: cubit.TripsListByTypeCurrentShared,
                                completedList:
                                    cubit.TripsListByTypeCompletedShared,
                                canceledList:
                                    cubit.TripsListByTypeCanceledShared,
                                suspendedList:
                                    cubit.TripsListByTypeSuspendedShared,
                                onCurrentTap: (trip) {
                                  navigateTo(
                                    context,
                                    BlocProvider(
                                      create: (_) =>
                                          sl<DriverAddPrivateTripCubit>(),
                                      child:
                                          DriverOngoingSharedTripScreenClean(
                                        trip: trip,
                                      ),
                                    ),
                                  );
                                },
                                onCompletedTap: (trip) {
                                  navigateTo(
                                    context,
                                    DriverSharedCompletedTripsScreenClean(
                                      trip: trip,
                                    ),
                                  );
                                },
                                onCanceledTap: (trip) {
                                  navigateTo(
                                    context,
                                    DriverSharedCanceledTripsScreenClean(
                                      trip: trip,
                                    ),
                                  );
                                },
                                onSuspendedTap: (trip) {
                                  navigateTo(
                                    context,
                                    SharedSuspendedTripsScreenClean(
                                      trip: trip,
                                    ),
                                  );
                                },
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

  Widget _buildSubTabs({
    required BuildContext context,
    required bool isPrivate,
    required int currentIndexSub,
    required ValueChanged<int> onTabChanged,
    required List currentList,
    required List completedList,
    required List canceledList,
    required List suspendedList,
    required void Function(Trip) onCurrentTap,
    required void Function(Trip) onCompletedTap,
    required void Function(Trip) onCanceledTap,
    required void Function(Trip) onSuspendedTap,
  }) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          SizedBox(
            height: 40.0,
            child: TabBar(
              onTap: onTabChanged,
              indicatorColor: currentIndexSub == 0
                  ? iconsColor
                  : currentIndexSub == 1
                      ? Colors.green
                      : currentIndexSub == 2
                          ? Colors.red
                          : currentIndexSub == 3
                              ? Colors.orange
                              : iconsColor,
              physics: const NeverScrollableScrollPhysics(),
              labelPadding: EdgeInsets.zero,
              labelColor: mainColor,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(child: defaultText(text: S.of(context).currentW)),
                Tab(child: defaultText(text: S.of(context).completed)),
                Tab(child: defaultText(text: S.of(context).canceled)),
                Tab(child: defaultText(text: S.of(context).suspended)),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                RefreshIndicator(
                  onRefresh: () async =>
                      await context.read<DriverTripsCubit>().loadDriverTrips(),
                  child: _buildTripsList(
                    context: context,
                    items: currentList,
                    borderColor: iconsColor,
                    isPrivate: isPrivate,
                    onTap: onCurrentTap,
                  ),
                ),
                RefreshIndicator(
                  onRefresh: () async =>
                      await context.read<DriverTripsCubit>().loadDriverTrips(),
                  child: _buildTripsList(
                    context: context,
                    items: completedList,
                    borderColor: Colors.green,
                    isPrivate: isPrivate,
                    onTap: onCompletedTap,
                  ),
                ),
                RefreshIndicator(
                  onRefresh: () async =>
                      await context.read<DriverTripsCubit>().loadDriverTrips(),
                  child: _buildTripsList(
                    context: context,
                    items: canceledList,
                    borderColor: Colors.red,
                    isPrivate: isPrivate,
                    onTap: onCanceledTap,
                  ),
                ),
                RefreshIndicator(
                  onRefresh: () async =>
                      await context.read<DriverTripsCubit>().loadDriverTrips(),
                  child: _buildTripsList(
                    context: context,
                    items: suspendedList,
                    borderColor: Colors.orange,
                    isPrivate: isPrivate,
                    onTap: onSuspendedTap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripsList({
    required BuildContext context,
    required List items,
    required Color borderColor,
    required bool isPrivate,
    required Function(Trip trip) onTap,
  }) {
    if (items.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    S.of(context).noTrips,
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: items.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final Trip trip = items[index] is Trip
            ? items[index] as Trip
            : (items[index] is Map
                ? Trip.fromMap(Map<String, dynamic>.from(items[index]))
                : Trip.fromMap({}));
        final timeText = trip.tripDatetime.contains('T')
            ? trip.tripDatetime.split('T')[1].substring(0, 5)
            : (trip.tripDatetime.contains(' ')
                ? trip.tripDatetime.split(' ')[1]
                : trip.tripDatetime);

        return isPrivate
            ? privateTripContainer(
                context: context,
                borderColor: borderColor,
                onTap: () => onTap(trip),
                timeText: timeText,
                dateText: S.of(context).outAt + trip.tripDatetime,
                locationText: trip.toLocationName,
              )
            : sharedTripContainer(
                context: context,
                borderColor: borderColor,
                onTap: () => onTap(trip),
                timeText: timeText,
                dateText: S.of(context).outAt + trip.tripDatetime,
                locationText: trip.toLocationName,
              );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 15.0),
    );
  }
}
