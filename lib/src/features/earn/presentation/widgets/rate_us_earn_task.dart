import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';
import 'package:storryca/src/core/widgets/app_snackbar.dart';
import 'package:storryca/src/core/widgets/gradient_button.dart';
import 'package:url_launcher/url_launcher.dart';

/// Google forbids rewarding ratings, so this never touches the wallet — it
/// only opens the Play Store listing. There is no App Store equivalent here
/// yet (the app's numeric App Store ID isn't derivable from the bundle ID
/// the way an Android `packageName` doubles as its own Play Store ID).
Future<void> _openStoreListing(BuildContext context) async {
  if (Platform.isIOS) {
    AppSnackbar.info(context, 'Rating is available on the Play Store app.');
    return;
  }
  final packageName = (await PackageInfo.fromPlatform()).packageName;
  final opened = await launchUrl(
    Uri.parse('market://details?id=$packageName'),
    mode: LaunchMode.externalApplication,
  );
  if (!opened && context.mounted) {
    AppSnackbar.error(context, 'Could not open the Play Store.');
  }
}

class RateUsEarnTask extends StatelessWidget {
  const RateUsEarnTask({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Color.fromRGBO(181, 77, 232, 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Expanded(
            child: Row(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Color(0xff8343D5)),
                    borderRadius: BorderRadius.circular(6),
                    gradient: profileIconCardGradientCOLR,
                  ),
                  child: Image.asset(rateStarIMG, width: 40),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Row(
                        spacing: 4,
                        children: [
                          Expanded(
                            child: Text(
                              'Rate Us on Play Store',
                              style: GoogleFonts.playfair(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 3,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(153, 79, 255, 0.1),
                              border: Border.all(
                                width: 0.1,
                                color: Color(0xFF994FFF),
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'One Time',
                              style: TextStyle(
                                color: Color(0xFF994FFF),
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Tell others what you think — no reward, just love.',
                        style: defaultTextStyle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 65,
                height: 30,
                child: GradientButton(
                  label: 'Rate Now',
                  fontSize: 12,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  radius: 4,
                  onPressed: () => _openStoreListing(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
