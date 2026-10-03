import 'package:flutter/material.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/widgets/error_state.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/features/author/presentation/widgets/empty_story_tab.dart';
import 'package:storryca/src/features/author/presentation/widgets/story_item_pp.dart';
import 'package:storryca/src/features/discover/types/story_item.typres.dart';

class SeeAllAuthorStoriesTab extends StatefulWidget {
  const SeeAllAuthorStoriesTab({super.key, required this.authorId});

  final int authorId;

  @override
  State<SeeAllAuthorStoriesTab> createState() =>
      _SeeAllAuthorStoriesTabState();
}

class _SeeAllAuthorStoriesTabState extends State<SeeAllAuthorStoriesTab> {
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
        authorId: widget.authorId,
        limit: 50,
      );
      setState(() => _items = paged.items);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return ErrorState(message: _error!, onRetry: _load, height: 300);
    }
    if (_items == null) return const LoadingState(height: 300);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Visibility(
        visible: _items!.isNotEmpty,
        replacement: EmptyStoryTab(),
        child: SingleChildScrollView(
          child: Column(
            spacing: 8,
            children: [
              ..._items!.map((item) {
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
        ),
      ),
    );
  }
}
