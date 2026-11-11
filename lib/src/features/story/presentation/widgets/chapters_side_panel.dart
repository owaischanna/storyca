import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/network/models/chapter_api_model.dart';
import 'package:storryca/src/features/story/presentation/widgets/read_mode_chapter_item.dart';

class ChaptersSidePanel extends StatelessWidget {
  const ChaptersSidePanel({
    super.key,
    required this.chapters,
    required this.currentChapterId,
  });

  final List<ChapterApiModel> chapters;
  final int currentChapterId;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff0E0318),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              spacing: 16,
              children: [
                // HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Chapters (${chapters.length})',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Icon(
                        Remix.close_large_line,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                // DIVIDER
                Divider(color: Color.fromRGBO(181, 77, 232, 0.1)),

                // LIST OF CHAPTER
                Column(
                  spacing: 8,
                  children: [
                    ...chapters.map((item) {
                      return ReadModeChapterItem(
                        id: item.id,
                        index: item.orderIndex,
                        name: item.title,
                        date: '',
                        isCurrent: item.id == currentChapterId,
                        storyId: item.storyId,
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
