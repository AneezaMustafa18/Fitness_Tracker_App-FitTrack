import 'dart:async';

import 'package:fitness_tracker_app/app/themes/app_colors.dart';
import 'package:fitness_tracker_app/core/constant/app_assets.dart';
import 'package:flutter/material.dart';

import 'splash_screen_2.dart';

class SplashScreen1 extends StatefulWidget {
  const SplashScreen1({super.key});

  @override
  State<SplashScreen1> createState() => _SplashScreen1State();
}

class _SplashScreen1State extends State<SplashScreen1> {
  Timer? _typingTimer;
  Timer? _cursorTimer;

  String _fitnessText = '';
  String _trackerText = '';

  int _fitnessIndex = 0;
  int _trackerIndex = 0;

  bool _showCursor = true;

  // Used for finger swipe detection
  double _dragStartX = 0;

  static const double _designWidth = 239;
  static const double _designHeight = 435;

  @override
  void initState() {
    super.initState();

    _startTypingAnimation();
    _startCursorAnimation();
  }

  // ============================================================
  // TYPING ANIMATION
  // ============================================================

  void _startTypingAnimation() {
    _typingTimer?.cancel();

    _typingTimer = Timer.periodic(
      const Duration(milliseconds: 120),
          (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        // FITNESS
        if (_fitnessIndex < 'FITNESS'.length) {
          setState(() {
            _fitnessIndex++;
            _fitnessText =
                'FITNESS'.substring(0, _fitnessIndex);
          });
          return;
        }

        // TRACKER
        if (_trackerIndex < 'TRACKER'.length) {
          setState(() {
            _trackerIndex++;
            _trackerText =
                'TRACKER'.substring(0, _trackerIndex);
          });
          return;
        }

        timer.cancel();

        Future.delayed(
          const Duration(milliseconds: 1800),
              () {
            if (!mounted) return;

            setState(() {
              _fitnessText = '';
              _trackerText = '';

              _fitnessIndex = 0;
              _trackerIndex = 0;
            });

            _startTypingAnimation();
          },
        );
      },
    );
  }

  // ============================================================
  // CURSOR BLINK
  // ============================================================

  void _startCursorAnimation() {
    _cursorTimer?.cancel();

    _cursorTimer = Timer.periodic(
      const Duration(milliseconds: 500),
          (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        setState(() {
          _showCursor = !_showCursor;
        });
      },
    );
  }

  // ============================================================
  // GO TO SPLASH 2
  // ============================================================

  void _goToSplash2() {
    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SplashScreen2(),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _typingTimer?.cancel();
    _cursorTimer?.cancel();

    super.dispose();
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

          // ======================================================
          // FINGER DRAG START
          // ======================================================

          onHorizontalDragStart: (details) {
            _dragStartX = details.globalPosition.dx;
          },

          // ======================================================
          // FINGER DRAG END
          // ======================================================

          onHorizontalDragEnd: (details) {
            final dragEndX = details.globalPosition.dx;

            // Positive = finger moved from right → left
            final dragDistance = _dragStartX - dragEndX;

            // Only navigate when user actually swipes left
            if (dragDistance > 60) {
              _goToSplash2();
            }
          },

          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final screenHeight = constraints.maxHeight;

              // ==================================================
              // RESPONSIVE SCALE
              // ==================================================
              //
              // FIX: previously used min(scaleX, scaleY), i.e. "fit
              // inside" — on phones whose aspect ratio differs from
              // the design canvas that left visible empty bars on one
              // side. Using max(scaleX, scaleY) instead makes the
              // design COVER the full screen on every device (like
              // BoxFit.cover) with no gaps, same as the other splash
              // screens. Wrapped in ClipRect below so the (now
              // slightly larger than screen) content doesn't overflow
              // visibly.

              final scaleX = screenWidth / _designWidth;
              final scaleY = screenHeight / _designHeight;

              final scale = scaleX > scaleY ? scaleX : scaleY;

              final contentWidth = _designWidth * scale;
              final contentHeight = _designHeight * scale;

              return ClipRect(
                child: Center(
                  child: SizedBox(
                    width: contentWidth,
                    height: contentHeight,
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: SizedBox(
                        width: _designWidth,
                        height: _designHeight,
                        child: _buildDesign(),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SPLASH 1 DESIGN
  // ============================================================

  Widget _buildDesign() {
    return SizedBox(
      width: _designWidth,
      height: _designHeight,
      child: Stack(
        children: [
          // ======================================================
          // LOGO
          // ======================================================

          Positioned(
            left: 39,
            top: 45,
            width: 160,
            height: 160,
            child: _buildLogo(),
          ),

          // ======================================================
          // FITNESS
          // ======================================================

          Positioned(
            left: 0,
            right: 0,
            top: 223,
            height: 45,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _fitnessText,
                    maxLines: 1,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 39,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      height: 1,
                    ),
                  ),

                  if (_fitnessIndex > 0 &&
                      _fitnessIndex < 'FITNESS'.length)
                    _buildCursor(
                      AppColors.white,
                      fontSize: 39,
                    ),
                ],
              ),
            ),
          ),

          // ======================================================
          // TRACKER
          // ======================================================

          Positioned(
            left: 0,
            right: 0,
            top: 266,
            height: 40,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _trackerText,
                    maxLines: 1,
                    style: const TextStyle(
                      color: AppColors.glowBlue,
                      fontSize: 31,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      height: 1,
                    ),
                  ),

                  if (_fitnessIndex == 'FITNESS'.length &&
                      _trackerIndex > 0 &&
                      _trackerIndex < 'TRACKER'.length)
                    _buildCursor(
                      AppColors.glowBlue,
                      fontSize: 31,
                    ),
                ],
              ),
            ),
          ),

          // ======================================================
          // DESCRIPTION
          // ======================================================

          const Positioned(
            left: 15,
            right: 15,
            top: 316,
            child: Text(
              'Track your activities,\n'
                  'improve your health.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.45,
              ),
            ),
          ),

          // ======================================================
          // PAGE INDICATORS
          // ======================================================

          Positioned(
            left: 0,
            right: 0,
            top: 400,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIndicator(true),
                const SizedBox(width: 13),
                _buildIndicator(false),
                const SizedBox(width: 13),
                _buildIndicator(false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOGO
  // ============================================================

  Widget _buildLogo() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.glowBlue.withValues(
              alpha: 0.18,
            ),
            blurRadius: 22,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: AppColors.glowBlue.withValues(
              alpha: 0.08,
            ),
            blurRadius: 45,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Image.asset(
        AppAssets.logo,
        width: 160,
        height: 160,
        fit: BoxFit.contain,
      ),
    );
  }

  // ============================================================
  // CURSOR
  // ============================================================

  Widget _buildCursor(
      Color color, {
        required double fontSize,
      }) {
    return AnimatedOpacity(
      opacity: _showCursor ? 1 : 0,
      duration: const Duration(milliseconds: 100),
      child: Padding(
        padding: const EdgeInsets.only(left: 2),
        child: Text(
          '|',
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: FontWeight.w300,
            height: 1,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PAGE INDICATOR
  // ============================================================

  Widget _buildIndicator(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      width: active ? 17 : 12,
      height: 4,
      decoration: BoxDecoration(
        color: active
            ? AppColors.glowBlue
            : AppColors.primaryBlue.withValues(
          alpha: 0.30,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}