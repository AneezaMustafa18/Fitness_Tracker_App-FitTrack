
import 'dart:typed_data';

import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../app/themes/app_colors.dart';
import '../../domain/entities/profile.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
const EditProfileScreen({
super.key,
required this.profile,
});

final Profile profile;

@override
State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
late final TextEditingController _nameController;
late final TextEditingController _phoneController;

Uint8List? _selectedImageBytes;

bool _isUploadingImage = false;
bool _isSaving = false;

@override
void initState() {
super.initState();

_nameController = TextEditingController(
text: widget.profile.name,
);

_phoneController = TextEditingController(
text: widget.profile.phone,
);

_nameController.addListener(_onNameChanged);
}

@override
void dispose() {
_nameController.removeListener(_onNameChanged);
_nameController.dispose();
_phoneController.dispose();
super.dispose();
}

void _onNameChanged() {
if (mounted) {
setState(() {});
}
}

// ============================================================
// PICK IMAGE
// ============================================================

  Future<void> _pickImage() async {
    if (_isUploadingImage || _isSaving) {
      return;
    }

    try {
      final ImagePicker picker = ImagePicker();

      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return;
      }

      final Uint8List bytes = await pickedFile.readAsBytes();

      if (bytes.isEmpty) {
        Get.snackbar(
          'Invalid Image',
          'The selected image could not be loaded.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
        );
        return;
      }

      if (!mounted) return;

      setState(() {
        _selectedImageBytes = bytes;
        _isUploadingImage = true;
      });

      final provider = context.read<ProfileProvider>();

      final bool success =
      await provider.uploadProfileImage(bytes);

      if (!mounted) return;

      setState(() {
        _isUploadingImage = false;
      });

      if (success) {
        Get.snackbar(
          'Photo Updated',
          'Your profile photo has been uploaded successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: AppColors.white,
        );
      } else {
        setState(() {
          _selectedImageBytes = null;
        });

        Get.snackbar(
          'Upload Failed',
          provider.errorMessage ??
              'Unable to upload profile image. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
        );
      }
    } catch (e) {
      debugPrint('EDIT PROFILE IMAGE PICK ERROR: $e');

      if (!mounted) return;

      setState(() {
        _selectedImageBytes = null;
        _isUploadingImage = false;
      });

      Get.snackbar(
        'Image Error',
        'Unable to select the image. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    }
  }

// ============================================================
// SAVE PROFILE
// ============================================================

Future<void> _save() async {
final String name = _nameController.text.trim();
final String phone = _phoneController.text.trim();

if (name.isEmpty) {
Get.snackbar(
'Required',
'Please enter your name.',
snackPosition: SnackPosition.BOTTOM,
backgroundColor: AppColors.error,
colorText: AppColors.white,
);
return;
}

if (_isUploadingImage) {
Get.snackbar(
'Please Wait',
'Your profile image is still uploading.',
snackPosition: SnackPosition.BOTTOM,
backgroundColor: Colors.orange,
colorText: AppColors.white,
);
return;
}

if (_isSaving) {
return;
}

setState(() {
_isSaving = true;
});

final provider = context.read<ProfileProvider>();

final bool success = await provider.updateProfile(
name: name,
phone: phone,
);

if (!mounted) return;

setState(() {
_isSaving = false;
});

if (success) {
Get.snackbar(
'Success',
'Profile updated successfully.',
snackPosition: SnackPosition.BOTTOM,
backgroundColor: Colors.green,
colorText: AppColors.white,
);

Navigator.of(context).pop(true);
} else {
Get.snackbar(
'Update Failed',
provider.errorMessage ??
'Unable to update profile. Please try again.',
snackPosition: SnackPosition.BOTTOM,
backgroundColor: AppColors.error,
colorText: AppColors.white,
);
}
}

// ============================================================
// PROFILE IMAGE
// ============================================================

ImageProvider? _getProfileImage() {
if (_selectedImageBytes != null) {
return MemoryImage(_selectedImageBytes!);
}

final String imageUrl =
widget.profile.profileImage.trim();

if (imageUrl.isNotEmpty) {
return NetworkImage(imageUrl);
}

return null;
}

String _getInitial() {
final String name = _nameController.text.trim();

if (name.isNotEmpty) {
return name[0].toUpperCase();
}

final String email = widget.profile.email.trim();

if (email.isNotEmpty) {
return email[0].toUpperCase();
}

return 'U';
}

// ============================================================
// RESPONSIVE
// ============================================================

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

// ============================================================
// BUILD
// ============================================================

@override
Widget build(BuildContext context) {
final colors = Theme.of(context).colorScheme;
final ImageProvider? imageProvider =
_getProfileImage();

return Scaffold(
backgroundColor: colors.surface,
appBar: AppBar(
backgroundColor: colors.surface,
foregroundColor: colors.onSurface,
elevation: 0,
centerTitle: true,
title: Text(
'Edit Profile',
style: GoogleFonts.poppins(
fontSize: _s(context, 20),
fontWeight: FontWeight.w600,
color: colors.onSurface,
),
),
),
body: SafeArea(
child: SingleChildScrollView(
keyboardDismissBehavior:
ScrollViewKeyboardDismissBehavior.onDrag,
padding: EdgeInsets.fromLTRB(
_s(context, 20),
_s(context, 12),
_s(context, 20),
_s(context, 30),
),
child: Column(
children: [
SizedBox(height: _s(context, 8)),

Stack(
alignment: Alignment.bottomRight,
children: [
Container(
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
child: imageProvider != null
? Image(
image: imageProvider,
fit: BoxFit.cover,
errorBuilder:
(context, error, stackTrace) {
return _buildInitialAvatar(
context,
);
},
)
    : _buildInitialAvatar(context),
),
),

GestureDetector(
onTap: _isUploadingImage
? null
    : _pickImage,
child: Container(
width: _s(context, 42),
height: _s(context, 42),
decoration: BoxDecoration(
color: AppColors.primaryBlue,
shape: BoxShape.circle,
border: Border.all(
color: colors.surface,
width: 3,
),
),
child: _isUploadingImage
? Padding(
padding: EdgeInsets.all(
_s(context, 9),
),
child:
const CircularProgressIndicator(
strokeWidth: 2.2,
color: AppColors.white,
),
)
    : Icon(
Icons.camera_alt_rounded,
size: _s(context, 19),
color: AppColors.white,
),
),
),
],
),

SizedBox(height: _s(context, 10)),

TextButton.icon(
onPressed: _isUploadingImage
? null
    : _pickImage,
icon: Icon(
Icons.photo_library_outlined,
size: _s(context, 19),
color: _isUploadingImage
? colors.onSurfaceVariant
    : AppColors.primaryBlue,
),
label: Text(
_isUploadingImage
? 'Uploading...'
    : 'Change Profile Photo',
style: GoogleFonts.poppins(
fontSize: _s(context, 13),
fontWeight: FontWeight.w500,
color: _isUploadingImage
? colors.onSurfaceVariant
    : AppColors.primaryBlue,
),
),
),

SizedBox(height: _s(context, 20)),

_buildFieldLabel(
context,
'Name',
),

SizedBox(height: _s(context, 8)),

TextField(
controller: _nameController,
textInputAction: TextInputAction.next,
textCapitalization:
TextCapitalization.words,
style: GoogleFonts.poppins(
fontSize: _s(context, 14),
color: colors.onSurface,
),
decoration: InputDecoration(
hintText: 'Enter your name',
hintStyle: GoogleFonts.poppins(
color: colors.onSurfaceVariant,
fontSize: _s(context, 13),
),
prefixIcon: Icon(
Icons.person_outline_rounded,
color: AppColors.primaryBlue,
size: _s(context, 21),
),
),
),

SizedBox(height: _s(context, 20)),

_buildFieldLabel(
context,
'Phone',
),

SizedBox(height: _s(context, 8)),

TextField(
controller: _phoneController,
keyboardType: TextInputType.phone,
textInputAction: TextInputAction.done,
style: GoogleFonts.poppins(
fontSize: _s(context, 14),
color: colors.onSurface,
),
decoration: InputDecoration(
hintText: 'Enter your phone number',
hintStyle: GoogleFonts.poppins(
color: colors.onSurfaceVariant,
fontSize: _s(context, 13),
),
prefixIcon: Icon(
Icons.phone_outlined,
color: AppColors.primaryBlue,
size: _s(context, 21),
),
),
),

SizedBox(height: _s(context, 30)),

SizedBox(
width: double.infinity,
height: _s(context, 52),
child: ElevatedButton(
onPressed:
_isSaving || _isUploadingImage
? null
    : _save,
style: ElevatedButton.styleFrom(
backgroundColor:
AppColors.primaryBlue,
foregroundColor:
AppColors.white,
disabledBackgroundColor:
AppColors.primaryBlue
    .withOpacity(0.55),
disabledForegroundColor:
AppColors.white,
elevation: 0,
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
_s(context, 12),
),
),
),
child: _isSaving
? SizedBox(
width: _s(context, 22),
height: _s(context, 22),
child:
const CircularProgressIndicator(
strokeWidth: 2.5,
color: AppColors.white,
),
)
    : Text(
'Save Changes',
style: GoogleFonts.poppins(
fontSize: _s(context, 14),
fontWeight: FontWeight.w600,
color: AppColors.white,
),
),
),
),
],
),
),
),
);
}

Widget _buildFieldLabel(
BuildContext context,
String text,
) {
final colors = Theme.of(context).colorScheme;

return Align(
alignment: Alignment.centerLeft,
child: Text(
text,
style: GoogleFonts.poppins(
fontSize: _s(context, 14),
fontWeight: FontWeight.w600,
color: colors.onSurface,
),
),
);
}

Widget _buildInitialAvatar(
BuildContext context,
) {
return Center(
child: Text(
_getInitial(),
style: GoogleFonts.poppins(
fontSize: _s(context, 42),
fontWeight: FontWeight.w700,
color: AppColors.primaryBlue,
),
),
);
}
}





