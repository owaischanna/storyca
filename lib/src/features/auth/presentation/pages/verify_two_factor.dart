import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/widgets/app_snackbar.dart';
import 'package:storryca/src/core/widgets/gradient_button.dart';
import 'package:storryca/src/core/widgets/single_text_input_field.dart';

/// The second step of signing in to a 2FA-enabled account — entering the
/// current code from the reader's authenticator app. Unlike [VerifyEmail],
/// there is no code to resend here (the authenticator app generates it, the
/// server never sends one), and the pending session this depends on is
/// held server-side for 5 minutes, after which it has to restart at Sign In.
class VerifyTwoFactor extends StatefulWidget {
  const VerifyTwoFactor({super.key});

  @override
  State<VerifyTwoFactor> createState() => _VerifyTwoFactorState();
}

class _VerifyTwoFactorState extends State<VerifyTwoFactor> {
  static const int otpLength = 6;
  static const int _sessionSeconds = 5 * 60;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  Timer? _timer;
  int _secondsLeft = _sessionSeconds;
  bool _expired = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(otpLength, (_) => FocusNode());
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 0) {
        timer.cancel();
        setState(() => _expired = true);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String _formatTime(int seconds) {
    final mm = (seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (seconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  bool _isOtpComplete() => _controllers.every((c) => c.text.trim().isNotEmpty);

  void _handleChanged({required int index, required String value}) {
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.length > 1) {
      _fillFromPaste(digitsOnly);
      return;
    }

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

    if (_isOtpComplete()) submit();
  }

  void _handleBackspace(int index) {
    if (_controllers[index].text.isNotEmpty) {
      _controllers[index].clear();
      return;
    }
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
    if (_isOtpComplete()) submit();
  }

  Future<void> submit() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length != otpLength) {
      AppSnackbar.error(context, 'Enter the 6-digit code.');
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await authService.verifyTwoFactor(code);
      if (!mounted) return;
      context.go('/main/1');
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.isUnauthorized) {
        // "No pending two-step verification session." — the 5-minute window
        // ran out server-side even if our own countdown hasn't hit zero yet.
        setState(() => _expired = true);
      }
      AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
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
                    onPressed: () => context.go('/signin'),
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
                            'Two-Step Verification',
                            style: GoogleFonts.playfair(
                              color: Colors.white,
                              fontSize: 34,
                            ),
                          ),
                          Text(
                            'Enter the 6-digit code from your authenticator app.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(primaryTextCOLR),
                              fontSize: 12,
                            ),
                          ),
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
                        // OTP
                        Row(
                          spacing: 8,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...List.generate(
                              otpLength,
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

                        // SESSION TIMER / EXPIRED
                        Center(
                          child: _expired
                              ? Column(
                                  spacing: 8,
                                  children: [
                                    Text(
                                      'This sign-in attempt has expired.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(primaryTextCOLR),
                                        fontSize: 14,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => context.go('/signin'),
                                      child: Text(
                                        'Back to Sign In',
                                        style: TextStyle(
                                          color: Color(0xFF9110DE),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'This code expires in ',
                                        style: TextStyle(
                                          color: Color(primaryTextCOLR),
                                          fontSize: 16,
                                        ),
                                      ),
                                      TextSpan(
                                        text: _formatTime(_secondsLeft),
                                        style: TextStyle(
                                          color: Color(0xFF9110DE),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),

                        // BUTTON
                        GradientButton(
                          label: _isSubmitting ? 'Verifying...' : 'Verify & Continue',
                          hasIcon: false,
                          onPressed: (_isSubmitting || _expired) ? () {} : submit,
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
