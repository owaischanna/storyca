import 'package:flutter/material.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/widgets/error_state.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/features/discover/types/story_item.typres.dart';
import 'package:storryca/src/features/story/presentation/widgets/no_story_recommendations.dart';
import 'package:storryca/src/features/story/presentation/widgets/story_recommended_item.dart';

class StoryRecommendedTab extends StatefulWidget {
  const StoryRecommendedTab({
    super.key,
    required this.storyId,
    required this.genre,
  });

  final int storyId;
  final String genre;

  @override
  State<StoryRecommendedTab> createState() => _StoryRecommendedTabState();
}

class _StoryRecommendedTabState extends State<StoryRecommendedTab> {
  List<StoryItemTypes>? _items;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final paged = await storiesRepository.catalog(
        genre: widget.genre,
        limit: 9,
      );
      setState(() {
        _items = paged.items.where((s) => s.id != widget.storyId).toList();
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return ErrorState(message: _error!, onRetry: _load, height: 200);
    }
    if (_items == null) return const LoadingState(height: 200);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Visibility(
        visible: _items!.isNotEmpty,
        replacement: NoStoryRecommendations(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // STORIES
              Column(
                spacing: 8,
                children: [
                  ..._items!.take(8).map((item) {
                    return StoryRecommendedItem(
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
