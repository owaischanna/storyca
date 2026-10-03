import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/features/profile/presentation/contents/profile.contents.dart';

class ProfileFooterAuth extends StatelessWidget {
  const ProfileFooterAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Color(0xffB54DE8)),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          spacing: 16,
          children: [
            Expanded(
              child: Row(
                spacing: 16,
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Color(0xff8343D5)),
                      borderRadius: BorderRadius.circular(40),
                      gradient: profileIconCardGradientCOLR,
                    ),
                    child: Image.asset(authIconIMG, width: 20),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Login or Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          profileAuthCaption,
                          softWrap: true,
                          style: TextStyle(
                            color: Color(0xff9D8AC5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => context.push('/signin'),
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: defaultGradientTTB,
                ),
                child: Row(
                  children: [
                    Text(
                      'Login / Sign Up',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Icon(
                      Remix.arrow_right_s_line,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
