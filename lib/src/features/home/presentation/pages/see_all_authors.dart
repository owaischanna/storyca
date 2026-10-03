import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/widgets/branded_refresh_indicator.dart';
import 'package:storryca/src/core/widgets/error_state.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/features/home/presentation/types/author.types.dart';
import 'package:storryca/src/features/home/presentation/widgets/author_item.dart';

class SeeAllAuthors extends StatefulWidget {
  const SeeAllAuthors({super.key});

  @override
  State<SeeAllAuthors> createState() => _SeeAllAuthorsState();
}

class _SeeAllAuthorsState extends State<SeeAllAuthors> {
  List<AuthorTypes>? _items;
  int _page = 1;
  bool _hasMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool loadMore = false}) async {
    setState(() => _error = null);
    final page = loadMore ? _page + 1 : 1;
    try {
      final paged = await authorsRepository.list(
        sort: 'popular',
        page: page,
        limit: 20,
      );
      setState(() {
        _items = loadMore ? [...?_items, ...paged.items] : paged.items;
        _page = paged.pagination.page;
        _hasMore = paged.pagination.hasMore;
      });
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
        child: SafeArea(
          child: Column(
            spacing: 16,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  spacing: 12,
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(Remix.arrow_left_s_line),
                      color: Colors.white,
                      iconSize: 24,
                    ),
                    Text(
                      'Authors',
                      style: GoogleFonts.playfair(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BrandedRefreshIndicator(
                  onRefresh: () => _load(),
                  child: _error != null
                    ? ErrorState(message: _error!, onRetry: () => _load())
                    : _items == null
                    ? const LoadingState()
                    : Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          child: Column(
                            spacing: 16,
                            children: [
                              Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  ..._items!.map((item) {
                                    return AuthorItem(
                                      id: item.id,
                                      name: item.name,
                                      image: item.image,
                                    );
                                  }),
                                ],
                              ),
                              if (_hasMore)
                                TextButton(
                                  onPressed: () => _load(loadMore: true),
                                  child: Text(
                                    'Load more',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              SizedBox(height: 32),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
