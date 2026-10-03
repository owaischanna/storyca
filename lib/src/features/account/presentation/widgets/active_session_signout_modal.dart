import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/features/account/contents/account_settings_content.dart';

class ActiveSessionSignoutModal extends StatelessWidget {
  const ActiveSessionSignoutModal({super.key, required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(0),
      backgroundColor: Colors.transparent,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF0D0216),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              spacing: 16,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
                Text(
                  'Sign Out of All Devices',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  activeSessionSigmoutModalCaption,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xff9D8AC5), fontSize: 12),
                ),
                Column(
                  spacing: 8,
                  children: [
                    // DELETE BUTTON
                    GestureDetector(
                      onTap: onConfirm,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: defaultGradientTTB,
                        ),
                        child: Center(
                          child: Text(
                            'Sign Out',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ),

                    // CANCEL BUTTON
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 0.3,
                            color: Color(0xff9D8AC5),
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.transparent,
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xFF9D8AC5),
                              fontSize: 12,
                            ),
                          ),
                        ),
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
