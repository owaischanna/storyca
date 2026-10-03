import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/widgets/app_snackbar.dart';

class StoryActionsBTMS extends StatefulWidget {
  const StoryActionsBTMS({
    super.key,
    required this.storyId,
    required this.state,
    required this.publishStatus,
    this.onChanged,
  });

  final int storyId;

  /// "Ongoing" or "Completed".
  final String state;

  /// "Draft" | "In Review" | "Published" — only a Draft may be deleted.
  final String publishStatus;

  /// Called after a successful change so the list can reload.
  final VoidCallback? onChanged;

  @override
  State<StoryActionsBTMS> createState() => _StoryActionsBTMSState();
}

class _StoryActionsBTMSState extends State<StoryActionsBTMS> {
  bool _busy = false;

  bool get _isCompleted => widget.state.toLowerCase() == "completed";
  bool get _isDraft => widget.publishStatus.toLowerCase() == "draft";

  Future<void> _run(Future<String> Function(String token) action) async {
    if (_busy) return;
    final token = await authService.getToken();
    if (!mounted) return;
    if (token == null) {
      AppSnackbar.warning(context, "Sign in to manage your story.");
      return;
    }
    setState(() => _busy = true);
    try {
      final message = await action(token);
      if (!mounted) return;
      context.pop();
      AppSnackbar.success(context, message);
      widget.onChanged?.call();
    } on ApiException catch (e) {
      // e.g. 422 "A story needs 20 published chapters…", or 403 on a
      // non-draft delete — the server message reads correctly as-is. Close
      // the sheet first: a snackbar raised under it would be hidden.
      if (!mounted) return;
      context.pop();
      AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toggleCompleted() => _run((token) async {
    final state = await storiesRepository.setStoryState(
      widget.storyId,
      _isCompleted ? "ongoing" : "completed",
      token,
    );
    return state == "Completed"
        ? "Story marked as completed."
        : "Story set back to ongoing.";
  });

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff0E0318),
        title: const Text(
          "Delete this draft?",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "This cannot be undone.",
          style: TextStyle(color: Color(0xff9D8AC5)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Color(0xffC23B3B)),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _run((token) async {
      await storiesRepository.deleteStory(widget.storyId, token);
      return "Story deleted.";
    });
  }

  @override
  Widget build(BuildContext context) {
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

            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Actions',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Icon(
                    Remix.close_large_line,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),

            // DIVIDER
            Divider(thickness: 0.5, color: Color.fromRGBO(195, 132, 255, 0.1)),

            // MARK AS COMPLETED / SET BACK TO ONGOING
            GestureDetector(
              onTap: _toggleCompleted,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Color.fromRGBO(195, 132, 255, 0.05),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  spacing: 8,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(0, 176, 118, 0.1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Icon(
                        Remix.check_double_line,
                        color: Color(0xff00B076),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Text(
                            _isCompleted
                                ? 'Mark As Ongoing'
                                : 'Mark As Completed',
                            style: whiteF14TS,
                          ),
                          Text(
                            _isCompleted
                                ? 'Set this story back to ongoing at any time.'
                                : 'Needs 20 published chapters. It’s not permanent.',
                            style: defaultTextStyle10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // EDIT STORY
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Color.fromRGBO(195, 132, 255, 0.05),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                spacing: 8,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(145, 16, 222, 0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return defaultGradientTTB.createShader(bounds);
                      },
                      child: Icon(Remix.edit_line, color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text('Edit Story', style: whiteF14TS),
                        Text(
                          'Manage the title, genre, tags, photo and so on of this story',
                          style: defaultTextStyle10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // DELETE STORY — drafts only; anything submitted or live stays
            // with the admin (it may already be unlocked in readers'
            // libraries).
            if (_isDraft)
              GestureDetector(
                onTap: _delete,
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Color.fromRGBO(195, 132, 255, 0.05),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    spacing: 8,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(194, 59, 59, 0.1),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Icon(
                          Remix.delete_bin_5_line,
                          color: Color(0xffC23B3B),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            Text('Delete Story', style: whiteF14TS),
                            Text(
                              'Feel like you need a fresh start? You can delete this story now',
                              style: defaultTextStyle10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // SPACING
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
