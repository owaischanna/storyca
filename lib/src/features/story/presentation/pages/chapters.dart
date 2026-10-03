import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/models/chapter_api_model.dart';
import 'package:storryca/src/core/widgets/app_snackbar.dart';
import 'package:storryca/src/core/widgets/border_gradient_button.dart';
import 'package:storryca/src/core/widgets/error_state.dart';
import 'package:storryca/src/core/widgets/gradient_button.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/features/story/presentation/widgets/chapter_item.dart';
import 'package:storryca/src/features/story/presentation/widgets/chapter_reorder_item.dart';
import 'package:storryca/src/features/story/presentation/widgets/no_chapters.dart';

class Chapters extends StatefulWidget {
  const Chapters({super.key, required this.storyId});

  final int storyId;

  @override
  State<Chapters> createState() => _ChaptersState();
}

class _ChaptersState extends State<Chapters> {
  bool isReordering = false;
  bool _busy = false;
  String? _token;

  List<ChapterApiModel>? _chapters;
  String? _error;

  /// Working copy while [isReordering] is true — reordered locally, then
  /// sent to the API all at once on Save.
  List<ChapterApiModel> _reorderDraft = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _dateLabel(String raw) {
    final date = DateTime.tryParse(raw);
    if (date == null) return raw;
    try {
      return DateFormat('MMM d, yyyy').format(date);
    } catch (_) {
      return raw;
    }
  }

  Future<void> _load() async {
    setState(() => _error = null);
    _token = await authService.getToken();
    try {
      final chapters = await chaptersRepository.byStoryId(
        widget.storyId,
        token: _token,
      );
      if (mounted) setState(() => _chapters = chapters);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not load chapters. Try again.');
    }
  }

  Future<void> _addChapter() async {
    await context.push('/write/${widget.storyId}/0');
    _load();
  }

  Future<void> _editChapter(int chapterId) async {
    await context.push('/write/${widget.storyId}/$chapterId');
    _load();
  }

  Future<void> _publishChapter(ChapterApiModel chapter) async {
    final token = _token;
    if (token == null) return;
    setState(() => _busy = true);
    try {
      await chaptersRepository.createOrUpdateChapter(
        storyId: widget.storyId,
        chapterId: chapter.id,
        title: chapter.title,
        body: chapter.body,
        status: 'published',
        token: token,
      );
      await _load();
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteChapter(int chapterId) async {
    final token = _token;
    if (token == null) return;
    setState(() => _busy = true);
    try {
      await chaptersRepository.deleteChapter(chapterId, token);
      await _load();
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _publishAll() async {
    final token = _token;
    final chapters = _chapters;
    if (token == null || chapters == null) return;
    setState(() => _busy = true);
    try {
      for (final chapter in chapters) {
        if (chapter.status == 'Published') continue;
        await chaptersRepository.createOrUpdateChapter(
          storyId: widget.storyId,
          chapterId: chapter.id,
          title: chapter.title,
          body: chapter.body,
          status: 'published',
          token: token,
        );
      }
      if (mounted) AppSnackbar.success(context, 'All chapters published.');
      await _load();
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteAll() async {
    final token = _token;
    final chapters = _chapters;
    if (token == null || chapters == null) return;
    setState(() => _busy = true);
    try {
      for (final chapter in chapters) {
        await chaptersRepository.deleteChapter(chapter.id, token);
      }
      await _load();
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _startReordering() {
    setState(() {
      _reorderDraft = List.of(_chapters ?? []);
      isReordering = true;
    });
  }

  Future<void> _saveReorder() async {
    final token = _token;
    if (token == null) return;
    setState(() => _busy = true);
    try {
      for (var i = 0; i < _reorderDraft.length; i++) {
        final chapter = _reorderDraft[i];
        final newOrderIndex = i + 1;
        if (chapter.orderIndex == newOrderIndex) continue;
        await chaptersRepository.createOrUpdateChapter(
          storyId: widget.storyId,
          chapterId: chapter.id,
          title: chapter.title,
          body: chapter.body,
          status: chapter.status.toLowerCase(),
          orderIndex: newOrderIndex,
          token: token,
        );
      }
      if (mounted) setState(() => isReordering = false);
      await _load();
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chapters = _chapters;
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
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        spacing: 4,
                        children: [
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Icon(
                              Remix.arrow_left_s_line,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chapters',
                                style: GoogleFonts.playfair(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                'Keep writing and building your world.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (chapters != null && chapters.isNotEmpty)
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
                            if (value == 'publish') _publishAll();
                            if (value == 'delete_all') _deleteAll();
                          },
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem(
                                height: 40,
                                value: 'publish',
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 8,
                                  children: [
                                    Icon(
                                      Remix.flag_line,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    Text(
                                      'Publish All',
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
                                value: 'delete_all',
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
                                      'Delete All',
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

                // CHAPTERS
                if (_error != null)
                  ErrorState(message: _error!, onRetry: _load, height: 300)
                else if (chapters == null)
                  const LoadingState(height: 300)
                else if (chapters.isEmpty)
                  Column(
                    children: [
                      NoChapters(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          height: 40,
                          child: GradientButton(
                            label: 'Add Chapter',
                            radius: 6,
                            hasIcon: true,
                            icon: Remix.add_large_line,
                            fontSize: 12,
                            iconSize: 14,
                            padding: EdgeInsets.all(0),
                            onPressed: _busy ? () {} : _addChapter,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      spacing: 12,
                      children: [
                        // ACTIONS
                        if (!isReordering)
                          Row(
                            spacing: 12,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 100,
                                height: 35,
                                child: BorderGradientButton(
                                  label: 'Reorder',
                                  radius: 6,
                                  hasIcon: true,
                                  icon: Remix.list_unordered,
                                  fontSize: 12,
                                  iconSize: 14,
                                  padding: EdgeInsets.all(0),
                                  onPressed: _busy ? () {} : _startReordering,
                                ),
                              ),
                              SizedBox(
                                width: 100,
                                height: 35,
                                child: GradientButton(
                                  label: 'Add Chapter',
                                  radius: 6,
                                  hasIcon: true,
                                  icon: Remix.add_large_line,
                                  fontSize: 12,
                                  iconSize: 14,
                                  padding: EdgeInsets.all(0),
                                  onPressed: _busy ? () {} : _addChapter,
                                ),
                              ),
                            ],
                          ),

                        if (isReordering)
                          Row(
                            spacing: 12,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 80,
                                height: 35,
                                child: BorderGradientButton(
                                  label: 'Cancel',
                                  radius: 6,
                                  fontSize: 12,
                                  iconSize: 14,
                                  padding: EdgeInsets.all(0),
                                  onPressed: _busy
                                      ? () {}
                                      : () => setState(
                                          () => isReordering = false,
                                        ),
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                height: 35,
                                child: GradientButton(
                                  label: _busy ? 'Saving…' : 'Save',
                                  radius: 6,
                                  hasIcon: true,
                                  icon: Remix.checkbox_circle_line,
                                  fontSize: 12,
                                  iconSize: 14,
                                  padding: EdgeInsets.all(0),
                                  onPressed: _busy ? () {} : _saveReorder,
                                ),
                              ),
                            ],
                          ),

                        // LIST OF CHAPTERS
                        if (!isReordering)
                          Column(
                            spacing: 8,
                            children: [
                              ...List.generate(chapters.length, (index) {
                                final chapter = chapters[index];
                                return ChapterItem(
                                  index: index + 1,
                                  title: chapter.title,
                                  words: chapter.wordCount.toString(),
                                  status: chapter.status,
                                  date: _dateLabel(chapter.updatedAt),
                                  onEdit: () => _editChapter(chapter.id),
                                  onPublish: chapter.status == 'Published'
                                      ? null
                                      : () => _publishChapter(chapter),
                                  onDelete: () => _deleteChapter(chapter.id),
                                );
                              }),
                            ],
                          ),

                        if (isReordering)
                          ReorderableListView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            onReorderItem: (oldIndex, newIndex) {
                              setState(() {
                                final item = _reorderDraft.removeAt(oldIndex);
                                _reorderDraft.insert(newIndex, item);
                              });
                            },
                            children: [
                              ...List.generate(_reorderDraft.length, (index) {
                                final chapter = _reorderDraft[index];
                                return ChapterReorderItem(
                                  key: Key(chapter.id.toString()),
                                  index: index + 1,
                                  title: chapter.title,
                                  words: chapter.wordCount.toString(),
                                  status: chapter.status,
                                  date: _dateLabel(chapter.updatedAt),
                                );
                              }),
                            ],
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
