import 'package:car_app/core/utils/location_helper.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:flutter/material.dart';

/// Compact card for displaying a trip in a list.
/// Used in trips_list_screen and available_trips_screen.
class TripCardWidget extends StatelessWidget {
  const TripCardWidget({
    super.key,
    required this.trip,
    required this.onTap,
    this.trailing,
  });

  final Trip trip;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Status Badge ────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatusBadge(status: trip.status),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: 12),

              // ── From ─────────────────────────────────────────────────────
              _LocationRow(
                icon: Icons.radio_button_checked,
                color: Colors.green,
                text: cleanLocationName(trip.fromLocationName),
                label: S.of(context).chatFrom,
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(right: 9),
                child: Container(
                  width: 2,
                  height: 20,
                  color: Colors.grey.shade300,
                ),
              ),
              const SizedBox(height: 4),

              // ── To ───────────────────────────────────────────────────────
              _LocationRow(
                icon: Icons.location_on,
                color: Colors.red,
                text: cleanLocationName(trip.toLocationName),
                label: S.of(context).chatTo,
              ),
              const SizedBox(height: 12),

              // ── Meta row ─────────────────────────────────────────────────
              Row(
                children: [
                  _MetaChip(
                    icon: Icons.event_seat,
                    label: '${trip.numberOfSeats} ${S.of(context).seats}',
                  ),
                  const SizedBox(width: 8),
                  _MetaChip(
                    icon: Icons.access_time,
                    label: _formatDateTime(trip.tripDatetime),
                  ),
                  if (trip.approvedPrice != null) ...[
                    const SizedBox(width: 8),
                    _MetaChip(
                      icon: Icons.attach_money,
                      label: '${trip.approvedPrice!.toStringAsFixed(0)} ₪',
                      color: Colors.green,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(String raw) {
    try {
      final str = raw.trim();
      if (str.isEmpty) return '';
      if (str.contains('T')) {
        final parts = str.split('T');
        final date = parts[0];
        final time = parts.length > 1 ? parts[1].split('.')[0].replaceAll('Z', '') : '';
        final timeShort = time.length >= 5 ? time.substring(0, 5) : time;
        return timeShort.isNotEmpty ? '$timeShort  $date' : date;
      }
      final parts = str.split(' ');
      if (parts.length < 2) return str;
      final date = parts[0];
      final timeParts = parts[1].split(':');
      return '${timeParts[0]}:${timeParts[1]}  $date';
    } catch (_) {
      return raw;
    }
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final TripStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      TripStatus.open => (S.of(context).statusOpen, Colors.blue),
      TripStatus.accepted => (S.of(context).statusAccepted, Colors.green),
      TripStatus.completed => (S.of(context).statusCompleted, Colors.teal),
      TripStatus.suspended => (S.of(context).statusSuspended, Colors.orange),
      TripStatus.canceled => (S.of(context).statusCanceled, Colors.red),
      TripStatus.closed => (S.of(context).statusClosed, Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.icon,
    required this.color,
    required this.text,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String text;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500)),
              Text(
                text,
                style: const TextStyle(fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label, this.color});
  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.grey.shade600;
    return Row(
      children: [
        Icon(icon, size: 14, color: c),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: c)),
      ],
    );
  }
}
