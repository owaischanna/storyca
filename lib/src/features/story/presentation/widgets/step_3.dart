import 'dart:io';

import 'package:dashed_border/dashed_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';
import 'package:storryca/src/core/widgets/border_gradient_button.dart';
import 'package:storryca/src/core/widgets/gradient_button.dart';
import 'package:storryca/src/features/story/presentation/widgets/step_counter_item.dart';

class Step3 extends StatefulWidget {
  const Step3({
    super.key,
    required this.updateStep,
    this.cover,
    required this.updateSelectedImage,
    this.trailer,
  });

  /// The optional "Novel Trailer" field, shown under the cover.
  final Widget? trailer;

  final void Function(int) updateStep;
  final dynamic cover;
  final void Function(dynamic) updateSelectedImage;

  @override
  State<Step3> createState() => _Step3State();
}

class _Step3State extends State<Step3> {
  final ImagePicker imagePicker = ImagePicker();

  Future pickImageFromGallery() async {
    final XFile? selectedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      imageQuality: 85,
    );

    if (selectedImage != null) {
      widget.updateSelectedImage(FileImage(File(selectedImage.path)));
    }
  }

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
                      Remix.image_add_line,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ),
                Column(
                  spacing: 4,
                  children: [
                    Text(
                      'Cover',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Add a cover that represents your story and stands our to readers',
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
              // STORY COVER
              Column(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.cover == null
                      ? Column(
                          spacing: 4,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Story Cover',
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
                              'Upload a cover image that represents your story.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 8,
                              ),
                            ),
                          ],
                        )
                      : SizedBox.shrink(),
                  widget.cover == null
                      ? Column(
                          spacing: 16,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                border: DashedBorder(
                                  dashGap: 2,
                                  dashLength: 2,
                                  color: Color(0xff9110DE),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                spacing: 16,
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) {
                                      return defaultGradientTTB.createShader(
                                        bounds,
                                      );
                                    },
                                    child: Icon(
                                      Remix.upload_cloud_2_line,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Upload your cover',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Drag and drop an image here',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text('or', style: whiteF10TS),
                                  SizedBox(
                                    width: 120,
                                    height: 40,
                                    child: BorderGradientButton(
                                      label: 'Browser Files',
                                      padding: EdgeInsets.all(0),
                                      radius: 6,
                                      onPressed: () => pickImageFromGallery(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Recommended size: 300 x 400 px (3:4 ratio)',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  'File types: JPG, PNG • Max size: 10MB',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Column(
                          spacing: 16,
                          children: [
                            SizedBox(
                              width: 200,
                              height: 268,
                              child: Stack(
                                children: [
                                  Container(
                                    width: 200,
                                    height: 268,
                                    decoration: BoxDecoration(
                                      border: DashedBorder(
                                        dashGap: 2,
                                        dashLength: 2,
                                        color: Color(0xFF9110DE),
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image(
                                        image: widget.cover,
                                        width: 200,
                                        height: 268,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: GestureDetector(
                                      onTap: () {
                                        widget.updateSelectedImage(null);
                                      },
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                          color: Color.fromRGBO(
                                            194,
                                            59,
                                            59,
                                            0.1,
                                          ),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Remix.delete_bin_5_line,
                                            color: Color(0xFFC23B3B),
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Column(
                              spacing: 8,
                              children: [
                                Text('Cover Preview', style: whiteF12TS),
                                Text(
                                  'This is how your cover will appear in the app',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                                SizedBox(
                                  width: 150,
                                  height: 40,
                                  child: BorderGradientButton(
                                    label: 'Change Cover',
                                    hasIcon: true,
                                    icon: Remix.pencil_line,
                                    radius: 6,
                                    padding: EdgeInsets.all(0),
                                    onPressed: () => pickImageFromGallery(),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Recommended size: 300 x 400 px (3:4 ratio)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  'File types: JPG, PNG • Max size: 10MB',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ],
              ),

              // NOVEL TRAILER
              ?widget.trailer,
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
                  label: 'Back: Settings',
                  hasIcon: true,
                  icon: Remix.arrow_left_s_line,
                  padding: EdgeInsets.all(0),
                  radius: 8,
                  fontSize: 12,
                  onPressed: () => widget.updateStep(2),
                ),
              ),
              SizedBox(
                width: 120,
                height: 40,
                child: GradientButton(
                  label: 'Next: Review',
                  hasIcon: true,
                  icon: Remix.arrow_right_s_line,
                  padding: EdgeInsets.all(0),
                  radius: 8,
                  fontSize: 12,
                  reverse: true,
                  onPressed: () => widget.updateStep(4),
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
