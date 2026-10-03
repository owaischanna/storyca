import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/auth_service.dart';
import 'package:storryca/src/core/widgets/app_image.dart';
import 'package:storryca/src/core/widgets/app_snackbar.dart';
import 'package:storryca/src/core/widgets/gradient_button.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/core/widgets/single_text_input_field.dart';
import 'package:storryca/src/features/account/contents/account_settings_content.dart';

class EnableTSV extends StatefulWidget {
  const EnableTSV({super.key});

  @override
  State<EnableTSV> createState() => EnableTSVState();
}

class EnableTSVState extends State<EnableTSV> {
  static const int otpLength = 6;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  String? _token;
  TwoFactorSetup? _setup;
  String? _loadError;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(otpLength, (_) => TextEditingController());

    _focusNodes = List.generate(otpLength, (_) => FocusNode());
    _loadSetup();
  }

  Future<void> _loadSetup() async {
    setState(() => _loadError = null);
    final token = await authService.getToken();
    if (token == null) {
      setState(() => _loadError = 'Sign in to enable two-step verification.');
      return;
    }
    _token = token;
    try {
      final setup = await authService.setupTwoFactor(token);
      if (mounted) setState(() => _setup = setup);
    } on ApiException catch (e) {
      if (mounted) setState(() => _loadError = e.displayMessage);
    }
  }

  void _showSecret() {
    final secret = _setup?.secret;
    if (secret == null || secret.isEmpty) return;
    showDialog(
      context: context,
      barrierColor: Color.fromRGBO(255, 255, 255, 0.15),
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xff0E0318),
        title: Text(
          'Manual setup key',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        content: SelectableText(
          secret,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Close',
              style: TextStyle(color: Color(0xff9110DE)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _verify() async {
    final code = _controllers.map((c) => c.text).join();
    final token = _token;
    if (code.length != otpLength) {
      AppSnackbar.error(context, 'Enter the 6-digit code.');
      return;
    }
    if (token == null || _isVerifying) return;
    setState(() => _isVerifying = true);
    try {
      await authService.enableTwoFactor(token, code);
      if (!mounted) return;
      context.pushReplacement('/tsv-enabled-success');
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
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
      _verify();
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
      _verify();
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
                        'Enable Two-Step Verification',
                        style: GoogleFonts.playfair(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // CAPTION
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: EdgeInsetsGeometry.only(bottom: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 1,
                          color: Color.fromRGBO(157, 138, 197, 0.2),
                        ),
                      ),
                    ),
                    child: Text(
                      tsvEnableHeroCaption,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),

                // STEP 1
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 1,
                          color: Color.fromRGBO(157, 138, 197, 0.2),
                        ),
                      ),
                    ),
                    child: Row(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Color(0xff9110DE),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              '1',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            spacing: 16,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 2,
                                children: [
                                  Text(
                                    'Download Google Authenticator',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    tsvStep1Caption,
                                    style: TextStyle(
                                      color: Color(0xff9D8AC5),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                spacing: 16,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 0.5,
                                        color: Color(0xff5C09B4),
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Row(
                                      spacing: 8,
                                      children: [
                                        Image.asset(googleIconIMG, width: 18),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'GET IT ON',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              'Google Play',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 0.5,
                                        color: Color(0xff5C09B4),
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Row(
                                      spacing: 8,
                                      children: [
                                        Image.asset(appleIconIMG, width: 18),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Download on the ',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              'App Store',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // STEP 2
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 1,
                          color: Color.fromRGBO(157, 138, 197, 0.2),
                        ),
                      ),
                    ),
                    child: Row(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Color(0xff9110DE),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              '2',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            spacing: 16,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 2,
                                children: [
                                  Text(
                                    'Scan the QR code',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    tsvStep2Caption,
                                    style: TextStyle(
                                      color: Color(0xff9D8AC5),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                spacing: 16,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 140,
                                    height: 140,
                                    padding: EdgeInsets.all(8),
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      // A QR code needs a solid white quiet
                                      // zone to scan reliably — without this,
                                      // a QR image with a transparent
                                      // background (common from a
                                      // server-generated PNG) loses contrast
                                      // against this screen's dark theme and
                                      // reads as broken/illegible.
                                      color: Colors.white,
                                      border: Border.all(
                                        width: 1,
                                        color: Color(0xff9110DE),
                                      ),
                                      borderRadius:
                                          BorderRadiusGeometry.circular(8),
                                    ),
                                    child:
                                        (_setup?.qrUrl.isNotEmpty ?? false)
                                            ? AppImage(
                                                _setup!.qrUrl,
                                                width: 124,
                                                height: 124,
                                                // Never crop a scannable
                                                // code — `cover` (AppImage's
                                                // default once a size is
                                                // given) can cut off the
                                                // finder patterns if the
                                                // source image isn't exactly
                                                // square.
                                                fit: BoxFit.contain,
                                              )
                                            : _loadError != null
                                                ? Icon(
                                                    Remix.qr_code_line,
                                                    color: Colors.black26,
                                                    size: 48,
                                                  )
                                                : const LoadingState(
                                                    height: 124,
                                                  ),
                                  ),
                                  GestureDetector(
                                    onTap: _showSecret,
                                    child: Text(
                                      'Can’t scan the code?',
                                      style: TextStyle(
                                        color: Color(0xff9110DE),
                                        fontSize: 12,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Color(0xff9110DE),
                                      ),
                                    ),
                                  ),
                                  if (_loadError != null)
                                    Text(
                                      _loadError!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xffC23B3B),
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // STEP 3
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Row(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Color(0xff9110DE),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              '3',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            spacing: 16,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 2,
                                children: [
                                  Text(
                                    'Enter the 6-digit code',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    tsvStep3Caption,
                                    style: TextStyle(
                                      color: Color(0xff9D8AC5),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                spacing: 8,
                                children: [
                                  ...List.generate(
                                    6,
                                    (index) => SingleTextInputField(
                                      controller: _controllers[index],
                                      focusNode: _focusNodes[index],
                                      onChanged: (value) => _handleChanged(
                                        index: index,
                                        value: value,
                                      ),
                                      onBackspace: () =>
                                          _handleBackspace(index),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GradientButton(
                    label: _isVerifying ? 'Verifying…' : 'Verify',
                    onPressed: _isVerifying ? () {} : _verify,
                  ),
                ),

                // CANCEL
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Center(
                    child: Text(
                      'Cancel',
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
