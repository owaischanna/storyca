import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/core/widgets/custom_field.dart';
import 'package:storryca/src/core/widgets/gradient_button.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();

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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: Column(
                        spacing: 2,
                        children: [
                          Text(
                            'Forgot Password',
                            style: GoogleFonts.playfair(
                              color: Colors.white,
                              fontSize: 34,
                            ),
                          ),
                          Text(
                            'No worries Enter your email address and we’ll send you a link to retest your password.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(primaryTextCOLR),
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 32),
                          Image.asset(forgotPasswordIMG, width: 180),
                        ],
                      ),
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

                        // BUTTON
                        GradientButton(
                          label: 'Send Reset Link',
                          hasIcon: false,
                          onPressed: () => context.push('/verify-email'),
                        ),

                        // INFO
                        Row(
                          spacing: 8,
                          children: [
                            Icon(
                              Remix.information_line,
                              color: Color(0xff9110DE),
                              size: 16,
                            ),
                            Expanded(
                              child: Text(
                                'if you don’t see the email, check your spam folder.',
                                style: TextStyle(
                                  color: Color(primaryTextCOLR),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
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
                          'OR',
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

                  // SIGN IN
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Remember your password? ',
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
