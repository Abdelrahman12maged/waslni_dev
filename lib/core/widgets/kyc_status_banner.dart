import 'package:flutter/material.dart';
import 'package:car_app/generated/l10n.dart';

class KycStatusBanner extends StatelessWidget {
  final String status; // 'pending' | 'rejected' | 'approved'
  final VoidCallback? onUpdateProfileTap;

  const KycStatusBanner({
    super.key,
    required this.status,
    this.onUpdateProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    if (status == 'approved' || status.isEmpty) return const SizedBox.shrink();

    final isPending = status == 'pending' || status == 'under_review';
    final bgColor = isPending ? Colors.amber.shade100 : Colors.red.shade100;
    final borderColor = isPending ? Colors.amber.shade700 : Colors.red.shade700;
    final textColor = isPending ? Colors.amber.shade900 : Colors.red.shade900;
    final icon = isPending ? Icons.hourglass_top_rounded : Icons.gavel_rounded;
    final message = isPending
        ? S.of(context).kycUnderReview
        : S.of(context).kycRejected;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPending ? S.of(context).kycUnderReviewTitle : S.of(context).kycRejectedTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withValues(alpha: 0.9),
                  ),
                ),
                if (!isPending && onUpdateProfileTap != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onUpdateProfileTap,
                    child: Text(
                      S.of(context).updateDataAndDocs,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: textColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
