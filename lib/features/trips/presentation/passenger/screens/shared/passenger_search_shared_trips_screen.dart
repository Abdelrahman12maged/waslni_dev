import 'dart:developer';
import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/router/navigation_manager.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/core/widgets/app_cached_image.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/utils/location_helper.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/core/widgets/unread_badge.dart';
import 'package:car_app/core/utils/chat_channel_helper.dart';
import 'package:car_app/features/chat/presentation/screens/trip_chat_screen.dart';
import 'package:car_app/features/map/domain/entities/place_suggestion.dart';
import 'package:car_app/features/trips/domain/entities/offer.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/domain/entities/trip_passenger.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_search_shared_trips_cubit.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_search_shared_trips_state.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/shared/shared_trip_map_picker_screen.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class PassengerSearchSharedTripsScreen extends StatelessWidget {
  const PassengerSearchSharedTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PassengerSearchSharedTripsCubit>(
      create: (context) => sl<PassengerSearchSharedTripsCubit>()..init(),
      child: const _PassengerSearchSharedTripsContent(),
    );
  }
}

class _PassengerSearchSharedTripsContent extends StatelessWidget {
  const _PassengerSearchSharedTripsContent();

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
    final cubit = PassengerSearchSharedTripsCubit.get(context);

    return Scaffold(
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
          S.of(context).searchSharedTrips,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.bell,
                color: AppColors.primary, size: 18),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
        ],
      ),
      body: BlocConsumer<PassengerSearchSharedTripsCubit,
          PassengerSearchSharedTripsState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is PassengerSearchSharedTripsLoading ||
              state is PassengerSearchSharedTripsInitial) {
            return Column(
              children: [
                _buildCompactRouteCard(context, cubit, null),
                Expanded(child: Center(child: mySpinKit())),
              ],
            );
          }

          if (state is PassengerSearchSharedTripsError) {
            return Column(
              children: [
                _buildCompactRouteCard(context, cubit, null),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.location_off_rounded,
                                size: 42, color: Colors.red.shade400),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                            ),
                            onPressed: () => cubit.refreshLocation(),
                            icon:
                                const Icon(Icons.my_location_rounded, size: 18),
                            label: Text(S.of(context).enableLocationAndRetry,
                                style: GoogleFonts.cairo(fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          final loadedState = state as PassengerSearchSharedTripsLoaded;
          final trips = loadedState.filteredTrips;
          final suggestions = loadedState.placeSuggestions;
          final originSuggestions = loadedState.originPlaceSuggestions;
          final savedLocations = loadedState.savedLocations;
          final selectedQuery = loadedState.selectedQuery;
          final hasDestCoords =
              loadedState.destLat != null && loadedState.destLng != null;
          final selectedTime = loadedState.selectedTime;
          final isCustomOrigin = loadedState.isUsingCustomOrigin;

          return Column(
            children: [
              // ── 1. Compact Unified Route Card (Uber/Careem style) ────────
              _buildCompactRouteCard(context, cubit, loadedState),

              // ── 2. Overlay Suggestions Dropdowns ────────────────────────
              if (originSuggestions.isNotEmpty)
                _buildSuggestionsDropdown(
                  context,
                  title: S.of(context).suggestedPickup,
                  icon: Icons.trip_origin,
                  color: Colors.green,
                  suggestions: originSuggestions,
                  onSelect: (s) => cubit.selectOriginSuggestion(s),
                ),
              if (suggestions.isNotEmpty)
                _buildSuggestionsDropdown(
                  context,
                  title: S.of(context).suggestedDestination,
                  icon: Icons.flag_rounded,
                  color: Colors.red,
                  suggestions: suggestions,
                  onSelect: (s) => cubit.selectSuggestion(s),
                ),

              // ── 3. Quick Saved Location Chips (if any) ──────────────────
              if (savedLocations.isNotEmpty &&
                  originSuggestions.isEmpty &&
                  suggestions.isEmpty)
                _buildCompactSavedLocations(
                    context, cubit, savedLocations, selectedQuery),

              // ── 4. Compact Results Bar ──────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Text(
                      S.of(context).availableTrips(trips.length),
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    if (hasDestCoords ||
                        isCustomOrigin ||
                        selectedTime != null) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          cubit.clearSearch();
                          cubit.clearTimeFilter();
                          cubit.resetOriginToGps();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.close_rounded,
                                  size: 12, color: Colors.red.shade700),
                              const SizedBox(width: 4),
                              Text(
                                S.of(context).clearFilters,
                                style: GoogleFonts.cairo(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded,
                          color: AppColors.primary, size: 20),
                      onPressed: () => cubit.fetchSharedTrips(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: S.of(context).update,
                    ),
                  ],
                ),
              ),

              // ── 5. Trips List (Maximum Viewport Height) ──────────────────
              Expanded(
                child: trips.isEmpty
                    ? _buildEmptyState(context, cubit, selectedQuery,
                        hasDestCoords, selectedTime)
                    : RefreshIndicator(
                        onRefresh: () => cubit.fetchSharedTrips(),
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                          itemCount: trips.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            return _buildSharedTripCard(context, trips[index]);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── Compact Unified Route Card ─────────────────────────────────────────

  Widget _buildCompactRouteCard(
    BuildContext context,
    PassengerSearchSharedTripsCubit cubit,
    PassengerSearchSharedTripsLoaded? state,
  ) {
    final isSearchingOrigin = state?.isSearchingOrigin ?? false;
    final isSearchingDest = state?.isSearchingPlace ?? false;
    final isCustomOrigin = state?.isUsingCustomOrigin ?? false;
    final hasDestCoords = state?.destLat != null;
    final hasTimeFilter = state?.selectedTime != null;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
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
          // ── Quick Actions Row (Map Button + Time Button) ───────────────
          Row(
            children: [
              // Map Route Button (Pill)
              InkWell(
                onTap: () => _openMapPicker(context, cubit, state),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.map_rounded,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        S.of(context).routeMapButton,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Time Filter Button (Pill)
              InkWell(
                onTap: () => _pickTime(context, cubit, state?.selectedTime),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasTimeFilter
                        ? AppColors.primary
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 13,
                        color:
                            hasTimeFilter ? Colors.white : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hasTimeFilter
                            ? DateFormat('hh:mm a', 'ar')
                                .format(state!.selectedTime!.toLocal())
                            : S.of(context).timeOptional,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: hasTimeFilter
                              ? Colors.white
                              : Colors.grey.shade700,
                        ),
                      ),
                      if (hasTimeFilter) ...[
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () => cubit.clearTimeFilter(),
                          child: const Icon(Icons.close,
                              size: 12, color: Colors.white),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Quick GPS Reset (if custom origin was used)
              if (isCustomOrigin)
                InkWell(
                  onTap: () => cubit.resetOriginToGps(),
                  child: Row(
                    children: [
                      Icon(Icons.my_location_rounded,
                          size: 13, color: Colors.teal.shade700),
                      const SizedBox(width: 3),
                      Text(
                        'GPS',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),
          Divider(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 6),

          // ── Origin Input Row (من) ───────────────────────────────────────
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: cubit.originController,
                  onChanged: (q) => cubit.onOriginQueryChanged(q),
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(fontSize: 12.5),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 6),
                    hintText: isCustomOrigin
                        ? (state?.customOriginName ??
                            S.of(context).pickupLocation)
                        : S.of(context).currentGpsLocation,
                    hintStyle: GoogleFonts.cairo(
                      color: isCustomOrigin
                          ? Colors.black87
                          : Colors.teal.shade700,
                      fontSize: 12,
                      fontWeight:
                          isCustomOrigin ? FontWeight.bold : FontWeight.w600,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (isSearchingOrigin)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                )
              else if (cubit.originController.text.isNotEmpty)
                InkWell(
                  onTap: () => cubit.clearOriginSearch(),
                  child: const Icon(Icons.clear, size: 16, color: Colors.grey),
                ),
              IconButton(
                icon: Icon(Icons.map_outlined,
                    size: 16, color: Colors.teal.shade700),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                tooltip: S.of(context).pickPickupLocationOnMap,
                onPressed: () =>
                    _openMapPicker(context, cubit, state, pickOriginOnly: true),
              ),
            ],
          ),

          // Connecting route line
          Padding(
            padding: const EdgeInsets.only(right: 3),
            child: Row(
              children: [
                Container(
                  width: 2,
                  height: 12,
                  color: Colors.grey.shade300,
                ),
              ],
            ),
          ),

          // ── Destination Input Row (إلى) ─────────────────────────────────
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.rectangle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: cubit.searchController,
                  onChanged: (q) => cubit.onSearchQueryChanged(q),
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(fontSize: 12.5),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 6),
                    hintText: S.of(context).whereTo,
                    hintStyle: GoogleFonts.cairo(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (isSearchingDest)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                )
              else if (cubit.searchController.text.isNotEmpty)
                InkWell(
                  onTap: () => cubit.clearSearch(),
                  child: const Icon(Icons.clear, size: 16, color: Colors.grey),
                ),
              IconButton(
                icon: Icon(Icons.map_outlined,
                    size: 16,
                    color: hasDestCoords
                        ? Colors.red.shade600
                        : Colors.grey.shade500),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                tooltip: S.of(context).pickDestinationOnMap,
                onPressed: () => _openMapPicker(context, cubit, state,
                    pickDestinationOnly: true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Compact Suggestions Dropdown ────────────────────────────────────────

  Widget _buildSuggestionsDropdown(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<PlaceSuggestion> suggestions,
    required ValueChanged<PlaceSuggestion> onSelect,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 2, 14, 4),
      constraints: const BoxConstraints(maxHeight: 180),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            color: color.withOpacity(0.08),
            child: Row(
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: suggestions.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.grey.shade100),
              itemBuilder: (context, index) {
                final s = suggestions[index];
                return ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -3),
                  leading: Icon(Icons.place_outlined, color: color, size: 16),
                  title: Text(
                    s.description,
                    style: GoogleFonts.cairo(fontSize: 12),
                  ),
                  onTap: () {
                    onSelect(s);
                    FocusScope.of(context).unfocus();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Compact Saved Locations ─────────────────────────────────────────────

  Widget _buildCompactSavedLocations(
    BuildContext context,
    PassengerSearchSharedTripsCubit cubit,
    List<Map<String, dynamic>> savedLocations,
    String selectedQuery,
  ) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: savedLocations.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = selectedQuery.isEmpty;
            return ChoiceChip(
              visualDensity: const VisualDensity(vertical: -4),
              label: Text(S.of(context).all,
                  style: GoogleFonts.cairo(fontSize: 11)),
              selected: isSelected,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 11,
              ),
              onSelected: (_) => cubit.clearSearch(),
            );
          }
          final loc = savedLocations[index - 1];
          final name = loc['name']?.toString() ?? S.of(context).location;
          final isSelected = cubit.searchController.text == name;
          return ChoiceChip(
            visualDensity: const VisualDensity(vertical: -4),
            avatar:
                const Icon(Icons.star_rounded, size: 13, color: Colors.amber),
            label: Text(name, style: GoogleFonts.cairo(fontSize: 11)),
            selected: isSelected,
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontSize: 11,
            ),
            onSelected: (_) => cubit.selectSavedLocation(name),
          );
        },
      ),
    );
  }

  // ─── Empty State ─────────────────────────────────────────────────────────

  Widget _buildEmptyState(
    BuildContext context,
    PassengerSearchSharedTripsCubit cubit,
    String query,
    bool hasDestCoords,
    DateTime? selectedTime,
  ) {
    String message;
    if (hasDestCoords && selectedTime != null) {
      message = S.of(context).noMatchingSharedTrips(query);
    } else if (hasDestCoords) {
      message = S.of(context).noMatchingSharedTrips(query);
    } else if (selectedTime != null) {
      message = S.of(context).noSharedTripsAvailable;
    } else {
      message = S.of(context).noSharedTripsAvailable;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car_outlined,
                size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasDestCoords || selectedTime != null) ...[
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                    ),
                    onPressed: () {
                      cubit.clearSearch();
                      cubit.clearTimeFilter();
                    },
                    child: Text(S.of(context).viewAllTrips,
                        style: GoogleFonts.cairo(
                            color: AppColors.primary, fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                ],
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: () => cubit.fetchSharedTrips(),
                  child: Text(S.of(context).update,
                      style: GoogleFonts.cairo(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Trip Card ───────────────────────────────────────────────────────────

  Widget _buildSharedTripCard(BuildContext context, Trip trip) {
    final driver = trip.driver;
    final driverName = driver?.name.isNotEmpty == true
        ? driver!.name
        : S.of(context).verifiedDriver;
    final fromLoc = cleanLocationName(trip.fromLocationName).isNotEmpty
        ? cleanLocationName(trip.fromLocationName)
        : S.of(context).pickupLocation;
    final toLoc = cleanLocationName(trip.toLocationName).isNotEmpty
        ? cleanLocationName(trip.toLocationName)
        : S.of(context).destination;

    final totalSeats = trip.totalSeats > 0
        ? trip.totalSeats
        : (trip.driver?.car?.seats != null && trip.driver!.car!.seats! > 0
            ? trip.driver!.car!.seats!
            : 4);

    // Sum of seats currently booked across all passengers (reserved_seats)
    final int existingOccupiedSeats = trip.reservedSeats > 0
        ? trip.reservedSeats
        : (trip.passengers.isNotEmpty
            ? trip.passengers
                .fold<int>(0, (sum, p) => sum + (p.seats > 0 ? p.seats : 1))
            : (trip.joinedPassengersCount > 0
                ? trip.joinedPassengersCount
                : (trip.availableSeats >= 0 && totalSeats > trip.availableSeats
                    ? (totalSeats - trip.availableSeats)
                    : 0)));

    final availableSeats = trip.availableSeats >= 0
        ? trip.availableSeats
        : (totalSeats - existingOccupiedSeats).clamp(0, totalSeats);

    final currentParticipants = trip.joinedPassengersCount > 0
        ? trip.joinedPassengersCount
        : (trip.passengers.isNotEmpty
            ? trip.passengers.length
            : (existingOccupiedSeats > 0 ? 1 : 0));

    final isJoined = _isUserJoined(trip);
    final myPassenger = _getMyPassengerRecord(trip);
    final mySeats =
        myPassenger?.seats ?? (trip.createdBy == _currentUserId ? 1 : 0);

    final car = driver?.car;
    String? carInfo;
    if (car != null && (car.type.isNotEmpty || car.model.isNotEmpty)) {
      carInfo = '${car.type} ${car.model}'.trim();
    }

    final driverPhoto = ApiEndpoints.buildImageUrl(driver?.photo);
    final hasDriverPhoto = driverPhoto != null && driverPhoto.isNotEmpty;

    // Total agreed price for the trip (from approved_price, accepted offer, or max/min price)
    double totalAgreedPrice = (trip.approvedPrice != null && trip.approvedPrice! > 0)
        ? trip.approvedPrice!
        : 0.0;
    if (totalAgreedPrice <= 0 && trip.offers.isNotEmpty) {
      for (final o in trip.offers) {
        if (o.status == OfferStatus.accepted ||
            o.effectiveStatus == 'accepted' ||
            o.effectiveStatus == 'approved') {
          totalAgreedPrice = o.price;
          break;
        }
      }
    }
    if (totalAgreedPrice <= 0) {
      totalAgreedPrice = trip.maximumPrice > 0 ? trip.maximumPrice : trip.minimumPrice;
    }

    // Projected total occupied seats if a passenger joins with 1 seat
    final projectedOccupiedSeats =
        (isJoined ? (existingOccupiedSeats > 0 ? existingOccupiedSeats : 1) : (existingOccupiedSeats + 1))
            .clamp(1, totalSeats);

    // Dynamic price for 1 seat = (1 / projectedOccupiedSeats) * totalAgreedPrice
    final double priceForOneSeat = totalAgreedPrice > 0
        ? ((1 / projectedOccupiedSeats) * totalAgreedPrice)
        : 0.0;
    // Minimum price per seat if the vehicle becomes 100% full
    final double minPriceWhenFull =
        totalSeats > 0 ? (totalAgreedPrice / totalSeats) : totalAgreedPrice;

    final hasAvailableSeats = availableSeats > 0;
    final hasMatchDistance = trip.matchDistanceOriginKm != null;

    return InkWell(
      onTap: () => _navigateToTripDetails(context, trip),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isJoined ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isJoined
                ? const Color(0xFF16A34A)
                : (hasAvailableSeats
                    ? Colors.grey.shade200
                    : Colors.red.shade200),
            width: isJoined ? 2.0 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isJoined
                  ? const Color(0xFF16A34A).withOpacity(0.14)
                  : Colors.black.withOpacity(0.04),
              blurRadius: isJoined ? 10 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Joined Badge if user already booked
            if (isJoined)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(14)),
                  border: Border(
                    bottom: BorderSide(color: Color(0xFF86EFAC), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 16, color: Color(0xFF16A34A)),
                    const SizedBox(width: 6),
                    Text(
                      '${S.of(context).youAreJoinedInTrip}${mySeats > 0 ? ' (${S.of(context).yourBookingSeats(mySeats)})' : ''}',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: const Color(0xFF166534),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            // Match Distance Badge (if from /nearby-shared and not already showing joined badge)
            else if (hasMatchDistance)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.near_me_rounded,
                        size: 13, color: Colors.teal.shade700),
                    const SizedBox(width: 5),
                    Text(
                      '${S.of(context).startsDistanceKm(trip.matchDistanceOriginKm!.toStringAsFixed(1))}'
                      '${trip.matchDistanceDestinationKm != null ? ' · ${S.of(context).destinationDistanceKm(trip.matchDistanceDestinationKm!.toStringAsFixed(1))}' : ''}',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: Colors.teal.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Driver Info + Seats Badge Row ────────────────────────
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        backgroundImage: appCachedImageProvider(driverPhoto),
                        child: !hasDriverPhoto
                            ? const Icon(Icons.person,
                                color: AppColors.primary, size: 20)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driverName,
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                color: AppColors.primary,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.access_time_rounded,
                                    size: 11, color: Colors.grey.shade500),
                                const SizedBox(width: 3),
                                Text(
                                  _formatDateTime(context, trip.tripDatetime),
                                  style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                if (carInfo != null) ...[
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      '• $carInfo',
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.cairo(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Seats badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: hasAvailableSeats
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: hasAvailableSeats
                                ? Colors.green.shade200
                                : Colors.red.shade200,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.event_seat_rounded,
                              size: 12,
                              color: hasAvailableSeats
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              hasAvailableSeats
                                  ? S.of(context).seatsRemaining(availableSeats)
                                  : S.of(context).tripFull,
                              style: GoogleFonts.cairo(
                                color: hasAvailableSeats
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // ── Reserved Seats & Current Participants Summary ────────
                  Row(
                    children: [
                      Icon(Icons.people_outline_rounded,
                          size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        S.of(context).tripParticipantsSummary(
                            currentParticipants,
                            existingOccupiedSeats,
                            totalSeats),
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),
                  Divider(height: 1, color: Colors.grey.shade100),
                  const SizedBox(height: 8),

                  // ── Route: From -> To ───────────────────────────────────
                  Row(
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.radio_button_checked,
                              size: 12, color: Colors.green),
                          Container(
                              width: 1,
                              height: 14,
                              color: Colors.grey.shade300),
                          const Icon(Icons.location_on,
                              size: 12, color: Colors.red),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fromLoc,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                  fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              toLoc,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ── Price Breakdown + Action ───────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '${totalAgreedPrice.toStringAsFixed(2)} ${S.of(context).jod}',
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  S.of(context).tripTotalLabel,
                                  style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            if (totalAgreedPrice > 0 && totalSeats > 0)
                              Text(
                                S.of(context).perSeatWhenFull(
                                  '${minPriceWhenFull.toStringAsFixed(2)} ${S.of(context).jod}',
                                  totalSeats.toString(),
                                ),
                                style: GoogleFonts.cairo(
                                  fontSize: 9.5,
                                  color: Colors.teal.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isJoined)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (hasAvailableSeats) ...[
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: AppColors.primary,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () =>
                                    _navigateToTripDetails(context, trip),
                                child: Text(
                                  S.of(context).increaseSeats,
                                  style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            UnreadBadge(
                              chatId: ChatChannelHelper.sharedTripGroupChatId(
                                  tripId: trip.id),
                              currentUserId: _currentUserId.toString(),
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF16A34A),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () => _openChat(context, trip),
                                icon: const Icon(Icons.chat_bubble_rounded,
                                    size: 13),
                                label: Text(
                                  S.of(context).chatAction,
                                  style: GoogleFonts.cairo(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else if (hasAvailableSeats)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () =>
                              _navigateToTripDetails(context, trip),
                          child: Text(
                            S.of(context).detailsAndBooking,
                            style: GoogleFonts.cairo(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade400),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () =>
                              _navigateToTripDetails(context, trip),
                          child: Text(
                            S.of(context).details,
                            style: GoogleFonts.cairo(
                              fontSize: 11.5,
                              color: Colors.grey.shade700,
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
    );
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

  void _openChat(BuildContext context, Trip trip) {
    final driver = trip.driver;
    final driverName = driver?.name.isNotEmpty == true
        ? driver!.name
        : S.of(context).verifiedDriver;
    final phone = driver?.phone ?? '';
    final price = trip.approvedPrice ??
        (trip.maximumPrice > 0 ? trip.maximumPrice : trip.minimumPrice);
    final groupChatId =
        ChatChannelHelper.sharedTripGroupChatId(tripId: trip.id);

    final membersList = [
      if (driver != null) driver.toMap(),
      if (trip.creator != null) trip.creator!.toMap(),
      ...trip.passengers.map((p) => p.toMap()),
    ];

    navigateTo(
      context,
      TripChatScreenClean(
        driverName: driverName,
        driverPhone: phone,
        tripFrom: cleanLocationName(trip.fromLocationName),
        tripTo: cleanLocationName(trip.toLocationName),
        tripDatetime: trip.tripDatetime,
        acceptedPrice: price,
        tripId: trip.id,
        offerId: 0,
        chatId: groupChatId,
        tripType: 'shared',
        isInquiry: false,
        isOffersPhase: false,
        members: membersList,
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  Future<void> _openMapPicker(
    BuildContext context,
    PassengerSearchSharedTripsCubit cubit,
    PassengerSearchSharedTripsLoaded? state, {
    bool pickOriginOnly = false,
    bool pickDestinationOnly = false,
  }) async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => SharedTripMapPickerScreen(
          initialOrigin: state?.originLat != null && state?.originLng != null
              ? LatLng(state!.originLat!, state.originLng!)
              : null,
          initialOriginName: state?.customOriginName.isNotEmpty == true
              ? state!.customOriginName
              : null,
          initialDestination: state?.destLat != null && state?.destLng != null
              ? LatLng(state!.destLat!, state.destLng!)
              : null,
          initialDestinationName: state?.selectedQuery.isNotEmpty == true
              ? state!.selectedQuery
              : null,
          pickOriginOnly: pickOriginOnly,
          pickDestinationOnly: pickDestinationOnly,
        ),
      ),
    );

    if (result != null) {
      if (pickOriginOnly &&
          result['originLat'] != null &&
          result['originLng'] != null) {
        cubit.setOriginFromMap(
          lat: result['originLat'] as double,
          lng: result['originLng'] as double,
          name:
              (result['originName'] as String?) ?? S.of(context).pickupLocation,
        );
      } else if (pickDestinationOnly &&
          result['destLat'] != null &&
          result['destLng'] != null) {
        cubit.setDestinationFromMap(
          lat: result['destLat'] as double,
          lng: result['destLng'] as double,
          name: (result['destName'] as String?) ?? S.of(context).destination,
        );
      } else if (result['originLat'] != null && result['destLat'] != null) {
        cubit.setRouteFromMap(
          originLat: result['originLat'] as double,
          originLng: result['originLng'] as double,
          originName:
              (result['originName'] as String?) ?? S.of(context).pickupLocation,
          destLat: result['destLat'] as double,
          destLng: result['destLng'] as double,
          destName:
              (result['destName'] as String?) ?? S.of(context).destination,
        );
      } else if (result['originLat'] != null) {
        cubit.setOriginFromMap(
          lat: result['originLat'] as double,
          lng: result['originLng'] as double,
          name:
              (result['originName'] as String?) ?? S.of(context).pickupLocation,
        );
      } else if (result['destLat'] != null) {
        cubit.setDestinationFromMap(
          lat: result['destLat'] as double,
          lng: result['destLng'] as double,
          name: (result['destName'] as String?) ?? S.of(context).destination,
        );
      }
    }
  }

  Future<void> _pickTime(BuildContext context,
      PassengerSearchSharedTripsCubit cubit, DateTime? currentTime) async {
    final now = DateTime.now();
    final initial = currentTime ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      helpText: S.of(context).chooseDepartureTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (pickedDate == null) return;

    if (!context.mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      helpText: S.of(context).chooseTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (pickedTime == null) return;

    final combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (!context.mounted) return;
    cubit.setTimeFilter(combined);
  }

  void _navigateToTripDetails(BuildContext context, Trip trip) {
    context.push(
      AppRoutes.passengerSharedTripDetailsPassengers,
      extra: {'trip': trip},
    );
  }
}
