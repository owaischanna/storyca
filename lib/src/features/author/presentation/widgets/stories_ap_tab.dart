import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';
import 'package:storryca/src/features/author/presentation/widgets/no_story_pp.dart';
import 'package:storryca/src/features/author/presentation/widgets/story_item_pp.dart';
import 'package:storryca/src/features/discover/types/story_item.typres.dart';

class StoriesAPTab extends StatelessWidget {
  const StoriesAPTab({
    super.key,
    required this.authorId,
    required this.authorName,
    required this.stories,
  });

  final int authorId;
  final String authorName;
  final List<StoryItemTypes> stories;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Visibility(
        visible: stories.isNotEmpty,
        replacement: NoStoryPp(),
        child: SingleChildScrollView(
          child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Stories by $authorName', style: defaultTextStyle),
                  GestureDetector(
                    onTap: () =>
                        context.push('/see-all-author-stories/$authorId'),
                    child: Text('See All', style: secondaryF12TS),
                  ),
                ],
              ),
            ),

            // STORIES
            Column(
              spacing: 8,
              children: [
                ...stories.map((item) {
                  return StoryItemPP(
                    id: item.id,
                    image: item.image,
                    title: item.title,
                    description: item.description,
                    views: item.views,
                    likes: item.likes,
                    chapters: item.totalChapter,
                    status: item.status,
                  );
                }),
              ],
            ),
          ],
          ),
        ),
      ),
    );
  }
}
