import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../widgets/dragon_background.dart';
import '../widgets/toothless_eyes_painter.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _titleController;
  late final AnimationController _eyeController;
  late final AnimationController _glowController;
  late final AnimationController _exitController;

  late final Animation<double> _titleOpacity;
  late final Animation<double> _eyeOpenAmount;
  late final Animation<double> _glowPulse;
  late final Animation<double> _exitFade;

  @override
  void initState() {
    super.initState();

    // Title fades in briefly first.
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _titleOpacity = CurvedAnimation(parent: _titleController, curve: Curves.easeIn);

    // Eyes slowly open over 2.5s.
    _eyeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _eyeOpenAmount = CurvedAnimation(parent: _eyeController, curve: Curves.easeOutCubic);

    // Continuous glow pulse.
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _glowPulse = Tween<double>(begin: 0.55, end: 1.0)
        .animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));

    // Fade whole splash out into dashboard.
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _exitFade = CurvedAnimation(parent: _exitController, curve: Curves.easeInOut);

    _runSequence();
  }

  Future<void> _runSequence() async {
    await _titleController.forward();
    await Future.delayed(const Duration(milliseconds: 300));

    // Quick startled blink-flicker before the eyes settle fully open.
    await _eyeController.animateTo(0.14, duration: const Duration(milliseconds: 180));
    await _eyeController.animateTo(0.0, duration: const Duration(milliseconds: 120));
    await Future.delayed(const Duration(milliseconds: 180));

    await _eyeController.animateTo(1.0, duration: const Duration(milliseconds: 2200));
    await Future.delayed(const Duration(milliseconds: 600));
    await _exitController.forward();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, anim, __) => const DashboardScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _eyeController.dispose();
    _glowController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: Listenable.merge(
            [_titleController, _eyeController, _glowController, _exitController]),
        builder: (context, _) {
          // Dragon silhouette fades in behind the eyes as they open, so the
          // full head seems to emerge from total darkness along with them.
          final silhouetteOpacity = 0.10 * _eyeOpenAmount.value;

          return Opacity(
            opacity: 1 - _exitFade.value,
            child: DragonBackground(
              silhouetteOpacity: silhouetteOpacity,
              scaleOpacity: 0.02 * _eyeOpenAmount.value,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Large, full-width eye stage — the dramatic "waking up"
                    // moment fills most of the screen instead of a small box.
                    SizedBox(
                      width: double.infinity,
                      height: 220,
                      child: CustomPaint(
                        painter: ToothlessEyesPainter(
                          openAmount: _eyeOpenAmount.value,
                          glowIntensity: _glowPulse.value * _eyeOpenAmount.value,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Opacity(
                      opacity: _titleOpacity.value,
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [AppColors.neonGreen, AppColors.plasmaCyan],
                        ).createShader(bounds),
                        child: Text(
                          'BLACK FURY',
                          style: GoogleFonts.orbitron(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 6,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Opacity(
                      opacity: _titleOpacity.value * 0.8,
                      child: Text(
                        'NIGHT FURY VEHICLE SYSTEM',
                        style: GoogleFonts.orbitron(
                          fontSize: 11,
                          letterSpacing: 3,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
