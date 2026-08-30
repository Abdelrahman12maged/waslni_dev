import 'package:car_app/core/router/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/features/home/presentation/cubit/passenger_home_cubit.dart';
import 'package:car_app/features/home/presentation/cubit/passenger_home_state.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/shared/ongoing_shared_trip.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/core/router/navigation_manager.dart';
import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/network/api_client.dart';
import 'package:car_app/core/utils/trip_security_service.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/private/current_private_trip_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:car_app/core/services/home_widget_service.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_trips_cubit.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_trips_state.dart';

class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  final ValueNotifier<int> _carouselIndexNotifier = ValueNotifier<int>(0);

  final List<Widget> _carouselImages = [
    Image.asset('assets/images/carouselimage1.png',
        width: double.infinity, fit: BoxFit.fill),
    Image.asset('assets/images/driver.png',
        width: double.infinity, fit: BoxFit.fill),
    Image.asset('assets/images/passenger.png',
        width: double.infinity, fit: BoxFit.fill),
    Image.asset('assets/images/male.png',
        width: double.infinity, fit: BoxFit.fill),
    Image.asset('assets/images/female.png',
        width: double.infinity, fit: BoxFit.fill),
  ];

  @override
  void initState() {
    super.initState();
    TripSecurityService.syncActiveTripWithServer(sl<ApiClient>(), sl<LocalStorage>());
    // Update home widget with passenger's last trip
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncWidgetWithLastTrip();
    });
  }

  void _syncWidgetWithLastTrip() {
    try {
      final activeTrip = TripSecurityService.getActiveTrip(sl<LocalStorage>());
      if (activeTrip != null) {
        HomeWidgetService.updateActiveTrip(trip: activeTrip, isDriver: false);
        return;
      }
      final tripsCubit = PassengerTripsCubit.of(context);
      final allTrips = [
        ...tripsCubit.TripsListByTypeCompletedPrivete,
        ...tripsCubit.TripsListByTypeCompletedShared,
        ...tripsCubit.TripsListByTypeCurrentPrivete,
        ...tripsCubit.TripsListByTypeCurrentShared,
      ];
      if (allTrips.isNotEmpty) {
        // Sort by id desc to get the most recent
        allTrips.sort((a, b) => b.id.compareTo(a.id));
        HomeWidgetService.updatePassengerLastTrip(allTrips.first);
      } else {
        HomeWidgetService.updatePassengerLastTrip(null);
      }
    } catch (_) {
      HomeWidgetService.updatePassengerLastTrip(null);
    }
  }

  @override
  void dispose() {
    _carouselIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PassengerTripsCubit, PassengerTripsState>(
      listenWhen: (_, s) => s is PassengerTripsLoaded,
      listener: (_, __) => _syncWidgetWithLastTrip(),
      child: BlocBuilder<PassengerHomeCubit, PassengerHomeState>(
        builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async {
            await TripSecurityService.syncActiveTripWithServer(sl<ApiClient>(), sl<LocalStorage>());
            if (mounted) setState(() {});
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Carousel ──────────────────────────────────────────────
                Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: CarouselSlider(
                        items: _carouselImages,
                        options: CarouselOptions(
                          onPageChanged: (index, _) =>
                              _carouselIndexNotifier.value = index,
                          height: 170.0,
                          viewportFraction: 1.0,
                          enableInfiniteScroll: true,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 3),
                          autoPlayAnimationDuration: const Duration(seconds: 1),
                          autoPlayCurve: Curves.fastOutSlowIn,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ValueListenableBuilder<int>(
                        valueListenable: _carouselIndexNotifier,
                        builder: (context, currentIndex, _) {
                          return AnimatedSmoothIndicator(
                            activeIndex: currentIndex,
                            count: _carouselImages.length,
                            effect: const ExpandingDotsEffect(
                              dotHeight: 8,
                              dotWidth: 8,
                              activeDotColor: Colors.white,
                              dotColor: Colors.white54,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15.0),

                // ── Active Pre-Trip Live Tracking Banner ─────────────────
                _buildActivePreTripBanner(context),
                const SizedBox(height: 15.0),

                // ── Search Shared Trip Destination Card ─────────────────
                _buildSearchSharedTripsBanner(context),
                const SizedBox(height: 20.0),

                // ── Quick Trip Actions Header & Buttons ──────────────────
                defaultText(
                  text: S.of(context).userlayouthomestarttrip,
                  textFontSize: 15.0,
                  textFontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 12.0),
                Row(
                  children: [
                    tripCard(
                      context: context,
                      svgPath: 'assets/images/privatetrip.svg',
                      cardName: S.of(context).userlayouthomeprivatetrip,
                      textColor: AppColors.primary,
                      onTap: () => context.push(AppRoutes.passengerAddPrivateTrip),
                    ),
                    const SizedBox(width: 12.0),
                    tripCard(
                      context: context,
                      svgPath: 'assets/images/sharedtrip.svg',
                      cardName: S.of(context).userlayouthomesharedtrip,
                      textColor: AppColors.primary,
                      onTap: () => context.push(AppRoutes.passengerAddSharedTrip),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
              ],
            ),
          ),
        );
      },
    ),
  );
}

  Widget _buildSearchSharedTripsBanner(BuildContext context) {
    return InkWell(
      onTap: () => context.push(AppRoutes.passengerSearchSharedTrips),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 13, 21, 117),
              Color.fromARGB(255, 83, 109, 229),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).searchSharedTripHome,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    S.of(context).searchSharedTripSub,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white70,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivePreTripBanner(BuildContext context) {
    final storage = sl<LocalStorage>();
    final activeTrip = TripSecurityService.getActiveTrip(storage);
    if (activeTrip == null || !TripSecurityService.isPreTripTrackingActive(activeTrip)) {
      return const SizedBox.shrink();
    }

    final isPrivate = activeTrip.type == TripType.private;
    final fromName = activeTrip.fromLocationName.isNotEmpty ? activeTrip.fromLocationName : S.of(context).pickupPoint;
    final toName = activeTrip.toLocationName.isNotEmpty ? activeTrip.toLocationName : S.of(context).destinationPoint;
    final driverName = activeTrip.driver?.name.isNotEmpty == true ? activeTrip.driver!.name : S.of(context).driver;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.radar_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      S.of(context).liveTrackingInProgress,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                driverName.toString(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.trip_origin, color: Colors.amber, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '$fromName ➔ $toName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              onPressed: () {
                navigateTo(
                  context,
                  isPrivate
                      ? PassengerCurrentPrivateTripScreenClean(
                          trip: activeTrip,
                        )
                      : PassengerOngoingSharedTripScreenClean(
                          trip: activeTrip,
                        ),
                );
              },
              icon: const Icon(Icons.my_location_rounded, size: 18),
              label: Text(
                S.of(context).openLiveTrackingMap,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
