import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart' as app_auth;
import 'login_screen.dart';
import 'package:fitness_tracker_app/features/dashboard/data/domain/presentation/screens/home_screen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Do NOT create a new AuthProvider here.
    // App-wide AuthProvider already comes from main.dart.
    return const _SignupView();
  }
}

// ============================================================================
// SIGNUP VIEW
// ============================================================================

class _SignupView extends StatefulWidget {
  const _SignupView();

  @override
  State<_SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<_SignupView> {
  static const Color primaryBlue = Color(0xFF006DFF);
  static const Color textColor = Color(0xFF101828);
  static const Color secondaryText = Color(0xFF667085);
  static const Color borderColor = Color(0xFFD9E2F0);

  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  final TextEditingController nameController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // SIGN UP
  // ==========================================================================

  Future<void> _signup() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final app_auth.AuthProvider authProvider =
    context.read<app_auth.AuthProvider>();

    // Prevent double tap / duplicate signup request.
    if (authProvider.isLoading) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    final String name = nameController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text;

    final bool success = await authProvider.signup(
      name: name,
      email: email,
      password: password,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      _showSuccess(
        'Account created successfully.',
      );

      await authProvider.logout();

      if (!mounted) {
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LoginScreen(
            email: email,
          ),
        ),
      );

      return;
    }

    final String? message =
        authProvider.errorMessage;

    if (message != null &&
        message.trim().isNotEmpty) {
      _showMessage(message);
    } else {
      _showMessage(
        'Unable to create account. Please try again.',
      );
    }
  }

  // ==========================================================================
  // GOOGLE SIGNUP
  // ==========================================================================

  Future<void> _signupWithGoogle() async {
    final app_auth.AuthProvider authProvider =
    context.read<app_auth.AuthProvider>();

    if (authProvider.isLoading) {
      return;
    }

    final bool success =
    await authProvider.loginWithGoogle();

    if (!mounted) {
      return;
    }

    if (success) {
      _goHome();
    } else {
      final String? message =
          authProvider.errorMessage;

      if (message != null &&
          message.isNotEmpty) {
        _showMessage(message);
      }
    }
  }

  // ==========================================================================
  // FACEBOOK SIGNUP
  // ==========================================================================

  Future<void> _signupWithFacebook() async {
    final app_auth.AuthProvider authProvider =
    context.read<app_auth.AuthProvider>();

    if (authProvider.isLoading) {
      return;
    }

    final bool success =
    await authProvider.loginWithFacebook();

    if (!mounted) {
      return;
    }

    if (success) {
      _goHome();
    } else {
      final String? message =
          authProvider.errorMessage;

      if (message != null &&
          message.isNotEmpty) {
        _showMessage(message);
      }
    }
  }

  // ==========================================================================
  // GO HOME
  // ==========================================================================

  void _goHome() {
    Get.offAll(
          () => const HomeScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(
        milliseconds: 200,
      ),
    );
  }

  // ==========================================================================
  // GO TO LOGIN
  // ==========================================================================

  void _goToLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  // ==========================================================================
  // ERROR MESSAGE
  // ==========================================================================

  void _showMessage(String message) {
    Get.snackbar(
      'Signup Failed',
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        20,
      ),
      borderRadius: 12,
      backgroundColor:
      const Color(0xFF101828),
      colorText: Colors.white,
      duration: const Duration(
        seconds: 3,
      ),
      titleText: Text(
        'Signup Failed',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      messageText: Text(
        message,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ==========================================================================
  // SUCCESS MESSAGE
  // ==========================================================================

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        20,
      ),
      borderRadius: 12,
      backgroundColor:
      const Color(0xFF12B76A),
      colorText: Colors.white,
      duration: const Duration(
        seconds: 2,
      ),
      titleText: Text(
        'Success',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      messageText: Text(
        message,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final Size size =
    MediaQuery.sizeOf(context);

    final double width = size.width;
    final double height = size.height;

    final bool isDesktop =
        width >= 900;

    final bool isTablet =
        width >= 600 && width < 900;

    final double horizontalPadding =
    isDesktop
        ? 40
        : isTablet
        ? 48
        : 24;

    final double maxWidth =
    isDesktop ? 470 : 520;

    final double buttonHeight =
    isDesktop ? 56 : 52;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (
              context,
              constraints,
              ) {
            return SingleChildScrollView(
              physics:
              const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints:
                BoxConstraints(
                  minHeight:
                  constraints.maxHeight,
                ),
                child: Center(
                  child: Padding(
                    padding:
                    EdgeInsets.symmetric(
                      horizontal:
                      horizontalPadding,
                      vertical: 20,
                    ),
                    child: ConstrainedBox(
                      constraints:
                      BoxConstraints(
                        maxWidth: maxWidth,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .stretch,
                          children: [
                            // ==================================================
                            // BACK BUTTON
                            // ==================================================

                            Align(
                              alignment:
                              Alignment
                                  .centerLeft,
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration:
                                BoxDecoration(
                                  color:
                                  const Color(
                                    0xFFF5F8FC,
                                  ),
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                    12,
                                  ),
                                  border:
                                  Border.all(
                                    color:
                                    borderColor,
                                  ),
                                ),
                                child:
                                IconButton(
                                  onPressed: () {
                                    if (Navigator
                                        .of(
                                      context,
                                    )
                                        .canPop()) {
                                      Navigator.of(
                                        context,
                                      ).pop();
                                    }
                                  },
                                  padding:
                                  EdgeInsets.zero,
                                  icon:
                                  const Icon(
                                    Icons
                                        .arrow_back_ios_new_rounded,
                                    size: 18,
                                    color:
                                    textColor,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              height:
                              isDesktop
                                  ? 28
                                  : height <
                                  700
                                  ? 14
                                  : 22,
                            ),

                            // ==================================================
                            // TITLE
                            // ==================================================

                            Text(
                              'Create Account',
                              textAlign:
                              TextAlign.center,
                              style:
                              GoogleFonts
                                  .poppins(
                                color:
                                textColor,
                                fontSize:
                                isDesktop
                                    ? 30
                                    : isTablet
                                    ? 28
                                    : 26,
                                fontWeight:
                                FontWeight.w700,
                                height: 1.2,
                              ),
                            ),

                            const SizedBox(
                              height: 7,
                            ),

                            Text(
                              'Sign up to get started',
                              textAlign:
                              TextAlign.center,
                              style:
                              GoogleFonts
                                  .poppins(
                                color:
                                secondaryText,
                                fontSize:
                                isDesktop
                                    ? 15
                                    : isTablet
                                    ? 14
                                    : 13,
                                fontWeight:
                                FontWeight.w400,
                              ),
                            ),

                            SizedBox(
                              height:
                              isDesktop
                                  ? 30
                                  : height <
                                  700
                                  ? 18
                                  : 24,
                            ),

                            // ==================================================
                            // USERNAME
                            // ==================================================

                            _SignupField(
                              controller:
                              nameController,
                              label: 'Username',
                              hint:
                              'Enter your username',
                              icon: Icons
                                  .person_outline_rounded,
                              validator:
                                  (value) {
                                if (value ==
                                    null ||
                                    value
                                        .trim()
                                        .isEmpty) {
                                  return 'Enter your username';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(
                              height: 15,
                            ),

                            // ==================================================
                            // EMAIL
                            // ==================================================

                            _SignupField(
                              controller:
                              emailController,
                              label: 'Email',
                              hint:
                              'Enter your email',
                              icon: Icons
                                  .mail_outline_rounded,
                              keyboardType:
                              TextInputType
                                  .emailAddress,
                              validator:
                                  (value) {
                                if (value ==
                                    null ||
                                    value
                                        .trim()
                                        .isEmpty) {
                                  return 'Enter your email';
                                }

                                if (!GetUtils
                                    .isEmail(
                                  value.trim(),
                                )) {
                                  return 'Enter a valid email address';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(
                              height: 15,
                            ),

                            // ==================================================
                            // PASSWORD
                            // ==================================================

                            _SignupField(
                              controller:
                              passwordController,
                              label: 'Password',
                              hint:
                              'Enter your password',
                              icon: Icons
                                  .lock_outline_rounded,
                              obscureText:
                              obscurePassword,
                              suffixIcon:
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscurePassword =
                                    !obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  obscurePassword
                                      ? Icons
                                      .visibility_outlined
                                      : Icons
                                      .visibility_off_outlined,
                                  size: 21,
                                  color:
                                  secondaryText,
                                ),
                              ),
                              validator:
                                  (value) {
                                if (value ==
                                    null ||
                                    value.isEmpty) {
                                  return 'Enter your password';
                                }

                                if (value.length <
                                    6) {
                                  return 'Password must be at least 6 characters';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(
                              height: 15,
                            ),

                            // ==================================================
                            // CONFIRM PASSWORD
                            // ==================================================

                            _SignupField(
                              controller:
                              confirmPasswordController,
                              label:
                              'Confirm Password',
                              hint:
                              'Confirm your password',
                              icon: Icons
                                  .lock_outline_rounded,
                              obscureText:
                              obscureConfirmPassword,
                              suffixIcon:
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscureConfirmPassword =
                                    !obscureConfirmPassword;
                                  });
                                },
                                icon: Icon(
                                  obscureConfirmPassword
                                      ? Icons
                                      .visibility_outlined
                                      : Icons
                                      .visibility_off_outlined,
                                  size: 21,
                                  color:
                                  secondaryText,
                                ),
                              ),
                              validator:
                                  (value) {
                                if (value ==
                                    null ||
                                    value.isEmpty) {
                                  return 'Confirm your password';
                                }

                                if (value !=
                                    passwordController
                                        .text) {
                                  return 'Passwords do not match';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(
                              height: 22,
                            ),

                            // ==================================================
                            // SIGN UP BUTTON
                            // ==================================================

                            SizedBox(
                              width:
                              double.infinity,
                              height:
                              buttonHeight,
                              child:
                              ElevatedButton(
                                onPressed:
                                _signup,
                                style:
                                ElevatedButton
                                    .styleFrom(
                                  backgroundColor:
                                  primaryBlue,
                                  foregroundColor:
                                  Colors.white,
                                  elevation: 0,
                                  padding:
                                  EdgeInsets
                                      .zero,
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      10,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Sign Up',
                                  style:
                                  GoogleFonts
                                      .poppins(
                                    fontSize:
                                    isDesktop
                                        ? 16
                                        : 15,
                                    fontWeight:
                                    FontWeight
                                        .w600,
                                    color:
                                    Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              height:
                              isDesktop
                                  ? 26
                                  : 22,
                            ),

                            // ==================================================
                            // OR DIVIDER
                            // ==================================================

                            Row(
                              children: [
                                const Expanded(
                                  child: Divider(
                                    color:
                                    borderColor,
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    'Or sign up with',
                                    style:
                                    GoogleFonts
                                        .poppins(
                                      color:
                                      secondaryText,
                                      fontSize:
                                      12.5,
                                      fontWeight:
                                      FontWeight
                                          .w500,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(
                                    color:
                                    borderColor,
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(
                              height:
                              isDesktop
                                  ? 22
                                  : 18,
                            ),

                            // ==================================================
                            // SOCIAL BUTTONS
                            // ==================================================

                            Row(
                              children: [
                                Expanded(
                                  child:
                                  _SocialButton(
                                    label: 'Google',
                                    icon: Icons
                                        .g_mobiledata_rounded,
                                    iconColor:
                                    const Color(
                                      0xFFEA4335,
                                    ),
                                    enabled: true,
                                    onTap:
                                    _signupWithGoogle,
                                    height:
                                    buttonHeight,
                                  ),
                                ),
                                const SizedBox(
                                  width: 14,
                                ),
                                Expanded(
                                  child:
                                  _SocialButton(
                                    label:
                                    'Facebook',
                                    icon: Icons
                                        .facebook_rounded,
                                    iconColor:
                                    const Color(
                                      0xFF1877F2,
                                    ),
                                    enabled: true,
                                    onTap:
                                    _signupWithFacebook,
                                    height:
                                    buttonHeight,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(
                              height:
                              isDesktop
                                  ? 45
                                  : height <
                                  700
                                  ? 28
                                  : 40,
                            ),

                            // ==================================================
                            // LOGIN
                            // ==================================================

                            Center(
                              child: Wrap(
                                alignment:
                                WrapAlignment
                                    .center,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style:
                                    GoogleFonts
                                        .poppins(
                                      color:
                                      textColor,
                                      fontSize:
                                      isDesktop
                                          ? 14
                                          : 13,
                                      fontWeight:
                                      FontWeight
                                          .w400,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap:
                                    _goToLogin,
                                    child: Text(
                                      'Login',
                                      style:
                                      GoogleFonts
                                          .poppins(
                                        color:
                                        primaryBlue,
                                        fontSize:
                                        isDesktop
                                            ? 14
                                            : 13,
                                        fontWeight:
                                        FontWeight
                                            .w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// SOCIAL BUTTON
// ============================================================================

class _SocialButton extends StatelessWidget {
  // FIX:
  // borderColor is declared inside this class,
  // so const BorderSide can access it safely.
  static const Color borderColor =
  Color(0xFFD9E2F0);

  final String label;
  final IconData icon;
  final Color iconColor;
  final bool enabled;
  final VoidCallback onTap;
  final double height;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.enabled,
    required this.onTap,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: OutlinedButton.icon(
        onPressed:
        enabled ? onTap : null,
        icon: Icon(
          icon,
          color: iconColor,
          size: 22,
        ),
        label: Text(
          label,
          style: GoogleFonts.poppins(
            color:
            const Color(0xFF101828),
            fontSize: 13.5,
            fontWeight:
            FontWeight.w600,
          ),
        ),
        style:
        OutlinedButton.styleFrom(
          backgroundColor:
          const Color(0xFFFCFDFF),
          side: const BorderSide(
            color: borderColor,
          ),
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(10),
          ),
          padding:
          EdgeInsets.zero,
        ),
      ),
    );
  }
}

// ============================================================================
// SIGNUP FIELD
// ============================================================================

class _SignupField extends StatelessWidget {
  static const Color primaryBlue =
  Color(0xFF006DFF);

  static const Color borderColor =
  Color(0xFFD9E2F0);

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _SignupField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final double width =
        MediaQuery.sizeOf(context).width;

    final bool large =
        width >= 600;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: GoogleFonts.poppins(
        color:
        const Color(0xFF101828),
        fontSize:
        large ? 15 : 14,
        fontWeight:
        FontWeight.w400,
      ),
      cursorColor: primaryBlue,
      decoration:
      InputDecoration(
        labelText: label,
        hintText: hint,
        floatingLabelBehavior:
        FloatingLabelBehavior
            .always,
        labelStyle:
        GoogleFonts.poppins(
          color:
          const Color(0xFF667085),
          fontSize:
          large ? 13 : 12,
          fontWeight:
          FontWeight.w500,
        ),
        hintStyle:
        GoogleFonts.poppins(
          color:
          const Color(0xFF98A2B3),
          fontSize:
          large ? 14 : 13,
          fontWeight:
          FontWeight.w400,
        ),
        prefixIcon: Icon(
          icon,
          size:
          large ? 21 : 20,
          color:
          const Color(0xFF344054),
        ),
        suffixIcon:
        suffixIcon,
        filled: true,
        fillColor:
        const Color(0xFFFCFDFF),
        contentPadding:
        EdgeInsets.symmetric(
          horizontal:
          large ? 16 : 14,
          vertical:
          large ? 17 : 16,
        ),
        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            10,
          ),
          borderSide:
          const BorderSide(
            color: borderColor,
          ),
        ),
        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            10,
          ),
          borderSide:
          const BorderSide(
            color: primaryBlue,
            width: 1.4,
          ),
        ),
        errorBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            10,
          ),
          borderSide:
          const BorderSide(
            color:
            Color(0xFFEF4444),
          ),
        ),
        focusedErrorBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            10,
          ),
          borderSide:
          const BorderSide(
            color:
            Color(0xFFEF4444),
            width: 1.4,
          ),
        ),
        errorStyle:
        GoogleFonts.poppins(
          color:
          const Color(0xFFEF4444),
          fontSize:
          large ? 12 : 11,
          fontWeight:
          FontWeight.w400,
        ),
      ),
    );
  }
}