import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';
import 'package:storryca/src/core/widgets/border_gradient_button.dart';
import 'package:storryca/src/core/widgets/gradient_button.dart';
import 'package:storryca/src/features/story/contents/story_chapter_items.dart';
import 'package:storryca/src/features/story/presentation/widgets/chapter_item.dart';

class StoryDetails extends StatefulWidget {
  const StoryDetails({super.key, required this.storyId});

  final int storyId;

  @override
  State<StoryDetails> createState() => _StoryDetailsState();
}

class _StoryDetailsState extends State<StoryDetails> {
  final totalChapters = 12;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF020004),
      body: Container(
        decoration: BoxDecoration(gradient: pageGradientCOLR),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              spacing: 16,
              children: [
                // HEADER
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Icon(
                          Remix.arrow_left_s_line,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                      PopupMenuButton(
                        icon: Icon(
                          Remix.more_2_line,
                          size: 24,
                          color: Colors.white,
                        ),
                        color: Color.fromRGBO(23, 0, 45, 0.9),
                        menuPadding: EdgeInsets.all(0),
                        shape: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(width: 0),
                        ),
                        position: PopupMenuPosition.under,
                        onSelected: (value) {},
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                              height: 40,
                              value: 'edit',
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 8,
                                children: [
                                  Icon(
                                    Remix.pencil_line,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  Text(
                                    'Edit Story',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              height: 40,
                              value: 'delete',
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 8,
                                children: [
                                  Icon(
                                    Remix.delete_bin_5_line,
                                    color: Color(0xffC23B3B),
                                    size: 16,
                                  ),
                                  Text(
                                    'Delete Story',
                                    style: TextStyle(
                                      color: Color(0xffC23B3B),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ];
                        },
                      ),
                    ],
                  ),
                ),

                // STORY CARD
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Color.fromRGBO(92, 9, 180, 0.1),
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromRGBO(92, 9, 180, 0.1),
                    ),
                    child: Column(
                      spacing: 8,
                      children: [
                        Row(
                          spacing: 8,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.asset(
                                story1IMG,
                                width: 70,
                                height: 94,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                spacing: 8,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bound by Shadows',
                                    style: GoogleFonts.playfair(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Row(
                                    spacing: 8,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 3,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color.fromRGBO(
                                            255,
                                            77,
                                            255,
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Remix.edit_line,
                                              color: Color(secondaryCOLR),
                                              size: 10,
                                            ),
                                            Text(
                                              'Draft',
                                              style: secondaryF10TS,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        'Romance, Dark Romance',
                                        style: defaultTextStyle10,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Nulla ac enim mattis sem eget ornare. Nunc lacus rutrum a quis ipsum. Hendrerit rhoncus sagittis amet eu scelerisque mi. ',
                                    style: defaultTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(color: Color.fromRGBO(157, 138, 197, 0.1)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              spacing: 8,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) {
                                    return defaultGradientTTB.createShader(
                                      bounds,
                                    );
                                  },
                                  child: Icon(
                                    Remix.eye_line,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                Column(
                                  spacing: 4,
                                  children: [
                                    Text('12.4k', style: whiteF14TS),
                                    Text('view', style: defaultTextStyle),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 70,
                              child: VerticalDivider(
                                color: Color.fromRGBO(157, 138, 197, 0.1),
                              ),
                            ),
                            Column(
                              spacing: 8,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) {
                                    return defaultGradientTTB.createShader(
                                      bounds,
                                    );
                                  },
                                  child: Icon(
                                    Remix.file_list_3_line,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                Column(
                                  spacing: 4,
                                  children: [
                                    Text('3.2k', style: whiteF14TS),
                                    Text('Reads', style: defaultTextStyle),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 70,
                              child: VerticalDivider(
                                color: Color.fromRGBO(157, 138, 197, 0.1),
                              ),
                            ),
                            Column(
                              spacing: 8,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) {
                                    return defaultGradientTTB.createShader(
                                      bounds,
                                    );
                                  },
                                  child: Icon(
                                    Remix.heart_line,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                Column(
                                  spacing: 4,
                                  children: [
                                    Text('11.3K', style: whiteF14TS),
                                    Text('Likes', style: defaultTextStyle),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 70,
                              child: VerticalDivider(
                                color: Color.fromRGBO(157, 138, 197, 0.1),
                              ),
                            ),
                            Column(
                              spacing: 8,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) {
                                    return defaultGradientTTB.createShader(
                                      bounds,
                                    );
                                  },
                                  child: Icon(
                                    Remix.star_line,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                Column(
                                  spacing: 4,
                                  children: [
                                    Text('316', style: whiteF14TS),
                                    Text('Reviews', style: defaultTextStyle),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // PROGRESS STAT
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Color.fromRGBO(92, 9, 180, 0.1),
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: Color.fromRGBO(92, 9, 180, 0.1),
                    ),
                    child: Row(
                      spacing: 16,
                      children: [
                        Expanded(
                          child: Row(
                            spacing: 16,
                            children: [
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 4,
                                        value: 0.9,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Color(0xff5C09B4),
                                            ),
                                        backgroundColor: Color.fromRGBO(
                                          217,
                                          217,
                                          217,
                                          0.1,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      child: SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: Center(
                                          child: Text('90%', style: whiteF10TS),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  spacing: 12,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      spacing: 4,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Keep going! You’re making great progress.',
                                          style: whiteF10TS,
                                        ),
                                        Text(
                                          '12 of 18 chapters published',
                                          style: defaultTextStyle10,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 8,
                                      child: ShaderMask(
                                        shaderCallback: (bounds) {
                                          return const LinearGradient(
                                            colors: [
                                              Color(0xff8842FF),
                                              Color(0xFF5C09B4),
                                            ],
                                          ).createShader(bounds);
                                        },
                                        child: LinearProgressIndicator(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                          value: 0.9,
                                          backgroundColor: Color.fromRGBO(
                                            217,
                                            217,
                                            217,
                                            0.1,
                                          ),
                                          valueColor: AlwaysStoppedAnimation(
                                            Colors.white,
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
                        Icon(
                          Remix.arrow_right_s_line,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),

                // RECENT CHAPTERS
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    spacing: 12,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Chapters',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            height: 30,
                            child: GradientButton(
                              label: 'Add Chapter',
                              hasIcon: true,
                              icon: Remix.add_large_line,
                              iconSize: 12,
                              fontSize: 12,
                              radius: 5,
                              padding: EdgeInsets.all(0),
                              onPressed: () => {},
                            ),
                          ),
                        ],
                      ),

                      // LIST OF CHAPTERS
                      Column(
                        spacing: 8,
                        children: [
                          ...List.generate(storyChapterItems.length, (index) {
                            final item = storyChapterItems[index];
                            return ChapterItem(
                              index: totalChapters - index,
                              title: item.name,
                              words: item.words,
                              status: item.status,
                              date: item.date,
                              onEdit: () {},
                              onPublish: null,
                              onDelete: () {},
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),

                // VIEW ALL
                SizedBox(
                  height: 35,
                  width: 150,
                  child: BorderGradientButton(
                    label: 'View all $totalChapters Chapters',
                    hasIcon: true,
                    icon: Remix.arrow_right_s_line,
                    padding: EdgeInsets.all(0),
                    reverse: true,
                    radius: 6,
                    fontSize: 12,
                    iconSize: 12,
                    onPressed: () => context.push('/chapters/${widget.storyId}'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
