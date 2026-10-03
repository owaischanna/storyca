import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/mappers.dart';
import 'package:storryca/src/core/network/models/story_api_model.dart';
import 'package:storryca/src/core/widgets/branded_refresh_indicator.dart';
import 'package:storryca/src/core/widgets/error_state.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/features/author/presentation/widgets/no_stories.dart';
import 'package:storryca/src/features/author/presentation/widgets/story_item.dart';

class AuthorCenter extends StatefulWidget {
  const AuthorCenter({super.key});

  @override
  State<AuthorCenter> createState() => _AuthorCenterState();
}

class _AuthorCenterState extends State<AuthorCenter> {
  List<StoryApiModel>? _stories;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    final token = await authService.getToken();
    if (token == null) {
      setState(() => _stories = []);
      return;
    }
    try {
      final user = await usersRepository.me(token);
      // Drafts and "In Review" stories included — /authors/{id}/stories only
      // ever returns published ones, which left this screen unable to show
      // anything the author hadn't already gotten live.
      final stories = await storiesRepository.myStories(
        authorId: user.id,
        token: token,
      );
      setState(() => _stories = stories);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF020004),
      body: Container(
        decoration: BoxDecoration(gradient: pageGradientCOLR),
        child: BrandedRefreshIndicator(
          onRefresh: _load,
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
                      Column(
                        children: [
                          Text(
                            'Author Center',
                            style: GoogleFonts.playfair(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'Manage your stories',
                            style: defaultTextStyle10,
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => context.push('/new-story'),
                        child: Icon(
                          Remix.add_circle_line,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // ITEMS
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: _error != null
                      ? ErrorState(message: _error!, onRetry: _load, height: 300)
                      : _stories == null
                      ? const LoadingState(height: 300)
                      : Visibility(
                          visible: _stories!.isNotEmpty,
                          replacement: NoStories(),
                          child: Column(
                            spacing: 16,
                            children: [
                              ..._stories!.map((story) {
                                final item = storyItemFromApi(story);
                                return StoryItem(
                                  id: item.id,
                                  image: item.image,
                                  title: item.title,
                                  description: item.description,
                                  views: item.views,
                                  likes: item.likes,
                                  chapters: item.totalChapter,
                                  status: item.status,
                                  category: item.category,
                                  publishStatus: story.status,
                                  onChanged: _load,
                                );
                              }),
                            ],
                          ),
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
