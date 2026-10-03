import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/widgets/app_snackbar.dart';
import 'package:storryca/src/core/widgets/error_state.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/features/story/presentation/widgets/borderless_text_field.dart';

class Write extends StatefulWidget {
  const Write({super.key, required this.storyId, required this.chapterId});

  final int storyId;

  /// 0 means "new chapter" — nothing to load, [_isNew] is true.
  final int chapterId;

  @override
  State<Write> createState() => _WriteState();
}

class _WriteState extends State<Write> {
  /// Matches the server's own rule exactly (Milestone 4): a chapter can be
  /// saved as a draft at any length, but publishing one under this refuses
  /// with a 422 — checked here too so the author sees why before sending
  /// the request, not after it's rejected.
  static const int _minPublishWords = 300;
  static const String _idealWordRange = '600 - 1000';

  late TextEditingController titleController;
  late TextEditingController bodyController;
  int wordCount = 0;

  bool get _meetsPublishMinimum => wordCount >= _minPublishWords;

  String get _wordCountLabel {
    if (_meetsPublishMinimum) {
      return '$wordCount Words (ideal $_idealWordRange)';
    }
    final remaining = _minPublishWords - wordCount;
    return '$wordCount Words ($remaining more to publish — ideal $_idealWordRange)';
  }

  bool get _isNew => widget.chapterId == 0;

  String? _token;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  /// Set once the chapter has been saved at least once this session, so a
  /// second Save/Publish edits it instead of creating a duplicate.
  int? _savedChapterId;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    bodyController = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    _token = await authService.getToken();
    if (_isNew) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final chapter = await chaptersRepository.byId(
        widget.chapterId,
        token: _token,
      );
      if (chapter == null) {
        if (mounted) {
          setState(() {
            _error = 'Chapter not found.';
            _loading = false;
          });
        }
        return;
      }
      titleController.text = chapter.title;
      bodyController.text = chapter.body;
      _savedChapterId = chapter.id;
      if (mounted) {
        setState(() {
          wordCount = chapter.wordCount;
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    }
  }

  void _updateWordCount(String body) {
    final count = body.trim().isEmpty ? 0 : body.trim().split(RegExp(r'\s+')).length;
    setState(() => wordCount = count);
  }

  Future<void> _save({required bool publish}) async {
    final token = _token;
    if (token == null) {
      AppSnackbar.warning(context, 'Sign in to save this chapter.');
      return;
    }
    final title = titleController.text.trim();
    final body = bodyController.text.trim();
    if (title.isEmpty && body.isEmpty) {
      AppSnackbar.error(context, 'Add a title or content before saving.');
      return;
    }
    if (publish && !_meetsPublishMinimum) {
      AppSnackbar.error(
        context,
        'This chapter needs at least $_minPublishWords words before it can '
        'be published. This one has $wordCount.',
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final result = await chaptersRepository.createOrUpdateChapter(
        storyId: widget.storyId,
        chapterId: _savedChapterId,
        title: title,
        body: body,
        status: publish ? 'published' : 'draft',
        token: token,
      );
      _savedChapterId = result.id;
      if (mounted) {
        setState(() => wordCount = result.wordCount);
        AppSnackbar.success(
          context,
          publish ? 'Chapter published.' : 'Chapter saved as draft.',
        );
      }
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final token = _token;
    final chapterId = _savedChapterId;
    if (token == null || chapterId == null) {
      if (mounted) context.pop();
      return;
    }
    setState(() => _saving = true);
    try {
      await chaptersRepository.deleteChapter(chapterId, token);
      if (mounted) {
        AppSnackbar.success(context, 'Chapter deleted.');
        context.pop();
      }
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF020004),
      body: Container(
        decoration: BoxDecoration(gradient: pageGradientCOLR),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              spacing: 16,
              children: [
                // HEADER
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Icon(
                          Remix.arrow_left_s_line,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                      PopupMenuButton(
                        icon: Icon(
                          Remix.more_2_line,
                          size: 24,
                          color: Colors.white,
                        ),
                        color: Color.fromRGBO(23, 0, 45, 0.9),
                        menuPadding: EdgeInsets.all(0),
                        shape: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(width: 0),
                        ),
                        position: PopupMenuPosition.under,
                        onSelected: (value) {
                          if (_saving) return;
                          if (value == 'draft') _save(publish: false);
                          if (value == 'publish') _save(publish: true);
                          if (value == 'delete') _delete();
                        },
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                              height: 40,
                              value: 'draft',
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 8,
                                children: [
                                  Icon(
                                    Remix.edit_line,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  Text(
                                    'Save Draft',
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
                              value: 'publish',
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 8,
                                children: [
                                  Icon(
                                    Remix.pencil_line,
                                    color: _meetsPublishMinimum
                                        ? Colors.white
                                        : Color(primaryTextCOLR),
                                    size: 16,
                                  ),
                                  Text(
                                    _meetsPublishMinimum
                                        ? 'Publish'
                                        : 'Publish (needs $_minPublishWords words)',
                                    style: TextStyle(
                                      color: _meetsPublishMinimum
                                          ? Colors.white
                                          : Color(primaryTextCOLR),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!_isNew)
                              PopupMenuItem(
                                height: 40,
                                value: 'delete',
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 8,
                                  children: [
                                    Icon(
                                      Remix.delete_bin_5_line,
                                      color: Color(0xffC23B3B),
                                      size: 16,
                                    ),
                                    Text(
                                      'Delete Chapter',
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
                    ],
                  ),
                ),

                if (_loading)
                  const LoadingState(height: 400)
                else if (_error != null)
                  ErrorState(message: _error!, onRetry: _load, height: 400)
                else
                  Column(
                    children: [
                      // TITLE
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromRGBO(145, 16, 222, 0.1),
                              Color.fromRGBO(92, 9, 180, 0.1),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: BorderlessTextField(
                          controller: titleController,
                          placeholder: 'Enter chapter title',
                          hideText: false,
                          hasPrefixIcon: false,
                          hasSuffixIcon: false,
                          onSubmitted: () {},
                          suffixAction: () {},
                          onChange: (value) {},
                        ),
                      ),

                      // BODY
                      Container(
                        height: MediaQuery.of(context).size.height * 0.6,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: BorderlessTextField(
                          controller: bodyController,
                          placeholder: 'Begin the master piece...',
                          hideText: false,
                          hasPrefixIcon: false,
                          hasSuffixIcon: false,
                          onSubmitted: () {},
                          suffixAction: () {},
                          onChange: _updateWordCount,
                          maxLines: 200,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          fontStyle: GoogleFonts.playfair(
                            color: Colors.white,
                            fontSize: 14,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),

                      // FOOTER
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromRGBO(145, 16, 222, 0.1),
                              Color.fromRGBO(92, 9, 180, 0.1),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (_saving)
                              Text('Saving…', style: defaultTextStyle10),
                            Text(
                              _wordCountLabel,
                              style: defaultTextStyle10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
