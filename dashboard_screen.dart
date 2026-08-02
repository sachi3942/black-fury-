import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/vehicle_data.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fuel_gauge.dart';
import '../widgets/glass_card.dart';
import '../widgets/gps_tracker_card.dart';
import '../widgets/ignition_toggle.dart';
import '../widgets/status_badge.dart';
import '../widgets/thief_alert_dialog.dart';
import '../widgets/trip_metrics_grid.dart';
import '../widgets/dragon_background.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseService _firebase = FirebaseService();

  VehicleData _data = VehicleData.empty();
  bool _isLocked = true; // conservative default until first read
  bool _isConnected = false;
  bool _isSendingRelay = false;
  bool _thiefDialogShowing = false;

  StreamSubscription<VehicleData>? _dataSub;
  StreamSubscription<bool>? _thiefSub;
  StreamSubscription<bool>? _connSub;

  @override
  void initState() {
    super.initState();

    _dataSub = _firebase.dataStream.listen((data) {
      if (!mounted) return;
      setState(() => _data = data);
    });

    _connSub = _firebase.connectionStream.listen((connected) {
      if (!mounted) return;
      setState(() => _isConnected = connected);
    });

    _thiefSub = _firebase.thiefAlertStream.listen((isThief) {
      if (isThief && !_thiefDialogShowing) {
        _thiefDialogShowing = true;
        showThiefAlertDialog(
          context,
          onAcknowledge: () async {
            await _firebase.clearThiefAlert();
          },
        ).then((_) {
          _thiefDialogShowing = false;
        });
      }
    });

    _firebase.startPolling();
  }

  @override
  void dispose() {
    _dataSub?.cancel();
    _thiefSub?.cancel();
    _connSub?.cancel();
    _firebase.dispose();
    super.dispose();
  }

  Future<void> _handleRelayChange(bool wantsLocked) async {
    setState(() => _isSendingRelay = true);
    final success = await _firebase.setRelay(locked: wantsLocked);
    if (!mounted) return;
    setState(() {
      _isSendingRelay = false;
      if (success) _isLocked = wantsLocked;
    });
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send command. Check connection.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: DragonBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => _firebase.startPolling(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
              children: [
                _Header(isConnected: _isConnected),
                const SizedBox(height: 18),
                Center(child: StatusBadge(isLocked: _isLocked)),
                const SizedBox(height: 20),
                IgnitionToggle(
                  isLocked: _isLocked,
                  isSending: _isSendingRelay,
                  onChanged: _handleRelayChange,
                ),
                const SizedBox(height: 20),
                Center(child: FuelGauge(fuelPercent: _data.fuelPercent)),
                const SizedBox(height: 20),
                TripMetricsGrid(
                  tripDistKm: _data.tripDistKm,
                  tripFuelLiters: _data.tripFuelLiters,
                ),
                const SizedBox(height: 20),
                GpsTrackerCard(
                  lat: _data.lat,
                  lng: _data.lng,
                  hasValidLocation: _data.hasValidLocation,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool isConnected;

  const _Header({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: AppColors.neonGreen.withOpacity(0.35),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neonGreen.withOpacity(0.12),
              border: Border.all(color: AppColors.neonGreen, width: 1.4),
              boxShadow: neonGlow(AppColors.neonGreen, blur: 14, spread: -2),
            ),
            child: const Icon(Icons.dark_mode_rounded, color: AppColors.neonGreen),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'BLACK FURY',
              style: GoogleFonts.orbitron(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isConnected ? AppColors.neonGreen : AppColors.crimson,
                  boxShadow: neonGlow(
                    isConnected ? AppColors.neonGreen : AppColors.crimson,
                    blur: 8,
                    spread: 0,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isConnected ? 'LIVE' : 'OFFLINE',
                style: TextStyle(
                  fontSize: 11,
                  color: isConnected ? AppColors.neonGreen : AppColors.crimson,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
