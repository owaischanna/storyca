import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';
import 'package:storryca/src/core/widgets/border_gradient_button.dart';
import 'package:storryca/src/core/widgets/custom_dropdown.dart';
import 'package:storryca/src/core/widgets/gradient_button.dart';
import 'package:storryca/src/features/story/presentation/widgets/step_counter_item.dart';
import 'package:storryca/src/features/story/presentation/widgets/tags_text_field.dart';
import 'package:textfield_tags/textfield_tags.dart';

class Step2 extends StatelessWidget {
  const Step2({
    super.key,
    required this.updateStep,
    required this.titleController,
    required this.languageController,
    required this.regionController,
    required this.updateState,
    required this.contentRating,
    required this.updateContentRating,
    required this.tagsController,
    required this.targetAudience,
    required this.updateTargetAudience,
    required this.languages,
    required this.regions,
    this.initialTags = const [],
  });

  /// Tags already chosen — the story's own when editing, or the ones typed
  /// before stepping away — so returning to this step doesn't lose them.
  final List<String> initialTags;

  final void Function(int) updateStep;
  final void Function() updateState;
  final TextEditingController titleController;
  final TextEditingController languageController;
  final TextEditingController regionController;
  final String contentRating;
  final void Function(String rating) updateContentRating;
  final StringTagController tagsController;
  final String targetAudience;
  final void Function(String audience) updateTargetAudience;
  final List<String> languages;
  final List<String> regions;

  @override
  Widget build(BuildContext context) {
    List contentRatings = ['Everyone', '4+', '12+', '16+', '18+'];
    List<TargetAudience> targetAudiences = [
      TargetAudience(name: 'General', icon: Remix.team_line),
      TargetAudience(name: 'Male', icon: Remix.men_line),
      TargetAudience(name: 'Female', icon: Remix.women_line),
    ];

    // Only default these once — see the matching comment in step_1.dart for
    // why setting them unconditionally on every build was destructive.
    if (languageController.text.isEmpty && languages.isNotEmpty) {
      languageController.text = languages.first;
    }
    if (regionController.text.isEmpty && regions.isNotEmpty) {
      regionController.text = regions.first;
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
              Expanded(child: Divider(color: Color(secondaryCOLR))),
              StepCounterItem(step: 2, label: 'Settings', isActive: true),
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
                      Remix.equalizer_line,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ),
                Column(
                  spacing: 4,
                  children: [
                    Text(
                      'Story Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Help readers discover your story by setting the right details',
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
              // CONTENT RATING
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
                            TextSpan(text: 'Content Rating', style: whiteF12TS),
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
                        'Choose the rating that best matches your story’s content',
                        style: TextStyle(color: Colors.white70, fontSize: 8),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        spacing: 16,
                        children: [
                          ...List.generate(contentRatings.length, (index) {
                            final item = contentRatings[index];
                            final isSelected = contentRating == item;
                            return GestureDetector(
                              onTap: () => updateContentRating(item),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: isSelected
                                        ? Color(secondaryCOLR)
                                        : Color.fromRGBO(157, 138, 197, 0.5),
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item,
                                  style: isSelected
                                      ? secondaryF12TS
                                      : defaultTextStyle,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // TAGS
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
                            TextSpan(text: 'Tags', style: whiteF12TS),
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
                        'Add tags to help readers find your story.',
                        style: TextStyle(color: Colors.white70, fontSize: 8),
                      ),
                    ],
                  ),
                  TextFieldTags(
                    textfieldTagsController: tagsController,
                    initialTags: initialTags,
                    textSeparators: [' ', ','],
                    inputFieldBuilder: (context, values) {
                      const maxTags = 3;
                      final canAddTag = values.tags.length < maxTags;

                      return Column(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TagsTextField(
                            tagController: tagsController,
                            controller: values.textEditingController,
                            focusNode: values.focusNode,
                            placeholder: values.tags.isEmpty
                                ? 'Type a tag and press space'
                                : '',
                            hideText: false,
                            hasPrefixIcon: false,
                            hasSuffixIcon: false,
                            radius: 6,
                            borderColor: Color.fromRGBO(145, 16, 222, 0.2),
                            prefixIcon: values.tags.isNotEmpty
                                ? SingleChildScrollView(
                                    controller: values.tagScrollController,
                                    scrollDirection: Axis.horizontal,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: values.tags.map((tag) {
                                          return Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 5,
                                                ),
                                                decoration: BoxDecoration(
                                                  gradient:
                                                      defaultGradientTTB50,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                child: Row(
                                                  spacing: 8,
                                                  children: [
                                                    Text(
                                                      tag,
                                                      style: whiteF12TS,
                                                    ),
                                                    GestureDetector(
                                                      onTap: () => values
                                                          .onTagRemoved(tag),
                                                      child: Icon(
                                                        Remix.close_large_line,
                                                        size: 12,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  )
                                : null,
                            onSubmitted: () {
                              if (!canAddTag) return;

                              values.onTagSubmitted(
                                values.textEditingController.text,
                              );
                            },
                            suffixAction: () {},
                            onChange: (value) {
                              if (!canAddTag) return;

                              values.onTagChanged(value);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  Row(
                    spacing: 4,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return defaultGradientTTB.createShader(bounds);
                        },
                        child: Icon(
                          Remix.information_line,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                      Text('max of 3 tags', style: defaultTextStyle10),
                    ],
                  ),
                ],
              ),

              // LANGUAGE AND REGION
              Row(
                spacing: 16,
                children: [
                  // LANGUAGE
                  Expanded(
                    child: Column(
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
                                  TextSpan(text: 'Language', style: whiteF12TS),
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
                              'select the primary language of your story',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 8,
                              ),
                            ),
                          ],
                        ),
                        CustomDropdown(
                          controller: languageController,
                          items: languages,
                          borderColor: Color.fromRGBO(145, 16, 222, 0.2),
                          iconColor: Colors.white,
                          radius: 6,
                          prefixIcon: Remix.global_line,
                        ),
                      ],
                    ),
                  ),

                  // REGION
                  Expanded(
                    child: Column(
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
                                  TextSpan(text: 'Region', style: whiteF12TS),
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
                              'Choose the region this story is targeted for',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 8,
                              ),
                            ),
                          ],
                        ),
                        CustomDropdown(
                          controller: regionController,
                          items: regions,
                          borderColor: Color.fromRGBO(145, 16, 222, 0.2),
                          iconColor: Colors.white,
                          radius: 6,
                          prefixIcon: Remix.map_pin_line,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // TARGET AUDIENCE
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
                            TextSpan(
                              text: 'Target Audience',
                              style: whiteF12TS,
                            ),
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
                        'Who is your main audience',
                        style: TextStyle(color: Colors.white70, fontSize: 8),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 16,
                    children: [
                      ...targetAudiences.map((item) {
                        final isSelected = item.name == targetAudience;

                        return Expanded(
                          child: GestureDetector(
                            onTap: () => updateTargetAudience(item.name),
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: isSelected
                                      ? Color(secondaryCOLR)
                                      : Color.fromRGBO(157, 138, 197, 0.5),
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Column(
                                spacing: 4,
                                children: [
                                  Icon(
                                    item.icon,
                                    color: isSelected
                                        ? Color(0xFF9110DE)
                                        : Color(primaryTextCOLR),
                                    size: 24,
                                  ),
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected
                                          ? Color(0xFF9110DE)
                                          : Color(primaryTextCOLR),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // ACTION
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 120,
                height: 40,
                child: BorderGradientButton(
                  label: 'Back: Basics',
                  hasIcon: true,
                  icon: Remix.arrow_left_s_line,
                  padding: EdgeInsets.all(0),
                  radius: 8,
                  fontSize: 12,
                  onPressed: () => updateStep(1),
                ),
              ),
              SizedBox(
                width: 120,
                height: 40,
                child: GradientButton(
                  label: 'Next: Cover',
                  hasIcon: true,
                  icon: Remix.arrow_right_s_line,
                  padding: EdgeInsets.all(0),
                  radius: 8,
                  fontSize: 12,
                  reverse: true,
                  onPressed: () => updateStep(3),
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

class TargetAudience {
  final String name;
  final IconData icon;

  TargetAudience({required this.name, required this.icon});
}
