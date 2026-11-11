import 'package:flutter/gestures.dart';
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
import 'package:url_launcher/url_launcher.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool passwordVisibility = false;
  bool confirmPasswordVisibility = false;
  bool isAgreed = false;

  /// The age question, as on the website. Unticked = under 18: books rated
  /// 18+ stay hidden from this account.
  bool isAdult = false;
  bool isSubmitting = false;

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

  Future<void> _openLegalPage(String path) async {
    await launchUrl(
      Uri.parse('https://storryca.com/$path'),
      mode: LaunchMode.inAppBrowserView,
    );
  }

  Future<void> submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    if (email.isEmpty || password.isEmpty) {
      AppSnackbar.error(context, 'Enter your email and password.');
      return;
    }
    if (password != confirmPassword) {
      AppSnackbar.error(context, 'Passwords do not match.');
      return;
    }
    if (!isAgreed) {
      AppSnackbar.error(context, 'Please agree to the Terms and Privacy Policy.');
      return;
    }
    setState(() => isSubmitting = true);
    try {
      final result = await authService.register(
        email,
        password,
        confirmPassword,
        isAdult: isAdult,
      );
      if (!mounted) return;
      if (result.requiresEmailVerification) {
        context.go(
          '/verify-email',
          extra: {'email': result.email, 'token': result.token!},
        );
      } else {
        context.go('/main/1');
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, e.message);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Sign up failed: $e');
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  Future<void> googleSignIn() async {
    setState(() => isSubmitting = true);
    try {
      final result = await authService.loginWithGoogle();
      if (!mounted || result == null) return;
      context.go('/main/1');
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => isSubmitting = false);
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
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  // HEADER
                  IconButton(
                    onPressed: () {
                      // Opened from onboarding's Login there is nothing to
                      // go back to — go into the app instead of failing.
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/main/2');
                      }
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
                          'Create Account',
                          style: GoogleFonts.playfair(
                            color: Colors.white,
                            fontSize: 34,
                          ),
                        ),
                        Text(
                          'Join now and start your journey',
                          style: TextStyle(
                            color: Color(primaryTextCOLR),
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 32),
                        Image.asset(signupIMG, width: 180),
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
                            CustomTextField(
                              controller: emailController,
                              placeholder: 'Enter your email',
                              hideText: false,
                              hasPrefixIcon: true,
                              hasSuffixIcon: false,
                              prefixIcon: Remix.mail_line,
                              onSubmitted: () {},
                              suffixAction: () {},
                              onChange: (value) {},
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

                        // TERMS & CONDITIONS
                        Row(
                          children: [
                            Checkbox(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              activeColor: Color(0xFF9110DE),
                              side: BorderSide(
                                width: 1,
                                color: Color(primaryTextCOLR),
                              ),
                              value: isAgreed,
                              onChanged: (value) {
                                setState(() {
                                  isAgreed = !isAgreed;
                                });
                              },
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'I agree to the ',
                                      style: TextStyle(
                                        color: Color(primaryTextCOLR),
                                        fontSize: 12,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: TextStyle(
                                        color: Color(0xff9110DE),
                                        fontSize: 12,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () =>
                                            _openLegalPage('terms-of-service'),
                                    ),
                                    TextSpan(
                                      text: ' and ',
                                      style: TextStyle(
                                        color: Color(primaryTextCOLR),
                                        fontSize: 12,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        color: Color(0xff9110DE),
                                        fontSize: 12,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () =>
                                            _openLegalPage('privacy-policy'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // AGE
                        Row(
                          children: [
                            Checkbox(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              activeColor: Color(0xFF9110DE),
                              side: BorderSide(
                                width: 1,
                                color: Color(primaryTextCOLR),
                              ),
                              value: isAdult,
                              onChanged: (value) {
                                setState(() => isAdult = !isAdult);
                              },
                            ),
                            Expanded(
                              child: Text(
                                'I am 18 years of age or older. (Leave unticked '
                                'if you are under 18 — you will not see books '
                                'rated 18+.)',
                                style: TextStyle(
                                  color: Color(primaryTextCOLR),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // BUTTON
                        GradientButton(
                          label: isSubmitting ? 'Signing Up...' : 'Sign Up',
                          hasIcon: false,
                          onPressed: isSubmitting ? () {} : submit,
                        ),
                      ],
                    ),
                  ),

                  // DIVIDER
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      spacing: 16,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1,
                                  color: Color.fromRGBO(157, 138, 197, 0.2),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          'OR SIGN UP WITH',
                          style: TextStyle(
                            color: Color(primaryTextCOLR),
                            fontSize: 12,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1,
                                  color: Color.fromRGBO(157, 138, 197, 0.2),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // GOOGLE
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
                      onTap: isSubmitting ? null : googleSignIn,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Color.fromRGBO(145, 16, 222, 0.2),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          spacing: 8,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(googleIMG, width: 24, height: 24),
                            Text(
                              'Continue with Google',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // NO ACCOUNT
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: GestureDetector(
                        onTap: () => context.pushReplacement('/signin'),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Already have an account? ',
                                style: TextStyle(
                                  color: Color(primaryTextCOLR),
                                  fontSize: 12,
                                ),
                              ),
                              TextSpan(
                                text: 'Sign In',
                                style: TextStyle(
                                  color: Color(0xff9110DE),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
