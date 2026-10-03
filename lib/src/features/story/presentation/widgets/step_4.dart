import 'package:dashed_border/dashed_border.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';
import 'package:storryca/src/core/widgets/border_gradient_button.dart';
import 'package:storryca/src/core/widgets/gradient_button.dart';
import 'package:storryca/src/features/story/presentation/widgets/step_counter_item.dart';

class Step4 extends StatelessWidget {
  const Step4({
    super.key,
    required this.updateStep,
    this.cover,
    required this.title,
    required this.genre,
    required this.summary,
    required this.contentRating,
    required this.tags,
    required this.language,
    required this.region,
    required this.targetAudience,
    required this.submitting,
    required this.onSubmit,
  });

  final void Function(int) updateStep;
  final dynamic cover;
  final String title;
  final String genre;
  final String summary;
  final String contentRating;
  final String tags;
  final String language;
  final String region;
  final String targetAudience;
  final bool submitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        spacing: 16,
        children: [
          // STEP INDICATOR
          Row(
            spacing: 8,
            children: [
              StepCounterItem(step: 1, label: 'Basic', isActive: true),
              Expanded(child: Divider(color: Color(secondaryCOLR))),
              StepCounterItem(step: 2, label: 'Settings', isActive: true),
              Expanded(child: Divider(color: Color(secondaryCOLR))),
              StepCounterItem(step: 3, label: 'Cover', isActive: true),
              Expanded(child: Divider(color: Color(secondaryCOLR))),
              StepCounterItem(step: 4, label: 'Review', isActive: true),
            ],
          ),

          // HERO
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              spacing: 16,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Color.fromRGBO(92, 9, 180, 0.1),
                  ),
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return defaultGradientTTB.createShader(bounds);
                    },
                    child: Icon(Remix.todo_line, color: Colors.white, size: 25),
                  ),
                ),
                Column(
                  spacing: 4,
                  children: [
                    Text(
                      'Review Your Story',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Please review all details below. You can go back to edit anything',
                      style: defaultTextStyle10,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // CARD
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color.fromRGBO(181, 77, 232, 0.1),
              border: Border.all(
                width: 1,
                color: Color.fromRGBO(181, 77, 232, 0.5),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  spacing: 16,
                  children: [
                    Text(
                      'Cover Preview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      width: 150,
                      height: 200,
                      decoration: BoxDecoration(
                        border: DashedBorder(
                          dashGap: 2,
                          dashLength: 2,
                          color: Color(0xFF9110DE),
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: cover != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image(
                                image: cover,
                                width: 150,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(),
                    ),
                    SizedBox(
                      width: 150,
                      height: 40,
                      child: BorderGradientButton(
                        label: cover != null ? 'Change Cover' : 'Upload Cover',
                        hasIcon: true,
                        icon: Remix.pencil_line,
                        radius: 6,
                        padding: EdgeInsets.all(0),
                        onPressed: () => updateStep(3),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    spacing: 16,
                    children: [
                      Column(
                        spacing: 16,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Basics',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              ShaderMask(
                                shaderCallback: (bounds) {
                                  return defaultGradientTTB.createShader(
                                    bounds,
                                  );
                                },
                                child: GestureDetector(
                                  onTap: () => updateStep(1),
                                  child: Row(
                                    spacing: 2,
                                    children: [
                                      Icon(
                                        Remix.pencil_line,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      Text(
                                        'Edit',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Title: ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: title.isEmpty ? '—' : title,
                                  style: whiteF10TS,
                                ),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Genre: ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: genre.isEmpty ? '—' : genre,
                                  style: whiteF10TS,
                                ),
                              ],
                            ),
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Summary',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                summary.isEmpty ? '—' : summary,
                                style: whiteF10TS,
                              ),
                            ],
                          ),

                          Divider(color: Color.fromRGBO(157, 138, 197, 0.3)),
                        ],
                      ),
                      Column(
                        spacing: 16,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Settings',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              ShaderMask(
                                shaderCallback: (bounds) {
                                  return defaultGradientTTB.createShader(
                                    bounds,
                                  );
                                },
                                child: GestureDetector(
                                  onTap: () => updateStep(2),
                                  child: Row(
                                    spacing: 2,
                                    children: [
                                      Icon(
                                        Remix.pencil_line,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      Text(
                                        'Edit',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Content Rating: ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: contentRating.isEmpty ? '—' : contentRating,
                                  style: whiteF10TS,
                                ),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Tags: ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: tags.isEmpty ? '—' : tags,
                                  style: whiteF10TS,
                                ),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Language: ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: language.isEmpty ? '—' : language,
                                  style: whiteF10TS,
                                ),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Region: ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: region.isEmpty ? '—' : region,
                                  style: whiteF10TS,
                                ),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Target Audience: ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: targetAudience.isEmpty ? '—' : targetAudience,
                                  style: whiteF10TS,
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

          // ACTION
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 120,
                height: 40,
                child: BorderGradientButton(
                  label: 'Back: Cover',
                  hasIcon: true,
                  icon: Remix.arrow_left_s_line,
                  padding: EdgeInsets.all(0),
                  radius: 8,
                  fontSize: 12,
                  onPressed: () => updateStep(3),
                ),
              ),
              SizedBox(
                width: 120,
                height: 40,
                child: GradientButton(
                  label: submitting ? 'Submitting…' : 'Submit Story',
                  hasIcon: true,
                  icon: Remix.arrow_right_s_line,
                  padding: EdgeInsets.all(0),
                  radius: 8,
                  fontSize: 12,
                  reverse: true,
                  onPressed: submitting ? () {} : onSubmit,
                ),
              ),
            ],
          ),

          // FOOTER
          Padding(
            padding: EdgeInsetsGeometry.only(top: 100, bottom: 20),
            child: Row(
              spacing: 4,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Remix.save_3_line,
                  color: Color(primaryTextCOLR),
                  size: 12,
                ),
                Text(
                  'All changes are saved automatically',
                  style: defaultTextStyle10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
