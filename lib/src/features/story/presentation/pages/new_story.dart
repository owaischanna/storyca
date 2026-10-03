import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/widgets/app_snackbar.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/features/story/presentation/widgets/step_1.dart';
import 'package:storryca/src/features/story/presentation/widgets/step_2.dart';
import 'package:storryca/src/features/story/presentation/widgets/step_3.dart';
import 'package:storryca/src/features/story/presentation/widgets/step_4.dart';
import 'package:textfield_tags/textfield_tags.dart';

/// Genre dropdowns leave the controller at this placeholder until the
/// author actually picks one from the real list — never a real genre name,
/// so it's treated the same as "nothing selected" when validating/saving.
const String genrePlaceholder = 'Select a genre';

class NewStory extends StatefulWidget {
  const NewStory({super.key});

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
      if (!mounted) return;
      setState(() {
        genres = results[0];
        languages = results[1];
        regions = results[2];
        _loadingOptions = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loadingOptions = false);
      AppSnackbar.error(context, e.message);
    }
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
    final tags = tagsController.getTags?.join(',') ?? '';

    if (submitForReview) {
      final missing = [
        if (genre.isEmpty) 'a genre',
        if (summary.isEmpty) 'a summary',
        if (contentRating.isEmpty) 'a content rating',
        if (tags.isEmpty) 'at least one tag',
        if (languageController.text.isEmpty) 'a language',
        if (regionController.text.isEmpty) 'a region',
        if (targetAudience.isEmpty) 'a target audience',
        if (_coverPath == null) 'a cover image',
      ];
      if (missing.isNotEmpty) {
        AppSnackbar.error(context, 'Please add ${missing.join(', ')}.');
        return;
      }
    }

    setState(() => _submitting = true);
    try {
      final result = await storiesRepository.createOrUpdateStory(
        title: title,
        status: submitForReview ? 'published' : 'draft',
        genre: genre.isEmpty ? null : genre,
        summary: summary.isEmpty ? null : summary,
        contentRating: _contentRatingValue.isEmpty ? null : _contentRatingValue,
        tags: tags.isEmpty ? null : tags,
        language: languageController.text.isEmpty ? null : languageController.text,
        region: regionController.text.isEmpty ? null : regionController.text,
        audience: targetAudience.isEmpty ? null : targetAudience.toLowerCase(),
        coverPath: _coverPath,
        token: token,
      );
      if (!mounted) return;
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
                            'Create New Story',
                            style: GoogleFonts.playfair(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
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
                    ),

                  // STEP 3
                  if (step == 3)
                    Step3(
                      updateStep: updateStep,
                      updateSelectedImage: updateSelectedImage,
                      cover: cover,
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
                      tags: tagsController.getTags?.join(', ') ?? '',
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
