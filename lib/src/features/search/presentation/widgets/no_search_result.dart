import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/features/discover/content/categories.content.dart';
import 'package:storryca/src/features/search/contents/try_sugesstions_contents.dart';
import 'package:storryca/src/features/search/presentation/widgets/trending_search_item.dart';
import 'package:storryca/src/features/search/presentation/widgets/try_suggestion_item.dart';

class NoSearchResult extends StatelessWidget {
  const NoSearchResult({
    super.key,
    required this.searchController,
    required this.onSelectQuery,
  });

  final TextEditingController searchController;
  final void Function(String query) onSelectQuery;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 32,
      children: [
        // HERO
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Column(
            spacing: 16,
            children: [
              Image.asset(noSearchResultIMG, width: 180),
              Column(
                spacing: 8,
                children: [
                  Text(
                    'No results found',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  RichText(
                    softWrap: true,
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              'We couldn’t find any stories, authors, or genres matching ',

                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        TextSpan(
                          text: '“${searchController.text}”',
                          style: TextStyle(
                            color: Color(0xff9110DE),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // SUGGESTIONS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Color.fromRGBO(157, 138, 197, 0.2),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              spacing: 8,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Icon(
                      Remix.lightbulb_ai_line,
                      size: 16,
                      color: Color(0xffF8B231),
                    ),
                    Text(
                      'Try these suggestions',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
                ...List.generate(suggestions.length, (index) {
                  final item = suggestions[index];
                  return TrySuggestionItem(
                    title: item.title,
                    caption: item.caption,
                    icon: item.icon,
                    isLast: suggestions.length == (index + 1),
                  );
                }),
              ],
            ),
          ),
        ),

        // TRENDING SEARCHES
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🔥 Trending Searches',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Wrap(
                  runSpacing: 12,
                  spacing: 12,
                  children: [
                    ...categories.map((item) {
                      return TrendingSearchItem(
                        item: item,
                        onTap: () => onSelectQuery(item),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
