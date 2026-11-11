import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';
import 'package:storryca/src/core/widgets/gradient_button.dart';

/// Shown on a book page in place of "Unlock to Read" when nobody is signed
/// in: reading (and unlocking) needs an account first.
class SignInToRead extends StatelessWidget {
  const SignInToRead({super.key, this.freeChapters = 0});

  /// The book's free opening chapters, from the server's flags.
  final int freeChapters;

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
                      Remix.user_3_line,
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
                      Text('Sign In to Read', style: whiteF14TS),
                      Text(
                        freeChapters > 0
                            ? 'Read the first $freeChapters '
                                  '${freeChapters == 1 ? 'chapter' : 'chapters'} '
                                  'free. Sign in or create an account to '
                                  'continue after that.'
                            : 'Sign in or create an account to start reading '
                                  'this book.',
                        style: defaultTextStyle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            spacing: 6,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 96,
                height: 30,
                child: GradientButton(
                  label: 'Sign In',
                  fontSize: 12,
                  radius: 5,
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                  onPressed: () => context.push('/signin'),
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/signup'),
                child: Container(
                  width: 96,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 0.5,
                      color: Color.fromRGBO(195, 132, 255, 0.5),
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    'Create Account',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
