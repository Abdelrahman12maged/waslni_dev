import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/generated/l10n.dart';

/// Modal dialog for driver canceling an ongoing shared trip with optional reason.
void showDriverCancelSharedTripDialog({
  required BuildContext context,
  required Function(String reason) onConfirmCancel,
}) {
  final reasonController = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        S.of(context).cancelSharedTripCompletely,
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.bold,
          color: Colors.red[700],
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).cancelSharedTripEjectAllConfirmMessage,
            style: GoogleFonts.cairo(fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: reasonController,
            decoration: InputDecoration(
              hintText: S.of(context).cancellationReasonOptional,
              hintStyle: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            style: GoogleFonts.cairo(fontSize: 13),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(
            S.of(context).no,
            style: GoogleFonts.cairo(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            Navigator.pop(ctx);
            onConfirmCancel(reasonController.text.trim());
          },
          child: Text(
            S.of(context).cancelTripEntirely,
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}
