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
import 'package:storryca/src/core/widgets/single_text_input_field.dart';
import 'package:storryca/src/features/account/contents/account_settings_content.dart';

class DisableTSV extends StatefulWidget {
  const DisableTSV({super.key});

  @override
  State<DisableTSV> createState() => _DisableTSVState();
}

class _DisableTSVState extends State<DisableTSV> {
  static const int otpLength = 6;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisibility = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(otpLength, (_) => TextEditingController());

    _focusNodes = List.generate(otpLength, (_) => FocusNode());
  }

  Future<void> _disable() async {
    final code = _controllers.map((c) => c.text).join();
    final password = _passwordController.text;
    if (code.length != otpLength) {
      AppSnackbar.error(context, 'Enter the 6-digit code.');
      return;
    }
    if (password.isEmpty) {
      AppSnackbar.error(context, 'Enter your current password.');
      return;
    }
    if (_isSubmitting) return;
    final token = await authService.getToken();
    if (token == null) {
      if (mounted) {
        AppSnackbar.warning(context, 'Sign in to manage two-step verification.');
      }
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await authService.disableTwoFactor(
        token: token,
        code: code,
        currentPassword: password,
      );
      if (!mounted) return;
      AppSnackbar.success(context, 'Two-step verification disabled.');
      context.go('/account-security');
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
  }

  @override
  void dispose() {
    _passwordController.dispose();
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
                    spacing: 16,
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
                        'Disable Two-Step Verification',
                        style: GoogleFonts.playfair(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // HERO
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Image.asset(tsvDisableIMG, width: 200),
                ),

                // WARNING
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Color(0xff520E92)),
                      borderRadius: BorderRadius.circular(12),
                      color: Color.fromRGBO(20, 4, 46, 0.6),
                    ),
                    child: Row(
                      spacing: 8,
                      children: [
                        Image.asset(tsvWarningIMG, width: 60),
                        Expanded(
                          child: Column(
                            spacing: 4,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Are you sure?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                disableTSVWarningCaption,
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
                  ),
                ),

                // TITLE AND CAPTION
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    spacing: 4,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'To disable, verify it’s you',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        disableTSVHeroCaption,
                        style: TextStyle(
                          color: Color(primaryTextCOLR),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // OTP CODE
                Row(
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(
                      6,
                      (index) => SingleTextInputField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        onChanged: (value) =>
                            _handleChanged(index: index, value: value),
                        onBackspace: () => _handleBackspace(index),
                      ),
                    ),
                  ],
                ),

                // CURRENT PASSWORD
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Password',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      CustomTextField(
                        controller: _passwordController,
                        placeholder: 'Enter your password',
                        hideText: !_passwordVisibility,
                        hasPrefixIcon: false,
                        hasSuffixIcon: true,
                        suffixIcon: Icon(
                          _passwordVisibility
                              ? Remix.eye_close_line
                              : Remix.eye_line,
                          color: Color(0xFF9D8AC5),
                          size: 24,
                        ),
                        onSubmitted: () {},
                        suffixAction: () => setState(
                          () => _passwordVisibility = !_passwordVisibility,
                        ),
                        onChange: (value) {},
                      ),
                    ],
                  ),
                ),

                // BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GradientButton(
                    label: _isSubmitting
                        ? 'Disabling…'
                        : 'Disable Two-Step Verification',
                    hasIcon: true,
                    icon: Remix.error_warning_line,
                    onPressed: _isSubmitting ? () {} : _disable,
                  ),
                ),

                // NOT NOW
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Center(
                    child: Text(
                      'Go to Account & Security',
                      style: TextStyle(color: Color(0xff9110DE), fontSize: 16),
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
    );
  }
}
