import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RouteSimpleRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const RouteSimpleRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF22273B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
