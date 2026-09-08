import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/core/widgets/kyc_status_banner.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_trips_cubit.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_trips_state.dart';
import 'package:car_app/features/trips/presentation/driver/widgets/new_trips/driver_empty_trips_view.dart';
import 'package:car_app/features/trips/presentation/driver/widgets/new_trips/driver_pricing_dialog.dart';
import 'package:car_app/features/trips/presentation/driver/widgets/new_trips/driver_search_filter_header.dart';
import 'package:car_app/features/trips/presentation/driver/widgets/new_trips/driver_trip_card_item.dart';
import 'package:car_app/generated/l10n.dart';

class DriverNewTripsAcceptView extends StatefulWidget {
  const DriverNewTripsAcceptView({super.key});

  @override
  State<DriverNewTripsAcceptView> createState() =>
      _DriverNewTripsAcceptViewState();
}

class _DriverNewTripsAcceptViewState extends State<DriverNewTripsAcceptView> {
  int currentIndex = 0;
  bool isLoading = true;
  List driver_rejected_trips = [];

  @override
  void initState() {
    super.initState();
    driver_rejected_trips =
        di.sl<LocalStorage>().readStringList(key: 'driver_rejected_trips') ??
            [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        DriverTripsCubit.get(context).getDriverTripsByTypes(
          stoploading: stoploading,
          isLoading: isLoading,
        );
      }
    });
  }

  stoploading() async {
    setState(() {
      driver_rejected_trips =
          di.sl<LocalStorage>().readStringList(key: 'driver_rejected_trips') ??
              [];
      isLoading = false;
    });
    if (kDebugMode) {
      log('driver_rejected_trips: $driver_rejected_trips', name: 'DriverTrips');
    }
  }

  setNewLoading(newValue) {
    setState(() {
      isLoading = newValue;
    });
  }

  String _getKycStatus() {
    try {
      if (Hive.isBoxOpen('hive_box')) {
        final box = Hive.box('hive_box');
        final userData = box.get('user_data');
        if (userData is Map) {
          final userObj =
              userData['user'] is Map ? userData['user'] : userData;
          if (userObj is Map) {
            final kyc = userObj['kyc_status']?.toString() ??
                userObj['kyc']?.toString();
            if (kyc != null && kyc.isNotEmpty) return kyc;
            final isApproved = userObj['is_approved'] ?? userObj['approved'];
            if (isApproved == 0 || isApproved == false || isApproved == '0') {
              return 'pending';
            }
          }
        }
      }
    } catch (_) {}
    return 'approved';
  }

  @override
  Widget build(BuildContext context) {
    final kycStatus = _getKycStatus();
    final isKycBlocked = kycStatus == 'pending' ||
        kycStatus == 'under_review' ||
        kycStatus == 'rejected';
    final cubit = DriverTripsCubit.get(context);

    return BlocConsumer<DriverTripsCubit, DriverTripsState>(
      listener: (context, state) {},
      builder: (context, state) {
        return SafeArea(
          child: Scaffold(
            appBar: defaultAppBar(
              leadingOnPressed: () {
                Navigator.of(context).pop();
              },
              titleText: S.of(context).newTrips,
            ),
            body: Column(
              children: [
                if (isKycBlocked)
                  KycStatusBanner(
                    status: kycStatus,
                    onUpdateProfileTap: () =>
                        context.go(AppRoutes.driverSettings),
                  ),
                DriverSearchFilterHeader(cubit: cubit),
                Expanded(
                  child: isLoading
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/loading.gif",
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width,
                              )
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: DefaultTabController(
                                  length: 2,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        height: 50,
                                        child: TabBar(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          onTap: (value) {
                                            setState(() {
                                              currentIndex = value;
                                            });
                                          },
                                          isScrollable: false,
                                          splashBorderRadius:
                                              BorderRadius.circular(5),
                                          indicatorSize:
                                              TabBarIndicatorSize.tab,
                                          indicator: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          labelColor: Colors.white,
                                          unselectedLabelColor: Colors.black,
                                          tabs: [
                                            Tab(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  defaultText(
                                                    text: S
                                                        .of(context)
                                                        .privateTrip,
                                                    textColor: currentIndex == 0
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                  if (cubit
                                                      .TripsListByTypePrivete
                                                      .isNotEmpty) ...[
                                                    const SizedBox(width: 6),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 6,
                                                          vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: currentIndex == 0
                                                            ? Colors.white
                                                                .withOpacity(
                                                                    0.25)
                                                            : AppColors.primary
                                                                .withOpacity(
                                                                    0.12),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: Text(
                                                        '${cubit.TripsListByTypePrivete.length}',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                               FontWeight.bold,
                                                          color:
                                                              currentIndex == 0
                                                                  ? Colors.white
                                                                  : AppColors
                                                                      .primary,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                            Tab(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  defaultText(
                                                    text: S
                                                        .of(context)
                                                        .sharedTrip,
                                                    textColor: currentIndex == 1
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                  if (cubit
                                                      .TripsListByTypeShared
                                                      .isNotEmpty) ...[
                                                    const SizedBox(width: 6),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 6,
                                                          vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: currentIndex == 1
                                                            ? Colors.white
                                                                .withOpacity(
                                                                    0.25)
                                                            : AppColors.primary
                                                                .withOpacity(
                                                                    0.12),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: Text(
                                                        '${cubit.TripsListByTypeShared.length}',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                               FontWeight.bold,
                                                          color:
                                                              currentIndex == 1
                                                                  ? Colors.white
                                                                  : AppColors
                                                                      .primary,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10.0),
                                      Expanded(
                                        child: DriverAutoRefreshView(
                                          onRefresh: () {
                                            if (!isLoading) {
                                              DriverTripsCubit.get(context)
                                                  .getDriverTripsByTypes(
                                                      isLoading: false);
                                            }
                                          },
                                          child: TabBarView(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            children: [
                                              RefreshIndicator(
                                                onRefresh: () async {
                                                  await Future.microtask(() =>
                                                      DriverTripsCubit.get(
                                                              context)
                                                          .getDriverTripsByTypes(
                                                              isLoading:
                                                                  false));
                                                },
                                                child: Builder(
                                                  builder: (context) {
                                                    final cubit =
                                                        DriverTripsCubit.get(
                                                            context);
                                                    final visibleTrips = cubit
                                                        .TripsListByTypePrivete
                                                        .where((t) {
                                                      if (driver_rejected_trips
                                                          .contains(t.id
                                                              .toString())) {
                                                        return false;
                                                      }
                                                      if (t.isStale ||
                                                          t.status !=
                                                              TripStatus.open) {
                                                        return false;
                                                      }
                                                      final offerStatus = cubit
                                                          .checkOfferStatus(t);
                                                      if (offerStatus ==
                                                              'accepted' ||
                                                          offerStatus ==
                                                              'another_driver_accepted') {
                                                        return false;
                                                      }
                                                      return true;
                                                    }).toList();

                                                    if (visibleTrips.isEmpty) {
                                                      return const SingleChildScrollView(
                                                        physics:
                                                            AlwaysScrollableScrollPhysics(),
                                                        child:
                                                            DriverEmptyTripsView(
                                                                isPrivate:
                                                                    true),
                                                      );
                                                    }

                                                    return ListView.separated(
                                                      itemCount:
                                                          visibleTrips.length,
                                                      shrinkWrap: true,
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 20),
                                                      separatorBuilder:
                                                          (context, index) =>
                                                              const SizedBox(
                                                                  height: 12.0),
                                                      itemBuilder:
                                                          (context, index) {
                                                        final trip =
                                                            visibleTrips[index];
                                                        return DriverTripCardItem(
                                                          trip: trip,
                                                          setNewLoading:
                                                              setNewLoading,
                                                          onOfferTap: () {
                                                            showDriverPricingDialog(
                                                              context,
                                                              tripId: trip.id,
                                                              maxPrice: trip
                                                                  .maximumPrice,
                                                              minPrice: trip
                                                                  .minimumPrice,
                                                              tripDetails: trip,
                                                            );
                                                          },
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                              RefreshIndicator(
                                                onRefresh: () async {
                                                  await Future.microtask(() =>
                                                      DriverTripsCubit.get(
                                                              context)
                                                          .getDriverTripsByTypes(
                                                              isLoading:
                                                                  false));
                                                },
                                                child: Builder(
                                                  builder: (context) {
                                                    final cubit =
                                                        DriverTripsCubit.get(
                                                            context);
                                                    final visibleTrips = cubit
                                                        .TripsListByTypeShared
                                                        .where((t) {
                                                      if (driver_rejected_trips
                                                          .contains(t.id
                                                              .toString())) {
                                                        return false;
                                                      }
                                                      if (t.isStale ||
                                                          t.status !=
                                                              TripStatus.open) {
                                                        return false;
                                                      }
                                                      final offerStatus = cubit
                                                          .checkOfferStatus(t);
                                                      if (offerStatus ==
                                                              'accepted' ||
                                                          offerStatus ==
                                                              'another_driver_accepted') {
                                                        return false;
                                                      }
                                                      return true;
                                                    }).toList();

                                                    if (visibleTrips.isEmpty) {
                                                      return const SingleChildScrollView(
                                                        physics:
                                                            AlwaysScrollableScrollPhysics(),
                                                        child:
                                                            DriverEmptyTripsView(
                                                                isPrivate:
                                                                    false),
                                                      );
                                                    }

                                                    return ListView.separated(
                                                      itemCount:
                                                          visibleTrips.length,
                                                      shrinkWrap: true,
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 20),
                                                      separatorBuilder:
                                                          (context, index) =>
                                                              const SizedBox(
                                                                  height: 12.0),
                                                      itemBuilder:
                                                          (context, index) {
                                                        final trip =
                                                            visibleTrips[index];
                                                        return DriverTripCardItem(
                                                          trip: trip,
                                                          setNewLoading:
                                                              setNewLoading,
                                                          onOfferTap: () {
                                                            showDriverPricingDialog(
                                                              context,
                                                              tripId: trip.id,
                                                              maxPrice: trip
                                                                  .maximumPrice,
                                                              minPrice: trip
                                                                  .minimumPrice,
                                                              tripDetails: trip,
                                                            );
                                                          },
                                                        );
                                                      },
                                                    );
                                                  },
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
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
