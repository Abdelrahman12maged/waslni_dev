import 'package:flutter/material.dart';
import 'package:car_app/generated/l10n.dart';

/// Price display card for passenger private trip.
class PassengerPrivatePriceCard extends StatelessWidget {
  final String price;

  const PassengerPrivatePriceCard({
    super.key,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.payments_outlined,
              color: Color(0xFF276EF1), size: 20),
          const SizedBox(width: 10),
          Text(
            S.of(context).price,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            '$price ${S.of(context).jod}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}
