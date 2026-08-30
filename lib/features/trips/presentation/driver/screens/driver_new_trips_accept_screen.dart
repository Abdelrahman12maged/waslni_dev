import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_trips_cubit.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_trips_state.dart';
import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/core/storage/local_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_app/features/trips/data/models/trip_model.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';

import 'package:flutter/material.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_add_private_trip_cubit.dart';
import 'package:car_app/features/trips/presentation/driver/screens/private/ongoing_private_trip_screen.dart';
import 'package:car_app/features/trips/presentation/driver/screens/shared/ongoing_shared_trip.dart';
import 'package:car_app/core/router/navigation_manager.dart';
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/widgets/kyc_status_banner.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/core/widgets/app_cached_image.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/features/chat/presentation/screens/trip_chat_screen.dart';
import 'package:car_app/core/utils/chat_channel_helper.dart';
import 'package:car_app/core/widgets/unread_badge.dart';

class DriverNewTripsAcceptScreenClean extends StatefulWidget {
  const DriverNewTripsAcceptScreenClean({super.key});

  @override
  State<DriverNewTripsAcceptScreenClean> createState() =>
      _DriverNewTripsAcceptScreenCleanState();
}

class _DriverNewTripsAcceptScreenCleanState
    extends State<DriverNewTripsAcceptScreenClean> {
  int currentIndex = 0;
  bool isLoading = true;
  List driver_rejected_trips = [];

  @override
  void initState() {
    super.initState();
    driver_rejected_trips =
        di.sl<LocalStorage>().readStringList(key: 'driver_rejected_trips') ?? [];
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

  String _getCreatorName(dynamic tripData, BuildContext context) {
    if (tripData is Trip) {
      return tripData.creator?.name.isNotEmpty == true
          ? tripData.creator!.name
          : S.of(context).passenger;
    }
    if (tripData is Map) {
      final creator = tripData['creator'];
      if (creator is Map && creator['name'] != null) {
        return creator['name'].toString();
      }
      final user = tripData['user'];
      if (user is Map && user['name'] != null) {
        return user['name'].toString();
      }
      if (tripData['creator_name'] != null) {
        return tripData['creator_name'].toString();
      }
    }
    return S.of(context).passenger;
  }

  String _formatDateTime(dynamic dt) {
    if (dt == null) return '';
    final str = dt.toString().trim();
    if (str.isEmpty) return '';
    if (str.contains('T')) {
      final parts = str.split('T');
      final date = parts[0];
      final time =
          parts.length > 1 ? parts[1].split('.')[0].replaceAll('Z', '') : '';
      final timeShort = time.length >= 5 ? time.substring(0, 5) : time;
      return timeShort.isNotEmpty ? '$timeShort $date' : date;
    }
    if (str.contains(' ')) {
      final parts = str.split(' ');
      if (parts.length >= 2) return '${parts[1]} ${parts[0]}';
      return str;
    }
    return str;
  }

  String _getKycStatus() {
    try {
      if (Hive.isBoxOpen('hive_box')) {
        final box = Hive.box('hive_box');
        final userData = box.get('user_data');
        if (userData is Map) {
          final userObj = userData['user'] is Map ? userData['user'] : userData;
          if (userObj is Map) {
            final kyc =
                userObj['kyc_status']?.toString() ?? userObj['kyc']?.toString();
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
                _buildSearchFilterHeader(context, cubit),
                Expanded(
                  child: isLoading
                      ? Container(
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
                                      Container(
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
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  defaultText(
                                                    text: S.of(context).privateTrip,
                                                    textColor: currentIndex == 0
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                  if (cubit.TripsListByTypePrivete.isNotEmpty) ...[
                                                    const SizedBox(width: 6),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: currentIndex == 0
                                                            ? Colors.white.withOpacity(0.25)
                                                            : AppColors.primary.withOpacity(0.12),
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Text(
                                                        '${cubit.TripsListByTypePrivete.length}',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.bold,
                                                          color: currentIndex == 0
                                                              ? Colors.white
                                                              : AppColors.primary,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                            Tab(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  defaultText(
                                                    text: S.of(context).sharedTrip,
                                                    textColor: currentIndex == 1
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                  if (cubit.TripsListByTypeShared.isNotEmpty) ...[
                                                    const SizedBox(width: 6),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: currentIndex == 1
                                                            ? Colors.white.withOpacity(0.25)
                                                            : AppColors.primary.withOpacity(0.12),
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Text(
                                                        '${cubit.TripsListByTypeShared.length}',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.bold,
                                                          color: currentIndex == 1
                                                              ? Colors.white
                                                              : AppColors.primary,
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
                                      const SizedBox(
                                        height: 10.0,
                                      ),
                                      Expanded(
                                        child: _AutoRefreshView(
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
                                              // ─── Private Trips Tab ───
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
                                                          final offerStatus =
                                                              cubit.checkOfferStatus(t);
                                                          if (offerStatus ==
                                                                  'accepted' ||
                                                              offerStatus ==
                                                                  'another_driver_accepted') {
                                                            return false;
                                                          }
                                                          return true;
                                                        }).toList();

                                                    if (visibleTrips.isEmpty) {
                                                      return SingleChildScrollView(
                                                        physics:
                                                            const AlwaysScrollableScrollPhysics(),
                                                        child:
                                                            _buildEmptyTripsState(
                                                                context,
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
                                                        return _DriverTripCardItem(
                                                          trip: trip,
                                                          setNewLoading:
                                                              setNewLoading,
                                                          onOfferTap: () {
                                                            pricingDialoge(
                                                              context,
                                                              trip.id,
                                                              trip.maximumPrice,
                                                              trip.minimumPrice,
                                                              trip,
                                                            );
                                                          },
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),

                                              // ─── Shared Trips Tab ───
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
                                                          final offerStatus =
                                                              cubit.checkOfferStatus(t);
                                                          if (offerStatus ==
                                                                  'accepted' ||
                                                              offerStatus ==
                                                                  'another_driver_accepted') {
                                                            return false;
                                                          }
                                                          return true;
                                                        }).toList();

                                                    if (visibleTrips.isEmpty) {
                                                      return SingleChildScrollView(
                                                        physics:
                                                            const AlwaysScrollableScrollPhysics(),
                                                        child:
                                                            _buildEmptyTripsState(
                                                                context,
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
                                                        return _DriverTripCardItem(
                                                          trip: trip,
                                                          setNewLoading:
                                                              setNewLoading,
                                                          onOfferTap: () {
                                                            pricingDialoge(
                                                              context,
                                                              trip.id,
                                                              trip.maximumPrice,
                                                              trip.minimumPrice,
                                                              trip,
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

double _safeDoubleParse(dynamic value, [double defaultValue = 0.0]) {
  if (value == null) return defaultValue;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? defaultValue;
}

// pricing Dialoug(), start
pricingDialoge(context, tripId, maxPrice, minPrice, tripDetails) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      double parsedMin = _safeDoubleParse(minPrice);
      double parsedMax = _safeDoubleParse(maxPrice);
      if (parsedMin <= 0) parsedMin = 1.0;
      if (parsedMax <= 0 || parsedMax < parsedMin) {
        parsedMax = parsedMin + 10.0;
      }
      // Single directional slider: driver picks ONE price from min → max
      double sliderValue = parsedMin;
      if (kDebugMode) {
        log('$context, $tripId, max: $maxPrice, min: $minPrice',
            name: 'OfferDialog');
      }
      int trip_id = int.tryParse(tripId?.toString() ?? '') ?? 0;
      var note = null;
      double price = parsedMin;
      var percentage_added = null;
      bool isSubmitting = false;
      // Divisions for float support: use 0.5 JOD steps, clamped to 200 divisions max
      final range = parsedMax - parsedMin;
      final divisions = (range / 0.5).clamp(1, 200).toInt();
      // Start with empty field so driver can type their own price
      final priceController = TextEditingController();

      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.white,
            elevation: 0.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      children: [
                        const Icon(Icons.local_offer_rounded,
                            color: AppColors.primary, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          S.of(context).averagePrice,
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Price range info row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${S.of(context).minPriceLabel} ${parsedMin.toStringAsFixed(1)} ${S.of(context).jod}',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade600),
                        ),
                        Text(
                          '${S.of(context).maxPriceLabel} ${parsedMax.toStringAsFixed(1)} ${S.of(context).jod}',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Large price display
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Text(
                          '${sliderValue.toStringAsFixed(2)} ${S.of(context).jod}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Single directional slider (min → max)
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor:
                            AppColors.primary.withOpacity(0.15),
                        thumbColor: AppColors.primary,
                        overlayColor: AppColors.primary.withOpacity(0.1),
                        trackHeight: 5,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 10),
                        valueIndicatorColor: AppColors.primary,
                        valueIndicatorTextStyle: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      child: Slider(
                        value: sliderValue,
                        min: parsedMin,
                        max: parsedMax,
                        divisions: divisions,
                        label:
                            '${sliderValue.toStringAsFixed(2)} ${S.of(context).jod}',
                        onChanged: (val) {
                          setState(() {
                            sliderValue = val;
                            price = val;
                            priceController.text =
                                val.toStringAsFixed(2);
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      S.of(context).orEnterCustomValue,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: priceController,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              hintText: parsedMin.toStringAsFixed(2),
                              hintStyle:
                                  TextStyle(color: Colors.grey.shade400),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                      width: 1, color: AppColors.primary)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                      width: 1, color: AppColors.primary)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                      width: 1.5,
                                      color: AppColors.primary)),
                              suffixText: S.of(context).jod,
                              suffixStyle: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold),
                            ),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            onChanged: (value) {
                              final val = _safeDoubleParse(value);
                              if (val >= parsedMin && val <= parsedMax) {
                                setState(() {
                                  sliderValue = val;
                                  price = val;
                                });
                              } else {
                                price = val;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(S.of(context).cancel),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                          ),
                          onPressed: isSubmitting
                              ? null
                              : () {
                                  final entered = double.tryParse(
                                          priceController.text.trim()) ??
                                      price;
                                  final effectivePrice =
                                      entered > 0 ? entered : sliderValue;
                                  if (effectivePrice <= 0) {
                                    showToast(
                                        text: S.of(context).pleaseEnterValue,
                                        state: ToastStates.WARNING);
                                    return;
                                  }
                                  if (parsedMax > 0 &&
                                      effectivePrice > parsedMax) {
                                    showToast(
                                        text:
                                            S.of(context).offerCannotExceedMax('$parsedMax ${S.of(context).jod}'),
                                        state: ToastStates.WARNING);
                                    return;
                                  }
                                  if (parsedMin > 0 &&
                                      effectivePrice < parsedMin) {
                                    showToast(
                                        text:
                                            S.of(context).offerCannotBeLessThanMin('$parsedMin ${S.of(context).jod}'),
                                        state: ToastStates.WARNING);
                                    return;
                                  }
                                  setState(() {
                                    isSubmitting = true;
                                  });
                                  final cubit = DriverTripsCubit.get(context);
                                  Navigator.pop(context);
                                  cubit.createOffer(
                                      context,
                                      trip_id: trip_id,
                                      note: note,
                                      price: effectivePrice,
                                      percentage_added: percentage_added,
                                      trip: tripDetails is Trip
                                          ? tripDetails
                                          : (tripDetails is Map<String, dynamic>
                                              ? TripModel.fromJson(tripDetails)
                                              : TripModel.fromJson({})));
                                },
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  S.of(context).send,
                                  style:
                                      const TextStyle(color: Colors.white),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildOfferButton(
    BuildContext context, dynamic tripData, VoidCallback openPricingDialog) {
  final trip = tripData is Trip
      ? tripData
      : (tripData is Map<String, dynamic>
          ? TripModel.fromJson(tripData)
          : TripModel.fromJson({}));
  final cubit = DriverTripsCubit.get(context);
  final offerStatus = cubit.checkOfferStatus(trip);

  if (offerStatus == 'pending') {
    return defaultButton(
      onPressed: () {
        showToast(
          text: S.of(context).offerSentWaitingPassenger,
          state: ToastStates.WARNING,
        );
      },
      text: S.of(context).waitingAcceptance,
      background: Colors.amber.shade800,
      height: 40,
    );
  } else if (offerStatus == 'individual_rejected') {
    return defaultButton(
      onPressed: openPricingDialog,
      text: S.of(context).offerRejectedSendNew,
      background: Colors.deepOrange.shade700,
      height: 40,
    );
  } else if (offerStatus == 'accepted') {
    return defaultButton(
      onPressed: () {
        showToast(
          text: S.of(context).offerAcceptedTransitioning,
          state: ToastStates.SUCESS,
        );
        final isPrivate = trip.type != TripType.shared;
        navigateTo(
          context,
          BlocProvider(
            create: (_) => di.sl<DriverAddPrivateTripCubit>(),
            child: isPrivate
                ? DriverOngoingPrivateTripScreenClean(
                    trip: trip,
                  )
                : DriverOngoingSharedTripScreenClean(
                    trip: trip,
                  ),
          ),
        );
      },
      text: S.of(context).offerAcceptedSuccess,
      background: Colors.green.shade800,
      height: 40,
    );
  } else if (offerStatus == 'another_driver_accepted') {
    return defaultButton(
      onPressed: () {
        showToast(
          text: S.of(context).offersClosed,
          state: ToastStates.ERROR,
        );
      },
      text: S.of(context).anotherDriverSelected,
      background: Colors.grey.shade700,
      height: 40,
    );
  }

  return defaultButton(
    onPressed: openPricingDialog,
    text: S.of(context).pricing,
    background: AppColors.primary,
    height: 40,
  );
}

class _AutoRefreshView extends StatefulWidget {
  final Widget child;
  final VoidCallback onRefresh;
  const _AutoRefreshView({required this.child, required this.onRefresh});

  @override
  State<_AutoRefreshView> createState() => _AutoRefreshViewState();
}

class _AutoRefreshViewState extends State<_AutoRefreshView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      widget.onRefresh();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ─── Search & Filter Header (Radius & Date) ──────────────────────────────────

Widget _buildSearchFilterHeader(BuildContext context, DriverTripsCubit cubit) {
  final selectedDate = cubit.selectedDate;
  final radius = cubit.selectedRadius;

  String dateLabel = S.of(context).allDates;
  if (selectedDate != null) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final target =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    if (target == today) {
      dateLabel = S.of(context).todayTrips;
    } else if (target == tomorrow) {
      dateLabel = S.of(context).tomorrowTrips;
    } else {
      dateLabel = DateFormat('yyyy/MM/dd', 'ar').format(selectedDate);
    }
  }

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            // Radius Button
            Expanded(
              child: InkWell(
                onTap: () => _showRadiusFilterModal(context, cubit),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: AppColors.primary.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.radar_rounded,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          S.of(context).radiusKm(radius.toInt()),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.tune_rounded,
                          size: 16, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Date Picker Button
            Expanded(
              child: InkWell(
                onTap: () => _openCustomCalendarPicker(context, cubit),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: selectedDate != null
                        ? Colors.amber.shade50
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selectedDate != null
                          ? Colors.amber.shade700
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 16,
                        color: selectedDate != null
                            ? Colors.amber.shade900
                            : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          dateLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: selectedDate != null
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: selectedDate != null
                                ? Colors.amber.shade900
                                : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (selectedDate != null)
                        InkWell(
                          onTap: () =>
                              cubit.updateSearchFilters(clearDate: true),
                          child: const Icon(Icons.close_rounded,
                              size: 16, color: Colors.red),
                        )
                      else
                        const Icon(Icons.keyboard_arrow_down_rounded,
                            size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Quick Date Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildQuickDateChip(
                context,
                title: S.of(context).all,
                isSelected: selectedDate == null,
                onTap: () => cubit.updateSearchFilters(clearDate: true),
              ),
              const SizedBox(width: 6),
              _buildQuickDateChip(
                context,
                title: S.of(context).todayTrips,
                isSelected: selectedDate != null &&
                    DateTime(selectedDate.year, selectedDate.month,
                            selectedDate.day) ==
                        DateTime(DateTime.now().year, DateTime.now().month,
                            DateTime.now().day),
                onTap: () {
                  final now = DateTime.now();
                  cubit.updateSearchFilters(
                      date: DateTime(now.year, now.month, now.day));
                },
              ),
              const SizedBox(width: 6),
              _buildQuickDateChip(
                context,
                title: S.of(context).tomorrowTrips,
                isSelected: selectedDate != null &&
                    DateTime(selectedDate.year, selectedDate.month,
                            selectedDate.day) ==
                        DateTime(DateTime.now().year, DateTime.now().month,
                            DateTime.now().day + 1),
                onTap: () {
                  final now = DateTime.now();
                  cubit.updateSearchFilters(
                      date: DateTime(now.year, now.month, now.day + 1));
                },
              ),
              const SizedBox(width: 6),
              _buildQuickDateChip(
                context,
                title: S.of(context).specificDate,
                isSelected: selectedDate != null &&
                    DateTime(selectedDate.year, selectedDate.month,
                            selectedDate.day) !=
                        DateTime(DateTime.now().year, DateTime.now().month,
                            DateTime.now().day) &&
                    DateTime(selectedDate.year, selectedDate.month,
                            selectedDate.day) !=
                        DateTime(DateTime.now().year, DateTime.now().month,
                            DateTime.now().day + 1),
                onTap: () => _openCustomCalendarPicker(context, cubit),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildQuickDateChip(
  BuildContext context, {
  required String title,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : Colors.black87,
        ),
      ),
    ),
  );
}

void _showRadiusFilterModal(BuildContext context, DriverTripsCubit cubit) {
  double currentRadius = cubit.selectedRadius;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 20.0,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        S.of(context).searchRadiusTitle,
                        style:
                            const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    S.of(context).searchRadiusDesc(currentRadius.toInt()),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      S.of(context).kmUnit(currentRadius.toInt()),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Slider(
                    value: currentRadius,
                    min: 5.0,
                    max: 200.0,
                    divisions: 39,
                    activeColor: AppColors.primary,
                    inactiveColor: Colors.grey.shade300,
                    label: S.of(context).kmUnit(currentRadius.toInt()),
                    onChanged: (val) {
                      setState(() {
                        currentRadius = val;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  // Preset radius chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [10, 25, 50, 75, 100, 150].map((r) {
                      final isSel = currentRadius.toInt() == r;
                      return ChoiceChip(
                        label: Text(S.of(context).kmUnit(r)),
                        selected: isSel,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : Colors.black87,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              currentRadius = r.toDouble();
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        cubit.updateSearchFilters(radius: currentRadius);
                      },
                      child: Text(
                        S.of(context).applySearchRadius,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> _openCustomCalendarPicker(
    BuildContext context, DriverTripsCubit cubit) async {
  final now = DateTime.now();
  final picked = await showDatePicker(
    context: context,
    initialDate: cubit.selectedDate ?? now,
    firstDate: now.subtract(const Duration(days: 1)),
    lastDate: now.add(const Duration(days: 90)),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            onSurface: Colors.black87,
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    cubit.updateSearchFilters(date: picked);
  }
}

// ─── Empty Trips State Widget ────────────────────────────────────────────────

Widget _buildEmptyTripsState(BuildContext context, {required bool isPrivate}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isPrivate ? Icons.directions_car_outlined : Icons.group_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 14),
          Text(
            isPrivate
                ? S.of(context).noNewPrivateTrips
                : S.of(context).noNewSharedTrips,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            S.of(context).expandSearchRadiusHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    ),
  );
}

// ─── Modern & Expandable Driver Trip Card ────────────────────────────────────

// ─── Location Name Cleaner (Removes Plus Codes, numbers & duplicates) ────────

String cleanLocationName(String? raw) {
  if (raw == null) return '';
  var text = raw.trim();
  if (text.isEmpty) return '';

  // 1. Remove Plus Codes (e.g. "Hp2c+w55", "HP2C+W55", "7G7M+X4", "8G4P+3M")
  text = text.replaceAll(
      RegExp(r'\b[A-Za-z0-9]{2,8}\+[A-Za-z0-9]{2,8}\b', caseSensitive: false),
      '');

  // 2. Remove standalone numbers & postal codes (e.g. "2142654", "11181")
  text = text.replaceAll(RegExp(r'\b\d+\b'), '');

  // 3. Normalize commas and punctuation
  text = text.replaceAll('،', ',');
  final parts = text.split(',');

  final cleanedTokens = <String>[];
  for (var part in parts) {
    var p = part
        .replaceAll(RegExp(r'[#@$%^&*_+=\/\\|~<>{}\[\]\(\)]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (p.isNotEmpty && p.length > 1 && !cleanedTokens.contains(p)) {
      cleanedTokens.add(p);
    }
  }

  if (cleanedTokens.isEmpty) {
    final fallback = raw
        .replaceAll(
            RegExp(r'[A-Za-z0-9]{2,8}\+[A-Za-z0-9]{2,8}', caseSensitive: false),
            '')
        .trim();
    return fallback.isNotEmpty ? fallback : raw;
  }

  return cleanedTokens.join('، ');
}

// ─── Modern Driver Trip Card ────────────────────────────────────────────────

class _DriverTripCardItem extends StatelessWidget {
  final Trip trip;
  final Function(bool) setNewLoading;
  final VoidCallback onOfferTap;

  const _DriverTripCardItem({
    required this.trip,
    required this.setNewLoading,
    required this.onOfferTap,
  });

  String _formatDepartureDateTime(BuildContext context, String rawDatetime) {
    final str = rawDatetime.trim();
    if (str.isEmpty) return S.of(context).notSpecified;
    try {
      final parsed =
          DateTime.parse(str.contains('T') ? str : str.replaceAll(' ', 'T'))
              .toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tripDay = DateTime(parsed.year, parsed.month, parsed.day);
      final diffDays = tripDay.difference(today).inDays;

      final timeStr = DateFormat('hh:mm a', Localizations.localeOf(context).languageCode).format(parsed);
      if (diffDays == 0) {
        return S.of(context).timeTodayAt(timeStr);
      } else if (diffDays == 1) {
        return S.of(context).timeTomorrowAt(timeStr);
      } else {
        final dateStr = DateFormat('yyyy/MM/dd', Localizations.localeOf(context).languageCode).format(parsed);
        return S.of(context).dateTimeAt(dateStr, timeStr);
      }
    } catch (_) {
      return str;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPrivate = trip.type == TripType.private;
    final creatorName = trip.creator?.name.isNotEmpty == true
        ? trip.creator!.name
        : S.of(context).passenger;
    final formattedDeparture =
        _formatDepartureDateTime(context, trip.tripDatetime);

    final cleanFrom = cleanLocationName(trip.fromLocationName).isNotEmpty
        ? cleanLocationName(trip.fromLocationName)
        : S.of(context).startingLocation;

    final cleanTo = cleanLocationName(trip.toLocationName).isNotEmpty
        ? cleanLocationName(trip.toLocationName)
        : S.of(context).destinationLocation;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header: Creator Name & Trip Type Badge ───
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      isPrivate ? Colors.blue.shade50 : Colors.purple.shade50,
                  backgroundImage: appCachedImageProvider(ApiEndpoints.buildImageUrl(trip.creator?.photo)),
                  child: (trip.creator?.photo == null ||
                          ApiEndpoints.buildImageUrl(trip.creator!.photo) == null)
                      ? Icon(
                          isPrivate
                              ? Icons.person_outline_rounded
                              : Icons.group_outlined,
                          color: isPrivate
                              ? Colors.blue.shade700
                              : Colors.purple.shade700,
                          size: 20,
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    creatorName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Type Badge (خاصة / مشتركة)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color:
                        isPrivate ? Colors.blue.shade50 : Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isPrivate
                          ? Colors.blue.shade200
                          : Colors.purple.shade200,
                    ),
                  ),
                  child: Text(
                    isPrivate
                        ? '🚗 ${S.of(context).userlayouthomeprivatetrip}'
                        : '👥 ${S.of(context).userlayouthomesharedtrip}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isPrivate
                          ? Colors.blue.shade800
                          : Colors.purple.shade800,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ─── Departure Date & Time Banner (Prominent) ───
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.access_time_filled_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).departureDateTime,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formattedDeparture,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ─── Route: Clean Origin & Destination Timeline ───
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green.shade600,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.green.shade100, width: 2),
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 32,
                      color: Colors.grey.shade300,
                    ),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.red.shade100, width: 2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cleanFrom,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        cleanTo,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ─── Key Metrics Badges (Price, Seats, Distance, Gender) ───
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                // Price Range
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.payments_outlined,
                          size: 14, color: Colors.amber.shade900),
                      const SizedBox(width: 4),
                      Text(
                        '${trip.minimumPrice.toStringAsFixed(1)} - ${trip.maximumPrice.toStringAsFixed(1)} ${S.of(context).jod}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
                // Distance
                if (trip.distance != null && trip.distance! > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.straighten_rounded,
                            size: 14, color: Colors.black54),
                        const SizedBox(width: 4),
                        Text(
                          S.of(context).kmUnit(trip.distance!.toStringAsFixed(1)),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Seats
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event_seat_rounded,
                          size: 14, color: Colors.teal.shade800),
                      const SizedBox(width: 4),
                      Text(
                        isPrivate
                            ? S.of(context).fullCarSeats
                            : '${trip.numberOfSeats} ${S.of(context).seatsRequestedCount}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                // Gender Preference
                if (trip.genderPreference != GenderPreference.noPreference)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: trip.genderPreference == GenderPreference.female
                          ? Colors.pink.shade50
                          : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: trip.genderPreference == GenderPreference.female
                            ? Colors.pink.shade200
                            : Colors.blue.shade200,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trip.genderPreference == GenderPreference.female
                              ? Icons.female_rounded
                              : Icons.male_rounded,
                          size: 14,
                          color:
                              trip.genderPreference == GenderPreference.female
                                  ? Colors.pink.shade800
                                  : Colors.blue.shade800,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trip.genderPreference == GenderPreference.female
                              ? S.of(context).womenOnly
                              : S.of(context).menOnly,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color:
                                trip.genderPreference == GenderPreference.female
                                    ? Colors.pink.shade800
                                    : Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 14),

            // ─── Actions Bar: Reject, Chat with Badge & Pricing ───
            Builder(
              builder: (context) {
                final currentDriverId = int.tryParse(
                        di.sl<LocalStorage>().read(key: 'userid')?.toString() ??
                        di.sl<LocalStorage>().read(key: 'user_id')?.toString() ??
                        di.sl<LocalStorage>().read(key: 'id')?.toString() ??
                        '') ??
                    0;
                final targetChatId = ChatChannelHelper.privateTripChatId(
                    tripId: trip.id, driverId: currentDriverId);

                return Row(
                  children: [
                    SizedBox(
                      height: 40,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onPressed: () {
                          RejectTripDialouge(
                            setNewLoading: setNewLoading,
                            context,
                            id: trip.id,
                          );
                        },
                        icon: const Icon(Icons.close_rounded, size: 16),
                        label: Text(
                          S.of(context).toReject,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    UnreadBadge(
                      chatId: targetChatId,
                      currentUserId: currentDriverId.toString(),
                      child: SizedBox(
                        height: 40,
                        width: 44,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(
                                color: AppColors.primary.withOpacity(0.4)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () {
                            navigateTo(
                              context,
                              TripChatScreenClean(
                                driverName: creatorName,
                                driverPhone: trip.creator?.phone ?? '',
                                tripFrom: cleanFrom,
                                tripTo: cleanTo,
                                tripDatetime: trip.tripDatetime,
                                acceptedPrice: trip.maximumPrice > 0
                                    ? trip.maximumPrice
                                    : trip.minimumPrice,
                                tripId: trip.id,
                                offerId: 0,
                                driverId: currentDriverId,
                                passengerId: trip.creator?.id ?? trip.createdBy,
                                chatId: targetChatId,
                                tripType: isPrivate ? 'private' : 'shared',
                                isInquiry: !isPrivate,
                                isOffersPhase: true,
                                members: [
                                  if (trip.creator != null)
                                    trip.creator!.toMap(),
                                ],
                              ),
                            );
                          },
                          child: const Icon(Icons.chat_outlined,
                              size: 20, color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildOfferButton(
                        context,
                        trip,
                        onOfferTap,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
