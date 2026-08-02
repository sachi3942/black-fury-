import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import 'glass_card.dart';

class TripMetricsGrid extends StatelessWidget {
  final double tripDistKm;
  final double tripFuelLiters;

  const TripMetricsGrid({
    super.key,
    required this.tripDistKm,
    required this.tripFuelLiters,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon: Icons.route_rounded,
            label: 'TRIP DISTANCE',
            value: '${tripDistKm.toStringAsFixed(1)} km',
            color: AppColors.plasmaCyan,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _MetricCard(
            icon: Icons.local_gas_station_rounded,
            label: 'TRIP FUEL USED',
            value: '${tripFuelLiters.toStringAsFixed(2)} L',
            color: AppColors.neonGreen,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: color.withOpacity(0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.orbitron(
              fontSize: 10,
              letterSpacing: 1.5,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
