import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/core/widgets/gradient_button.dart';
import 'package:storryca/src/features/account/contents/account_settings_content.dart';
import 'package:storryca/src/features/account/contents/tsv_enabled_success_content.dart';
import 'package:storryca/src/features/account/presentation/widgets/tsv_option_item.dart';

class TsvEnabledSuccess extends StatefulWidget {
  const TsvEnabledSuccess({super.key});

  @override
  State<TsvEnabledSuccess> createState() => _TsvEnabledSuccessState();
}

class _TsvEnabledSuccessState extends State<TsvEnabledSuccess> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF020004),
      body: Container(
        decoration: BoxDecoration(gradient: pageGradientCOLR),
        child: SingleChildScrollView(
          child: SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [
                  // HERO
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      spacing: 8,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Image.asset(tsvEnabledIMG, width: 200)],
                        ),
                        Text(
                          'Two-Step Verification is enabled',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          tsvEnableHeroCaption,
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
                      padding: EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          width: 1,
                          color: Color.fromRGBO(157, 138, 197, 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          ...List.generate(tsvEnabledSuccessItems.length, (
                            index,
                          ) {
                            final item = tsvEnabledSuccessItems[index];
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
                      label: 'Done',
                      hasIcon: false,
                      onPressed: () => context.go('/account-security'),
                    ),
                  ),

                  // NOT NOW
                  GestureDetector(
                    onTap: () => context.push('/account-security'),
                    child: Center(
                      child: Text(
                        'Go to Account & Security',
                        style: TextStyle(
                          color: Color(0xff9110DE),
                          fontSize: 16,
                        ),
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
      ),
    );
  }
}
