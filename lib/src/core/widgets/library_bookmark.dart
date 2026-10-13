import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/widgets/app_snackbar.dart';
import 'package:storryca/src/core/widgets/sign_in_redirect.dart';

/// The bookmark is "saved to library" — one shared toggle for every card and
/// menu that offers it, so they all behave like the story page's button.
class LibraryBookmark {
  // Taps on a story already being saved/removed are dropped, so rapid
  // tapping can't race two writes.
  static final Set<int> _busy = {};

  static Future<void> toggle(BuildContext context, int storyId) async {
    final token = await authService.getToken();
    if (!context.mounted) return;
    if (token == null) {
      goToSignIn(context);
      return;
    }
    if (!_busy.add(storyId)) return;
    try {
      await libraryRepository.ensureSavedIds(token);
      final wasSaved = libraryRepository.savedIds.value.contains(storyId);
      // Repaint comes from the server's answer (save/unsave update savedIds).
      final saved = wasSaved
          ? await libraryRepository.unsave(storyId, token)
          : await libraryRepository.save(storyId, token);
      if (context.mounted) {
        AppSnackbar.success(
          context,
          saved ? 'Saved to your library.' : 'Removed from your library.',
        );
      }
    } on ApiException catch (e) {
      if (context.mounted && !redirectIfSignedOut(context, e)) {
        AppSnackbar.error(context, e.message);
      }
    } finally {
      _busy.remove(storyId);
    }
  }

  static bool isSaved(int storyId) =>
      libraryRepository.savedIds.value.contains(storyId);
}

/// A tappable bookmark that shows the story's real saved state.
class SavedBookmarkIcon extends StatefulWidget {
  const SavedBookmarkIcon({
    super.key,
    required this.storyId,
    required this.color,
    this.size,
  });

  final int storyId;
  final Color color;
  final double? size;

  @override
  State<SavedBookmarkIcon> createState() => _SavedBookmarkIconState();
}

class _SavedBookmarkIconState extends State<SavedBookmarkIcon> {
  @override
  void initState() {
    super.initState();
    authService.getToken().then(libraryRepository.ensureSavedIds);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: libraryRepository.savedIds,
      builder: (context, ids, _) => GestureDetector(
        // Opaque so the tap lands here, not on the card around it.
        behavior: HitTestBehavior.opaque,
        onTap: () => LibraryBookmark.toggle(context, widget.storyId),
        child: Icon(
          ids.contains(widget.storyId)
              ? Remix.bookmark_fill
              : Remix.bookmark_line,
          color: widget.color,
          size: widget.size,
        ),
      ),
    );
  }
}
