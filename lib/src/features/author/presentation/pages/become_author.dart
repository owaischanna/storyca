import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/models/author_request_api_model.dart';
import 'package:storryca/src/core/widgets/app_snackbar.dart';
import 'package:storryca/src/core/widgets/custom_badge.dart';
import 'package:storryca/src/core/widgets/gradient_button.dart';
import 'package:storryca/src/features/author/presentation/contents/author_center_content.dart';
import 'package:url_launcher/url_launcher.dart';

class BecomeAuthor extends StatefulWidget {
  const BecomeAuthor({super.key});

  @override
  State<BecomeAuthor> createState() => _BecomeAuthorState();
}

class _BecomeAuthorState extends State<BecomeAuthor> {
  AuthorRequestApiModel? _request;
  bool _loaded = false;
  bool _submitting = false;
  String? _token;

  /// Set when the status check itself failed (rather than succeeding and
  /// saying "no request exists"). Defaulting to "no request" on a failed
  /// check would let someone who already applied see an active Apply Now
  /// button again after a cold app restart, since the in-memory cookie jar
  /// is empty until the first successful call of the new session — so a
  /// failure here must keep applying blocked, not silently allow it.
  bool _statusCheckFailed = false;
  int _statusRetries = 0;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    _token = await authService.getToken();
    if (_token == null) {
      if (mounted) setState(() => _loaded = true);
      return;
    }
    try {
      final request = await usersRepository.authorRequestStatus(_token!);
      if (mounted) {
        setState(() {
          _request = request;
          _loaded = true;
          _statusCheckFailed = false;
          _statusRetries = 0;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _statusCheckFailed = true);
      // Transient (cold-start cookie/network hiccup) — try again shortly
      // rather than leaving the reader stuck behind a permanent block. Capped
      // so a genuinely broken connection doesn't retry forever in the
      // background.
      if (_statusRetries >= 3) return;
      _statusRetries++;
      await Future.delayed(const Duration(seconds: 3));
      if (mounted && _statusCheckFailed) _loadStatus();
    }
  }

  Future<void> _apply({required String source}) async {
    final token = _token;
    if (token == null) {
      AppSnackbar.warning(context, 'Sign in to apply.');
      return;
    }
    setState(() => _submitting = true);
    try {
      await usersRepository.submitAuthorRequest(token, source: source);
      if (mounted) {
        AppSnackbar.success(context, 'Author request submitted successfully.');
      }
      await _loadStatus();
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _emailNow() async {
    await launchUrl(
      Uri(
        scheme: 'mailto',
        path: 'storrycateam@gmail.com',
        query: 'subject=Author Application',
      ),
    );
  }

  /// null = show Apply Now, otherwise the button is disabled/relabeled.
  String? get _disabledLabel {
    if (_statusCheckFailed) return 'Checking status…';
    final request = _request;
    if (request == null) return null;
    if (request.isPending) return 'Under Review';
    if (request.isApproved) return 'Already an Author';
    return null; // declined -> allow re-applying
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
                Row(
                  spacing: 16,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 126,
                      padding: EdgeInsets.only(left: 16, bottom: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Icon(
                              Remix.arrow_left_s_line,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 2,
                            children: [
                              Text(
                                'Become an Author',
                                style: GoogleFonts.playfair(
                                  color: Colors.white,
                                  fontSize: 26,
                                ),
                              ),
                              Text(
                                'Share your story with the world on Storryca.',
                                style: defaultTextStyle,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Image.asset(becomeAuthorIMG, width: 100),
                  ],
                ),

                // INSTRUCTION
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Color.fromRGBO(181, 77, 232, 0.3),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      spacing: 16,
                      children: [
                        // LEAD
                        Row(
                          spacing: 8,
                          children: [
                            Image.asset(logoIMG, width: 30),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'STORRYCA NOVEL COMPANY LTD',
                                  style: GoogleFonts.playfair(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Author Submissions Guidelines',
                                  style: secondaryF12TS,
                                ),
                              ],
                            ),
                          ],
                        ),

                        // INFO
                        Text(
                          becomeAuthorInstructionCaption,
                          style: defaultTextStyle,
                        ),

                        // LIST OF ITEMS
                        Column(
                          spacing: 16,
                          children: [
                            // 1
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: Color.fromRGBO(181, 77, 232, 0.3),
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: Color.fromRGBO(181, 77, 232, 0.1),
                              ),
                              child: Row(
                                spacing: 8,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: profileIconCardGradientCOLR,
                                      border: Border.all(
                                        width: 0.5,
                                        color: Color.fromRGBO(
                                          181,
                                          77,
                                          232,
                                          0.3,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Center(
                                      child: ShaderMask(
                                        shaderCallback: (bounds) {
                                          return defaultGradientTTB
                                              .createShader(bounds);
                                        },
                                        child: Icon(
                                          Remix.shield_star_line,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      spacing: 16,
                                      children: [
                                        Text(
                                          '1. Originality Requirement',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          '• All submissions must be 100% original and written by the author\n• AI-generated, assisted, or plagiarized content is strictly prohibited\n• Any violation will result in automatic rejection',
                                          style: TextStyle(
                                            color: Color(primaryTextCOLR),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 2
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: Color.fromRGBO(181, 77, 232, 0.3),
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: Color.fromRGBO(181, 77, 232, 0.1),
                              ),
                              child: Row(
                                spacing: 8,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: profileIconCardGradientCOLR,
                                      border: Border.all(
                                        width: 0.5,
                                        color: Color.fromRGBO(
                                          181,
                                          77,
                                          232,
                                          0.3,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Center(
                                      child: ShaderMask(
                                        shaderCallback: (bounds) {
                                          return defaultGradientTTB
                                              .createShader(bounds);
                                        },
                                        child: Icon(
                                          Remix.file_list_3_line,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      spacing: 16,
                                      children: [
                                        Text(
                                          '2. Chapter Submission Requirements',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          'Applicants must submit a minimum of three (3) chapters.\nEach chapter must meet the following criteria:\n• Minimum of 1,000 characters per chapter\n• Well-structured and properly formatted\n• Clear grammar, punctuation, and readability\n• Engaging storytelling with a strong narrative flow',
                                          style: TextStyle(
                                            color: Color(primaryTextCOLR),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 3
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: Color.fromRGBO(181, 77, 232, 0.3),
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: Color.fromRGBO(181, 77, 232, 0.1),
                              ),
                              child: Row(
                                spacing: 8,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: profileIconCardGradientCOLR,
                                      border: Border.all(
                                        width: 0.5,
                                        color: Color.fromRGBO(
                                          181,
                                          77,
                                          232,
                                          0.3,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Center(
                                      child: ShaderMask(
                                        shaderCallback: (bounds) {
                                          return defaultGradientTTB
                                              .createShader(bounds);
                                        },
                                        child: Icon(
                                          Remix.file_pdf_2_line,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      spacing: 16,
                                      children: [
                                        Text(
                                          '2. File Format',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          '• All Submissions must be compiled into a single PDF document \n• The document should be neat, properly arranged, and professional\n• Include clear separation between chapters (e.g., Chapter 1, Chapter 2, Chapter 3)',
                                          style: TextStyle(
                                            color: Color(primaryTextCOLR),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 4
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: Color.fromRGBO(181, 77, 232, 0.3),
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: Color.fromRGBO(181, 77, 232, 0.1),
                              ),
                              child: Row(
                                spacing: 8,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: profileIconCardGradientCOLR,
                                      border: Border.all(
                                        width: 0.5,
                                        color: Color.fromRGBO(
                                          181,
                                          77,
                                          232,
                                          0.3,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Center(
                                      child: ShaderMask(
                                        shaderCallback: (bounds) {
                                          return defaultGradientTTB
                                              .createShader(bounds);
                                        },
                                        child: Icon(
                                          Remix.list_unordered,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      spacing: 16,
                                      children: [
                                        Text(
                                          '4. Genre/Niche Selection',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          'Applicants must clearly state the genre (niche) of their story. Storryca currently accepts the following categories:',
                                          style: TextStyle(
                                            color: Color(primaryTextCOLR),
                                            fontSize: 10,
                                          ),
                                        ),
                                        Wrap(
                                          runSpacing: 8,
                                          spacing: 8,
                                          children: [
                                            CustomBadge(
                                              label: 'Romance',
                                              fontSize: 10,
                                              textColor: Color(0xFFFF4DFF),
                                              borderColor: Color(0xFFFF4DFF),
                                              radius: 3,
                                              bgColor: Color.fromRGBO(
                                                255,
                                                77,
                                                255,
                                                0.1,
                                              ),
                                            ),
                                            CustomBadge(
                                              label: 'African Folktales',
                                              fontSize: 10,
                                              textColor: Color(0xFF00B076),
                                              borderColor: Color(0xFF00B076),
                                              radius: 3,
                                              bgColor: Color.fromRGBO(
                                                0,
                                                176,
                                                118,
                                                0.1,
                                              ),
                                            ),
                                            CustomBadge(
                                              label: 'Dark Romance',
                                              fontSize: 10,
                                              textColor: Color(0xFF00A3FD),
                                              borderColor: Color(0xFF00A3FD),
                                              radius: 3,
                                              bgColor: Color.fromRGBO(
                                                0,
                                                176,
                                                118,
                                                0.1,
                                              ),
                                            ),
                                            CustomBadge(
                                              label: 'Fantasy',
                                              fontSize: 10,
                                              textColor: Color(0xFFFE682E),
                                              borderColor: Color(0xFFFE682E),
                                              radius: 3,
                                              bgColor: Color.fromRGBO(
                                                0,
                                                176,
                                                118,
                                                0.1,
                                              ),
                                            ),
                                            CustomBadge(
                                              label: 'Werewolf Stories',
                                              fontSize: 10,
                                              textColor: Color(primaryTextCOLR),
                                              borderColor: Color(
                                                primaryTextCOLR,
                                              ),
                                              radius: 3,
                                              bgColor: Color.fromRGBO(
                                                0,
                                                176,
                                                118,
                                                0.1,
                                              ),
                                            ),
                                            CustomBadge(
                                              label: 'Inspirational Stories',
                                              fontSize: 10,
                                              textColor: Color(0xFFF89531),
                                              borderColor: Color(0xFFF89531),
                                              radius: 3,
                                              bgColor: Color.fromRGBO(
                                                0,
                                                176,
                                                118,
                                                0.1,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Note: Submissions outside these categories may not be considered.',
                                          style: TextStyle(
                                            color: Color(primaryTextCOLR),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 5
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: Color.fromRGBO(181, 77, 232, 0.3),
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: Color.fromRGBO(181, 77, 232, 0.1),
                              ),
                              child: Row(
                                spacing: 8,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: profileIconCardGradientCOLR,
                                      border: Border.all(
                                        width: 0.5,
                                        color: Color.fromRGBO(
                                          181,
                                          77,
                                          232,
                                          0.3,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Center(
                                      child: ShaderMask(
                                        shaderCallback: (bounds) {
                                          return defaultGradientTTB
                                              .createShader(bounds);
                                        },
                                        child: Icon(
                                          Remix.medal_line,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      spacing: 16,
                                      children: [
                                        Text(
                                          '5. Professional Presentation',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          '• Use readable fonts (e.g., Times New Roman, Arial)\n• Proper spacing and alignment\n• Include a title for your story\n• Optional: Include your name or pen name on the document',
                                          style: TextStyle(
                                            color: Color(primaryTextCOLR),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 6
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: Color.fromRGBO(181, 77, 232, 0.3),
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: Color.fromRGBO(181, 77, 232, 0.1),
                              ),
                              child: Row(
                                spacing: 8,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: profileIconCardGradientCOLR,
                                      border: Border.all(
                                        width: 0.5,
                                        color: Color.fromRGBO(
                                          181,
                                          77,
                                          232,
                                          0.3,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Center(
                                      child: ShaderMask(
                                        shaderCallback: (bounds) {
                                          return defaultGradientTTB
                                              .createShader(bounds);
                                        },
                                        child: Icon(
                                          Remix.mail_line,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      spacing: 16,
                                      children: [
                                        Text(
                                          '6. Submission Email',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text:
                                                    'Send your completed PDF and application to: ',
                                                style: TextStyle(
                                                  color: Color(primaryTextCOLR),
                                                  fontSize: 10,
                                                ),
                                              ),
                                              TextSpan(
                                                text: 'storrycateam@gmail.com',
                                                style: TextStyle(
                                                  color: Color(secondaryCOLR),
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // MESSAGE
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: Color.fromRGBO(181, 77, 232, 0.3),
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: Color.fromRGBO(181, 77, 232, 0.1),
                              ),
                              child: Row(
                                spacing: 8,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: profileIconCardGradientCOLR,
                                      border: Border.all(
                                        width: 0.5,
                                        color: Color.fromRGBO(
                                          181,
                                          77,
                                          232,
                                          0.3,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Center(
                                      child: ShaderMask(
                                        shaderCallback: (bounds) {
                                          return defaultGradientTTB
                                              .createShader(bounds);
                                        },
                                        child: Icon(
                                          Remix.bard_line,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      spacing: 16,
                                      children: [
                                        Text(
                                          'We look forward to discovering unique voices and powerful stories.',
                                          style: TextStyle(
                                            color: Color(primaryTextCOLR),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              'Storryca Novel Company Ltd',
                                              style: TextStyle(
                                                color: Color(primaryTextCOLR),
                                                fontSize: 10,
                                              ),
                                            ),
                                            Text(
                                              '“Where Stories Come Alive”',
                                              style: TextStyle(
                                                color: Color(secondaryCOLR),
                                                fontSize: 10,
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
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // DECLINED NOTE
                if (_request?.isDeclined == true &&
                    (_request?.reviewNote?.isNotEmpty ?? false))
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Color(0xffC23B3B)),
                        borderRadius: BorderRadius.circular(8),
                        color: Color.fromRGBO(194, 59, 59, 0.1),
                      ),
                      child: Text(
                        _request!.reviewNote!,
                        style: TextStyle(color: Color(0xffC23B3B), fontSize: 12),
                      ),
                    ),
                  ),

                // ACTIONS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _emailNow,
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Color(secondaryCOLR),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              spacing: 4,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) {
                                    return defaultGradientTTB.createShader(
                                      bounds,
                                    );
                                  },
                                  child: Icon(
                                    Remix.mail_line,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                ShaderMask(
                                  shaderCallback: (bounds) {
                                    return defaultGradientTTB.createShader(
                                      bounds,
                                    );
                                  },
                                  child: Text(
                                    'Email Now',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: GradientButton(
                            label:
                                _disabledLabel ??
                                (_submitting ? 'Submitting…' : 'Apply Now'),
                            hasIcon: true,
                            icon: Remix.ball_pen_line,
                            radius: 8,
                            padding: EdgeInsets.all(0),
                            onPressed: (!_loaded || _submitting || _disabledLabel != null)
                                ? () {}
                                : () => _apply(source: 'apply_now'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // FOOTER
                Text(
                  'All submissions will be reviewed by our editorial team.\nOnly selected applicants will be contacted.',
                  textAlign: TextAlign.center,
                  style: defaultTextStyle10,
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
