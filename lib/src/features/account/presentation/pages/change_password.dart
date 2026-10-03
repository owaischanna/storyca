import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/widgets/app_snackbar.dart';
import 'package:storryca/src/core/widgets/custom_field.dart';
import 'package:storryca/src/core/widgets/gradient_button.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => ChangePasswordState();
}

class ChangePasswordState extends State<ChangePassword> {
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmNewPasswordController = TextEditingController();

  bool newPasswordVisibility = false;
  bool confirmNewPasswordVisibility = false;
  bool _saving = false;

  void toggleNewPasswordVisibility() {
    setState(() {
      newPasswordVisibility = !newPasswordVisibility;
    });
  }

  void toggleConfirmNewPasswordVisibility() {
    setState(() {
      confirmNewPasswordVisibility = !confirmNewPasswordVisibility;
    });
  }

  Future<void> _save() async {
    final current = currentPasswordController.text;
    final next = newPasswordController.text;
    final confirm = confirmNewPasswordController.text;

    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      AppSnackbar.warning(context, 'All password fields are required.');
      return;
    }
    if (next != confirm) {
      AppSnackbar.warning(context, 'New password and confirm password do not match.');
      return;
    }
    if (next.length < 8) {
      AppSnackbar.warning(context, 'New password must be at least 8 characters.');
      return;
    }

    final token = await authService.getToken();
    if (token == null) {
      if (mounted) AppSnackbar.warning(context, 'Sign in to change your password.');
      return;
    }

    setState(() => _saving = true);
    try {
      await usersRepository.changePassword(
        token,
        currentPassword: current,
        newPassword: next,
        confirmPassword: confirm,
      );
      if (mounted) {
        AppSnackbar.success(context, 'Password changed successfully.');
        context.pop();
      }
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.displayMessage);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
                        'Change Password',
                        style: GoogleFonts.playfair(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // PROFILE PHOTO
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(100),
                    child: Image.asset(noAvatarIMG, width: 84, height: 84),
                  ),
                ),

                // FORM
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
                  child: Column(
                    spacing: 16,
                    children: [
                      // CURRENT PASSWORD
                      Column(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Password',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          CustomTextField(
                            controller: currentPasswordController,
                            placeholder: '',
                            hideText: true,
                            hasPrefixIcon: false,
                            hasSuffixIcon: false,
                            onSubmitted: () {},
                            suffixAction: () {},
                            onChange: (value) {},
                          ),
                        ],
                      ),

                      // NEW PASSWORD
                      Column(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New Password',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          CustomTextField(
                            controller: newPasswordController,
                            placeholder: '',
                            hideText: newPasswordVisibility,
                            hasPrefixIcon: false,
                            hasSuffixIcon: true,
                            suffixIcon: Icon(
                              newPasswordVisibility
                                  ? Remix.eye_close_line
                                  : Remix.eye_line,
                              color: Color(0xFF9D8AC5),
                              size: 24,
                            ),
                            onSubmitted: () {},
                            suffixAction: () => toggleNewPasswordVisibility(),
                            onChange: (value) {},
                          ),
                        ],
                      ),

                      // CONFIRM NEW PASSWORD
                      Column(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Confirm New Password',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          CustomTextField(
                            controller: confirmNewPasswordController,
                            placeholder: '',
                            hideText: confirmNewPasswordVisibility,
                            hasPrefixIcon: false,
                            hasSuffixIcon: true,
                            suffixIcon: Icon(
                              confirmNewPasswordVisibility
                                  ? Remix.eye_close_line
                                  : Remix.eye_line,
                              color: Color(0xFF9D8AC5),
                              size: 24,
                            ),
                            onSubmitted: () {},
                            suffixAction: () =>
                                toggleConfirmNewPasswordVisibility(),
                            onChange: (value) {},
                          ),
                        ],
                      ),

                      // BUTTON
                      GradientButton(
                        label: _saving ? 'Saving…' : 'Save',
                        hasIcon: true,
                        icon: Remix.checkbox_circle_line,
                        onPressed: _saving ? () {} : _save,
                      ),
                    ],
                  ),
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
