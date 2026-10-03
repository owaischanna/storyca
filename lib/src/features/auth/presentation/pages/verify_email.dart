import 'dart:async';

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
import 'package:storryca/src/core/widgets/gradient_button.dart';
import 'package:storryca/src/core/widgets/single_text_input_field.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key, required this.email, required this.token});

  final String email;
  final String token;

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  static const int otpLength = 6;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  Timer? timer;
  int secondsLeft = 59;
  bool canRequestNewCode = false;
  bool isSubmitting = false;
  late String email = widget.email;

  @override
  void initState() {
    super.initState();
    startCountDown();

    _controllers = List.generate(otpLength, (_) => TextEditingController());

    _focusNodes = List.generate(otpLength, (_) => FocusNode());

    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final status = await authService.emailVerificationStatus(widget.token);
      if (!mounted) return;
      setState(() {
        if (status.email.isNotEmpty) email = status.email;
      });
      if (status.expiresAtUnix > 0) {
        final secondsLeftFromServer =
            status.expiresAtUnix -
            (DateTime.now().millisecondsSinceEpoch ~/ 1000);
        if (secondsLeftFromServer > 0) {
          secondsLeft = secondsLeftFromServer;
        }
        startCountDown();
      }
    } on ApiException catch (_) {
      // Keep the local countdown/email if status can't be fetched.
    }
  }

  void startCountDown() {
    timer?.cancel();
    canRequestNewCode = false;

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsLeft == 0) {
        timer.cancel();
        canRequestNewCode = true;
        setState(() {});
      } else {
        setState(() {
          secondsLeft--;
        });
      }
    });
  }

  // String _getOtp() {
  //   return _controllers.map((c) => c.text).join();
  // }

  String formatTime(int seconds) {
    final mm = (seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (seconds % 60).toString().padLeft(2, '0');
    return "$mm:$ss";
  }

  bool _isOtpComplete() {
    return _controllers.every((c) => c.text.trim().isNotEmpty);
  }

  void _handleChanged({required int index, required String value}) {
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');

    // Paste support
    if (digitsOnly.length > 1) {
      _fillFromPaste(digitsOnly);
      return;
    }

    // Single digit entered
    if (digitsOnly.isNotEmpty) {
      _controllers[index].text = digitsOnly;
      _controllers[index].selection = TextSelection.fromPosition(
        const TextPosition(offset: 1),
      );

      if (index < otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }

    if (_isOtpComplete()) {
      submit();
    }
  }

  void _handleBackspace(int index) {
    // If current box has value, clear it first
    if (_controllers[index].text.isNotEmpty) {
      _controllers[index].clear();
      return;
    }

    // If current box is empty, move back and clear previous
    if (index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    }
  }

  void _fillFromPaste(String pastedText) {
    final digits = pastedText.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return;

    for (int i = 0; i < otpLength; i++) {
      _controllers[i].text = i < digits.length ? digits[i] : '';
    }

    final lastFilledIndex = digits.length >= otpLength
        ? otpLength - 1
        : digits.length - 1;

    if (lastFilledIndex >= 0) {
      if (digits.length >= otpLength) {
        _focusNodes[otpLength - 1].unfocus();
      } else {
        _focusNodes[lastFilledIndex + 1].requestFocus();
      }
    }

    setState(() {});

    if (_isOtpComplete()) {
      submit();
    }
  }

  Future<void> submit() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length != otpLength) {
      AppSnackbar.error(context, 'Enter the 6-digit code.');
      return;
    }
    setState(() => isSubmitting = true);
    try {
      await authService.verifyEmail(widget.token, code);
      if (!mounted) return;
      AppSnackbar.success(context, 'Email verified. Please sign in.');
      context.go('/signin');
    } on ApiException catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  Future<void> getNewCode() async {
    canRequestNewCode = false;
    try {
      final expiresAtUnix = await authService.resendVerificationEmail(
        widget.token,
      );
      if (!mounted) return;
      if (expiresAtUnix > 0) {
        secondsLeft =
            expiresAtUnix - (DateTime.now().millisecondsSinceEpoch ~/ 1000);
      } else {
        secondsLeft = 59;
      }
      startCountDown();
      AppSnackbar.success(context, 'A new code has been sent.');
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 429) {
        // A code was already sent recently — not a real error.
        startCountDown();
        AppSnackbar.info(context, 'A code was already sent. Check your email.');
        return;
      }
      canRequestNewCode = true;
      setState(() {});
      AppSnackbar.error(context, e.message);
    }
  }

  @override
  void dispose() {
    timer?.cancel();

    for (final controller in _controllers) {
      controller.dispose();
    }

    for (final node in _focusNodes) {
      node.dispose();
    }

    super.dispose();
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: Column(
                        spacing: 2,
                        children: [
                          Text(
                            'Verify Your Email',
                            style: GoogleFonts.playfair(
                              color: Colors.white,
                              fontSize: 34,
                            ),
                          ),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Enter the 6-digit code sent to ',
                                  style: TextStyle(
                                    color: Color(primaryTextCOLR),
                                    fontSize: 12,
                                  ),
                                ),
                                TextSpan(
                                  text: email,
                                  style: TextStyle(
                                    color: Color(0xff9110DE),
                                    fontSize: 12,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      ' Please check your inbox and spam folder.',
                                  style: TextStyle(
                                    color: Color(primaryTextCOLR),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 32),
                          Image.asset(verifyEmailIMG, width: 180),
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
                        // FORM INSTRUCTION
                        Text(
                          'Enter 6-digit code',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),

                        // OTP
                        Row(
                          spacing: 8,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...List.generate(
                              6,
                              (index) => SingleTextInputField(
                                height: 70,
                                widthRatio: 0.12,
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                onChanged: (value) =>
                                    _handleChanged(index: index, value: value),
                                onBackspace: () => _handleBackspace(index),
                              ),
                            ),
                          ],
                        ),

                        // TIMER
                        if (!canRequestNewCode)
                          Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Get a new code ",
                                    style: TextStyle(
                                      color: Color(primaryTextCOLR),
                                      fontSize: 16,
                                    ),
                                  ),
                                  TextSpan(
                                    text: formatTime(secondsLeft),
                                    style: TextStyle(
                                      color: Color(0xFF9110DE),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // RESEND
                        if (canRequestNewCode)
                          Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Didn't receive the code ",
                                    style: TextStyle(
                                      color: Color(primaryTextCOLR),
                                      fontSize: 16,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Resend Code',
                                    style: TextStyle(
                                      color: Color(0xFF9110DE),
                                      fontSize: 16,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => getNewCode(),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // BUTTON
                        GradientButton(
                          label: isSubmitting ? 'Verifying...' : 'Verify & Continue',
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
                          'Need help?',
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

                  // CONTACT SUPPORT
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Contact Support',
                          style: TextStyle(
                            color: Color(0xff9110DE),
                            fontSize: 12,
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
