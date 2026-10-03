import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';
import 'package:storryca/src/core/network/image_url.dart';
import 'package:storryca/src/core/network/models/review_api_model.dart';
import 'package:storryca/src/core/widgets/app_image.dart';

class StoryReviewItem extends StatelessWidget {
  const StoryReviewItem({
    super.key,
    required this.review,
    this.onEdit,
    this.onDelete,
  });

  final ReviewApiModel review;

  /// Non-null only for the signed-in reader's own review (comments can't be
  /// edited, only removed).
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  String get _dateLabel {
    final parsed = DateTime.tryParse(review.createdAt);
    return parsed == null
        ? review.createdAt
        : DateFormat('MMM d, yyyy').format(parsed);
  }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: AppImage(
              avatarUrl(review.user.image),
              width: 40,
              height: 40,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        spacing: 6,
                        children: [
                          Flexible(
                            child: Text(
                              review.user.name,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.playfair(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (review.user.isAuthor)
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: Color(0xff9110DE),
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Icon(
                                Remix.leaf_fill,
                                color: Color(0xff9110DE),
                                size: 10,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(_dateLabel, style: defaultTextStyle10),
                        if (review.isMine)
                          SizedBox(
                            height: 24,
                            child: PopupMenuButton(
                              padding: EdgeInsets.all(0),
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
                              onSelected: (value) {
                                if (value == 'edit') onEdit?.call();
                                if (value == 'delete') onDelete?.call();
                              },
                              itemBuilder: (context) {
                                return [
                                  if (onEdit != null)
                                    PopupMenuItem(
                                      height: 40,
                                      value: 'edit',
                                      child: Row(
                                        spacing: 8,
                                        children: [
                                          Icon(
                                            Remix.edit_2_line,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          Text(
                                            'Edit',
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
                                      spacing: 8,
                                      children: [
                                        Icon(
                                          Remix.delete_bin_line,
                                          color: Color(0xffC23B3B),
                                          size: 16,
                                        ),
                                        Text(
                                          'Delete',
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
                          ),
                      ],
                    ),
                  ],
                ),
                // A comment carries no rating — no star row at all, as on the
                // website (not five empty stars).
                if (!review.isComment)
                  Row(
                    spacing: 4,
                    children: [
                      ...List.generate(review.rating, (index) {
                        return ShaderMask(
                          shaderCallback: ((bounds) {
                            return defaultGradientTTB.createShader(bounds);
                          }),
                          child: Icon(
                            Remix.star_fill,
                            color: Colors.white,
                            size: 12,
                          ),
                        );
                      }),
                      ...List.generate(5 - review.rating, (index) {
                        return Icon(
                          Remix.star_fill,
                          color: Color(0xFF332B42),
                          size: 12,
                        );
                      }),
                    ],
                  ),
                if (review.body.isNotEmpty)
                  Text(review.body, style: defaultTextStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
