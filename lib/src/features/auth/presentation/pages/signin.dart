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

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool passwordVisibility = false;
  bool isSubmitting = false;

  void togglePasswordVisibility() {
    setState(() {
      passwordVisibility = !passwordVisibility;
    });
  }

  Future<void> submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      AppSnackbar.error(context, 'Enter your email and password.');
      return;
    }
    setState(() => isSubmitting = true);
    try {
      final result = await authService.login(email, password);
      if (!mounted) return;
      if (result.requires2fa) {
        context.go('/verify-two-factor');
      } else if (result.requiresEmailVerification) {
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
      AppSnackbar.error(context, 'Sign in failed: $e');
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
                          'Welcome Back',
                          style: GoogleFonts.playfair(
                            color: Colors.white,
                            fontSize: 34,
                          ),
                        ),
                        Text(
                          'Sign in to continue to your account',
                          style: TextStyle(
                            color: Color(primaryTextCOLR),
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 32),
                        Image.asset(signinIMG, width: 180),
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

                        // FORGOT
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () => context.push('/forgot-password'),
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Color(0xFF9110DE),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // BUTTON
                        GradientButton(
                          label: isSubmitting ? 'Signing In...' : 'Sign In',
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
                          'OR CONTINUE WITH',
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
                        onTap: () => context.pushReplacement('/signup'),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Don’t have an account? ',
                                style: TextStyle(
                                  color: Color(primaryTextCOLR),
                                  fontSize: 12,
                                ),
                              ),
                              TextSpan(
                                text: 'Sign Up',
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
