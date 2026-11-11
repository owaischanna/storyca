import 'package:flutter/material.dart';
import 'package:storryca/src/core/utils/compact_count.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';
import 'package:storryca/src/core/network/models/story_api_model.dart';
import 'package:storryca/src/core/widgets/app_image.dart';
import 'package:storryca/src/core/widgets/custom_badge.dart';
import 'package:storryca/src/features/author/presentation/widgets/story_item_btms.dart';

class StoryItem extends StatelessWidget {
  const StoryItem({
    super.key,
    required this.id,
    required this.image,
    required this.title,
    required this.description,
    required this.views,
    required this.likes,
    required this.chapters,
    required this.status,
    required this.category,
    required this.publishStatus,
    this.story,
    this.onChanged,
  });

  /// The full story, for "Edit Story".
  final StoryApiModel? story;

  /// Called after the author completes/reopens or deletes this story.
  final VoidCallback? onChanged;

  final int id;
  final String image;
  final String title;
  final String description;
  final String views;
  final String likes;
  final int chapters;
  final String status;
  final String category;

  /// "Draft" | "In Review" | "Published" — separate from [status] (which is
  /// Ongoing/Completed), shown as its own badge so the author can tell an
  /// unpublished story apart from a live one at a glance.
  final String publishStatus;

  Color get _publishStatusColor => switch (publishStatus) {
    'Published' => Color(0xFF00B076),
    'In Review' => Color(0xFFFE682E),
    _ => Color(0xFFB54DE8),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Color.fromRGBO(181, 77, 232, 0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/chapters/$id'),
              child: Row(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AppImage(image, width: 50, height: 67),
                  ),
                  Expanded(
                    child: Column(
                      spacing: 8,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 2,
                          children: [
                            Row(
                              spacing: 4,
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    softWrap: true,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.playfair(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                if (status == 'Ongoing')
                                  CustomBadge(
                                    label: 'Ongoing',
                                    fontSize: 10,
                                    bgColor: Color.fromRGBO(181, 77, 232, 0.2),
                                  ),
                                if (status == 'Completed')
                                  CustomBadge(
                                    label: 'Completed',
                                    fontSize: 10,
                                    textColor: Color(0xff00B076),
                                    bgColor: Color.fromRGBO(0, 176, 118, 0.2),
                                  ),
                              ],
                            ),
                            Row(
                              spacing: 8,
                              children: [
                                CustomBadge(
                                  label: category,
                                  fontSize: 10,
                                  textColor: Color(0xFFFF4DFF),
                                  borderColor: Color(0xFFFF4DFF),
                                  radius: 3,
                                  bgColor: Color.fromRGBO(255, 77, 255, 0.1),
                                ),
                                CustomBadge(
                                  label: publishStatus,
                                  fontSize: 10,
                                  textColor: _publishStatusColor,
                                  borderColor: _publishStatusColor,
                                  radius: 3,
                                  bgColor: _publishStatusColor.withValues(alpha: 0.1),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Row(
                              spacing: 2,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Remix.eye_line,
                                  size: 12,
                                  color: Color(primaryTextCOLR),
                                ),
                                Text(compactCountText(views), style: defaultTextStyle),
                              ],
                            ),
                            Row(
                              spacing: 2,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Remix.star_line,
                                  size: 12,
                                  color: Color(primaryTextCOLR),
                                ),
                                Text(likes, style: defaultTextStyle),
                              ],
                            ),
                            Row(
                              spacing: 2,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Remix.heart_2_line,
                                  size: 12,
                                  color: Color(primaryTextCOLR),
                                ),
                                Text(likes, style: defaultTextStyle),
                              ],
                            ),
                            Row(
                              spacing: 2,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Remix.list_unordered,
                                  size: 12,
                                  color: Color(primaryTextCOLR),
                                ),
                                Text(
                                  '$chapters Chapters',
                                  style: defaultTextStyle,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => showStoryActions(context),
            child: Icon(
              Remix.more_2_line,
              size: 24,
              color: Color.fromRGBO(255, 251, 251, 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> showStoryActions(BuildContext context) {
    return showModalBottomSheet(
      barrierColor: Color.fromRGBO(255, 255, 255, 0.1),
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetModal) {
            return StoryActionsBTMS(
              storyId: id,
              state: status,
              publishStatus: publishStatus,
              story: story,
              onChanged: onChanged,
            );
          },
        );
      },
    );
  }
}
