import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/image_url.dart';
import 'package:storryca/src/core/network/models/user_api_model.dart';
import 'package:storryca/src/core/widgets/app_image.dart';
import 'package:storryca/src/core/widgets/app_snackbar.dart';
import 'package:storryca/src/core/widgets/error_state.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/features/profile/presentation/widgets/basic_profile_form.dart';
import 'package:storryca/src/features/profile/presentation/widgets/extras_profile_form.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String selectedTab = 'Basic';
  UserApiModel? _user;
  String? _error;
  File? _pickedImage;
  bool _uploadingPhoto = false;

  Future<void> _pickProfilePhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() {
      _pickedImage = File(picked.path);
      _uploadingPhoto = true;
    });

    final token = await authService.getToken();
    if (token == null) {
      if (mounted) {
        AppSnackbar.warning(context, 'Sign in to change your photo.');
        setState(() => _uploadingPhoto = false);
      }
      return;
    }
    try {
      final newImage = await usersRepository.uploadAvatar(picked.path, token);
      // Re-fetch for any other fields that may have changed, but trust the
      // upload response's own filename over this — `/users/me` can race the
      // server's write and briefly still return the old one, which made the
      // picture appear to silently revert right after a "successful" upload.
      final user = await usersRepository.me(token);
      if (mounted) {
        setState(() {
          _user = user.image == newImage ? user : user.copyWithImage(newImage);
          _pickedImage = null;
        });
        AppSnackbar.success(context, 'Photo updated successfully.');
      }
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.displayMessage);
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    final token = await authService.getToken();
    if (token == null) {
      setState(() => _error = 'You need to be signed in.');
      return;
    }
    try {
      final user = await usersRepository.me(token);
      setState(() => _user = user);
    } on ApiException catch (e) {
      setState(() => _error = e.displayMessage);
    }
  }

  Future<void> _save({
    required String name,
    required String username,
    required String email,
    String? phone,
    String? aboutMe,
  }) async {
    final token = await authService.getToken();
    if (token == null) return;
    try {
      await usersRepository.updateProfile(
        token,
        name: name,
        username: username,
        email: email,
        phone: phone,
        aboutMe: aboutMe,
      );
      if (!mounted) return;
      AppSnackbar.success(context, 'Profile updated.');
      context.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, e.displayMessage);
    }
  }

  void updateSelectedTab(String tab) {
    setState(() {
      selectedTab = tab;
    });
  }

  void copyToClipboard(String text) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: text));
    AppSnackbar.success(context, 'Copied');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF020004),
      body: Container(
        decoration: BoxDecoration(gradient: pageGradientCOLR),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              spacing: 16,
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                    bottom: 16,
                    right: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          context.pop();
                        },
                        icon: Icon(Remix.arrow_left_s_line),
                        color: Colors.white,
                        iconSize: 24,
                      ),
                      Text(
                        'Edit Profile',
                        style: GoogleFonts.playfair(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/change-password'),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: profileIconCardGradientCOLR,
                            border: Border.all(
                              width: 0.5,
                              color: Color(0xff8343D5),
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Icon(
                              Remix.git_repository_private_line,
                              color: Color(0xffCF7FFA),
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // PROFILE PHOTO
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 84,
                      height: 84,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipOval(
                            child: _pickedImage != null
                                ? Image.file(
                                    _pickedImage!,
                                    width: 84,
                                    height: 84,
                                    fit: BoxFit.cover,
                                  )
                                : AppImage(
                                    avatarUrl(_user?.image),
                                    width: 84,
                                    height: 84,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Positioned(
                            right: -2,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: _uploadingPhoto ? null : _pickProfilePhoto,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: Color(0xff8343D5),
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  color: Color(0xff120333),
                                ),
                                child: Center(
                                  child: _uploadingPhoto
                                      ? SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : ShaderMask(
                                          shaderCallback: ((bounds) {
                                            return defaultGradientTTB
                                                .createShader(bounds);
                                          }),
                                          child: Icon(
                                            Remix.camera_4_fill,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // TABBER
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 1,
                        color: Color.fromRGBO(197, 138, 166, 0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => updateSelectedTab('Basic'),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1,
                                  color: selectedTab == 'Basic'
                                      ? Color(0xff9110DE)
                                      : Colors.transparent,
                                ),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Basic',
                                style: TextStyle(
                                  color: selectedTab == 'Basic'
                                      ? Color(0xff9110DE)
                                      : Color(0xff9D8AC5),
                                  fontSize: 16,
                                  fontWeight: selectedTab == 'Basic'
                                      ? FontWeight.bold
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => updateSelectedTab('Extras'),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1,
                                  color: selectedTab == 'Extras'
                                      ? Color(0xff9110DE)
                                      : Colors.transparent,
                                ),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Extras',
                                style: TextStyle(
                                  color: selectedTab == 'Extras'
                                      ? Color(0xff9110DE)
                                      : Color(0xff9D8AC5),
                                  fontSize: 16,
                                  fontWeight: selectedTab == 'Extras'
                                      ? FontWeight.bold
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ID
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ID:',
                        style: TextStyle(
                          color: Color(0xff9D8AC5),
                          fontSize: 12,
                        ),
                      ),
                      Row(
                        spacing: 8,
                        children: [
                          Text(
                            _user?.identifier ?? '',
                            style: TextStyle(
                              color: Color(0xff9D8AC5),
                              fontSize: 12,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => copyToClipboard(_user?.identifier ?? ''),
                            child: Icon(
                              Remix.file_copy_line,
                              color: Color(0xff9D8AC5),
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // TABS
                if (_error != null)
                  ErrorState(message: _error!, onRetry: _load, height: 200)
                else if (_user == null)
                  const LoadingState(height: 200)
                else
                  Visibility(
                    visible: selectedTab == 'Basic',
                    replacement: ExtrasProfileForm(),
                    child: BasicProfileForm(user: _user!, onSaved: _save),
                  ),

                // SPACING
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
