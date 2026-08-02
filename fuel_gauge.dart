import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/app_config.dart';
import '../theme/app_theme.dart';

class FuelGauge extends StatelessWidget {
  final double fuelPercent; // 0-100

  const FuelGauge({super.key, required this.fuelPercent});

  Color get _fuelColor {
    if (fuelPercent <= 15) return AppColors.crimson;
    if (fuelPercent <= 40) return AppColors.plasmaCyan;
    return AppColors.neonGreen;
  }

  @override
  Widget build(BuildContext context) {
    final clamped = fuelPercent.clamp(0, 100).toDouble();
    final remainingLiters = AppConfig.tankCapacityLiters * (clamped / 100);
    final remainingKm = remainingLiters * AppConfig.kmPerLiter;

    return SizedBox(
      width: 210,
      height: 210,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 210,
            height: 210,
            child: CircularProgressIndicator(
              value: clamped / 100,
              strokeWidth: 14,
              backgroundColor: Colors.white.withOpacity(0.06),
              valueColor: AlwaysStoppedAnimation<Color>(_fuelColor),
              strokeCap: StrokeCap.round,
            ),
          ),
          Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: neonGlow(_fuelColor, blur: 30, spread: -6),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${clamped.toStringAsFixed(0)}%',
                style: GoogleFonts.orbitron(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: _fuelColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'FUEL LEVEL',
                style: GoogleFonts.orbitron(
                  fontSize: 11,
                  letterSpacing: 2,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '~${remainingKm.toStringAsFixed(0)} km range',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
