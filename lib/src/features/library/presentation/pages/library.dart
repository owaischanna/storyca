import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/widgets/branded_refresh_indicator.dart';
import 'package:storryca/src/core/widgets/default_appbar.dart';
import 'package:storryca/src/core/widgets/error_state.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/features/discover/content/categories.content.dart';
import 'package:storryca/src/features/discover/presentation/widgets/capsule_item.dart';
import 'package:storryca/src/features/discover/types/story_item.typres.dart';
import 'package:storryca/src/features/library/presentation/widgets/add_books_to_library.dart';
import 'package:storryca/src/features/library/presentation/widgets/empty_completed_library.dart';
import 'package:storryca/src/features/library/presentation/widgets/empty_reading_library.dart';
import 'package:storryca/src/features/library/presentation/widgets/empty_saved_library.dart';
import 'package:storryca/src/features/library/presentation/widgets/library_completed_list_item.dart';
import 'package:storryca/src/features/library/presentation/widgets/library_reading_list_item.dart';
import 'package:storryca/src/features/library/presentation/widgets/library_saved_grid_item.dart';

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  final List<String> libraryTabs = ['Reading', 'Saved', 'Completed'];
  late String selectedTab = libraryTabs.first;

  final List<String> sorters = [
    'Recent',
    'Oldest',
    'Popularity',
    'Title',
    'Author',
    'Rating',
    'Progress',
  ];
  late String selectedSorter = sorters.first;

  List<String> selectedFilterCategories = [];

  bool? _isLoggedIn;
  List<StoryItemTypes>? _reading;
  List<StoryItemTypes>? _saved;
  List<StoryItemTypes>? _completed;
  String? _error;

  String? _appliedGenre;
  String _appliedSort = 'recent';

  @override
  void initState() {
    super.initState();
    _load();
    // A story saved/removed from its page shows up here without a pull.
    libraryRepository.changed.addListener(_load);
  }

  @override
  void dispose() {
    libraryRepository.changed.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _error = null);
    final token = await authService.getToken();
    if (!mounted) return;
    if (token == null) {
      setState(() => _isLoggedIn = false);
      return;
    }
    try {
      final results = await Future.wait([
        libraryRepository.reading(token, genre: _appliedGenre, sort: _appliedSort),
        libraryRepository.saved(token, genre: _appliedGenre, sort: _appliedSort),
        libraryRepository.completed(token, genre: _appliedGenre, sort: _appliedSort),
      ]);
      if (!mounted) return;
      setState(() {
        _isLoggedIn = true;
        // Completed = reached the end of the final chapter (100% progress),
        // judged from the reader's own saved progress rather than the
        // story's publication status; anything short of that stays in Reading.
        final seen = <int>{};
        _completed = [...results[2], ...results[0]]
            .where((s) => s.progress >= 1 && seen.add(s.id))
            .toList();
        _reading = results[0].where((s) => s.progress < 1).toList();
        _saved = results[1];
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoggedIn = true;
        _error = e.message;
      });
    }
  }

  void updateTab(String tab) {
    setState(() {
      selectedTab = tab;
    });
  }

  void updateSorter(String sort) {
    setState(() {
      selectedSorter = sort;
    });
  }

  void toggleFilter(String filter) {
    setState(() {
      if (selectedFilterCategories.contains(filter)) {
        selectedFilterCategories.remove(filter);
      } else {
        selectedFilterCategories.add(filter);
      }
    });
  }

  void resetFilter() {
    setState(() {
      selectedSorter = sorters.first;
      selectedFilterCategories = [];
    });
  }

  Future<void> applyFilter() async {
    setState(() {
      _appliedGenre = selectedFilterCategories.isEmpty
          ? null
          : selectedFilterCategories.first;
      _appliedSort = selectedSorter.toLowerCase();
    });
    context.pop();
    await _load();
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
                // APPBAR
                DefaultNavbar(label: 'Library'),

                // TABBAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 12,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          spacing: 12,
                          children: [
                            ...libraryTabs.map((item) {
                              return CapsuleItem(
                                selectedCategory: selectedTab,
                                category: item,
                                update: updateTab,
                              );
                            }),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          showLibraryFilter(context);
                        },
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              width: 1,
                              color: Color(0xff8842FF),
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Remix.filter_2_line,
                              color: Color(0xff8842FF),
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // TABS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    spacing: 16,
                    children: [
                      if (_isLoggedIn == null)
                        const LoadingState(height: 300)
                      else if (_error != null)
                        ErrorState(message: _error!, onRetry: _load, height: 300)
                      else ...[
                        // READING
                        if (selectedTab == libraryTabs[0])
                          Visibility(
                            visible:
                                _isLoggedIn == true && (_reading?.isNotEmpty ?? false),
                            replacement: EmptyReadingLibrary(
                              isLoggedIn: _isLoggedIn == true,
                            ),
                            child: Column(
                              spacing: 16,
                              children: [
                                ...?_reading?.map((item) {
                                  return LibraryReadingListItem(
                                    id: item.id,
                                    title: item.title,
                                    image: item.image,
                                    currentChapter: item.currentChapter,
                                    totalChapter: item.totalChapter,
                                    progress: item.progress,
                                    progressChapterId: item.progressChapterId,
                                  );
                                }),
                              ],
                            ),
                          ),

                        // SAVED
                        if (selectedTab == libraryTabs[1])
                          Visibility(
                            visible:
                                _isLoggedIn == true && (_saved?.isNotEmpty ?? false),
                            replacement: EmptySavedLibrary(
                              isLoggedIn: _isLoggedIn == true,
                            ),
                            child: Column(
                              spacing: 16,
                              children: [
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: 0.8,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                      ),
                                  itemCount: (_saved?.length ?? 0) + 1,
                                  itemBuilder: (context, index) {
                                    final saved = _saved ?? [];
                                    if (index < saved.length) {
                                      final item = saved[index];
                                      return LibrarySavedGridItem(
                                        id: item.id,
                                        image: item.image,
                                        title: item.title,
                                        category: item.category,
                                        rating: item.rating,
                                      );
                                    } else {
                                      return AddBooksToLibrary();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),

                        // COMPLETED
                        if (selectedTab == libraryTabs[2])
                          Visibility(
                            visible:
                                _isLoggedIn == true && (_completed?.isNotEmpty ?? false),
                            replacement: EmptyCompletedLibrary(
                              isLoggedIn: _isLoggedIn == true,
                            ),
                            child: Column(
                              spacing: 16,
                              children: [
                                ...?_completed?.map((item) {
                                  return LibraryCompletedListItem(
                                    id: item.id,
                                    title: item.title,
                                    image: item.image,
                                    currentChapter: item.currentChapter,
                                    totalChapter: item.totalChapter,
                                    progress: item.progress,
                                    rating: item.rating,
                                    ratingCount: item.ratingCount,
                                    reads: item.reads,
                                  );
                                }),
                              ],
                            ),
                          ),
                      ],
                    ],
                  ),
                ),

                // SPACING
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> showLibraryFilter(BuildContext context) {
    String selectedSheetSorter = selectedSorter;

    return showModalBottomSheet(
      barrierColor: Color.fromRGBO(255, 255, 255, 0.1),
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xff0E0318),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: [
                  // DRAGGER
                  Container(
                    width: 100,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(195, 132, 255, 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),

                  // SORT BY
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12,
                      children: [
                        Text(
                          'Sort By',
                          style: TextStyle(
                            color: Color.fromRGBO(195, 132, 255, 0.5),
                            fontSize: 18,
                          ),
                        ),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final itemWidth = (constraints.maxWidth - 12) / 2;
                            return Wrap(
                              spacing: 12,
                              runSpacing: 0,
                              children: sorters.map((item) {
                                return SizedBox(
                                  width: itemWidth,
                                  child: RadioGroup(
                                    onChanged: (value) {
                                      setModalState(() {
                                        selectedSheetSorter = value ?? '';
                                        updateSorter(value ?? '');
                                      });
                                    },
                                    groupValue: selectedSheetSorter,
                                    child: Row(
                                      children: [
                                        Radio(
                                          value: item,
                                          fillColor:
                                              WidgetStateProperty.resolveWith<
                                                Color?
                                              >((states) {
                                                return Color.fromRGBO(
                                                  195,
                                                  132,
                                                  255,
                                                  0.5,
                                                );
                                              }),
                                        ),
                                        Expanded(
                                          child: Text(
                                            item,
                                            style: TextStyle(
                                              color: Color(0xffDFBDFF),
                                              fontSize: 16,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // DIVIDER
                  Divider(
                    thickness: 0.5,
                    color: Color.fromRGBO(195, 132, 255, 0.2),
                  ),

                  // FILTER BY
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12,
                      children: [
                        Text(
                          'Filter By',
                          style: TextStyle(
                            color: Color.fromRGBO(195, 132, 255, 0.5),
                            fontSize: 18,
                          ),
                        ),
                        Wrap(
                          runSpacing: 16,
                          spacing: 16,
                          children: [
                            ...categories.map((item) {
                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    toggleFilter(item);
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        selectedFilterCategories.contains(item)
                                        ? Color(0xff510C97)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(30),
                                    border:
                                        selectedFilterCategories.contains(item)
                                        ? Border.all(
                                            width: 0.5,
                                            color: Colors.transparent,
                                          )
                                        : Border.all(
                                            width: 0.5,
                                            color: Color.fromRGBO(
                                              195,
                                              132,
                                              255,
                                              0.5,
                                            ),
                                          ),
                                  ),
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      color: Color(0xffDFBDFF),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // DIVIDER
                  Divider(
                    thickness: 0.5,
                    color: Color.fromRGBO(195, 132, 255, 0.2),
                  ),

                  // ACTIONS
                  Row(
                    spacing: 16,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedSheetSorter = sorters.first;
                              resetFilter();
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 0.5,
                                color: Color.fromRGBO(195, 132, 255, 0.5),
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Center(
                              child: Text(
                                'Reset',
                                style: TextStyle(
                                  color: Color.fromRGBO(195, 132, 255, 0.5),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => applyFilter(),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              gradient: defaultGradientTTB,
                              border: Border.all(
                                width: 0.5,
                                color: Colors.transparent,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Center(
                              child: Text(
                                'Apply',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // SPACING
                  SizedBox(height: 50),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
