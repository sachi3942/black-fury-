import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';
import 'glass_card.dart';

class GpsTrackerCard extends StatelessWidget {
  final double lat;
  final double lng;
  final bool hasValidLocation;

  const GpsTrackerCard({
    super.key,
    required this.lat,
    required this.lng,
    required this.hasValidLocation,
  });

  Future<void> _launchMaps(BuildContext context) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: AppColors.plasmaCyan.withOpacity(0.45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.plasmaCyan, size: 22),
              const SizedBox(width: 8),
              Text(
                'GPS TRACKER',
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  letterSpacing: 2,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _CoordTile(label: 'LAT', value: lat.toStringAsFixed(6)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CoordTile(label: 'LNG', value: lng.toStringAsFixed(6)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: hasValidLocation ? () => _launchMaps(context) : null,
              icon: const Icon(Icons.map_rounded),
              label: const Text('TRACK BIKE ON GOOGLE MAPS'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.plasmaCyan.withOpacity(0.15),
                foregroundColor: AppColors.plasmaCyan,
                side: const BorderSide(color: AppColors.plasmaCyan, width: 1.3),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: GoogleFonts.orbitron(fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoordTile extends StatelessWidget {
  final String label;
  final String value;

  const _CoordTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: AppColors.textMuted, letterSpacing: 1)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
