import 'package:car_app/generated/l10n.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/features/home/domain/entities/nearby_trip.dart';
import 'package:car_app/features/home/presentation/cubit/passenger_home_cubit.dart';
import 'package:car_app/features/home/presentation/cubit/passenger_home_state.dart';
import 'package:car_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/core/router/navigation_manager.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/shared/ongoing_shared_trip.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:car_app/core/router/app_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/core/storage/local_storage.dart';

class PassengerNearbyTripsScreen extends StatefulWidget {
  const PassengerNearbyTripsScreen({super.key});

  @override
  State<PassengerNearbyTripsScreen> createState() =>
      _PassengerNearbyTripsScreenState();
}

class _PassengerNearbyTripsScreenState
    extends State<PassengerNearbyTripsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    await PassengerHomeCubit.of(context).loadNearbyTrips();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(
        leadingOnPressed: () => Navigator.of(context).pop(),
        titleText: S.of(context).nearbyTrips,
        backgroundColor: Colors.grey[300],
        actionsIconColor: AppColors.primary,
        actionsOnPressed: () =>
            navigateTo(context, const CleanNotificationsScreen()),
      ),
      body: BlocBuilder<PassengerHomeCubit, PassengerHomeState>(
        builder: (context, state) {
          if (_isLoading || state is PassengerHomeLoading) {
            return _buildLoadingWidget(context);
          }

          if (state is PassengerHomeError) {
            return _buildErrorWidget(context, state.message);
          }

          final allTrips =
              state is PassengerHomeLoaded ? state.nearbyTrips : <NearbyTrip>[];
          
          final storage = di.sl<LocalStorage>();
          final currentUserId = storage.read(key: 'user_id')?.toString() ??
              storage.read(key: 'userid')?.toString();
              
          final trips = allTrips.where((trip) {
            final isOwner = trip.userId?.toString() == currentUserId ||
                            trip.driverId?.toString() == currentUserId;
            return !isOwner && trip.status != 'completed' && trip.status != 'canceled';
          }).toList();

          if (trips.isEmpty) {
            return _buildEmptyWidget(context);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(10),
            itemCount: trips.length,
            separatorBuilder: (_, __) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              final trip = trips[index];
              return privateTripContainer(
                context: context,
                borderColor: trip.status == 'accepted'
                    ? Colors.green
                    : (trip.status == 'closed' ? Colors.red : AppColors.accent),
                onTap: () {
                  if (trip.driverId != null) {
                    context.push(
                      AppRoutes.passengerSharedTripDetails,
                      extra: trip.toJson(),
                    );
                  } else {
                    context.push(
                      AppRoutes.passengerSharedTripDetailsPassengers,
                      extra: trip.toJson(),
                    );
                  }
                },
                timeText: '${trip.tripDatetime} (${trip.type.toUpperCase()})',
                dateText: '',
                locationText: '${trip.distance} Km — ${trip.toLocationName}',
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/loading.gif',
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() => _isLoading = true);
              _loadTrips();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: Text(S.of(context).update),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/changelang.png',
            fit: BoxFit.contain,
            width: MediaQuery.of(context).size.width / 2,
          ),
          const SizedBox(height: 24),
          Text(
            S.of(context).noTripsNearby,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              setState(() => _isLoading = true);
              _loadTrips();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: Text(S.of(context).update),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}


// Trip Card Tile Widget
// ─────────────────────────────────────────────────────────────────────────────
