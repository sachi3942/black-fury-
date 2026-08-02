import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// Shows an un-dismissible, flashing red alert dialog for thief detection.
/// Returns when the user explicitly acknowledges it via [onAcknowledge].
Future<void> showThiefAlertDialog(
  BuildContext context, {
  required Future<void> Function() onAcknowledge,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black87,
    useRootNavigator: true,
    builder: (context) => PopScope(
      canPop: false,
      child: _FlashingThiefDialog(onAcknowledge: onAcknowledge),
    ),
  );
}

class _FlashingThiefDialog extends StatefulWidget {
  final Future<void> Function() onAcknowledge;

  const _FlashingThiefDialog({required this.onAcknowledge});

  @override
  State<_FlashingThiefDialog> createState() => _FlashingThiefDialogState();
}

class _FlashingThiefDialogState extends State<_FlashingThiefDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flashController;
  bool _acknowledging = false;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  Future<void> _handleAcknowledge() async {
    setState(() => _acknowledging = true);
    await widget.onAcknowledge();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flashController,
      builder: (context, _) {
        final t = _flashController.value;
        final glowColor = Color.lerp(
          AppColors.crimson.withOpacity(0.5),
          AppColors.crimson,
          t,
        )!;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: glowColor, width: 2.4),
              boxShadow: neonGlow(glowColor, blur: 28, spread: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber_rounded, color: glowColor, size: 56),
                const SizedBox(height: 16),
                Text(
                  '🚨 WARNING',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.orbitron(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: glowColor,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'UNFAIR VEHICLE MOVEMENT DETECTED!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _acknowledging ? null : _handleAcknowledge,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: glowColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _acknowledging
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.black,
                            ),
                          )
                        : Text(
                            'ACKNOWLEDGE & SECURE VEHICLE',
                            style: GoogleFonts.orbitron(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
