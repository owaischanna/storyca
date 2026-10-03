import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/local/recent_searches_store.dart';
import 'package:storryca/src/core/widgets/custom_field.dart';
import 'package:storryca/src/features/search/presentation/widgets/no_search_result.dart';
import 'package:storryca/src/features/search/presentation/widgets/pre_search.dart';
import 'package:storryca/src/features/search/presentation/widgets/search_result.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController();
  String debouncedQuery = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _runSearch(String query) {
    _debounce?.cancel();
    setState(() {
      searchController.text = query;
      debouncedQuery = query;
    });
    if (query.length >= 3) RecentSearchesStore.add(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF020004),
      body: Container(
        decoration: BoxDecoration(gradient: pageGradientCOLR),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              spacing: 16,
              children: [
                // SEARCH BAR
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                    bottom: 16,
                    right: 16,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          context.pop();
                        },
                        icon: Icon(Remix.arrow_left_s_line),
                        color: Colors.white,
                        iconSize: 24,
                      ),
                      Expanded(
                        child: CustomTextField(
                          controller: searchController,
                          placeholder: 'Search books, authors, genres...',
                          hideText: false,
                          hasPrefixIcon: true,
                          prefixIcon: Remix.search_2_line,
                          hasSuffixIcon: true,
                          suffixIcon: searchController.text.isNotEmpty
                              ? Icon(
                                  Remix.close_circle_fill,
                                  size: 16,
                                  color: Color(primaryTextCOLR),
                                )
                              : SizedBox.shrink(),
                          onSubmitted: () {},
                          suffixAction: () {
                            _debounce?.cancel();
                            setState(() {
                              searchController.clear();
                              debouncedQuery = '';
                            });
                          },
                          textInputAction: TextInputAction.search,
                          onChange: (value) {
                            setState(() {});
                            _debounce?.cancel();
                            _debounce = Timer(
                              const Duration(milliseconds: 400),
                              () {
                                setState(() => debouncedQuery = value);
                                if (value.length >= 3) {
                                  RecentSearchesStore.add(value);
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                if (searchController.text.isEmpty)
                  PreSearch(onSelectQuery: _runSearch),

                if (searchController.text.length >= 3 &&
                    debouncedQuery.length >= 3)
                  SearchResult(query: debouncedQuery),

                if (searchController.text.isNotEmpty &&
                    searchController.text.length < 3)
                  NoSearchResult(
                    searchController: searchController,
                    onSelectQuery: _runSearch,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
