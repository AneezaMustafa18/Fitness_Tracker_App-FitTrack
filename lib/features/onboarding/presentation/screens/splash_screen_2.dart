import 'dart:math' as math;

import 'package:fitness_tracker_app/app/themes/app_colors.dart';
import 'package:fitness_tracker_app/core/constant/app_assets.dart';
import 'package:flutter/material.dart';

import 'splash_screen_3.dart';

class SplashScreen2 extends StatefulWidget {
  const SplashScreen2({super.key});

  @override
  State<SplashScreen2> createState() => _SplashScreen2State();
}

class _SplashScreen2State extends State<SplashScreen2>
    with TickerProviderStateMixin {
  // ============================================================
  // ANIMATION CONTROLLERS
  // ============================================================

  late final AnimationController _glowController;
  late final AnimationController _orbitController;

  // ============================================================
  // SWIPE
  // ============================================================

  double _dragStartX = 0;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _glowController.dispose();
    _orbitController.dispose();

    super.dispose();
  }

  // ============================================================
  // GO TO SPLASH 3
  // ============================================================

  void _goToSplash3() {
    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SplashScreen3(),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,

          onHorizontalDragStart: (details) {
            _dragStartX = details.globalPosition.dx;
          },

          onHorizontalDragEnd: (details) {
            final endX = details.globalPosition.dx;
            final distance = _dragStartX - endX;

            if (distance >= 60) {
              _goToSplash3();
            }
          },

          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final screenHeight = constraints.maxHeight;

              // ==================================================
              // RESPONSIVE SCALE
              //
              // Reference: 293 x 518
              //
              // Increased minimum scale so the visual does not
              // become too small on smaller mobile screens.
              // ==================================================

              final widthScale = screenWidth / 293.0;
              final heightScale = screenHeight / 518.0;

              final scale = math.min(
                widthScale,
                heightScale,
              ).clamp(0.98, 1.45);

              // ==================================================
              // MAIN VISUAL SIZE
              //
              // Increased from 240 -> 270
              // Maximum increased from 255 -> 315
              // ==================================================

              final visualDiameter =
              (270.0 * scale).clamp(
                245.0,
                315.0,
              );

              // ==================================================
              // METRIC CIRCLE SIZE
              //
              // Increased so Calories / Steps / Heart Rate /
              // Progress don't look tiny around the main visual.
              // ==================================================

              final metricSize =
              (54.0 * scale).clamp(
                48.0,
                64.0,
              );

              // ==================================================
              // COMPLETE VISUAL HEIGHT
              //
              // Increased according to the larger visual.
              // ==================================================

              final visualHeight =
              (350.0 * scale).clamp(
                320.0,
                455.0,
              );

              // ==================================================
              // TITLE
              // ==================================================

              final titleSize =
              (20.0 * scale).clamp(
                18.0,
                23.0,
              );

              // ==================================================
              // DESCRIPTION
              // ==================================================

              final descriptionSize =
              (13.0 * scale).clamp(
                12.0,
                15.0,
              );

              return Column(
                children: [
                  // ==================================================
                  // TOP SPACE
                  // ==================================================

                  SizedBox(
                    height: (18.0 * scale).clamp(
                      14.0,
                      26.0,
                    ),
                  ),

                  // ==================================================
                  // FITNESS VISUAL
                  // ==================================================

                  SizedBox(
                    width: screenWidth,
                    height: visualHeight,
                    child: _buildFitnessVisual(
                      diameter: visualDiameter,
                      metricSize: metricSize,
                    ),
                  ),

                  // ==================================================
                  // GAP
                  // ==================================================

                  SizedBox(
                    height: (12.0 * scale).clamp(
                      8.0,
                      16.0,
                    ),
                  ),

                  // ==================================================
                  // TITLE
                  // ==================================================

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _responsiveHorizontalPadding(
                        screenWidth,
                      ),
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Track. ',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: titleSize,
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                            ),
                          ),
                          TextSpan(
                            text: 'Analyze. ',
                            style: TextStyle(
                              color: AppColors.glowBlue,
                              fontSize: titleSize,
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                            ),
                          ),
                          TextSpan(
                            text: 'Achieve.',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: titleSize,
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                    ),
                  ),

                  // ==================================================
                  // GAP
                  // ==================================================

                  SizedBox(
                    height: (10.0 * scale).clamp(
                      6.0,
                      13.0,
                    ),
                  ),

                  // ==================================================
                  // DESCRIPTION
                  // ==================================================

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _responsiveHorizontalPadding(
                        screenWidth,
                      ),
                    ),
                    child: Text(
                      'All your fitness data in one place.\n'
                          'Understand your progress and\n'
                          'achieve your goals.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: descriptionSize,
                        fontWeight: FontWeight.w400,
                        height: 1.42,
                      ),
                    ),
                  ),

                  // ==================================================
                  // REMAINING SPACE
                  // ==================================================

                  const Spacer(),

                  // ==================================================
                  // PAGE INDICATORS
                  // ==================================================

                  _buildIndicators(),

                  // ==================================================
                  // BOTTOM SPACE
                  // ==================================================

                  SizedBox(
                    height: (20.0 * scale).clamp(
                      16.0,
                      28.0,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // RESPONSIVE HORIZONTAL PADDING
  // ============================================================

  double _responsiveHorizontalPadding(double width) {
    if (width <= 320) {
      return 12;
    }

    if (width <= 390) {
      return 16;
    }

    return 20;
  }

  // ============================================================
  // FITNESS VISUAL
  // ============================================================

  Widget _buildFitnessVisual({
    required double diameter,
    required double metricSize,
  }) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _glowController,
        _orbitController,
      ]),
      builder: (context, child) {
        final screenWidth = MediaQuery.sizeOf(context).width;

        // ======================================================
        // CENTER X
        // ======================================================

        final centerX = screenWidth / 2;

        // ======================================================
        // CENTER Y
        //
        // Adjusted according to the bigger visual.
        // ======================================================

        final centerY =
            155.0 * (diameter / 270.0);

        // ======================================================
        // RING POSITION
        // ======================================================

        final ringLeft =
            centerX - diameter / 2;

        final ringTop =
            centerY - diameter / 2;

        // ======================================================
        // GLOW
        // ======================================================

        final glow =
            0.08 +
                (_glowController.value * 0.12);

        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // ==================================================
            // CIRCULAR RINGS
            // ==================================================

            Positioned(
              left: ringLeft,
              top: ringTop,
              child: SizedBox(
                width: diameter,
                height: diameter,
                child: CustomPaint(
                  painter: _OrbitPainter(
                    rotation: _orbitController.value,
                    glow: glow,
                  ),
                ),
              ),
            ),

            // ==================================================
            // CENTER CIRCLE
            // ==================================================

            Positioned(
              left:
              centerX -
                  diameter * 0.235,
              top:
              centerY -
                  diameter * 0.235,
              child: Container(
                width: diameter * 0.47,
                height: diameter * 0.47,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkBackground,
                  border: Border.all(
                    color: AppColors.glowBlue.withValues(
                      alpha: 0.78,
                    ),
                    width: 1.3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.glowBlue.withValues(
                        alpha: glow,
                      ),
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),

            // ==================================================
            // EXACT APP LOGO
            // ==================================================

            Positioned(
              left:
              centerX -
                  diameter * 0.175,
              top:
              centerY -
                  diameter * 0.175,
              child: SizedBox(
                width: diameter * 0.35,
                height: diameter * 0.35,
                child: Image.asset(
                  AppAssets.logo,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // ==================================================
            // CALORIES
            // ==================================================

            Positioned(
              left:
              centerX -
                  metricSize / 2,
              top: 0,
              child: _buildMetric(
                size: metricSize,
                icon: Icons.local_fire_department_rounded,
                label: 'Calories',
              ),
            ),

            // ==================================================
            // STEPS
            // ==================================================

            Positioned(
              left:
              centerX -
                  diameter / 2 -
                  metricSize * 0.28,
              top:
              centerY -
                  metricSize / 2,
              child: _buildMetric(
                size: metricSize,
                icon: Icons.directions_walk_rounded,
                label: 'Steps',
              ),
            ),

            // ==================================================
            // HEART RATE
            // ==================================================

            Positioned(
              left:
              centerX +
                  diameter / 2 -
                  metricSize * 0.72,
              top:
              centerY -
                  metricSize / 2,
              child: _buildMetric(
                size: metricSize,
                icon: Icons.favorite_rounded,
                label: 'Heart Rate',
              ),
            ),

            // ==================================================
            // PROGRESS
            // ==================================================

            Positioned(
              left:
              centerX -
                  metricSize / 2,
              top:
              ringTop +
                  diameter -
                  metricSize * 0.30,
              child: _buildMetric(
                size: metricSize,
                icon: Icons.bar_chart_rounded,
                label: 'Progress',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // METRIC WIDGET
  // ============================================================

  Widget _buildMetric({
    required double size,
    required IconData icon,
    required String label,
  }) {
    return SizedBox(
      width: size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ======================================================
          // CIRCLE
          // ======================================================

          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.darkBackground,
              border: Border.all(
                color: AppColors.glowBlue.withValues(
                  alpha: 0.72,
                ),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.glowBlue.withValues(
                    alpha: 0.10,
                  ),
                  blurRadius: 14,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: AppColors.glowBlue,
              size: size * 0.48,
            ),
          ),

          // ======================================================
          // LABEL GAP
          // ======================================================

          SizedBox(
            height: size * 0.08,
          ),

          // ======================================================
          // LABEL
          // ======================================================

          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
            style: TextStyle(
              color: AppColors.white,
              fontSize: (size * 0.18).clamp(
                9.0,
                11.0,
              ),
              fontWeight: FontWeight.w400,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAGE INDICATORS
  // ============================================================

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIndicator(false),

        const SizedBox(
          width: 10,
        ),

        _buildIndicator(true),

        const SizedBox(
          width: 10,
        ),

        _buildIndicator(false),
      ],
    );
  }

  // ============================================================
  // SINGLE INDICATOR
  // ============================================================

  Widget _buildIndicator(bool active) {
    return AnimatedContainer(
      duration: const Duration(
        milliseconds: 250,
      ),
      curve: Curves.easeOut,
      width: active ? 17 : 12,
      height: 4,
      decoration: BoxDecoration(
        color: active
            ? AppColors.glowBlue
            : AppColors.primaryBlue.withValues(
          alpha: 0.30,
        ),
        borderRadius: BorderRadius.circular(
          20,
        ),
      ),
    );
  }
}

// ==================================================================
// ORBIT PAINTER
// ==================================================================

class _OrbitPainter extends CustomPainter {
  final double rotation;
  final double glow;

  const _OrbitPainter({
    required this.rotation,
    required this.glow,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    // ============================================================
    // CENTER
    // ============================================================

    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    // ============================================================
    // RING RADII
    // ============================================================

    final outerRadius =
        size.width * 0.475;

    final middleRadius =
        size.width * 0.375;

    final innerRadius =
        size.width * 0.285;

    // ============================================================
    // OUTER RING
    // ============================================================

    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.glowBlue.withValues(
        alpha: 0.20,
      );

    // ============================================================
    // MIDDLE RING
    // ============================================================

    final middlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.glowBlue.withValues(
        alpha: 0.24,
      );

    // ============================================================
    // INNER RING
    // ============================================================

    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.glowBlue.withValues(
        alpha: 0.32,
      );

    // ============================================================
    // DRAW RINGS
    // ============================================================

    canvas.drawCircle(
      center,
      outerRadius,
      outerPaint,
    );

    canvas.drawCircle(
      center,
      middleRadius,
      middlePaint,
    );

    canvas.drawCircle(
      center,
      innerRadius,
      innerPaint,
    );

    // ============================================================
    // ROTATION
    // ============================================================

    final fullRotation =
        rotation * math.pi * 2;

    // ============================================================
    // OUTER ORBIT DOTS
    // ============================================================

    _drawDot(
      canvas,
      center,
      outerRadius,
      fullRotation,
      4,
    );

    _drawDot(
      canvas,
      center,
      outerRadius,
      fullRotation + math.pi * 0.66,
      4,
    );

    _drawDot(
      canvas,
      center,
      outerRadius,
      fullRotation + math.pi * 1.34,
      4,
    );

    // ============================================================
    // MIDDLE ORBIT DOTS
    // ============================================================

    _drawDot(
      canvas,
      center,
      middleRadius,
      -fullRotation + math.pi * 0.30,
      3.5,
    );

    _drawDot(
      canvas,
      center,
      middleRadius,
      -fullRotation + math.pi * 1.30,
      3.5,
    );

    // ============================================================
    // SUBTLE GLOW
    // ============================================================

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.glowBlue.withValues(
        alpha: 0.05 + glow * 0.10,
      );

    canvas.drawCircle(
      center,
      outerRadius,
      glowPaint,
    );
  }

  // ============================================================
  // DRAW ORBIT DOT
  // ============================================================

  void _drawDot(
      Canvas canvas,
      Offset center,
      double radius,
      double angle,
      double size,
      ) {
    final position = Offset(
      center.dx +
          radius * math.cos(angle),
      center.dy +
          radius * math.sin(angle),
    );

    final paint = Paint()
      ..color = AppColors.glowBlue
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      position,
      size / 2,
      paint,
    );
  }

  // ============================================================
  // REPAINT
  // ============================================================

  @override
  bool shouldRepaint(
      covariant _OrbitPainter oldDelegate,
      ) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.glow != glow;
  }
}