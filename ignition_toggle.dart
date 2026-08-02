import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import 'glass_card.dart';

/// Ignition / relay remote toggle.
/// [isLocked] true means the vehicle is currently locked (relay = 1).
/// [onChanged] receives the new "locked" boolean the user is requesting.
class IgnitionToggle extends StatelessWidget {
  final bool isLocked;
  final bool isSending;
  final ValueChanged<bool> onChanged;

  const IgnitionToggle({
    super.key,
    required this.isLocked,
    required this.isSending,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = isLocked ? AppColors.crimson : AppColors.neonGreen;

    return GlassCard(
      borderColor: color.withOpacity(0.5),
      child: Row(
        children: [
          Icon(Icons.power_settings_new_rounded, color: color, size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IGNITION / RELAY',
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    letterSpacing: 2,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isLocked ? 'Tap to unlock vehicle' : 'Tap to lock vehicle',
                  style: TextStyle(color: AppColors.textPrimary.withOpacity(0.85)),
                ),
              ],
            ),
          ),
          isSending
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                )
              : Switch(
                  value: !isLocked, // ON = unlocked
                  onChanged: (unlocked) => onChanged(!unlocked),
                ),
        ],
      ),
    );
  }
}
