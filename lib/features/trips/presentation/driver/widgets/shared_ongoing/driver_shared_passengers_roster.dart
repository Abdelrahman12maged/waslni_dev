import 'package:flutter/material.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/generated/l10n.dart';

/// Clean, focused component displaying the list of passengers in an ongoing shared trip.
class DriverPassengersRosterCard extends StatelessWidget {
  final List passengers;
  final int totalSeats;
  final int driverId;
  final Function(String phone) onCallPassenger;

  const DriverPassengersRosterCard({
    super.key,
    required this.passengers,
    required this.totalSeats,
    this.driverId = 0,
    required this.onCallPassenger,
  });

  @override
  Widget build(BuildContext context) {
    final actualPassengers = passengers.where((p) {
      if (p is! Map) return false;
      final pid = int.tryParse((p['id'] ??
                  p['passenger_id'] ??
                  p['user_id'] ??
                  p['passenger']?['id'])
              ?.toString() ??
          '') ??
          0;
      final userType = (p['user_type'] ?? p['passenger']?['user_type'])
          ?.toString()
          .toLowerCase();
      if (userType == 'driver') return false;
      if (driverId > 0 && pid == driverId) return false;
      return true;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).currentPassengers,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${actualPassengers.length} ${S.of(context).passengers}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (actualPassengers.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  S.of(context).noOtherPassengers,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ),
            )
          else
            ...actualPassengers.map((p) {
              final name = p['passenger']?['name']?.toString() ??
                  p['name']?.toString() ??
                  S.of(context).passengerDefaultName;
              final phone = p['passenger']?['phone']?.toString() ??
                  p['passenger']?['mobile']?.toString() ??
                  p['phone']?.toString() ??
                  p['mobile']?.toString() ??
                  '';
              final seats = p['seats'] ?? p['pivot']?['seats'] ?? 1;

              return Container(
                margin: const EdgeInsets.only(bottom: 8.0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(Icons.person,
                          size: 18, color: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '$seats ${S.of(context).seatsUnit}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (phone.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Text(
                                  phone,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (phone.isNotEmpty)
                      IconButton(
                        onPressed: () => onCallPassenger(phone),
                        icon: const Icon(Icons.phone_rounded,
                            color: Color(0xFF05A357), size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 32, minHeight: 32),
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
