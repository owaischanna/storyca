import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/image_url.dart';
import 'package:storryca/src/core/network/models/story_api_model.dart';
import 'package:storryca/src/core/utils/trailer_file.dart';
import 'package:storryca/src/core/widgets/app_snackbar.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/features/story/presentation/widgets/step_1.dart';
import 'package:storryca/src/features/story/presentation/widgets/step_2.dart';
import 'package:storryca/src/features/story/presentation/widgets/step_3.dart';
import 'package:storryca/src/features/story/presentation/widgets/step_4.dart';
import 'package:storryca/src/features/story/presentation/widgets/trailer_picker.dart';
import 'package:textfield_tags/textfield_tags.dart';

/// Genre dropdowns leave the controller at this placeholder until the
/// author actually picks one from the real list — never a real genre name,
/// so it's treated the same as "nothing selected" when validating/saving.
const String genrePlaceholder = 'Select a genre';

class NewStory extends StatefulWidget {
  const NewStory({super.key, this.story});

  /// Set for "Edit Story": the wizard opens prefilled with this story and
  /// saves over it. Null creates a new story.
  final StoryApiModel? story;

  @override
  State<NewStory> createState() => NewStoryState();
}

class NewStoryState extends State<NewStory> {
  int step = 1;

  TextEditingController titleController = TextEditingController();
  TextEditingController genreController = TextEditingController();
  TextEditingController summaryController = TextEditingController();

  TextEditingController languageController = TextEditingController();
  TextEditingController regionController = TextEditingController();

  String contentRating = '';
  String targetAudience = '';
  StringTagController tagsController = StringTagController();

  dynamic cover;

  /// Tags as last left on the Settings step (the tag field's controller is
  /// rebuilt each time that step opens).
  List<String> _tags = [];

  /// A newly picked trailer, uploaded on save; [existingTrailer] is the one
  /// the novel already has (editing), [removeTrailer] asks to delete it.
  PickedTrailer? trailer;
  StoryTrailer? existingTrailer;
  bool removeTrailer = false;
  String? trailerError;
  bool _checkingTrailer = false;

  bool get _editing => widget.story != null;

  List<String> genres = [];
  List<String> languages = [];
  List<String> regions = [];
  bool _loadingOptions = true;
  bool _submitting = false;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    _token = await authService.getToken();
    try {
      final results = await Future.wait([
        storiesRepository.genres(),
        storiesRepository.languages(),
        storiesRepository.regions(),
      ]);
      final editing = widget.story;
      StoryApiModel? story = editing;
      if (editing != null) {
        // The public story carries the trailer; drafts aren't public, so
        // fall back to the author's own copy from the list.
        try {
          story = await storiesRepository.byId(editing.id);
        } on ApiException {
          story = editing;
        }
      }
      if (!mounted) return;
      setState(() {
        genres = results[0];
        languages = results[1];
        regions = results[2];
        if (story != null) _prefill(story);
        _loadingOptions = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loadingOptions = false);
      AppSnackbar.error(context, e.message);
    }
  }

  /// The list's own spelling of [value] when it has one (the server may
  /// send "inspiration" for "Inspiration"), otherwise [value] as-is.
  String _match(List<String> options, String value) => options.firstWhere(
    (o) => o.toLowerCase() == value.toLowerCase(),
    orElse: () => value,
  );

  void _prefill(StoryApiModel story) {
    titleController.text = story.title;
    if (story.genre.isNotEmpty) {
      genreController.text = _match(genres, story.genre);
    }
    summaryController.text = story.summary;
    if (story.language.isNotEmpty) {
      languageController.text = _match(languages, story.language);
    }
    if (story.region.isNotEmpty) {
      regionController.text = _match(regions, story.region);
    }
    contentRating = switch (story.contentRating.toLowerCase()) {
      'everyone' => 'Everyone',
      '4' => '4+',
      '12' => '12+',
      '16' => '16+',
      '18' => '18+',
      _ => '',
    };
    targetAudience = _match(['General', 'Male', 'Female'], story.audience);
    _tags = story.tags
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    if ((story.cover ?? '').isNotEmpty) {
      cover = NetworkImage(coverUrl(story.cover, fallbackAsset: ''));
    }
    existingTrailer = story.trailer;
  }

  Future<void> pickTrailer() async {
    final file = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (file == null || !mounted) return;
    setState(() => _checkingTrailer = true);
    try {
      final picked = await PickedTrailer.inspect(file.path, file.name);
      final problem = picked.problem;
      if (!mounted) return;
      setState(() {
        if (problem == null) trailer = picked;
        trailerError = problem;
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => trailerError = 'Could not read that video. Try another file.',
        );
      }
    } finally {
      if (mounted) setState(() => _checkingTrailer = false);
    }
  }

  /// Drops a newly picked file first (the current trailer shows again);
  /// with nothing new picked, marks the current trailer for removal.
  void clearTrailer() {
    setState(() {
      if (trailer != null) {
        trailer = null;
      } else if (existingTrailer != null) {
        removeTrailer = true;
      }
      trailerError = null;
    });
  }

  void updateSelectedImage(dynamic newCover) {
    cover = newCover;
    setState(() {});
  }

  void updateContentRating(String rating) {
    setState(() {
      contentRating = rating;
    });
  }

  void updateTargetAudience(String audience) {
    setState(() {
      targetAudience = audience;
    });
  }

  void updateStep(int newStep) {
    setState(() {
      if (step == 2 && newStep != 2) {
        _tags = tagsController.getTags?.toList() ?? [];
      }
      if (step != 2 && newStep == 2) {
        tagsController = StringTagController();
      }
      step = newStep;
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    genreController.dispose();
    summaryController.dispose();
    languageController.dispose();
    regionController.dispose();
    tagsController.dispose();
    super.dispose();
  }

  void updateState() {
    setState(() {});
  }

  String? get _coverPath {
    final selected = cover;
    return selected is FileImage ? selected.file.path : null;
  }

  String get _contentRatingValue => switch (contentRating) {
    'Everyone' => 'everyone',
    '4+' => '4',
    '12+' => '12',
    '16+' => '16',
    '18+' => '18',
    _ => '',
  };

  /// Shared by the header's quick "Save Draft" action and Step 4's final
  /// submit button. A draft only strictly needs a title; submitting for
  /// review needs everything the wizard collects, including a cover.
  Future<void> _submit({required bool submitForReview}) async {
    final token = _token;
    if (token == null) {
      AppSnackbar.warning(context, 'Sign in to save your story.');
      return;
    }
    final title = titleController.text.trim();
    if (title.isEmpty) {
      AppSnackbar.error(context, 'Give your story a title first.');
      return;
    }
    final genre = genreController.text == genrePlaceholder
        ? ''
        : genreController.text.trim();
    final summary = summaryController.text.trim();
    final tags = (step == 2 ? tagsController.getTags ?? [] : _tags).join(',');

    if (submitForReview) {
      final missing = [
        if (genre.isEmpty) 'a genre',
        if (summary.isEmpty) 'a summary',
        if (contentRating.isEmpty) 'a content rating',
        if (tags.isEmpty) 'at least one tag',
        if (languageController.text.isEmpty) 'a language',
        if (regionController.text.isEmpty) 'a region',
        if (targetAudience.isEmpty) 'a target audience',
        if (_coverPath == null && cover == null) 'a cover image',
      ];
      if (missing.isNotEmpty) {
        AppSnackbar.error(context, 'Please add ${missing.join(', ')}.');
        return;
      }
    }

    setState(() => _submitting = true);
    try {
      final result = await storiesRepository.createOrUpdateStory(
        storyId: widget.story?.id,
        title: title,
        status: submitForReview ? 'published' : 'draft',
        genre: genre.isEmpty ? null : genre,
        summary: summary.isEmpty ? null : summary,
        contentRating: _contentRatingValue.isEmpty ? null : _contentRatingValue,
        tags: tags.isEmpty ? null : tags,
        language: languageController.text.isEmpty
            ? null
            : languageController.text,
        region: regionController.text.isEmpty ? null : regionController.text,
        audience: targetAudience.isEmpty ? null : targetAudience.toLowerCase(),
        coverPath: _coverPath,
        trailerPath: trailer?.path,
        removeTrailer: removeTrailer,
        token: token,
      );
      if (!mounted) return;
      if (_editing) {
        AppSnackbar.success(
          context,
          submitForReview ? 'Story saved and sent for review.' : 'Draft saved.',
        );
        context.pop(true);
        return;
      }
      context.pushReplacement(
        '/story-created/${result.storyId}',
        extra: submitForReview,
      );
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
                          Text(
                            _editing ? 'Edit Story' : 'Create New Story',
                            style: GoogleFonts.playfair(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      // Saving a live story as a draft would take it down,
                      // so editing one only offers the review submit.
                      if (!_editing ||
                          widget.story!.status.toLowerCase() == 'draft')
                        GestureDetector(
                          onTap: _submitting
                              ? null
                              : () => _submit(submitForReview: false),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Color.fromRGBO(181, 77, 232, 0.1),
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              spacing: 4,
                              children: [
                                Icon(
                                  Remix.save_3_line,
                                  size: 12,
                                  color: Color(secondaryCOLR),
                                ),
                                Text(
                                  _submitting ? 'Saving…' : 'Save Draft',
                                  style: secondaryF12TS,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                if (_loadingOptions)
                  const LoadingState(height: 300)
                else ...[
                  // STEP 1
                  if (step == 1)
                    Step1(
                      updateStep: updateStep,
                      titleController: titleController,
                      genreController: genreController,
                      summaryController: summaryController,
                      updateState: updateState,
                      genres: genres,
                    ),

                  // STEP 2
                  if (step == 2)
                    Step2(
                      updateStep: updateStep,
                      titleController: titleController,
                      languageController: languageController,
                      regionController: regionController,
                      updateState: updateState,
                      contentRating: contentRating,
                      updateContentRating: updateContentRating,
                      tagsController: tagsController,
                      targetAudience: targetAudience,
                      updateTargetAudience: updateTargetAudience,
                      languages: languages,
                      regions: regions,
                      initialTags: _tags,
                    ),

                  // STEP 3
                  if (step == 3)
                    Step3(
                      updateStep: updateStep,
                      updateSelectedImage: updateSelectedImage,
                      cover: cover,
                      trailer: TrailerPicker(
                        picked: trailer,
                        existing: removeTrailer ? null : existingTrailer,
                        error: trailerError,
                        checking: _checkingTrailer,
                        onPick: pickTrailer,
                        onClear: clearTrailer,
                      ),
                    ),

                  // STEP 4
                  if (step == 4)
                    Step4(
                      updateStep: updateStep,
                      cover: cover,
                      title: titleController.text,
                      genre: genreController.text == genrePlaceholder
                          ? ''
                          : genreController.text,
                      summary: summaryController.text,
                      contentRating: contentRating,
                      tags: _tags.join(', '),
                      language: languageController.text,
                      region: regionController.text,
                      targetAudience: targetAudience,
                      submitting: _submitting,
                      onSubmit: () => _submit(submitForReview: true),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
