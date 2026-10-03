import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';
import 'package:storryca/src/core/widgets/custom_dropdown.dart';
import 'package:storryca/src/core/widgets/custom_field.dart';
import 'package:storryca/src/core/widgets/gradient_button.dart';
import 'package:storryca/src/features/story/presentation/widgets/step_counter_item.dart';

class Step1 extends StatelessWidget {
  const Step1({
    super.key,
    required this.updateStep,
    required this.titleController,
    required this.genreController,
    required this.summaryController,
    required this.updateState,
    required this.genres,
  });

  final void Function(int) updateStep;
  final void Function() updateState;
  final TextEditingController titleController;
  final TextEditingController genreController;
  final TextEditingController summaryController;
  final List<String> genres;

  @override
  Widget build(BuildContext context) {
    // Only set the placeholder once — this widget is rebuilt on every
    // keystroke elsewhere in the wizard (via `updateState`), and overwriting
    // the controller's text unconditionally on every build was wiping out
    // whatever genre the author had already picked.
    if (genreController.text.isEmpty) {
      genreController.text = 'Select a genre';
    }

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
              Expanded(
                child: Divider(color: Color.fromRGBO(157, 138, 187, 0.2)),
              ),
              StepCounterItem(step: 2, label: 'Settings', isActive: false),
              Expanded(
                child: Divider(color: Color.fromRGBO(157, 138, 187, 0.2)),
              ),
              StepCounterItem(step: 3, label: 'Cover', isActive: false),
              Expanded(
                child: Divider(color: Color.fromRGBO(157, 138, 187, 0.2)),
              ),
              StepCounterItem(step: 4, label: 'Review', isActive: false),
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
                    child: Icon(
                      Remix.file_edit_line,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ),
                Column(
                  spacing: 4,
                  children: [
                    Text(
                      'Story Basics',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Let’s start building your next great story',
                      style: defaultTextStyle10,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // FORM
          Column(
            spacing: 16,
            children: [
              // TITLE
              Column(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    spacing: 4,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: 'Title', style: whiteF12TS),
                            TextSpan(
                              text: ' *',
                              style: TextStyle(
                                color: Color(0xFFC23B3B),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Choose a title that captures your story.',
                        style: TextStyle(color: Colors.white70, fontSize: 8),
                      ),
                    ],
                  ),
                  CustomTextField(
                    controller: titleController,
                    placeholder: 'e.g Bound by shadow',
                    hideText: false,
                    hasPrefixIcon: false,
                    hasSuffixIcon: true,
                    borderColor: Color.fromRGBO(145, 16, 222, 0.2),
                    radius: 6,
                    maxLength: 100,
                    suffixIcon: SizedBox(
                      height: 40,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${titleController.text.length}/100',
                            style: defaultTextStyle10,
                          ),
                        ],
                      ),
                    ),
                    onSubmitted: () {},
                    suffixAction: () {},
                    onChange: (value) {
                      updateState();
                    },
                  ),
                ],
              ),

              // GENRE
              Column(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    spacing: 4,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: 'Genre', style: whiteF12TS),
                            TextSpan(
                              text: ' *',
                              style: TextStyle(
                                color: Color(0xFFC23B3B),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Select the genre/niche that best fits your story',
                        style: TextStyle(color: Colors.white70, fontSize: 8),
                      ),
                    ],
                  ),
                  CustomDropdown(
                    controller: genreController,
                    items: genres,
                    borderColor: Color.fromRGBO(145, 16, 222, 0.2),
                    iconColor: Colors.white,
                    radius: 6,
                  ),
                ],
              ),

              // SUMMARY
              Column(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    spacing: 4,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: 'Summary', style: whiteF12TS),
                            TextSpan(
                              text: ' *',
                              style: TextStyle(
                                color: Color(0xFFC23B3B),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Write a short summary to introduce your story to readers.',
                        style: TextStyle(color: Colors.white70, fontSize: 8),
                      ),
                    ],
                  ),
                  CustomTextField(
                    controller: summaryController,
                    placeholder: 'Write your story summary...',
                    hideText: false,
                    hasPrefixIcon: false,
                    hasSuffixIcon: true,
                    borderColor: Color.fromRGBO(145, 16, 222, 0.2),
                    radius: 6,
                    maxLines: 4,
                    maxLength: 500,
                    onSubmitted: () {},
                    suffixAction: () {},
                    suffixIcon: SizedBox(
                      height: 40,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${summaryController.text.length}/500',
                            style: defaultTextStyle10,
                          ),
                        ],
                      ),
                    ),
                    onChange: (value) => updateState(),
                  ),
                  Row(
                    spacing: 4,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return defaultGradientTTB.createShader(bounds);
                        },
                        child: Icon(
                          Remix.lightbulb_ai_line,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                      Text(
                        'A great summary hooks readers and makes them want to read more.',
                        style: defaultTextStyle10,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // ACTION
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 120,
                height: 40,
                child: GradientButton(
                  label: 'Next: Settings',
                  hasIcon: true,
                  icon: Remix.arrow_right_s_line,
                  padding: EdgeInsets.all(0),
                  radius: 8,
                  fontSize: 12,
                  reverse: true,
                  onPressed: () => updateStep(2),
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
