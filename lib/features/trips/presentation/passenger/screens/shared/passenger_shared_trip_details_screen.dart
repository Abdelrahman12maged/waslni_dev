import 'dart:developer';
import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/router/navigation_manager.dart';
import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/core/widgets/app_cached_image.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/utils/location_helper.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/core/widgets/unread_badge.dart';
import 'package:car_app/core/utils/chat_channel_helper.dart';
import 'package:car_app/features/chat/presentation/screens/trip_chat_screen.dart';
import 'package:car_app/features/trips/data/models/trip_model.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_trips_cubit.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_trips_state.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Displays shared trip details for passengers looking to request seats.
/// Supports Approach C (in-memory [Trip], [tripId], or legacy [tripDetails]).
class PassengerSharedTripDetailsScreenClean extends StatefulWidget {
  const PassengerSharedTripDetailsScreenClean({
    super.key,
    this.trip,
    this.tripId,
  });

  final Trip? trip;
  final int? tripId;

  @override
  State<PassengerSharedTripDetailsScreenClean> createState() =>
      _PassengerSharedTripDetailsScreenCleanState();
}

class _PassengerSharedTripDetailsScreenCleanState
    extends State<PassengerSharedTripDetailsScreenClean> {
  int currentIndex = 0;

  int get _currentUserId {
    final raw = sl<LocalStorage>().read(key: 'userid') ??
        sl<LocalStorage>().read(key: 'user_id') ??
        sl<LocalStorage>().read(key: 'id');
    if (raw is int && raw > 0) return raw;
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  Trip? _resolveTrip() {
    return widget.trip;
  }

  @override
  Widget build(BuildContext context) {
    final trip = _resolveTrip();

    return SafeArea(
      child: Scaffold(
        appBar: defaultAppBar(
          leadingOnPressed: () => Navigator.of(context).pop(),
          titleText: S.of(context).tripDetails,
          backgroundColor: Colors.grey[300],
          actionsOnPressed: () => context.push(AppRoutes.notifications),
        ),
        body: BlocConsumer<PassengerTripsCubit, PassengerTripsState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (trip == null) {
              return Center(
                child: Text(
                  S.of(context).noTripsNearby,
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }

            return ConditionalBuilder(
              condition: state is! PassengerTripsLoading,
              fallback: (context) => mySpinKit(),
              builder: (context) {
                // ── Type guard: this screen is only for shared trips ──────
                if (trip.type != TripType.shared) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red.shade600, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            'This trip is not a shared trip.\nOffers are only available for shared trips.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Go Back'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // ── Normal shared-trip layout ─────────────────────────────
                final driver = trip.driver;
                final car = driver?.car;
                final driverName = driver?.name.isNotEmpty == true
                    ? driver!.name
                    : S.of(context).noDriversYet;
                final totalSeats =
                    trip.numberOfSeats > 0 ? trip.numberOfSeats : 1;
                final remainingSeats = trip.availableSeats > 0
                    ? trip.availableSeats
                    : (totalSeats - trip.passengers.length);
                final hasSeats = remainingSeats > 0;

                final minPerSeat =
                    (trip.minimumPrice / totalSeats).toStringAsFixed(3);
                final maxPerSeat =
                    (trip.maximumPrice / totalSeats).toStringAsFixed(3);

                return Padding(
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
                            onTap: (value) =>
                                setState(() => currentIndex = value),
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
                                  text: S.of(context).tripDetails,
                                  textColor: currentIndex == 0
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              Tab(
                                child: defaultText(
                                  text: S.of(context).driverDetails,
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
                              // ── Tab 0: Trip Details ────────────────────────
                              SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        iconAndText(
                                          text: S
                                              .of(context)
                                              .userlayouthomesharedtrip,
                                          icon: Icons.watch_later_outlined,
                                          iconColor: AppColors.accent,
                                        ),
                                        defaultText(
                                          text: trip.status.name.toUpperCase(),
                                        ),
                                        defaultText(
                                          text: trip.tripDatetime,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10.0),
                                    defaultText(
                                      text: S.of(context).startingLocation,
                                      textFontWeight: FontWeight.bold,
                                    ),
                                    const SizedBox(height: 5.0),
                                    iconAndText(
                                      text: cleanLocationName(
                                          trip.fromLocationName),
                                      icon: Icons.location_on_outlined,
                                      iconColor: AppColors.accent,
                                    ),
                                    const SizedBox(height: 10.0),
                                    defaultText(
                                      text: S.of(context).destinationLocation,
                                      textFontWeight: FontWeight.bold,
                                    ),
                                    const SizedBox(height: 5.0),
                                    iconAndText(
                                      text: cleanLocationName(
                                          trip.toLocationName),
                                      icon: Icons.location_on_outlined,
                                      iconColor: AppColors.accent,
                                    ),
                                    const SizedBox(height: 10.0),
                                    Row(
                                      children: [
                                        defaultText(
                                          text:
                                              '${S.of(context).seatsCountLabel}: ',
                                          textFontWeight: FontWeight.bold,
                                        ),
                                        defaultText(
                                          text: trip.numberOfSeats.toString(),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10.0),
                                    Row(
                                      children: [
                                        defaultText(
                                          text: 'Passengers: ',
                                          textFontWeight: FontWeight.bold,
                                        ),
                                        defaultText(
                                          text: trip.genderPreference ==
                                                  GenderPreference.male
                                              ? S.of(context).male
                                              : (trip.genderPreference ==
                                                      GenderPreference.female
                                                  ? S.of(context).female
                                                  : S.of(context).noPreference),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10.0),
                                    const DottedLine(
                                        dashColor: AppColors.primary),
                                    const SizedBox(height: 20.0),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        defaultText(
                                          text: S.of(context).totalPerSeat,
                                          textColor: AppColors.primary,
                                          textFontSize: 20,
                                          textFontWeight: FontWeight.bold,
                                        ),
                                        defaultText(
                                          text: "$maxPerSeat - $minPerSeat",
                                          textColor: AppColors.primary,
                                          textFontSize: 20,
                                          textFontWeight: FontWeight.bold,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 60.0),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        defaultButton(
                                          onPressed: hasSeats
                                              ? () {
                                                  pricingDialoge(
                                                    context,
                                                    trip.id,
                                                    maxPerSeat,
                                                    minPerSeat,
                                                    trip,
                                                  );
                                                }
                                              : () {},
                                          text: S.of(context).offerNow,
                                          background: hasSeats
                                              ? AppColors.primary
                                              : Colors.grey,
                                          fontSize: 16,
                                        ),
                                        if (!hasSeats) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            'No seats available',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.red.shade600,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 12.0),
                                        UnreadBadge(
                                          chatId: ChatChannelHelper
                                              .sharedTripGroupChatId(
                                                  tripId: trip.id),
                                          currentUserId:
                                              _currentUserId.toString(),
                                          child: SizedBox(
                                            width: double.infinity,
                                            height: 48,
                                            child: OutlinedButton.icon(
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor:
                                                    AppColors.primary,
                                                side: const BorderSide(
                                                    color: AppColors.primary,
                                                    width: 1.5),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10),
                                                ),
                                              ),
                                              onPressed: () {
                                                final groupChatId =
                                                    ChatChannelHelper
                                                        .sharedTripGroupChatId(
                                                            tripId: trip.id);
                                                final membersList = [
                                                  if (driver != null)
                                                    driver.toMap(),
                                                  if (trip.creator != null)
                                                    trip.creator!.toMap(),
                                                  ...trip.passengers
                                                      .map((p) => p.toMap()),
                                                ];
                                                navigateTo(
                                                  context,
                                                  TripChatScreenClean(
                                                    driverName: driverName,
                                                    driverPhone:
                                                        driver?.phone ?? '',
                                                    tripFrom: cleanLocationName(
                                                        trip.fromLocationName),
                                                    tripTo: cleanLocationName(
                                                        trip.toLocationName),
                                                    tripDatetime:
                                                        trip.tripDatetime,
                                                    acceptedPrice:
                                                        trip.approvedPrice ??
                                                            trip.maximumPrice,
                                                    tripId: trip.id,
                                                    offerId: 0,
                                                    chatId: groupChatId,
                                                    tripType: 'shared',
                                                    isInquiry: false,
                                                    isOffersPhase: false,
                                                    members: membersList,
                                                  ),
                                                );
                                              },
                                              icon: const Icon(
                                                  Icons.groups_rounded,
                                                  size: 22),
                                              label: Text(
                                                'الدردشة الجماعية للرحلة',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 14),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // ── Tab 1: Driver Details ──────────────────────
                              SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 10.0),
                                    Center(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 40,
                                            backgroundColor: AppColors.primary
                                                .withValues(alpha: 0.1),
                                            backgroundImage: appCachedImageProvider(ApiEndpoints.buildImageUrl(driver?.photo)),
                                            child: (driver?.photo == null ||
                                                    ApiEndpoints.buildImageUrl(
                                                            driver!.photo) ==
                                                        null)
                                                ? const Icon(Icons.person,
                                                    size: 40,
                                                    color: AppColors.primary)
                                                : null,
                                          ),
                                          const SizedBox(height: 5.0),
                                          defaultText(
                                            text: driverName,
                                            textFontWeight: FontWeight.bold,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10.0),
                                    if (car != null) ...[
                                      Row(
                                        children: [
                                          defaultText(
                                            text: S.of(context).typeOfCar,
                                            textFontWeight: FontWeight.bold,
                                          ),
                                          defaultText(
                                            text: car.type,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10.0),
                                      Row(
                                        children: [
                                          defaultText(
                                            text: S.of(context).modelOfCar,
                                            textFontWeight: FontWeight.bold,
                                          ),
                                          defaultText(
                                            text: car.model,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10.0),
                                    ],
                                    defaultText(
                                      text: S.of(context).destinationLocation,
                                      textFontWeight: FontWeight.bold,
                                    ),
                                    const SizedBox(height: 5.0),
                                    iconAndText(
                                      text: trip.toLocationName,
                                      icon: Icons.location_on_outlined,
                                      iconColor: AppColors.accent,
                                    ),
                                    const SizedBox(height: 60.0),
                                    Builder(
                                      builder: (context) {
                                        final bool isUserJoined =
                                            trip.createdBy == _currentUserId ||
                                                trip.passengers.any((p) =>
                                                    p.id == _currentUserId);
                                        final dmChatId = isUserJoined
                                            ? ChatChannelHelper
                                                .sharedTripDmChatId(
                                                    tripId: trip.id,
                                                    passengerId: _currentUserId)
                                            : ChatChannelHelper
                                                .sharedTripInquiryChatId(
                                                    tripId: trip.id,
                                                    passengerId:
                                                        _currentUserId);

                                        return UnreadBadge(
                                          chatId: dmChatId,
                                          currentUserId:
                                              _currentUserId.toString(),
                                          child: defaultButton(
                                            onPressed: () {
                                              final phone = driver?.phone ?? '';
                                              final approvedPrice =
                                                  trip.approvedPrice ??
                                                      trip.maximumPrice;

                                              navigateTo(
                                                context,
                                                TripChatScreenClean(
                                                  driverName: driverName,
                                                  driverPhone: phone,
                                                  driverPhoto: driver?.photo,
                                                  tripFrom: cleanLocationName(
                                                      trip.fromLocationName),
                                                  tripTo: cleanLocationName(
                                                      trip.toLocationName),
                                                  tripDatetime:
                                                      trip.tripDatetime,
                                                  acceptedPrice: approvedPrice,
                                                  tripId: trip.id,
                                                  offerId: 0,
                                                  chatId: dmChatId,
                                                  tripType: 'shared',
                                                  isInquiry: !isUserJoined,
                                                  isOffersPhase: false,
                                                  isDm: isUserJoined,
                                                  driverId: driver?.id ?? trip.driverId,
                                                  passengerId: _currentUserId,
                                                  members: [
                                                    if (driver != null)
                                                      driver.toMap(),
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
                                            },
                                            text: isUserJoined
                                                ? 'مراسلة السائق'
                                                : S.of(context).contactNow,
                                            background: AppColors.primary,
                                            fontSize: 16,
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
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

double _safeDoubleParse(dynamic value, [double defaultValue = 0.0]) {
  if (value == null) return defaultValue;
  return double.tryParse(value.toString()) ?? defaultValue;
}

// ── Pricing Dialog ────────────────────────────────────────────────────────────

void pricingDialoge(BuildContext context, int tripId, String maxPrice,
    String minPrice, Trip trip) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      final minVal = _safeDoubleParse(minPrice);
      final maxVal = _safeDoubleParse(maxPrice);
      final currentRangeValues = RangeValues(minVal, maxVal);

      if (kDebugMode) {
        log('$tripId, $maxPrice, $minPrice', name: 'OfferDialog');
      }

      double? price;

      return StatefulBuilder(
        builder: (ctx, setState) {
          return Dialog(
            backgroundColor: Colors.white,
            elevation: 0.0,
            child: SingleChildScrollView(
              reverse: true,
              child: Container(
                width: MediaQuery.of(ctx).size.width / 1.2,
                height: MediaQuery.of(ctx).size.height / 2.5,
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      S.of(ctx).averagePrice,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    RangeSlider(
                      activeColor: const Color.fromRGBO(255, 221, 82, 1),
                      values: currentRangeValues,
                      max: maxVal > 0 ? maxVal : 100,
                      min: minVal >= 0 ? minVal : 0,
                      divisions: 50,
                      labels: RangeLabels(
                        '${currentRangeValues.start.toStringAsFixed(3)} ${S.of(ctx).jod}',
                        '${currentRangeValues.end.toStringAsFixed(3)} ${S.of(ctx).jod}',
                      ),
                      onChanged: null,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${currentRangeValues.start} ${S.of(ctx).jod}'),
                        Text('${currentRangeValues.end} ${S.of(ctx).jod}'),
                      ],
                    ),
                    Text(
                      S.of(ctx).price,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      height: MediaQuery.of(ctx).size.height / 10,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(ctx).size.width / 5,
                            height: MediaQuery.of(ctx).size.height / 20,
                            child: TextFormField(
                              style: const TextStyle(fontSize: 10),
                              decoration: const InputDecoration(
                                hintTextDirection: TextDirection.ltr,
                                hintStyle: TextStyle(color: AppColors.primary),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1, color: AppColors.primary),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1, color: AppColors.primary),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1, color: AppColors.primary),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  price = _safeDoubleParse(value);
                                });
                              },
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(ctx).size.height / 20,
                            alignment: Alignment.center,
                            color: AppColors.primary,
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              S.of(ctx).jod,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: const ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(AppColors.primary),
                          ),
                          onPressed: () {
                            if (price == null ||
                                price! < currentRangeValues.start ||
                                price! > currentRangeValues.end) {
                              showToast(
                                  text: S.of(ctx).pleaseEnterValue,
                                  state: ToastStates.WARNING);
                              return;
                            }
                            successDialoug(ctx, S.of(ctx).SuccessfullySent);

                            PassengerTripsCubit.get(ctx).createOffer(
                              ctx,
                              trip_id: tripId,
                              note: null,
                              price: price!,
                              percentage_added: null,
                              trip: trip,
                            );
                          },
                          child: Text(
                            S.of(ctx).send,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(S.of(ctx).cancel),
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
