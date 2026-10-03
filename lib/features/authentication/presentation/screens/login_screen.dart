import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart' as app_auth;
import 'signup_screen.dart';
import 'package:fitness_tracker_app/features/dashboard/data/domain/presentation/screens/home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({
    super.key,
    this.email,
  });

  final String? email;

  @override
  Widget build(BuildContext context) {
    return _LoginView(initialEmail: email);
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView({
    this.initialEmail,
  });

  final String? initialEmail;

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  static const Color primaryBlue = Color(0xFF006DFF);
  static const Color textColor = Color(0xFF101828);
  static const Color secondaryText = Color(0xFF667085);
  static const Color borderColor = Color(0xFFD9E2F0);

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();

    emailController = TextEditingController(
      text: widget.initialEmail ?? '',
    );

    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final authProvider =
    context.read<app_auth.AuthProvider>();

    if (authProvider.isLoading) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    final bool success = await authProvider.login(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      _goHome();
    } else {
      final message = authProvider.errorMessage;

      if (message != null && message.isNotEmpty) {
        _showMessage(message);
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    final authProvider =
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
      final message = authProvider.errorMessage;

      if (message != null && message.isNotEmpty) {
        _showMessage(message);
      }
    }
  }

  Future<void> _loginWithFacebook() async {
    final authProvider =
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
      final message = authProvider.errorMessage;

      if (message != null && message.isNotEmpty) {
        _showMessage(message);
      }
    }
  }

  void _goHome() {
    Get.offAll(
          () => const HomeScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(
        milliseconds: 200,
      ),
    );
  }

  Future<void> _forgotPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showMessage(
        'Enter your email first to reset your password.',
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      _showMessage(
        'Please enter a valid email address.',
      );
      return;
    }

    final authProvider =
    context.read<app_auth.AuthProvider>();

    final bool success =
    await authProvider.forgotPassword(
      email: email,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      _showMessage(
        'Password reset email sent.',
      );
    } else {
      final message = authProvider.errorMessage;

      if (message != null && message.isNotEmpty) {
        _showMessage(message);
      }
    }
  }

  void _goToSignup() {
    Get.to(
          () => const SignupScreen(),
      transition: Transition.rightToLeft,
      duration: const Duration(
        milliseconds: 250,
      ),
    );
  }

  void _showMessage(String message) {
    Get.snackbar(
      '',
      '',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        20,
      ),
      borderRadius: 14,
      backgroundColor: textColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      titleText: const SizedBox.shrink(),
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final width = size.width;
    final height = size.height;

    final bool isDesktop = width >= 900;
    final bool isTablet =
        width >= 600 && width < 900;

    final double horizontalPadding =
    isDesktop
        ? 40
        : isTablet
        ? 48
        : 24;

    final double maxContentWidth =
    isDesktop
        ? 460
        : isTablet
        ? 520
        : 500;

    final double titleSize =
    isDesktop
        ? 30
        : isTablet
        ? 29
        : 26;

    final double subtitleSize =
    isDesktop
        ? 16
        : isTablet
        ? 15
        : 14;

    final double fieldGap =
    isDesktop
        ? 20
        : isTablet
        ? 18
        : 16;

    final double buttonHeight =
    isDesktop
        ? 56
        : isTablet
        ? 54
        : 52;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics:
              const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                      horizontalPadding,
                      vertical: 24,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth:
                        maxContentWidth,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .stretch,
                          children: [
                            Align(
                              alignment:
                              Alignment.centerLeft,
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
                                    if (Get
                                        .key
                                        .currentState
                                        ?.canPop() ??
                                        false) {
                                      Get.back();
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
                              height: isDesktop
                                  ? 38
                                  : height < 700
                                  ? 20
                                  : 32,
                            ),

                            Text(
                              'Welcome Back!',
                              textAlign:
                              TextAlign.center,
                              style:
                              GoogleFonts
                                  .poppins(
                                color:
                                textColor,
                                fontSize:
                                titleSize,
                                fontWeight:
                                FontWeight.w700,
                                height: 1.2,
                              ),
                            ),

                            const SizedBox(
                              height: 7,
                            ),

                            Text(
                              'Login to continue',
                              textAlign:
                              TextAlign.center,
                              style:
                              GoogleFonts
                                  .poppins(
                                color:
                                secondaryText,
                                fontSize:
                                subtitleSize,
                                fontWeight:
                                FontWeight.w400,
                                height: 1.4,
                              ),
                            ),

                            SizedBox(
                              height: isDesktop
                                  ? 38
                                  : height < 700
                                  ? 22
                                  : 32,
                            ),

                            _LoginField(
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

                            SizedBox(
                              height: fieldGap,
                            ),

                            _LoginField(
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
                                padding:
                                EdgeInsets.zero,
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

                                return null;
                              },
                            ),

                            Align(
                              alignment:
                              Alignment.centerRight,
                              child:
                              TextButton(
                                onPressed:
                                _forgotPassword,
                                style:
                                TextButton.styleFrom(
                                  padding:
                                  const EdgeInsets
                                      .only(
                                    top: 10,
                                    bottom: 8,
                                    left: 4,
                                  ),
                                  minimumSize:
                                  Size.zero,
                                  tapTargetSize:
                                  MaterialTapTargetSize
                                      .shrinkWrap,
                                ),
                                child: Text(
                                  'Forgot Password?',
                                  style:
                                  GoogleFonts
                                      .poppins(
                                    color:
                                    primaryBlue,
                                    fontSize: 13,
                                    fontWeight:
                                    FontWeight
                                        .w600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            SizedBox(
                              height:
                              buttonHeight,
                              child:
                              ElevatedButton(
                                onPressed:
                                _login,
                                style:
                                ElevatedButton
                                    .styleFrom(
                                  backgroundColor:
                                  primaryBlue,
                                  foregroundColor:
                                  Colors.white,
                                  elevation: 0,
                                  shadowColor:
                                  primaryBlue
                                      .withValues(
                                    alpha: .25,
                                  ),
                                  padding:
                                  EdgeInsets
                                      .zero,
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      13,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Login',
                                  style:
                                  GoogleFonts
                                      .poppins(
                                    color:
                                    Colors.white,
                                    fontSize:
                                    isDesktop
                                        ? 16
                                        : 15,
                                    fontWeight:
                                    FontWeight
                                        .w600,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              height:
                              isDesktop
                                  ? 30
                                  : 26,
                            ),

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
                                    'Or continue with',
                                    style:
                                    GoogleFonts
                                        .poppins(
                                      color:
                                      secondaryText,
                                      fontSize: 12,
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
                                  ? 24
                                  : 20,
                            ),

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
                                    onTap:
                                    _loginWithGoogle,
                                    height:
                                    buttonHeight,
                                  ),
                                ),
                                const SizedBox(
                                  width: 12,
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
                                    onTap:
                                    _loginWithFacebook,
                                    height:
                                    buttonHeight,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(
                              height: isDesktop
                                  ? 58
                                  : height < 700
                                  ? 32
                                  : 48,
                            ),

                            Center(
                              child: Wrap(
                                alignment:
                                WrapAlignment
                                    .center,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style:
                                    GoogleFonts
                                        .poppins(
                                      color:
                                      textColor,
                                      fontSize:
                                      isDesktop
                                          ? 14
                                          : 13,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap:
                                    _goToSignup,
                                    child: Text(
                                      'Sign Up',
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

class _SocialButton extends StatelessWidget {
  // FIX: borderColor is now defined inside
  // _SocialButton, so it is available here.
  static const Color borderColor =
  Color(0xFFD9E2F0);

  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final double height;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: OutlinedButton.icon(
        onPressed: onTap,
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
            BorderRadius.circular(13),
          ),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _LoginField extends StatelessWidget {
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

  const _LoginField({
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
    final width =
        MediaQuery.sizeOf(context).width;

    final bool isDesktop =
        width >= 900;

    final bool isTablet =
        width >= 600 && width < 900;

    final double textSize =
    isDesktop
        ? 16
        : isTablet
        ? 15
        : 14;

    final double labelSize =
    isDesktop
        ? 13
        : isTablet
        ? 13
        : 12;

    final double hintSize =
    isDesktop
        ? 15
        : isTablet
        ? 14
        : 13;

    final double iconSize =
    isDesktop
        ? 22
        : isTablet
        ? 21
        : 20;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: GoogleFonts.poppins(
        color:
        const Color(0xFF101828),
        fontSize: textSize,
        fontWeight:
        FontWeight.w400,
      ),
      cursorColor: primaryBlue,
      decoration:
      InputDecoration(
        labelText: label,
        hintText: hint,
        floatingLabelBehavior:
        FloatingLabelBehavior.always,
        labelStyle:
        GoogleFonts.poppins(
          color:
          const Color(0xFF667085),
          fontSize: labelSize,
          fontWeight:
          FontWeight.w500,
        ),
        hintStyle:
        GoogleFonts.poppins(
          color:
          const Color(0xFF98A2B3),
          fontSize: hintSize,
        ),
        prefixIcon: Icon(
          icon,
          size: iconSize,
          color:
          const Color(0xFF344054),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor:
        const Color(0xFFFCFDFF),
        contentPadding:
        EdgeInsets.symmetric(
          horizontal:
          isDesktop || isTablet
              ? 16
              : 14,
          vertical:
          isDesktop || isTablet
              ? 18
              : 16,
        ),
        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(13),
          borderSide:
          const BorderSide(
            color: borderColor,
          ),
        ),
        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(13),
          borderSide:
          const BorderSide(
            color: primaryBlue,
            width: 1.4,
          ),
        ),
        errorBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(13),
          borderSide:
          const BorderSide(
            color:
            Color(0xFFEF4444),
          ),
        ),
        focusedErrorBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(13),
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
          isDesktop ? 12 : 11,
        ),
      ),
    );
  }
}