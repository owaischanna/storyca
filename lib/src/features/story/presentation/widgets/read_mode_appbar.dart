import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';

class ReadModeAppbar extends StatelessWidget implements PreferredSizeWidget {
  const ReadModeAppbar({
    super.key,
    required this.scaffoldKey,
    required this.toggleAppbar,
    required this.title,
    required this.author,
    required this.percent,
    this.authorMuted = false,
    this.onMute,
    this.onReport,
    this.inLibrary = false,
    this.onToggleLibrary,
    this.onTextSize,
  });

  /// Opens the chapter text-size control.
  final VoidCallback? onTextSize;

  final String title;
  final String author;
  final int percent;
  final bool authorMuted;
  final VoidCallback? onMute;
  final VoidCallback? onReport;

  /// Saved-to-library state (the bookmark), read from the server on open.
  final bool inLibrary;
  final VoidCallback? onToggleLibrary;

  final GlobalKey<ScaffoldState> scaffoldKey;
  final void Function() toggleAppbar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Color(0xFF1D0632),
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Color.fromRGBO(181, 77, 232, 0.1),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                spacing: 8,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(
                      Remix.arrow_left_s_line,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.playfair(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        if (author.isNotEmpty)
                          Text('- $author', style: defaultTextStyle10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text('$percent%', style: whiteF14TS),
                PopupMenuButton(
                  icon: Icon(Remix.more_2_line, size: 24, color: Colors.white),
                  color: Color.fromRGBO(23, 0, 45, 0.9),
                  menuPadding: EdgeInsets.all(0),
                  shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(width: 0),
                  ),
                  position: PopupMenuPosition.under,
                  onSelected: (value) {
                    if (value == 'mute') onMute?.call();
                    if (value == 'report') onReport?.call();
                    if (value == 'library') onToggleLibrary?.call();
                    if (value == 'text-size') onTextSize?.call();
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        height: 40,
                        value: 'hide-appbar',
                        onTap: () => toggleAppbar(),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 8,
                          children: [
                            Icon(
                              Remix.eye_off_fill,
                              color: Colors.white,
                              size: 16,
                            ),
                            Text(
                              'Hide AppBar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        height: 40,
                        value: 'text-size',
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 8,
                          children: [
                            Icon(
                              Remix.font_size,
                              color: Colors.white,
                              size: 16,
                            ),
                            Text(
                              'Text Size',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        height: 40,
                        value: 'library',
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 8,
                          children: [
                            Icon(
                              inLibrary
                                  ? Remix.bookmark_fill
                                  : Remix.bookmark_line,
                              color: Colors.white,
                              size: 16,
                            ),
                            Text(
                              inLibrary ? 'Saved to Library' : 'Add to Library',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        height: 40,
                        value: 'share',
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 8,
                          children: [
                            Icon(
                              Remix.share_line,
                              color: Colors.white,
                              size: 16,
                            ),
                            Text(
                              'Share',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        height: 40,
                        value: 'mute',
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 8,
                          children: [
                            Icon(
                              Remix.notification_off_line,
                              color: Colors.white,
                              size: 16,
                            ),
                            Text(
                              authorMuted ? 'Unmute Updates' : 'Mute Updates',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        height: 40,
                        value: 'report',
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 8,
                          children: [
                            Icon(
                              Remix.user_unfollow_line,
                              color: Color(0xffC23B3B),
                              size: 16,
                            ),
                            Text(
                              'Report',
                              style: TextStyle(
                                color: Color(0xffC23B3B),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
                IconButton(
                  onPressed: () => scaffoldKey.currentState?.openEndDrawer(),
                  icon: Icon(Remix.booklet_line, size: 24, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
