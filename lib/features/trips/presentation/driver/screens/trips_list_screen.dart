import 'package:car_app/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/core/theme/colors.dart';
import 'package:car_app/core/router/navigation_manager.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_trips_cubit.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_trips_state.dart';

import 'package:car_app/features/trips/presentation/driver/screens/private/ongoing_private_trip_screen.dart';
import 'package:car_app/features/trips/presentation/driver/screens/private/private_completed_trips_screen.dart';
import 'package:car_app/features/trips/presentation/driver/screens/private/private_canceled_trips_screen.dart';
import 'package:car_app/features/trips/presentation/driver/screens/private/private_suspended_screen.dart';

import 'package:car_app/features/trips/presentation/driver/screens/shared/ongoing_shared_trip.dart';
import 'package:car_app/features/trips/presentation/driver/screens/shared/shared_completed_trips_screen.dart';
import 'package:car_app/features/trips/presentation/driver/screens/shared/shared_canceled_trips_screen.dart';
import 'package:car_app/features/trips/presentation/driver/screens/shared/shared_suspended_trips_screen.dart';

import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_add_private_trip_cubit.dart';
import 'package:car_app/features/trips/presentation/shared_widgets/trips_list_shimmer.dart';

class DriverTripsListScreenClean extends StatefulWidget {
  const DriverTripsListScreenClean({super.key});

  @override
  State<DriverTripsListScreenClean> createState() =>
      _DriverTripsListScreenCleanState();
}

class _DriverTripsListScreenCleanState
    extends State<DriverTripsListScreenClean> {
  String _formatCreatedAt(dynamic raw) {
    if (raw == null) return '';
    final str = raw.toString();
    if (str.contains('T')) {
      final parts = str.split('T');
      if (parts.length > 1) {
        final date = parts[0];
        final time = parts[1].length >= 5 ? parts[1].substring(0, 5) : parts[1];
        return '$date $time';
      }
      return parts[0];
    } else if (str.contains(' ')) {
      final parts = str.split(' ');
      if (parts.length > 1) {
        final date = parts[0];
        final time = parts[1].length >= 5 ? parts[1].substring(0, 5) : parts[1];
        return '$date $time';
      }
      return parts[0];
    }
    return str;
  }

  int currentIndex = 0;

  int currentIndexPrivet = 0;

  int currentIndexShared = 0;

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
      if (state is DriverTripsLoaded && isLoading) {
        stoploading();
      }
    }, builder: (context, state) {
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
                            // ── PRIVATE TRIPS TAB (4 SUB-TABS) ───────────
                            DefaultTabController(
                              length: 4,
                              child: Column(
                                children: [
                                  Container(
                                    height: 40.0,
                                    child: TabBar(
                                      onTap: (value) {
                                        setState(() {
                                          currentIndexPrivet = value;
                                        });
                                      },
                                      indicatorColor: currentIndexPrivet == 0
                                          ? iconsColor
                                          : currentIndexPrivet == 1
                                              ? Colors.green
                                              : currentIndexPrivet == 2
                                                  ? Colors.red
                                                  : currentIndexPrivet == 3
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
                                        // 1. Current Private Trips
                                        RefreshIndicator(
                                          onRefresh: () async => await context.read<DriverTripsCubit>().loadDriverTrips(),
                                          child: _buildTripsList(
                                            context: context,
                                            items: DriverTripsCubit.get(context).TripsListByTypeCurrentPrivete,
                                            borderColor: iconsColor,
                                            isPrivate: true,
                                            onTap: (trip) {
                                              navigateTo(
                                                context,
                                                BlocProvider(
                                                  create: (_) => sl<DriverAddPrivateTripCubit>(),
                                                  child: DriverOngoingPrivateTripScreenClean(
                                                    trip: trip,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                        // 2. Completed Private Trips
                                        RefreshIndicator(
                                          onRefresh: () async => await context.read<DriverTripsCubit>().loadDriverTrips(),
                                          child: _buildTripsList(
                                            context: context,
                                            items: DriverTripsCubit.get(context).TripsListByTypeCompletedPrivete,
                                            borderColor: Colors.green,
                                            isPrivate: true,
                                            onTap: (trip) {
                                              navigateTo(
                                                context,
                                                DriverPrivateCompletedTripsScreenClean(
                                                  trip: trip,
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                        // 3. Canceled Private Trips
                                        RefreshIndicator(
                                          onRefresh: () async => await context.read<DriverTripsCubit>().loadDriverTrips(),
                                          child: _buildTripsList(
                                            context: context,
                                            items: DriverTripsCubit.get(context).TripsListByTypeCanceledPrivete,
                                            borderColor: Colors.red,
                                            isPrivate: true,
                                            onTap: (trip) {
                                              navigateTo(
                                                context,
                                                DriverPrivateCanceledTripsScreenClean(
                                                  trip: trip,
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                        // 4. Suspended Private Trips
                                        RefreshIndicator(
                                          onRefresh: () async => await context.read<DriverTripsCubit>().loadDriverTrips(),
                                          child: _buildTripsList(
                                            context: context,
                                            items: DriverTripsCubit.get(context).TripsListByTypeSuspendedPrivete,
                                            borderColor: Colors.orange,
                                            isPrivate: true,
                                            onTap: (trip) {
                                              navigateTo(
                                                context,
                                                DriverPrivateSuspendedScreenClean(
                                                  trip: trip,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ── SHARED TRIPS TAB (4 SUB-TABS) ────────────
                            DefaultTabController(
                              length: 4,
                              child: Column(
                                children: [
                                  Container(
                                    height: 40.0,
                                    child: TabBar(
                                      onTap: (value) {
                                        setState(() {
                                          currentIndexShared = value;
                                        });
                                      },
                                      indicatorColor: currentIndexShared == 0
                                          ? iconsColor
                                          : currentIndexShared == 1
                                              ? Colors.green
                                              : currentIndexShared == 2
                                                  ? Colors.red
                                                  : currentIndexShared == 3
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
                                        // 1. Current Shared Trips
                                        RefreshIndicator(
                                          onRefresh: () async => await context.read<DriverTripsCubit>().loadDriverTrips(),
                                          child: _buildTripsList(
                                            context: context,
                                            items: DriverTripsCubit.get(context).TripsListByTypeCurrentShared,
                                            borderColor: iconsColor,
                                            isPrivate: false,
                                            onTap: (trip) {
                                              navigateTo(
                                                context,
                                                BlocProvider(
                                                  create: (_) => sl<DriverAddPrivateTripCubit>(),
                                                  child: DriverOngoingSharedTripScreenClean(
                                                    trip: trip,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                        // 2. Completed Shared Trips
                                        RefreshIndicator(
                                          onRefresh: () async => await context.read<DriverTripsCubit>().loadDriverTrips(),
                                          child: _buildTripsList(
                                            context: context,
                                            items: DriverTripsCubit.get(context).TripsListByTypeCompletedShared,
                                            borderColor: Colors.green,
                                            isPrivate: false,
                                            onTap: (trip) {
                                              navigateTo(
                                                context,
                                                DriverSharedCompletedTripsScreenClean(
                                                  trip: trip,
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                        // 3. Canceled Shared Trips
                                        RefreshIndicator(
                                          onRefresh: () async => await context.read<DriverTripsCubit>().loadDriverTrips(),
                                          child: _buildTripsList(
                                            context: context,
                                            items: DriverTripsCubit.get(context).TripsListByTypeCanceledShared,
                                            borderColor: Colors.red,
                                            isPrivate: false,
                                            onTap: (trip) {
                                              navigateTo(
                                                context,
                                                DriverSharedCanceledTripsScreenClean(
                                                  trip: trip,
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                        // 4. Suspended Shared Trips
                                        RefreshIndicator(
                                          onRefresh: () async => await context.read<DriverTripsCubit>().loadDriverTrips(),
                                          child: _buildTripsList(
                                            context: context,
                                            items: DriverTripsCubit.get(context).TripsListByTypeSuspendedShared,
                                            borderColor: Colors.orange,
                                            isPrivate: false,
                                            onTap: (trip) {
                                              navigateTo(
                                                context,
                                                SharedSuspendedTripsScreenClean(
                                                  trip: trip,
                                                ),
                                              );
                                            },
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
                    ],
                  ),
                ),
              ),
      );
    });
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
                  Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    S.of(context).noTrips,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
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
        final Trip trip = items[index];
        return isPrivate
            ? privateTripContainer(
                context: context,
                borderColor: borderColor,
                onTap: () => onTap(trip),
                timeText: trip.tripDatetime.contains('T')
                    ? trip.tripDatetime.split('T')[1].substring(0, 5)
                    : (trip.tripDatetime.contains(' ')
                        ? trip.tripDatetime.split(' ')[1]
                        : trip.tripDatetime),
                dateText: S.of(context).outAt + trip.tripDatetime,
                locationText: trip.toLocationName,
              )
            : sharedTripContainer(
                context: context,
                borderColor: borderColor,
                onTap: () => onTap(trip),
                timeText: trip.tripDatetime.contains('T')
                    ? trip.tripDatetime.split('T')[1].substring(0, 5)
                    : (trip.tripDatetime.contains(' ')
                        ? trip.tripDatetime.split(' ')[1]
                        : trip.tripDatetime),
                dateText: S.of(context).outAt + trip.tripDatetime,
                locationText: trip.toLocationName,
              );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 15.0),
    );
  }
}

checkIfTimeIsInPast(DateTime inputTime) {
  DateTime currentTime = DateTime.now();

  if (inputTime.isBefore(currentTime)) {
    return true;
  } else {
    return false;
  }
}

String subEnd(String string) {
  return string.length > 45 ? string.substring(0, 45) : string;
}
