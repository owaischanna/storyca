import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/models/chapter_api_model.dart';
import 'package:storryca/src/core/widgets/custom_field.dart';
import 'package:storryca/src/core/widgets/error_state.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/features/story/presentation/widgets/story_chapter_item.dart';

class StoryChaptersTab extends StatefulWidget {
  const StoryChaptersTab({super.key, required this.storyId});

  final int storyId;

  @override
  State<StoryChaptersTab> createState() => _StoryChaptersTabState();
}

class _StoryChaptersTabState extends State<StoryChaptersTab> {
  TextEditingController searchController = TextEditingController();
  List<ChapterApiModel>? _chapters;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final token = await authService.getToken();
      final chapters = await chaptersRepository.byStoryId(
        widget.storyId,
        token: token,
      );
      setState(() => _chapters = chapters);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: SingleChildScrollView(
        child: Column(
          spacing: 16,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 165,
                  height: 38,
                  child: CustomTextField(
                    controller: searchController,
                    placeholder: 'Search chapters',
                    radius: 5,
                    borderColor: Color.fromRGBO(181, 77, 232, 0.2),
                    hideText: false,
                    hasPrefixIcon: true,
                    prefixIcon: Remix.search_2_line,
                    hasSuffixIcon: false,
                    onSubmitted: () {},
                    suffixAction: () {},
                    onChange: (value) {},
                  ),
                ),
                Row(
                  spacing: 4,
                  children: [
                    Text('Oldest', style: secondaryF12TS),
                    Icon(
                      Remix.sort_desc,
                      color: Color(secondaryCOLR),
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),

            // CHAPTERS LIST
            if (_error != null)
              ErrorState(message: _error!, onRetry: _load, height: 200)
            else if (_chapters == null)
              const LoadingState(height: 200)
            else if (_chapters!.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'No chapters published yet.',
                  style: defaultTextStyle,
                ),
              )
            else
              Column(
                spacing: 8,
                children: [
                  ..._chapters!.map((item) {
                    return GestureDetector(
                      onTap: () => context.push(
                        '/read/${item.id}',
                        extra: widget.storyId,
                      ),
                      child: StoryChapterItem(
                        index: item.orderIndex,
                        name: item.title,
                        date: '',
                        views: '-',
                        isCurrent: false,
                        locked: item.locked,
                      ),
                    );
                  }),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
