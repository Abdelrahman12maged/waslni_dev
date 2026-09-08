import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/core/formatters/plate_number_formatter.dart';
import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/router/navigation_manager.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/utils/chat_channel_helper.dart';
import 'package:car_app/core/utils/location_helper.dart';
import 'package:car_app/core/widgets/app_cached_image.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/features/chat/presentation/screens/trip_chat_screen.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/domain/entities/trip_passenger.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_trips_cubit.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_trips_state.dart';
import 'package:car_app/generated/l10n.dart';

class PassengerSharedTripDetailsPassengersView extends StatefulWidget {
  final Trip? trip;
  final int? tripId;

  const PassengerSharedTripDetailsPassengersView({
    super.key,
    this.trip,
    this.tripId,
  });

  @override
  State<PassengerSharedTripDetailsPassengersView> createState() =>
      _PassengerSharedTripDetailsPassengersViewState();
}

class _PassengerSharedTripDetailsPassengersViewState
    extends State<PassengerSharedTripDetailsPassengersView> {
  int currentIndex = 0;
  int _selectedSeats = 1;
  Trip? _trip;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
    final targetId = widget.trip?.id ?? widget.tripId;
    if (targetId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          PassengerTripsCubit.get(context).refreshTripDetails(targetId);
        }
      });
    }
  }

  Trip? _resolveTrip() {
    return _trip ?? widget.trip;
  }

  int get _currentUserId {
    final raw = sl<LocalStorage>().read(key: 'userid') ??
        sl<LocalStorage>().read(key: 'user_id') ??
        sl<LocalStorage>().read(key: 'id');
    if (raw is int && raw > 0) return raw;
    final parsed = int.tryParse(raw?.toString() ?? '') ?? 0;
    if (parsed > 0) return parsed;
    try {
      if (Hive.isBoxOpen('hive_box')) {
        final box = Hive.box('hive_box');
        final rawUser = box.get('user_data');
        if (rawUser is Map) {
          final uId = rawUser['id'] ??
              rawUser['user']?['id'] ??
              rawUser['data']?['id'];
          if (uId is int && uId > 0) return uId;
          final pId = int.tryParse(uId?.toString() ?? '') ?? 0;
          if (pId > 0) return pId;
        }
      }
    } catch (_) {}
    return 0;
  }

  TripPassenger? _getMyPassengerRecord(Trip trip) {
    final uid = _currentUserId;
    if (uid == 0) return null;
    for (final p in trip.passengers) {
      if (p.id == uid) return p;
    }
    return null;
  }

  bool _isUserJoined(Trip trip) {
    final uid = _currentUserId;
    if (uid == 0) return false;
    if (trip.createdBy == uid) return true;
    return trip.passengers.any((p) => p.id == uid);
  }

  int _getTotalSeats(Trip trip) {
    if (trip.totalSeats > 0) return trip.totalSeats;
    if (trip.driver?.car?.seats != null && trip.driver!.car!.seats! > 0) {
      return trip.driver!.car!.seats!;
    }
    return 4;
  }

  int _getTotalBookedSeats(Trip trip) {
    if (trip.reservedSeats > 0) return trip.reservedSeats;
    if (trip.passengers.isNotEmpty) {
      final sum = trip.passengers
          .fold<int>(0, (acc, p) => acc + (p.seats > 0 ? p.seats : 1));
      if (sum > 0) return sum;
    }
    if (trip.joinedPassengersCount > 0) return trip.joinedPassengersCount;
    return 0;
  }

  int _getAvailableSeats(Trip trip) {
    if (trip.availableSeats >= 0) return trip.availableSeats;
    final total = _getTotalSeats(trip);
    final booked = _getTotalBookedSeats(trip);
    final remaining = total - booked;
    return remaining >= 0 ? remaining : 0;
  }

  int _getCurrentParticipants(Trip trip) {
    if (trip.joinedPassengersCount > 0) return trip.joinedPassengersCount;
    if (trip.passengers.isNotEmpty) return trip.passengers.length;
    return _getTotalBookedSeats(trip) > 0 ? 1 : 0;
  }

  double _getTotalAgreedPrice(Trip trip) {
    if (trip.approvedPrice != null && trip.approvedPrice! > 0) {
      return trip.approvedPrice!;
    }
    if (trip.maximumPrice > 0) {
      return trip.maximumPrice;
    }
    return trip.minimumPrice > 0 ? trip.minimumPrice : 0.0;
  }

  void _openChat(BuildContext context, Trip trip) {
    final driver = trip.driver;
    final driverName = driver?.name.isNotEmpty == true
        ? driver!.name
        : S.of(context).verifiedDriver;
    final phone = driver?.phone ?? '';
    final price = trip.approvedPrice ??
        (trip.maximumPrice > 0 ? trip.maximumPrice : trip.minimumPrice);

    final isJoined = _isUserJoined(trip);

    final dmChatId = isJoined
        ? ChatChannelHelper.sharedTripDmChatId(
            tripId: trip.id,
            passengerId: _currentUserId)
        : ChatChannelHelper.sharedTripInquiryChatId(
            tripId: trip.id,
            passengerId: _currentUserId);

    navigateTo(
      context,
      TripChatScreenClean(
        driverName: driverName,
        driverPhone: phone,
        driverPhoto: driver?.photo,
        tripFrom: cleanLocationName(trip.fromLocationName),
        tripTo: cleanLocationName(trip.toLocationName),
        tripDatetime: trip.tripDatetime,
        acceptedPrice: price,
        tripId: trip.id,
        offerId: 0,
        chatId: dmChatId,
        tripType: 'shared',
        isInquiry: !isJoined,
        isOffersPhase: false,
        isDm: isJoined,
        driverId: driver?.id ?? trip.driverId,
        passengerId: _currentUserId,
        members: [
          if (driver != null) driver.toMap(),
          {
            'id': _currentUserId,
            'name': sl<LocalStorage>().read(key: 'user_name')?.toString() ??
                sl<LocalStorage>().read(key: 'name')?.toString() ??
                '',
            'phone': sl<LocalStorage>().read(key: 'phone')?.toString() ?? '',
            'is_driver': false,
          },
        ],
      ),
    );
  }

  String _formatDateTime(BuildContext context, String rawDatetime) {
    final str = rawDatetime.trim();
    if (str.isEmpty) return S.of(context).notSpecified;
    try {
      final parsed =
          DateTime.parse(str.contains('T') ? str : str.replaceAll(' ', 'T'));
      return DateFormat('yyyy/MM/dd - hh:mm a', 'ar').format(parsed.toLocal());
    } catch (_) {
      return str;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.black87, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            S.of(context).sharedTripDetailsTitle,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded,
                  color: AppColors.primary, size: 20),
              onPressed: () => context.push(AppRoutes.notifications),
            ),
          ],
        ),
        body: BlocConsumer<PassengerTripsCubit, PassengerTripsState>(
          listener: (context, state) {
            if (state is PassengerTripsError) {
              showToast(text: state.message, state: ToastStates.ERROR);
            } else if (state is PassengerTripStatusChanged) {
              showToast(
                  text: S.of(context).bookingConfirmedRedirecting,
                  state: ToastStates.SUCESS);
              final tripToUse = _resolveTrip();
              if (tripToUse != null) {
                _openChat(context, tripToUse);
              }
            } else if (state is PassengerTripDetailsLoaded) {
              setState(() {
                _trip = state.trip;
              });
            }
          },
          builder: (context, state) {
            final trip = (state is PassengerTripDetailsLoaded)
                ? state.trip
                : (_trip ?? widget.trip);

            if (trip == null) {
              if (state is PassengerTripsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return Center(
                child: Text(
                  S.of(context).noTripsNearby,
                  style: GoogleFonts.cairo(fontSize: 15),
                ),
              );
            }

            final isJoined = _isUserJoined(trip);
            final myPassenger = _getMyPassengerRecord(trip);
            final myExistingSeats = myPassenger?.seats ??
                (trip.createdBy == _currentUserId ? 1 : 0);

            final totalSeats = _getTotalSeats(trip);
            final totalBookedSeats = _getTotalBookedSeats(trip);
            final availableSeats = _getAvailableSeats(trip);
            final currentParticipants = _getCurrentParticipants(trip);
            final totalAgreedPrice = _getTotalAgreedPrice(trip);

            final otherPassengersSeats = isJoined
                ? (totalBookedSeats - myExistingSeats).clamp(0, totalSeats)
                : totalBookedSeats;

            final effectiveMySeats =
                isJoined ? (myExistingSeats + _selectedSeats) : _selectedSeats;

            final totalOccupiedWithChoice =
                (otherPassengersSeats + effectiveMySeats).clamp(1, totalSeats);

            final double myShareRatio =
                (effectiveMySeats / totalOccupiedWithChoice).clamp(0.0, 1.0);
            final double myTotalCost = myShareRatio * totalAgreedPrice;
            final double costIfFull =
                (effectiveMySeats / totalSeats) * totalAgreedPrice;

            final driver = trip.driver;
            final car = driver?.car;
            final driverName = driver?.name.isNotEmpty == true
                ? driver!.name
                : S.of(context).verifiedDriver;

            return ConditionalBuilder(
              condition: state is! PassengerTripsLoading,
              fallback: (context) => mySpinKit(),
              builder: (context) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TabBar(
                          physics: const NeverScrollableScrollPhysics(),
                          onTap: (value) =>
                              setState(() => currentIndex = value),
                          isScrollable: false,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.black87,
                          labelStyle: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold, fontSize: 13),
                          unselectedLabelStyle: GoogleFonts.cairo(
                              fontWeight: FontWeight.w600, fontSize: 13),
                          tabs: [
                            Tab(text: S.of(context).tabTripDetailsBooking),
                            Tab(text: S.of(context).tabDriverVehicleDetails),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14.0),
                      Expanded(
                        child: TabBarView(
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isJoined) ...[
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        border: Border.all(
                                            color: Colors.green.shade300,
                                            width: 1.2),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.check_circle_rounded,
                                              color: Colors.green.shade700,
                                              size: 26),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  S
                                                      .of(context)
                                                      .youAreJoinedBannerTitle,
                                                  style: GoogleFonts.cairo(
                                                    fontSize: 13.5,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color:
                                                        Colors.green.shade900,
                                                  ),
                                                ),
                                                Text(
                                                  myExistingSeats > 0
                                                      ? S
                                                          .of(context)
                                                          .yourReservedSeatsCount(
                                                              myExistingSeats)
                                                      : S
                                                          .of(context)
                                                          .joinedInThisTrip,
                                                  style: GoogleFonts.cairo(
                                                    fontSize: 11.5,
                                                    color:
                                                        Colors.green.shade800,
                                                    fontWeight:
                                                        FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.green.shade700,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              elevation: 0,
                                            ),
                                            onPressed: () =>
                                                _openChat(context, trip),
                                            icon: const Icon(
                                                Icons.chat_bubble_rounded,
                                                size: 15),
                                            label: Text(
                                              S.of(context).chatAction,
                                              style: GoogleFonts.cairo(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.schedule_rounded,
                                                size: 15,
                                                color: AppColors.primary),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                _formatDateTime(
                                                    context, trip.tripDatetime),
                                                style: GoogleFonts.cairo(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                trip.status.name.toUpperCase(),
                                                style: GoogleFonts.cairo(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green.shade700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Divider(
                                            height: 1,
                                            color: Colors.grey.shade100),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Column(
                                              children: [
                                                const Icon(
                                                    Icons.radio_button_checked,
                                                    size: 14,
                                                    color: Colors.green),
                                                Container(
                                                    width: 1.5,
                                                    height: 24,
                                                    color:
                                                        Colors.grey.shade300),
                                                const Icon(Icons.location_on,
                                                    size: 14,
                                                    color: Colors.red),
                                              ],
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${S.of(context).pickupLocation}:',
                                                    style: GoogleFonts.cairo(
                                                        fontSize: 10.5,
                                                        color: Colors
                                                            .grey.shade500),
                                                  ),
                                                  Text(
                                                    cleanLocationName(
                                                        trip.fromLocationName),
                                                    style: GoogleFonts.cairo(
                                                        fontSize: 12.5,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    '${S.of(context).destination}:',
                                                    style: GoogleFonts.cairo(
                                                        fontSize: 10.5,
                                                        color: Colors
                                                            .grey.shade500),
                                                  ),
                                                  Text(
                                                    cleanLocationName(
                                                        trip.toLocationName),
                                                    style: GoogleFonts.cairo(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          S
                                              .of(context)
                                              .seatsAndFareDistribution,
                                          style: GoogleFonts.cairo(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildInfoMetricBox(
                                                title: S
                                                    .of(context)
                                                    .participantsCountLabel,
                                                value: '$currentParticipants',
                                                icon: Icons.groups_rounded,
                                                color: Colors.blue.shade700,
                                                bgColor: Colors.blue.shade50,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: _buildInfoMetricBox(
                                                title: S
                                                    .of(context)
                                                    .bookedSeatsLabel,
                                                value: '$totalBookedSeats',
                                                icon: Icons.people_rounded,
                                                color: Colors.amber.shade900,
                                                bgColor: Colors.amber.shade50,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: _buildInfoMetricBox(
                                                title: S
                                                    .of(context)
                                                    .remainingSeatsLabel,
                                                value: '$availableSeats',
                                                icon: Icons.event_seat_rounded,
                                                color: availableSeats > 0
                                                    ? Colors.green.shade700
                                                    : Colors.red.shade700,
                                                bgColor: availableSeats > 0
                                                    ? Colors.green.shade50
                                                    : Colors.red.shade50,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Divider(
                                            height: 1,
                                            color: Colors.grey.shade100),
                                        const SizedBox(height: 10),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.teal.shade50
                                                .withOpacity(0.6),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: Colors.teal.shade200),
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      S
                                                          .of(context)
                                                          .totalAgreedFareWithDriver,
                                                      style: GoogleFonts.cairo(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors
                                                            .grey.shade800,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    '${totalAgreedPrice.toStringAsFixed(2)} JOD',
                                                    style: GoogleFonts.cairo(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      S
                                                          .of(context)
                                                          .seatsCurrentlyBookedInTrip,
                                                      style: GoogleFonts.cairo(
                                                        fontSize: 12,
                                                        color: Colors
                                                            .grey.shade700,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    S
                                                        .of(context)
                                                        .seatsOutOfTotal(
                                                            totalOccupiedWithChoice,
                                                            totalSeats),
                                                    style: GoogleFonts.cairo(
                                                      fontSize: 12.5,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Divider(
                                                  height: 1,
                                                  color: Colors.teal.shade100),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      S
                                                          .of(context)
                                                          .yourShareNowWithRatio(
                                                              effectiveMySeats,
                                                              (myShareRatio *
                                                                      100)
                                                                  .toStringAsFixed(
                                                                      0)),
                                                      style: GoogleFonts.cairo(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors
                                                            .teal.shade900,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    '${myTotalCost.toStringAsFixed(2)} JOD',
                                                    style: GoogleFonts.cairo(
                                                      fontSize: 14.5,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Colors.teal.shade900,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              if (totalOccupiedWithChoice <
                                                  totalSeats)
                                                Row(
                                                  children: [
                                                    Icon(
                                                        Icons
                                                            .info_outline_rounded,
                                                        size: 13,
                                                        color: Colors
                                                            .teal.shade800),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        S
                                                            .of(context)
                                                            .noticePriceDropsWhenFull(
                                                                totalSeats,
                                                                costIfFull
                                                                    .toStringAsFixed(
                                                                        2)),
                                                        style:
                                                            GoogleFonts.cairo(
                                                          fontSize: 10.5,
                                                          color: Colors
                                                              .teal.shade800,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              else
                                                Row(
                                                  children: [
                                                    Icon(
                                                        Icons
                                                            .check_circle_outline_rounded,
                                                        size: 13,
                                                        color: Colors
                                                            .green.shade800),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        S
                                                            .of(context)
                                                            .noticeCarIsFull,
                                                        style:
                                                            GoogleFonts.cairo(
                                                          fontSize: 10.5,
                                                          color: Colors
                                                              .green.shade800,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                isJoined
                                                    ? S
                                                        .of(context)
                                                        .requestAdditionalSeats
                                                    : S
                                                        .of(context)
                                                        .chooseSeatsToBook,
                                                style: GoogleFonts.cairo(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: availableSeats > 0
                                                    ? Colors.green.shade50
                                                    : Colors.red.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                availableSeats > 0
                                                    ? S
                                                        .of(context)
                                                        .availableSeatsCount(
                                                            availableSeats)
                                                    : S.of(context).tripFull,
                                                style: GoogleFonts.cairo(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: availableSeats > 0
                                                      ? Colors.green.shade700
                                                      : Colors.red.shade700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        if (availableSeats > 0) ...[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              InkWell(
                                                onTap: _selectedSeats > 1
                                                    ? () => setState(() =>
                                                        _selectedSeats--)
                                                    : null,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color: _selectedSeats > 1
                                                        ? Colors.white
                                                        : Colors.grey.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                      color: _selectedSeats > 1
                                                          ? AppColors.primary
                                                          : Colors
                                                              .grey.shade300,
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    Icons.remove,
                                                    color: _selectedSeats > 1
                                                        ? AppColors.primary
                                                        : Colors.grey.shade400,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 20),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary
                                                      .withOpacity(0.08),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  '$_selectedSeats ${_selectedSeats == 1 ? S.of(context).seatSingle : (_selectedSeats == 2 ? S.of(context).twoSeats : S.of(context).multipleSeats)}',
                                                  style: GoogleFonts.cairo(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 20),
                                              InkWell(
                                                onTap: _selectedSeats <
                                                        availableSeats
                                                    ? () => setState(() =>
                                                        _selectedSeats++)
                                                    : null,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color: _selectedSeats <
                                                            availableSeats
                                                        ? AppColors.primary
                                                        : Colors.grey.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Icon(
                                                    Icons.add,
                                                    color: _selectedSeats <
                                                            availableSeats
                                                        ? Colors.white
                                                        : Colors.grey.shade400,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 14),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: Colors.grey.shade200),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    isJoined
                                                        ? S
                                                            .of(context)
                                                            .totalCostYourBooking(
                                                                effectiveMySeats)
                                                        : S
                                                            .of(context)
                                                            .amountToPayForBooking(
                                                                _selectedSeats),
                                                    style: GoogleFonts.cairo(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          Colors.grey.shade800,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '${myTotalCost.toStringAsFixed(2)} JOD',
                                                  style: GoogleFonts.cairo(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ] else ...[
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              S
                                                  .of(context)
                                                  .noAvailableSeatsCarFull,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.cairo(
                                                fontSize: 12.5,
                                                color: Colors.red.shade700,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  if (availableSeats > 0)
                                    SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14)),
                                          elevation: 0,
                                        ),
                                        onPressed: () {
                                          PassengerTripsCubit.of(context)
                                              .subscribeToSharedTrip(
                                            trip.id,
                                            seats: _selectedSeats,
                                            availableSeats: availableSeats,
                                          );
                                        },
                                        icon: const Icon(
                                            Icons.check_circle_outline_rounded,
                                            size: 18),
                                        label: Text(
                                          isJoined
                                              ? S
                                                  .of(context)
                                                  .confirmExtraSeatsAndChat
                                              : S
                                                  .of(context)
                                                  .confirmSeatsAndChat(
                                                      _selectedSeats),
                                          style: GoogleFonts.cairo(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (isJoined) ...[
                                    if (availableSeats > 0)
                                      const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                              color: Colors.green.shade700,
                                              width: 1.5),
                                          foregroundColor:
                                              Colors.green.shade700,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14)),
                                        ),
                                        onPressed: () =>
                                            _openChat(context, trip),
                                        icon: const Icon(
                                            Icons.chat_bubble_rounded,
                                            size: 18),
                                        label: Text(
                                          S.of(context).enterTripChatDirectly,
                                          style: GoogleFonts.cairo(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                            SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 36,
                                          backgroundColor: AppColors.primary
                                              .withOpacity(0.1),
                                          backgroundImage: appCachedImageProvider(
                                              ApiEndpoints.buildImageUrl(
                                                  driver?.photo)),
                                          child: (driver?.photo == null ||
                                                  ApiEndpoints.buildImageUrl(
                                                          driver!.photo) ==
                                                      null)
                                              ? const Icon(Icons.person,
                                                  size: 36,
                                                  color: AppColors.primary)
                                              : null,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          driverName,
                                          style: GoogleFonts.cairo(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        if (driver?.rating != null) ...[
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.star_rounded,
                                                  color: Colors.amber,
                                                  size: 16),
                                              const SizedBox(width: 4),
                                              Text(
                                                driver!.rating!,
                                                style: GoogleFonts.cairo(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          S.of(context).vehicleData,
                                          style: GoogleFonts.cairo(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        _buildDetailRow(
                                            S.of(context).carTypeAndModel,
                                            car != null
                                                ? '${car.type} ${car.model}'
                                                : S.of(context).notSpecified),
                                        if (car?.plateNumber != null &&
                                            car!.plateNumber.isNotEmpty)
                                          _buildDetailRow(
                                              S.of(context).plateNumber,
                                              PlateNumberFormatter.format(
                                                  car.plateNumber),
                                              textDirection:
                                                  TextDirection.ltr),
                                        if (car?.color != null &&
                                            car!.color!.isNotEmpty)
                                          _buildDetailRow(
                                              S.of(context).carColor,
                                              car.color!),
                                        _buildDetailRow(
                                            S.of(context).totalSeatsCount,
                                            '$totalSeats'),
                                        _buildDetailRow(
                                            S
                                                .of(context)
                                                .passengerGenderPreference,
                                            trip.genderPreference ==
                                                    GenderPreference.male
                                                ? S.of(context).malesOnly
                                                : (trip.genderPreference ==
                                                        GenderPreference.female
                                                    ? S.of(context).femalesOnly
                                                    : S
                                                        .of(context)
                                                        .allGenders)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14)),
                                        elevation: 0,
                                      ),
                                      onPressed: () =>
                                          _openChat(context, trip),
                                      icon: const Icon(
                                          Icons.chat_bubble_outline_rounded,
                                          size: 18),
                                      label: Text(
                                        S.of(context).contactDriver,
                                        style: GoogleFonts.cairo(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
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
        ),
      ),
    );
  }

  Widget _buildInfoMetricBox({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 10,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {TextDirection? textDirection}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            textDirection: textDirection,
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
