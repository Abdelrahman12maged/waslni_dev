import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/utils/location_helper.dart';
import 'package:car_app/features/home/domain/entities/nearby_trip.dart';
import 'package:car_app/features/home/presentation/cubit/passenger_home_cubit.dart';
import 'package:car_app/features/home/presentation/cubit/passenger_home_state.dart';
import 'package:car_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PassengerSharedTripsScreenClean — Safe Provider & Modern GoRouter Navigation
// ─────────────────────────────────────────────────────────────────────────────
class PassengerSharedTripsScreenClean extends StatelessWidget {
  const PassengerSharedTripsScreenClean({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PassengerHomeCubit>(
      create: (_) => di.sl<PassengerHomeCubit>()..loadNearbyTrips(),
      child: const _PassengerSharedTripsContent(),
    );
  }
}

class _PassengerSharedTripsContent extends StatefulWidget {
  const _PassengerSharedTripsContent();

  @override
  State<_PassengerSharedTripsContent> createState() =>
      __PassengerSharedTripsContentState();
}

class __PassengerSharedTripsContentState
    extends State<_PassengerSharedTripsContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
              ),
            ],
          ),
          child: Text(
            S.of(context).sharedTrip,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 20),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CleanNotificationsScreen(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<PassengerHomeCubit, PassengerHomeState>(
        builder: (context, state) {
          final allTrips = state is PassengerHomeLoaded
              ? state.nearbyTrips
              : <NearbyTrip>[];

          final storage = di.sl<LocalStorage>();
          final currentUserId = storage.read(key: 'user_id')?.toString() ??
              storage.read(key: 'userid')?.toString();

          final filteredTrips = allTrips.where((t) {
            final isOwner = t.userId?.toString() == currentUserId ||
                            t.driverId?.toString() == currentUserId;
            if (isOwner) return false;
            
            if (_searchQuery.isEmpty) return true;
            final query = _searchQuery.toLowerCase();
            final toLoc = t.toLocationName.toLowerCase();
            final fromLoc = t.fromLocationName.toLowerCase();
            return toLoc.contains(query) || fromLoc.contains(query);
          }).toList();

          return Column(
            children: [
              // ── Search Field ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: S.of(context).searchForTrip,
                    prefixIcon:
                        const Icon(Icons.search_rounded, color: AppColors.primary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
              ),

              // ── Trips List Content ────────────────────────────────────
              Expanded(
                child: state is PassengerHomeLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      )
                    : filteredTrips.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredTrips.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (ctx, index) {
                              final trip = filteredTrips[index];
                              return _TripCardTile(
                                trip: trip,
                                onTap: () {
                                  context.push(
                                    AppRoutes.passengerSharedTripDetails,
                                    extra: trip.toJson(),
                                  );
                                },
                              );
                            },
                          ),
              ),

              // ── Add Shared Trip Button ────────────────────────────────
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        context.push(AppRoutes.passengerAddSharedTrip);
                      },
                      icon: const Icon(Icons.add_circle_outline_rounded,
                          color: Colors.white),
                      label: Text(
                        S.of(context).addNewTrip,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_filled_outlined,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            S.of(context).noTripsNearby,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trip Card Tile Widget
// ─────────────────────────────────────────────────────────────────────────────
class _TripCardTile extends StatelessWidget {
  final NearbyTrip trip;
  final VoidCallback onTap;

  const _TripCardTile({required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Driver / Status Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFF1B5E20),
                          child:
                              Icon(Icons.person, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          S.of(context).sharedTrip,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B5E20).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        trip.status.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF1B5E20),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Locations
                Row(
                  children: [
                    const Icon(Icons.trip_origin,
                        color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cleanLocationName(trip.fromLocationName).isNotEmpty
                            ? cleanLocationName(trip.fromLocationName)
                            : S.of(context).pickupPoint,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.flag_rounded,
                        color: Color(0xFF1B5E20), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cleanLocationName(trip.toLocationName).isNotEmpty
                            ? cleanLocationName(trip.toLocationName)
                            : S.of(context).destinationPoint,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Footer (Date/Time & Price)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_month_rounded,
                            size: 15, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          '${trip.dateOnly} ${trip.timeOnly}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${trip.minimumPrice} JOD',
                      style: const TextStyle(
                        color: Color(0xFF1B5E20),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
