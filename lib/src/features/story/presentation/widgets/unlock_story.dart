import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';
import 'package:storryca/src/core/widgets/gradient_button.dart';

class UnlockStory extends StatelessWidget {
  const UnlockStory({
    super.key,
    required this.unlockStory,
    required this.price,
    this.unlocking = false,
    this.freeChapters = 0,
  });

  /// The book's free opening chapters, from the server's flags.
  final int freeChapters;

  final void Function() unlockStory;

  /// The book's price in coins, from the wallet — null while it's still
  /// loading (e.g. the reader isn't signed in yet), in which case the price
  /// row is left blank rather than showing a guessed number.
  final num? price;
  final bool unlocking;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Color.fromRGBO(181, 77, 232, 0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 16,
        children: [
          Expanded(
            child: Row(
              spacing: 8,
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.3, color: Color(0xff8343D5)),
                    borderRadius: BorderRadius.circular(6),
                    gradient: profileIconCardGradientCOLR,
                  ),
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return defaultGradientTTB.createShader(bounds);
                    },
                    child: Icon(
                      Remix.lock_2_line,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text('Unlock to Read', style: whiteF14TS),
                      Text(
                        freeChapters > 0
                            ? 'The first $freeChapters '
                                  '${freeChapters == 1 ? 'chapter is' : 'chapters are'} '
                                  'free. Unlock all chapters to read the rest.'
                            : 'Unlock this book to start reading all chapters.',
                        style: defaultTextStyle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (price != null)
                Row(
                  spacing: 4,
                  children: [
                    Image.asset(aCoinIMG, width: 16),
                    Text(
                      price!.toStringAsFixed(price! % 1 == 0 ? 0 : 1),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              SizedBox(
                width: 88,
                height: 30,
                child: GradientButton(
                  label: unlocking ? 'Unlocking…' : 'Unlock Now',
                  fontSize: 12,
                  radius: 5,
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                  onPressed: unlocking ? () {} : unlockStory,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
