import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/core/widgets/custom_field.dart';
import 'package:storryca/src/core/widgets/gradient_button.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool passwordVisibility = false;
  bool confirmPasswordVisibility = false;
  bool isAgreed = false;

  void togglePasswordVisibility() {
    setState(() {
      passwordVisibility = !passwordVisibility;
    });
  }

  void toggleConfirmPasswordVisibility() {
    setState(() {
      confirmPasswordVisibility = !confirmPasswordVisibility;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF020004),
      body: Container(
        decoration: BoxDecoration(gradient: pageGradientCOLR),
        child: SingleChildScrollView(
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  // HEADER
                  IconButton(
                    onPressed: () {
                      context.pop();
                    },
                    icon: Icon(Remix.arrow_left_s_line),
                    color: Colors.white,
                    iconSize: 24,
                  ),

                  // HERO
                  Center(
                    child: Column(
                      spacing: 2,
                      children: [
                        Text(
                          'Reset Password',
                          style: GoogleFonts.playfair(
                            color: Colors.white,
                            fontSize: 34,
                          ),
                        ),
                        Text(
                          'Create a new strong password for your account',
                          style: TextStyle(
                            color: Color(primaryTextCOLR),
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 32),
                        Image.asset(resetPasswordIMG, width: 180),
                      ],
                    ),
                  ),

                  // FORM
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      spacing: 16,
                      children: [
                        // EMAIL
                        Column(
                          spacing: 8,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email Address',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(145, 16, 222, 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                spacing: 8,
                                children: [
                                  Icon(
                                    Remix.mail_line,
                                    color: Color(0xff9110DE),
                                    size: 18,
                                  ),
                                  Text(
                                    'lilsoftx@gmail.com',
                                    style: TextStyle(
                                      color: Color(primaryTextCOLR),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // PASSWORD
                        Column(
                          spacing: 8,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            CustomTextField(
                              controller: passwordController,
                              placeholder: 'Enter your password',
                              hideText: passwordVisibility,
                              hasPrefixIcon: true,
                              hasSuffixIcon: true,
                              prefixIcon: Remix.git_repository_private_line,
                              suffixIcon: Icon(
                                passwordVisibility
                                    ? Remix.eye_close_line
                                    : Remix.eye_line,
                                color: Color(0xFF9D8AC5),
                                size: 24,
                              ),
                              onSubmitted: () {},
                              suffixAction: () => togglePasswordVisibility(),
                              onChange: (value) {},
                            ),
                          ],
                        ),

                        // CONFIRM PASSWORD
                        Column(
                          spacing: 8,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Confirm Password',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            CustomTextField(
                              controller: confirmPasswordController,
                              placeholder: 'It’s the same as the last password',
                              hideText: confirmPasswordVisibility,
                              hasPrefixIcon: true,
                              hasSuffixIcon: true,
                              prefixIcon: Remix.git_repository_private_line,
                              suffixIcon: Icon(
                                confirmPasswordVisibility
                                    ? Remix.eye_close_line
                                    : Remix.eye_line,
                                color: Color(0xFF9D8AC5),
                                size: 24,
                              ),
                              onSubmitted: () {},
                              suffixAction: () =>
                                  toggleConfirmPasswordVisibility(),
                              onChange: (value) {},
                            ),
                          ],
                        ),

                        // BUTTON
                        GradientButton(
                          label: 'Update Password',
                          hasIcon: false,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  // NO ACCOUNT
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: // INFO
                    Row(
                      spacing: 8,
                      children: [
                        Icon(
                          Remix.shield_check_line,
                          color: Color(0xff9110DE),
                          size: 24,
                        ),
                        Expanded(
                          child: Text(
                            'For your security, you’ll be signed in to your account after resetting your password.',
                            style: TextStyle(
                              color: Color(primaryTextCOLR),
                              fontSize: 12,
                            ),
                          ),
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
      ),
    );
  }
}
