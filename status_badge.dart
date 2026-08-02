import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final bool isLocked;

  const StatusBadge({super.key, required this.isLocked});

  @override
  Widget build(BuildContext context) {
    final color = isLocked ? AppColors.crimson : AppColors.neonGreen;
    final label = isLocked ? 'LOCKED' : 'UNLOCKED';
    final icon = isLocked ? Icons.lock_rounded : Icons.lock_open_rounded;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color, width: 1.4),
        boxShadow: neonGlow(color, blur: 16, spread: -1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.orbitron(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
