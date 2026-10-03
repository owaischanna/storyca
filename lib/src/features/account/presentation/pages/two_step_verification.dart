import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/core/widgets/gradient_button.dart';
import 'package:storryca/src/features/account/contents/account_settings_content.dart';
import 'package:storryca/src/features/account/contents/tsv_options_content.dart';
import 'package:storryca/src/features/account/presentation/widgets/tsv_info_modal.dart';
import 'package:storryca/src/features/account/presentation/widgets/tsv_option_item.dart';

class TwoStepVerification extends StatefulWidget {
  const TwoStepVerification({super.key});

  @override
  State<TwoStepVerification> createState() => _TwoStepVerificationState();
}

class _TwoStepVerificationState extends State<TwoStepVerification> {
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        'Two-Step Verification',
                        style: GoogleFonts.playfair(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierColor: Color.fromRGBO(255, 255, 255, 0.15),
                            builder: (context) {
                              return TSVInfoModal();
                            },
                          );
                        },
                        child: Icon(
                          Remix.question_line,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                // HERO
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    spacing: 8,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(twoStepVerificationIMG, width: 200),
                        ],
                      ),
                      Text(
                        'Add an extra layer of security',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        tsvHeroCaption,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(primaryTextCOLR),
                        ),
                      ),
                    ],
                  ),
                ),

                // MENU OPTIONS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        width: 1,
                        color: Color.fromRGBO(157, 138, 197, 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        ...List.generate(tsvOptionItems.length, (index) {
                          final item = tsvOptionItems[index];
                          return TSVOptionItem(
                            icon: item.icon,
                            title: item.title,
                            caption: item.caption,
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                // BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GradientButton(
                    label: 'Enable Two-Step Verification',
                    hasIcon: true,
                    icon: Remix.shield_check_line,
                    onPressed: () => context.pushReplacement('/enable-tsv'),
                  ),
                ),

                // NOT NOW
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Center(
                    child: Text(
                      'Not now',
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
