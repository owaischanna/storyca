import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/widgets/dashed_line.dart';

class TSVInfoModal extends StatelessWidget {
  const TSVInfoModal({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.all(0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF0D0216),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              spacing: 16,
              children: [
                // HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(),
                    Text(
                      'How it works',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Icon(
                        Remix.close_large_line,
                        size: 18,
                        color: Color(0xFFB54DE8),
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: 16,
                  children: [
                    SizedBox(
                      height: 170,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: Stack(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 0.5,
                                      color: Color(0xff8343D5),
                                    ),
                                    borderRadius: BorderRadius.circular(40),
                                    gradient: profileIconCardGradientCOLR,
                                  ),
                                  child: Icon(
                                    Remix.lock_password_line,
                                    size: 22,
                                    color: Color(0xffCF7FFA),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF9110DE),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '1',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                            child: DashedLine(
                              axis: Axis.vertical,
                              length: 20,
                              color: Color(0xFF9D8AC5),
                              dashWidth: 4,
                              dashGap: 4,
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: Stack(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 0.5,
                                      color: Color(0xff8343D5),
                                    ),
                                    borderRadius: BorderRadius.circular(40),
                                    gradient: profileIconCardGradientCOLR,
                                  ),
                                  child: Icon(
                                    Remix.smartphone_line,
                                    size: 22,
                                    color: Color(0xffCF7FFA),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF9110DE),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '2',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                            child: DashedLine(
                              axis: Axis.vertical,
                              length: 20,
                              color: Color(0xFF9D8AC5),
                              dashWidth: 4,
                              dashGap: 4,
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: Stack(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 0.5,
                                      color: Color(0xff8343D5),
                                    ),
                                    borderRadius: BorderRadius.circular(40),
                                    gradient: profileIconCardGradientCOLR,
                                  ),
                                  child: Icon(
                                    Remix.shield_check_fill,
                                    size: 22,
                                    color: Color(0xffCF7FFA),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF9110DE),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '3',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1,
                                  color: Color.fromRGBO(157, 138, 197, 0.2),
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 4,
                              children: [
                                Text(
                                  'Enter your password',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'You’ll  enter your password as you normally do.',
                                  style: TextStyle(
                                    color: Color(0xff9D8AC5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1,
                                  color: Color.fromRGBO(157, 138, 197, 0.2),
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 4,
                              children: [
                                Text(
                                  'Get verification code',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Go to Google Authenticator and copy your code',
                                  style: TextStyle(
                                    color: Color(0xff9D8AC5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 4,
                              children: [
                                Text(
                                  'Enter the code',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Enter the code to verify it’s you and access your account.',
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
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
