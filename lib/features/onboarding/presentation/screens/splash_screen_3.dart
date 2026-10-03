
import 'package:fitness_tracker_app/app/themes/app_colors.dart';
import 'package:fitness_tracker_app/core/constant/app_assets.dart';
import 'package:fitness_tracker_app/features/authentication/presentation/screens/login_screen.dart'
show LoginScreen;
import 'package:flutter/material.dart';

class SplashScreen3 extends StatelessWidget {
const SplashScreen3({super.key});

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: AppColors.darkBackground,
body: SafeArea(
child: LayoutBuilder(
builder: (context, constraints) {
final width = constraints.maxWidth;
final height = constraints.maxHeight;

// ==================================================
// RESPONSIVE SCALE
//
// Reference: mobile portrait around 428 x 926
// ==================================================

final widthScale = width / 428.0;
final heightScale = height / 926.0;

final scale = (widthScale < heightScale
? widthScale
    : heightScale)
    .clamp(0.90, 1.35);

// ==================================================
// RESPONSIVE VALUES
// ==================================================

final titleSize = (25.0 * scale).clamp(
24.0,
30.0,
);

final buttonTextSize = (16.0 * scale).clamp(
15.0,
18.0,
);

final loginTextSize = (13.0 * scale).clamp(
12.0,
15.0,
);

final horizontalPadding = (width * 0.06).clamp(
18.0,
28.0,
);

return Padding(
padding: EdgeInsets.symmetric(
horizontal: horizontalPadding,
),
child: Column(
children: [
// ==================================================
// TITLE
// ==================================================

SizedBox(
height: (height * 0.055).clamp(
32.0,
55.0,
),
),

Text(
'Your Fitness',
textAlign: TextAlign.center,
style: TextStyle(
color: AppColors.white,
fontSize: titleSize,
fontWeight: FontWeight.w700,
height: 1.15,
),
),

Text(
'Journey Starts',
textAlign: TextAlign.center,
style: TextStyle(
color: AppColors.glowBlue,
fontSize: titleSize,
fontWeight: FontWeight.w700,
height: 1.15,
),
),

Text(
'Here!',
textAlign: TextAlign.center,
style: TextStyle(
color: AppColors.white,
fontSize: titleSize,
fontWeight: FontWeight.w700,
height: 1.15,
),
),

// ==================================================
// ILLUSTRATION GAP
// ==================================================

SizedBox(
height: (height * 0.025).clamp(
14.0,
26.0,
),
),

// ==================================================
// ILLUSTRATION
// ==================================================

Expanded(
child: Center(
child: Image.asset(
AppAssets.splash3,
width: (width * 0.92).clamp(
280.0,
395.0,
),
fit: BoxFit.contain,
),
),
),

// ==================================================
// GET STARTED BUTTON
// ==================================================

SizedBox(
width: double.infinity,
height: (height * 0.075).clamp(
52.0,
68.0,
),
child: ElevatedButton(
onPressed: () {
Navigator.of(context).pushReplacement(
MaterialPageRoute(
builder: (_) => const LoginScreen(),
),
);
},
style: ElevatedButton.styleFrom(
backgroundColor:
AppColors.primaryBlue,
foregroundColor:
AppColors.white,
elevation: 0,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(
(12.0 * scale).clamp(
10.0,
15.0,
),
),
),
),
child: Text(
'Get Started',
style: TextStyle(
fontSize: buttonTextSize,
fontWeight: FontWeight.w600,
),
),
),
),

// ==================================================
// LOGIN GAP
// ==================================================

SizedBox(
height: (height * 0.025).clamp(
16.0,
25.0,
),
),

// ==================================================
// LOGIN TEXT
// ==================================================

GestureDetector(
onTap: () {
Navigator.of(context).pushReplacement(
MaterialPageRoute(
builder: (_) => const LoginScreen(),
),
);
},
child: RichText(
textAlign: TextAlign.center,
text: TextSpan(
style: TextStyle(
fontSize: loginTextSize,
height: 1.2,
),
children: const [
TextSpan(
text: 'Already have an account? ',
style: TextStyle(
color: AppColors.white,
),
),
TextSpan(
text: 'Login',
style: TextStyle(
color: AppColors.glowBlue,
fontWeight: FontWeight.w500,
),
),
],
),
),
),

// ==================================================
// PAGE INDICATORS GAP
// ==================================================

SizedBox(
height: (height * 0.045).clamp(
26.0,
42.0,
),
),

// ==================================================
// PAGE INDICATORS
// ==================================================

Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
_buildIndicator(false),
const SizedBox(width: 10),
_buildIndicator(false),
const SizedBox(width: 10),
_buildIndicator(true),
],
),

// ==================================================
// BOTTOM SPACE
// ==================================================

SizedBox(
height: (height * 0.025).clamp(
16.0,
28.0,
),
),
],
),
);
},
),
),
);
}

// ============================================================
// PAGE INDICATOR
// ============================================================

Widget _buildIndicator(bool active) {
return AnimatedContainer(
duration: const Duration(
milliseconds: 250,
),
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

