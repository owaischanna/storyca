import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/features/author/presentation/widgets/see_all_author_stories_tab.dart';
import 'package:storryca/src/features/author/presentation/widgets/see_all_completed_author_stories_tab.dart';
import 'package:storryca/src/features/author/presentation/widgets/see_all_ongoing_author_stories_tab.dart';

class SeeAllAuthorStories extends StatefulWidget {
  const SeeAllAuthorStories({super.key, required this.authorId});

  final int authorId;

  @override
  State<SeeAllAuthorStories> createState() => _SeeAllAuthorStoriesState();
}

class _SeeAllAuthorStoriesState extends State<SeeAllAuthorStories> {
  String _authorName = '';

  @override
  void initState() {
    super.initState();
    authorsRepository
        .byId(widget.authorId)
        .then((author) => setState(() => _authorName = author.name))
        .catchError((_) {});
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
                // HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                        child: Text(
                          'Stories by $_authorName',
                          style: GoogleFonts.playfair(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // SizedBox(width: 40),
                    ],
                  ),
                ),

                // TABBAR AND TABS
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: DefaultTabController(
                    length: 3,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TabBar(
                            dividerColor: Color.fromRGBO(157, 138, 197, 0.2),
                            indicatorColor: Color(0xff5C09B4),
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelStyle: TextStyle(
                              color: Color(0xff5C09B4),
                              fontSize: 12,
                            ),
                            unselectedLabelStyle: TextStyle(
                              color: Color(primaryTextCOLR),
                              fontSize: 12,
                            ),
                            tabs: [
                              Tab(
                                child: Text(
                                  'All',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  'Ongoing',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  'Completed',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              SeeAllAuthorStoriesTab(authorId: widget.authorId),
                              SeeAllOngoingAuthorStoriesTab(
                                authorId: widget.authorId,
                              ),
                              SeeAllCompletedAuthorStoriesTab(
                                authorId: widget.authorId,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
}
