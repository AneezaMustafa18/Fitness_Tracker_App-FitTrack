import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../app/themes/app_colors.dart';
import '../../../authentication/presentation/providers/auth_provider.dart'
as app_auth;
import '../../../authentication/presentation/screens/login_screen.dart';
import '../../domain/entities/profile.dart';
import '../providers/profile_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double _scale(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final widthScale = size.width / 428.0;
    final heightScale = size.height / 926.0;

    return (widthScale < heightScale
        ? widthScale
        : heightScale)
        .clamp(0.90, 1.35);
  }

  double _s(BuildContext context, double value) {
    return value * _scale(context);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<ProfileProvider>().loadProfile();
    });
  }

  Future<void> _editProfile(Profile profile) async {
    final updated =
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          profile: profile,
        ),
      ),
    );

    if (updated == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colors =
            Theme.of(dialogContext).colorScheme;

        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text(
            'Logout',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: colors.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
                elevation: 0,
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !mounted) {
      return;
    }

    try {
      await context
          .read<app_auth.AuthProvider>()
          .logout();

      if (!mounted) return;

      context.read<ProfileProvider>().clear();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
            (route) => false,
      );
    } catch (e) {
      debugPrint('PROFILE LOGOUT ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to logout. Please try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    final authUser =
        FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontSize: _s(context, 21),
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
        actions: [
          Consumer<ProfileProvider>(
            builder: (
                context,
                provider,
                _,
                ) {
              final profile = provider.profile;

              if (profile == null) {
                return const SizedBox.shrink();
              }

              return IconButton(
                tooltip: 'Edit Profile',
                onPressed: () =>
                    _editProfile(profile),
                icon: Icon(
                  Icons.edit_outlined,
                  size: _s(context, 23),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (
            context,
            provider,
            _,
            ) {
          if (provider.isLoading &&
              provider.profile == null) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
              ),
            );
          }

          final Profile? profile =
              provider.profile;

          final String displayName =
          profile?.name.trim().isNotEmpty == true
              ? profile!.name.trim()
              : authUser?.displayName
              ?.trim()
              .isNotEmpty ==
              true
              ? authUser!.displayName!.trim()
              : 'Fitness User';

          final String email =
          profile?.email.trim().isNotEmpty == true
              ? profile!.email.trim()
              : authUser?.email ?? '—';

          final String phone =
          profile?.phone.trim().isNotEmpty == true
              ? profile!.phone.trim()
              : '—';

          final String profileImage =
          profile?.profileImage
              .trim()
              .isNotEmpty ==
              true
              ? profile!.profileImage.trim()
              : authUser?.photoURL
              ?.trim() ??
              '';

          return RefreshIndicator(
            color: AppColors.primaryBlue,
            onRefresh: provider.loadProfile,
            child: ListView(
              physics:
              const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                _s(context, 20),
                _s(context, 18),
                _s(context, 20),
                _s(context, 30),
              ),
              children: [
                SizedBox(height: _s(context, 8)),

                Center(
                  child: _buildProfileAvatar(
                    context,
                    displayName,
                    profileImage,
                  ),
                ),

                SizedBox(height: _s(context, 16)),

                Center(
                  child: Text(
                    displayName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: _s(context, 23),
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                ),

                SizedBox(height: _s(context, 5)),

                Center(
                  child: Text(
                    email,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: _s(context, 13),
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),

                SizedBox(height: _s(context, 30)),

                _buildProfileItem(
                  context,
                  icon:
                  Icons.person_outline_rounded,
                  title: 'Full Name',
                  value: displayName,
                ),

                SizedBox(height: _s(context, 14)),

                _buildProfileItem(
                  context,
                  icon: Icons.email_outlined,
                  title: 'Email',
                  value: email,
                ),

                SizedBox(height: _s(context, 14)),

                _buildProfileItem(
                  context,
                  icon: Icons.phone_outlined,
                  title: 'Phone',
                  value: phone,
                ),

                SizedBox(height: _s(context, 30)),

                if (profile != null)
                  SizedBox(
                    height: _s(context, 52),
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _editProfile(profile),
                      icon: Icon(
                        Icons.edit_outlined,
                        size: _s(context, 20),
                      ),
                      label: Text(
                        'Edit Profile',
                        style: GoogleFonts.poppins(
                          fontSize: _s(context, 14),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style:
                      OutlinedButton.styleFrom(
                        foregroundColor:
                        AppColors.primaryBlue,
                        side: const BorderSide(
                          color:
                          AppColors.primaryBlue,
                        ),
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                            _s(context, 12),
                          ),
                        ),
                      ),
                    ),
                  ),

                SizedBox(height: _s(context, 16)),

                SizedBox(
                  height: _s(context, 52),
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: Icon(
                      Icons.logout_rounded,
                      size: _s(context, 20),
                    ),
                    label: Text(
                      'Logout',
                      style: GoogleFonts.poppins(
                        fontSize: _s(context, 14),
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      AppColors.error,
                      foregroundColor:
                      AppColors.white,
                      elevation: 0,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          _s(context, 12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileAvatar(
      BuildContext context,
      String displayName,
      String imageUrl,
      ) {
    final colors =
        Theme.of(context).colorScheme;

    final String initial =
    displayName.trim().isNotEmpty
        ? displayName
        .trim()[0]
        .toUpperCase()
        : 'U';

    return Container(
      width: _s(context, 125),
      height: _s(context, 125),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryBlue
            .withOpacity(0.10),
        border: Border.all(
          color: AppColors.primaryBlue
              .withOpacity(0.35),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: imageUrl.isNotEmpty
            ? Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (
              context,
              child,
              loadingProgress,
              ) {
            if (loadingProgress == null) {
              return child;
            }

            return Center(
              child:
              CircularProgressIndicator(
                strokeWidth: 2.5,
                color:
                AppColors.primaryBlue,
              ),
            );
          },
          errorBuilder: (
              context,
              error,
              stackTrace,
              ) {
            return _buildInitialAvatar(
              context,
              colors,
              initial,
            );
          },
        )
            : _buildInitialAvatar(
          context,
          colors,
          initial,
        ),
      ),
    );
  }

  Widget _buildInitialAvatar(
      BuildContext context,
      ColorScheme colors,
      String initial,
      ) {
    return Center(
      child: Text(
        initial,
        style: GoogleFonts.poppins(
          fontSize: _s(context, 45),
          fontWeight: FontWeight.w700,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildProfileItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String value,
      }) {
    final colors =
        Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _s(context, 16),
        vertical: _s(context, 15),
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius:
        BorderRadius.circular(
          _s(context, 12),
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: _s(context, 44),
            height: _s(context, 44),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue
                  .withOpacity(0.10),
              borderRadius:
              BorderRadius.circular(
                _s(context, 12),
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryBlue,
              size: _s(context, 22),
            ),
          ),

          SizedBox(
            width: _s(context, 14),
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: _s(context, 12),
                    fontWeight: FontWeight.w400,
                    color:
                    colors.onSurfaceVariant,
                  ),
                ),

                SizedBox(
                  height: _s(context, 3),
                ),

                Text(
                  value,
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: _s(context, 14),
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

