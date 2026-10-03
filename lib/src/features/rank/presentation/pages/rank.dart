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
import 'package:storryca/src/features/discover/presentation/widgets/capsule_item.dart';
import 'package:storryca/src/features/discover/types/story_item.typres.dart';
import 'package:storryca/src/features/rank/presentation/contents/ranking_criteria.content.dart';
import 'package:storryca/src/features/rank/presentation/contents/ranking_filter_conditions_list.dart';
import 'package:storryca/src/features/rank/presentation/widgets/audience_filter_item.dart';
import 'package:storryca/src/features/rank/presentation/widgets/content_rating.dart';
import 'package:storryca/src/features/rank/presentation/widgets/content_type.dart';
import 'package:storryca/src/features/rank/presentation/widgets/genre_filter_item.dart';
import 'package:storryca/src/features/rank/presentation/widgets/rank_item_1.dart';
import 'package:storryca/src/features/rank/presentation/widgets/rank_item_2.dart';
import 'package:storryca/src/features/rank/presentation/widgets/rank_item_3.dart';
import 'package:storryca/src/features/rank/presentation/widgets/rank_list_item.dart';
import 'package:storryca/src/features/rank/presentation/widgets/ranking_criteria_item.dart';
import 'package:storryca/src/features/rank/presentation/widgets/sort_order_item.dart';
import 'package:storryca/src/features/rank/presentation/widgets/time_range.dart';
import 'package:storryca/src/features/rank/types/ranking_filter_conditions.dart';
import 'package:storryca/src/features/rank/types/sort_order_types.dart';

class Rank extends StatefulWidget {
  const Rank({super.key});

  @override
  State<Rank> createState() => _RankState();
}

class _RankState extends State<Rank> {
  List<String> tabItems = ['Today', 'This Week', 'This Month', 'All Time'];
  late String selectedTab = tabItems.first;

  List<String> timeRanges = [
    'Today',
    'This Week',
    'This Month',
    'All Time',
    'Custom',
  ];
  String selectedTimeRange = '';

  String selectedGenre = '';

  String selectedRanking = '';

  List<String> contentTypes = ['All', 'Completed', 'Ongoing'];
  String selectedContentType = '';

  TextEditingController regionController = TextEditingController();
  List<String> regions = [
    'Global',
    'Nigeria',
    'United States',
    'United Kingdom',
    'Canada',
    'Germany',
    'Portugal',
    'United Arab Emmirates',
    'Qatar',
    'South Africa',
    'Ghana',
    'Mexicon',
  ];
  late String selectedRegion = regions.first;

  List<String> audiences = ['General', 'Male', 'Female'];
  String selectedAudience = '';

  List<String> contentRatings = ['Everyone', '4+', '12+', '16+', '18+'];
  String selectedContentRating = '';

  List<RankingFilterConditions> conditions = rankingFilterConditions;

  List<String> genres = [];
  List<StoryItemTypes>? _items;
  String? _error;
  String? _appliedGenre;
  String? _appliedState;
  String? _appliedAudience;
  String? _appliedContentRating;
  String _appliedSort = 'popular';

  List<SortOrderTypes> sortOrders = [
    SortOrderTypes(label: 'Highest First', icon: Remix.arrow_up_line),
    SortOrderTypes(label: 'Lowest First', icon: Remix.arrow_down_line),
    SortOrderTypes(label: 'Most Recent', icon: Remix.time_line),
  ];
  String selectedSortOrder = '';

  @override
  void initState() {
    super.initState();
    _loadGenres();
    _load();
  }

  Future<void> _loadGenres() async {
    try {
      final list = await storiesRepository.genresWithCounts();
      setState(() => genres = list.map((g) => g['name'] as String).toList());
    } on ApiException catch (_) {
      // genre chips are a filter convenience; fail quietly and keep the list
    }
  }

  Future<void> _refresh() => Future.wait([_loadGenres(), _load()]);

  String? get _period => switch (selectedTab) {
    'Today' => 'today',
    'This Week' => 'week',
    'This Month' => 'month',
    _ => null, // All Time
  };

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final paged = await storiesRepository.catalog(
        genre: _appliedGenre,
        state: _appliedState,
        audience: _appliedAudience,
        contentRating: _appliedContentRating,
        sort: _appliedSort,
        period: _period,
        limit: 30,
      );
      setState(() => _items = paged.items);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    }
  }

  void updateTab(String tab) {
    setState(() {
      selectedTab = tab;
      _items = null;
    });
    _load();
  }

  void updateTimeRange(String timeRange) {
    setState(() {
      selectedTimeRange = timeRange;
    });
  }

  void updateGenre(String genre) {
    setState(() {
      selectedGenre = genre;
    });
  }

  void updateRanking(String ranking) {
    setState(() {
      selectedRanking = ranking;
    });
  }

  void updateContentType(String contentType) {
    setState(() {
      selectedContentType = contentType;
    });
  }

  void updateRegion(String region) {
    setState(() {
      selectedRegion = region;
    });
  }

  void updateAudience(String audience) {
    setState(() {
      selectedAudience = audience;
    });
  }

  void updateContentRating(String contentRating) {
    setState(() {
      selectedContentRating = contentRating;
    });
  }

  void updateCondition(String label, bool isOn) {
    setState(() {
      final index = conditions.indexWhere((item) => item.label == label);
      if (index != -1) {
        conditions[index] = RankingFilterConditions(label: label, isOn: isOn);
      }
    });
  }

  void updateSortOrder(String sortOrder) {
    setState(() {
      selectedSortOrder = sortOrder;
    });
  }

  void resetFilter() {
    setState(() {
      selectedTimeRange = '';
      selectedGenre = '';
      selectedRanking = '';
      selectedRegion = regions.first;
      regionController.text = regions.first;
      selectedContentType = '';
      selectedAudience = '';
      selectedContentRating = '';
      selectedSortOrder = '';

      conditions.asMap().forEach((index, item) {
        conditions[index] = RankingFilterConditions(
          label: item.label,
          isOn: false,
        );
      });
    });
  }

  void applyFilter() {
    setState(() {
      _appliedGenre = selectedGenre.isEmpty || selectedGenre == 'All'
          ? null
          : selectedGenre;
      _appliedState = selectedContentType.isEmpty || selectedContentType == 'All'
          ? null
          : selectedContentType;
      _appliedAudience = selectedAudience.isEmpty
          ? null
          : selectedAudience.toLowerCase();
      _appliedContentRating = selectedContentRating.isEmpty
          ? null
          : selectedContentRating.toLowerCase().replaceAll('+', '');
      _appliedSort = switch (selectedSortOrder) {
        'Lowest First' => 'least_read',
        'Most Recent' => 'latest',
        _ => 'popular',
      };
    });
    context.pop();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF020004),
      body: Container(
        decoration: BoxDecoration(gradient: pageGradientCOLR),
        child: BrandedRefreshIndicator(
          onRefresh: _refresh,
          child: SafeArea(
            child: Column(
              spacing: 16,
              children: [
                // APPBAR
                DefaultNavbar(label: 'Rank'),

                // TABBAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 12,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            spacing: 12,
                            children: [
                              ...tabItems.map((item) {
                                return CapsuleItem(
                                  selectedCategory: selectedTab,
                                  category: item,
                                  update: updateTab,
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          showRankFilter(context);
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
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
                            Positioned(
                              top: -5,
                              right: -5,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  gradient: defaultGradientTTB,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    '9',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (_error != null)
                  ErrorState(message: _error!, onRetry: _load, height: 300)
                else if (_items == null)
                  const LoadingState(height: 300)
                else ...[
                  // RANK HIGHLIGHTS ITEMS
                  if (_items!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 32,
                        left: 8,
                        right: 8,
                        bottom: 50,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_items!.length > 1)
                            RankItem2(
                              id: _items![1].id,
                              title: _items![1].title,
                              image: _items![1].image,
                              reads: _items![1].reads,
                            ),
                          RankItem1(
                            id: _items![0].id,
                            title: _items![0].title,
                            image: _items![0].image,
                            reads: _items![0].reads,
                          ),
                          if (_items!.length > 2)
                            RankItem3(
                              id: _items![2].id,
                              title: _items![2].title,
                              image: _items![2].image,
                              reads: _items![2].reads,
                            ),
                        ],
                      ),
                    ),

                  // RANK LIST
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      spacing: 8,
                      children: [
                        ..._items!.skip(3).toList().asMap().entries.map((
                          entry,
                        ) {
                          final item = entry.value;
                          return RankListItem(
                            id: item.id,
                            rank: 4 + entry.key,
                            image: item.image,
                            title: item.title,
                            author: item.author,
                            category: item.category,
                            reads: item.reads,
                            rating: item.rating,
                            isSaved: item.isSaved,
                          );
                        }),
                      ],
                    ),
                  ),
                ],

                // SPACING
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> showRankFilter(BuildContext context) {
    return showModalBottomSheet(
      barrierColor: Color.fromRGBO(255, 255, 255, 0.1),
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetModal) {
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
              child: SingleChildScrollView(
                child: Column(
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

                    // DIVIDER
                    Divider(
                      thickness: 0.5,
                      color: Color.fromRGBO(195, 132, 255, 0.1),
                    ),

                    // HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8,
                          children: [
                            Text(
                              'Filter Rankings',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'Refine the rankings to find exactly what  you love',
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Icon(
                            Remix.close_line,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),

                    // DIVIDER
                    Divider(
                      thickness: 0.5,
                      color: Color.fromRGBO(195, 132, 255, 0.1),
                    ),

                    // TIME RANGE
                    Column(
                      spacing: 16,
                      children: [
                        Row(
                          spacing: 8,
                          children: [
                            Icon(
                              Remix.calendar_event_line,
                              size: 14,
                              color: Color(0xff994FFF),
                            ),
                            Text(
                              '1. Time Range',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Color.fromRGBO(175, 145, 231, 0.5),
                            ),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ...timeRanges.map((item) {
                                  return TimeRange(
                                    item: item,
                                    selectedTimeRange: selectedTimeRange,
                                    setSheetModal: setSheetModal,
                                    updateTimeRange: updateTimeRange,
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // DIVIDER
                    Divider(
                      thickness: 0.5,
                      color: Color.fromRGBO(195, 132, 255, 0.1),
                    ),

                    // GENRE
                    Column(
                      spacing: 16,
                      children: [
                        Row(
                          spacing: 8,
                          children: [
                            Icon(
                              Remix.book_shelf_fill,
                              size: 14,
                              color: Color(0xff994FFF),
                            ),
                            Text(
                              '2. Genre',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Wrap(
                            runSpacing: 12,
                            spacing: 12,
                            alignment: WrapAlignment.start,
                            children: [
                              GenreFilterItem(
                                selectedGenre: selectedGenre,
                                item: 'All',
                                setSheetModal: setSheetModal,
                                updateGenre: updateGenre,
                              ),

                              ...genres.map((item) {
                                return GenreFilterItem(
                                  selectedGenre: selectedGenre,
                                  item: item,
                                  setSheetModal: setSheetModal,
                                  updateGenre: updateGenre,
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // DIVIDER
                    Divider(
                      thickness: 0.5,
                      color: Color.fromRGBO(195, 132, 255, 0.1),
                    ),

                    // RANKING CRITERIA
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            spacing: 16,
                            children: [
                              Row(
                                spacing: 8,
                                children: [
                                  Icon(
                                    Remix.fire_fill,
                                    size: 14,
                                    color: Color(0xff994FFF),
                                  ),
                                  Text(
                                    '3. Ranking Criteria',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: Color.fromRGBO(195, 132, 255, 0.1),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    ...List.generate(rankings.length, (index) {
                                      final item = rankings[index];
                                      return RankingCriteriaItem(
                                        selectedRanking: selectedRanking,
                                        setSheetModal: setSheetModal,
                                        updateRanking: updateRanking,
                                        label: item.name,
                                        icon: item.icon,
                                        isLast: rankings.length == (index + 1),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // DIVIDER
                    Divider(
                      thickness: 0.5,
                      color: Color.fromRGBO(195, 132, 255, 0.1),
                    ),

                    // REGION
                    Column(
                      spacing: 16,
                      children: [
                        Row(
                          spacing: 8,
                          children: [
                            Icon(
                              Remix.global_line,
                              size: 14,
                              color: Color(0xff994FFF),
                            ),
                            Text(
                              '4. Region',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: DropdownMenu(
                            controller: regionController,
                            textStyle: TextStyle(
                              color: Color(0xffE1CCFF),
                              fontSize: 12,
                            ),
                            onSelected: (value) => updateRegion(value ?? ''),
                            width: MediaQuery.of(context).size.width * 0.95,
                            menuHeight: 400,
                            menuStyle: MenuStyle(
                              shape: WidgetStateProperty.resolveWith((states) {
                                return RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                );
                              }),
                              backgroundColor: WidgetStateColor.resolveWith((
                                states,
                              ) {
                                return Color.fromRGBO(23, 0, 45, 0.99);
                              }),
                              padding: WidgetStateProperty.resolveWith((
                                states,
                              ) {
                                return EdgeInsets.all(0);
                              }),
                            ),
                            decorationBuilder: (context, controller) {
                              return InputDecoration(
                                prefixIcon: Icon(
                                  Remix.global_line,
                                  color: Color(0xff994FFF),
                                  size: 16,
                                ),
                                suffixIcon: Icon(
                                  Remix.arrow_down_s_line,
                                  color: Color(0xff994FFF),
                                  size: 14,
                                ),
                                hintText: 'Global',
                                hintStyle: TextStyle(
                                  color: Color(0xffE1CCFF),
                                  fontSize: 12,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: Color.fromRGBO(153, 79, 255, 0.2),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: Color.fromRGBO(153, 79, 255, 0.2),
                                  ),
                                ),
                              );
                            },
                            dropdownMenuEntries: [
                              ...List.generate(regions.length, (index) {
                                final item = regions[index];
                                return DropdownMenuEntry(
                                  value: item,
                                  label: item,
                                  style: ButtonStyle(
                                    padding: WidgetStateProperty.resolveWith((
                                      states,
                                    ) {
                                      return EdgeInsets.symmetric(
                                        horizontal: 20,
                                      );
                                    }),
                                    foregroundColor:
                                        WidgetStateColor.resolveWith((state) {
                                          return Colors.white;
                                        }),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // CONTENT TYPE
                    Column(
                      spacing: 16,
                      children: [
                        Row(
                          spacing: 8,
                          children: [
                            Icon(
                              Remix.file_list_3_line,
                              size: 14,
                              color: Color(0xff994FFF),
                            ),
                            Text(
                              '5. Content Type',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Color.fromRGBO(175, 145, 231, 0.5),
                            ),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            spacing: 16,
                            children: [
                              ...contentTypes.map((item) {
                                return Expanded(
                                  child: ContentType(
                                    item: item,
                                    selectedContentType: selectedContentType,
                                    setSheetModal: setSheetModal,
                                    updateContentType: updateContentType,
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // AUDIENCE
                    Column(
                      spacing: 16,
                      children: [
                        Row(
                          spacing: 8,
                          children: [
                            Icon(
                              Remix.group_3_fill,
                              size: 14,
                              color: Color(0xff994FFF),
                            ),
                            Text(
                              '6. Audience',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Color.fromRGBO(175, 145, 231, 0.5),
                            ),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            spacing: 16,
                            children: [
                              ...audiences.map((item) {
                                return Expanded(
                                  child: AudienceFilterItem(
                                    item: item,
                                    selectedAudience: selectedAudience,
                                    setSheetModal: setSheetModal,
                                    updateAudience: updateAudience,
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // CONTENT RATING
                    Column(
                      spacing: 16,
                      children: [
                        Row(
                          spacing: 8,
                          children: [
                            Icon(
                              Remix.pulse_ai_line,
                              size: 14,
                              color: Color(0xff994FFF),
                            ),
                            Text(
                              '7. Content Rating',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Color.fromRGBO(175, 145, 231, 0.5),
                            ),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ...contentRatings.map((item) {
                                  return ContentRating(
                                    item: item,
                                    selectedContentRating:
                                        selectedContentRating,
                                    setSheetModal: setSheetModal,
                                    updateContentRating: updateContentRating,
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // DIVIDER
                    Divider(
                      thickness: 0.5,
                      color: Color.fromRGBO(195, 132, 255, 0.1),
                    ),

                    // CONDITIONS
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            spacing: 16,
                            children: [
                              Row(
                                spacing: 8,
                                children: [
                                  Icon(
                                    Remix.flashlight_fill,
                                    size: 14,
                                    color: Color(0xff994FFF),
                                  ),
                                  Text(
                                    '8. Conditions',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: Color.fromRGBO(195, 132, 255, 0.1),
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  children: [
                                    ...conditions.map((item) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            item.label,
                                            style: TextStyle(
                                              color: Color(0xffE1CCFF),
                                              fontSize: 12,
                                            ),
                                          ),
                                          Switch(
                                            value: item.isOn,
                                            inactiveTrackColor:
                                                Colors.transparent,
                                            focusColor: Colors.amber,
                                            inactiveThumbColor: Color.fromRGBO(
                                              142,
                                              114,
                                              201,
                                              0.1,
                                            ),
                                            onChanged: (value) {
                                              setSheetModal(() {
                                                updateCondition(
                                                  item.label,
                                                  value,
                                                );
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // DIVIDER
                    Divider(
                      thickness: 0.5,
                      color: Color.fromRGBO(195, 132, 255, 0.1),
                    ),

                    // SORT ORDER
                    Column(
                      spacing: 16,
                      children: [
                        Row(
                          spacing: 8,
                          children: [
                            Icon(
                              Remix.arrow_up_down_fill,
                              size: 14,
                              color: Color(0xff994FFF),
                            ),
                            Text(
                              '9. Sort Order',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Color.fromRGBO(175, 145, 231, 0.5),
                            ),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            spacing: 16,
                            children: [
                              ...sortOrders.map((item) {
                                return Expanded(
                                  child: SortOrderItem(
                                    item: item,
                                    selectedSortOrder: selectedSortOrder,
                                    setSheetModal: setSheetModal,
                                    updateSortOrder: updateSortOrder,
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // DIVIDER
                    Divider(
                      thickness: 0.5,
                      color: Color.fromRGBO(195, 132, 255, 0.1),
                    ),

                    // ACTIONS
                    Row(
                      spacing: 16,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setSheetModal(() {
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 8,
                                children: [
                                  Icon(
                                    Remix.reset_left_line,
                                    color: Color.fromRGBO(195, 132, 255, 0.5),
                                    size: 12,
                                  ),
                                  Text(
                                    'Reset',
                                    style: TextStyle(
                                      color: Color.fromRGBO(195, 132, 255, 0.5),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 8,
                                children: [
                                  Icon(
                                    Remix.shining_fill,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  Text(
                                    'Apply',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // SPACING
                    SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
