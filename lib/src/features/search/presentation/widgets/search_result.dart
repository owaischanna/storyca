import 'package:flutter/material.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/features/search/presentation/widgets/all_tab.dart';
import 'package:storryca/src/features/search/presentation/widgets/authors_tab.dart';
import 'package:storryca/src/features/search/presentation/widgets/genre_tab.dart';
import 'package:storryca/src/features/search/presentation/widgets/stories_tab.dart';

class SearchResult extends StatelessWidget {
  const SearchResult({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                dividerColor: Color.fromRGBO(157, 138, 197, 0.2),
                indicatorColor: Color(secondaryCOLR),
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: TextStyle(
                  color: Color(secondaryCOLR),
                  fontSize: 12,
                ),
                unselectedLabelStyle: TextStyle(
                  color: Color(primaryTextCOLR),
                  fontSize: 12,
                ),
                tabs: [
                  Tab(text: 'All'),
                  Tab(text: 'Stories'),
                  Tab(text: 'Authors'),
                  Tab(text: 'Genres'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  AllTab(query: query),
                  StoriesTab(query: query),
                  AuthorsTab(query: query),
                  GenreTab(query: query),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
