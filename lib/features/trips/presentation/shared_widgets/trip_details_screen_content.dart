import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/core/widgets/app_cached_image.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

/// A rich, modern, and detailed view for displaying completed, canceled, or suspended trips.
class TripDetailsScreenContent extends StatelessWidget {
  final Trip trip;
  final bool isDriver;
  final Widget? bottomAction;

  const TripDetailsScreenContent({
    super.key,
    required this.trip,
    this.isDriver = false,
    this.bottomAction,
  });

  String get _driverName => trip.driver?.name ?? '';
  String get _driverPhone => trip.driver?.phone ?? '';
  String get _creatorName => trip.creator?.name ?? '';
  String get _creatorPhone => trip.creator?.phone ?? '';

  String get _formattedDate {
    final raw = trip.tripDatetime;
    if (raw.contains('T')) {
      return raw.split('T')[0];
    }
    if (raw.contains(' ')) {
      return raw.split(' ')[0];
    }
    return raw;
  }

  String get _formattedTime {
    final raw = trip.tripDatetime;
    if (raw.contains('T')) {
      final parts = raw.split('T');
      if (parts.length > 1 && parts[1].length >= 5) {
        return parts[1].substring(0, 5);
      }
    }
    if (raw.contains(' ')) {
      final parts = raw.split(' ');
      if (parts.length > 1 && parts[1].length >= 5) {
        return parts[1].substring(0, 5);
      }
    }
    return raw;
  }

  String get _totalPrice {
    final price = trip.approvedPrice ?? trip.maximumPrice;
    return price > 0 ? price.toStringAsFixed(2) : trip.minimumPrice.toStringAsFixed(2);
  }

  String get _pricePerSeat {
    if (trip.numberOfSeats > 0 && (trip.approvedPrice != null || trip.maximumPrice > 0)) {
      final total = trip.approvedPrice ?? trip.maximumPrice;
      return (total / trip.numberOfSeats).toStringAsFixed(2);
    }
    return '0.00';
  }

  Color get _statusColor {
    switch (trip.status) {
      case TripStatus.completed:
        return const Color(0xFF10B981); // Emerald
      case TripStatus.canceled:
      case TripStatus.closed:
        return const Color(0xFFEF4444); // Red
      case TripStatus.suspended:
        return const Color(0xFFF59E0B); // Amber
      case TripStatus.accepted:
        return const Color(0xFF3B82F6); // Blue
      default:
        return AppColors.primary;
    }
  }

  String _statusLabel(BuildContext context) {
    switch (trip.status) {
      case TripStatus.completed:
        return S.of(context).completed;
      case TripStatus.canceled:
      case TripStatus.closed:
        return S.of(context).canceled;
      case TripStatus.suspended:
        return S.of(context).suspended;
      case TripStatus.accepted:
        return S.of(context).currentTrips;
      default:
        return S.of(context).currentTrips;
    }
  }

  IconData get _statusIcon {
    switch (trip.status) {
      case TripStatus.completed:
        return Icons.check_circle_rounded;
      case TripStatus.canceled:
      case TripStatus.closed:
        return Icons.cancel_rounded;
      case TripStatus.suspended:
        return Icons.pause_circle_filled_rounded;
      default:
        return Icons.directions_car_rounded;
    }
  }

  void _makePhoneCall(String phone) async {
    if (phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isShared = trip.type == TripType.shared;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 1. Top Status & Type Banner Card ────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _statusColor.withOpacity(0.25), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_statusIcon, color: _statusColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        _statusLabel(context),
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _statusColor,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isShared ? S.of(context).sharedTrip : S.of(context).privateTrip,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── 2. Route & Location Details Card ────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.route_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      S.of(context).routePath,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 4),
                        Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 38,
                          color: Colors.grey.shade300,
                        ),
                        Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).startingLocation,
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          Text(
                            trip.fromLocationName.isNotEmpty
                                ? trip.fromLocationName
                                : S.of(context).originLocation,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            S.of(context).destinationLocation,
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          Text(
                            trip.toLocationName.isNotEmpty
                                ? trip.toLocationName
                                : S.of(context).destinationLocation,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
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
          const SizedBox(height: 16),

          // ── 3. Date, Time & Specifications Card ─────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.calendar_today_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  title: S.of(context).tripDate,
                  value: _formattedDate,
                ),
                const Divider(height: 20),
                _buildInfoRow(
                  icon: Icons.access_time_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  title: S.of(context).tripTime,
                  value: _formattedTime,
                ),
                if (isShared) ...[
                  const Divider(height: 20),
                  _buildInfoRow(
                    icon: Icons.airline_seat_recline_normal_rounded,
                    iconColor: const Color(0xFF8B5CF6),
                    title: S.of(context).numberOfSeats,
                    value: S.of(context).seatsCount(trip.numberOfSeats),
                  ),
                ],
                const Divider(height: 20),
                _buildInfoRow(
                  icon: Icons.people_outline_rounded,
                  iconColor: const Color(0xFFEC4899),
                  title: S.of(context).genderPreference,
                  value: trip.genderPreference == GenderPreference.male
                      ? S.of(context).male
                      : (trip.genderPreference == GenderPreference.female
                          ? S.of(context).female
                          : S.of(context).noPreference),
                ),
                if (trip.tripDetails != null && trip.tripDetails!.isNotEmpty) ...[
                  const Divider(height: 20),
                  _buildInfoRow(
                    icon: Icons.notes_rounded,
                    iconColor: const Color(0xFF64748B),
                    title: S.of(context).additionalNotes,
                    value: trip.tripDetails!,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── 4. Driver / Passenger Info (if available) ───────────
          if (!isDriver && _driverName.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: appCachedImageProvider(ApiEndpoints.buildImageUrl(trip.driver?.photo)),
                    child: (trip.driver?.photo == null ||
                            ApiEndpoints.buildImageUrl(trip.driver!.photo) == null)
                        ? const Icon(Icons.person_rounded, color: AppColors.primary, size: 28)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).driverLabel,
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        Text(
                          _driverName,
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        if (trip.driver?.car != null)
                          Text(
                            '${trip.driver!.car!.type} ${trip.driver!.car!.model} (${trip.driver!.car!.plateNumber})'.trim(),
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_driverPhone.isNotEmpty)
                    IconButton(
                      onPressed: () => _makePhoneCall(_driverPhone),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.phone_rounded, color: Color(0xFF10B981), size: 20),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ] else if (isDriver && _creatorName.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: appCachedImageProvider(ApiEndpoints.buildImageUrl(trip.creator?.photo)),
                    child: (trip.creator?.photo == null ||
                            ApiEndpoints.buildImageUrl(trip.creator!.photo) == null)
                        ? const Icon(Icons.person_rounded, color: AppColors.primary, size: 28)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).passengerCreatorLabel,
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        Text(
                          _creatorName,
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_creatorPhone.isNotEmpty)
                    IconButton(
                      onPressed: () => _makePhoneCall(_creatorPhone),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.phone_rounded, color: Color(0xFF10B981), size: 20),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Passengers List (Shared Trips) ──────────────────────
          if (trip.passengers.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.group_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        S.of(context).joinedPassengersTitle(trip.passengers.length),
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: trip.passengers.length,
                    separatorBuilder: (_, __) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final p = trip.passengers[index];
                      return Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.grey.shade100,
                            backgroundImage: appCachedImageProvider(ApiEndpoints.buildImageUrl(p.photo)),
                            child: (p.photo == null ||
                                    ApiEndpoints.buildImageUrl(p.photo) == null)
                                ? Text(
                                    p.name.isNotEmpty ? p.name[0] : 'U',
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                if (p.seats > 0)
                                  Text(
                                    S.of(context).reservedSeatsCount(p.seats),
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (p.phone != null && p.phone!.isNotEmpty)
                            IconButton(
                              onPressed: () => _makePhoneCall(p.phone!),
                              icon: const Icon(Icons.phone_outlined, color: Color(0xFF10B981), size: 18),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── 5. Fare Summary Card ────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).tripPrice,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  '$_totalPrice ${S.of(context).jod}',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // ── Optional Bottom Action (e.g. Cancel on Suspended) ───
          if (bottomAction != null) ...[
            const SizedBox(height: 24),
            bottomAction!,
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}
