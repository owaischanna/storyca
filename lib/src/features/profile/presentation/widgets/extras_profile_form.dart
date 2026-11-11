import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/network/models/user_api_model.dart';
import 'package:storryca/src/core/widgets/app_snackbar.dart';
import 'package:storryca/src/core/widgets/custom_dropdown.dart';
import 'package:storryca/src/core/widgets/custom_field.dart';
import 'package:storryca/src/core/widgets/gradient_button.dart';
import 'package:storryca/src/features/profile/presentation/contents/edit_form_content.dart';

/// The same limits the website counts in the browser. The server does NOT
/// enforce them, so the app has to or the two would disagree.
const int aboutMyBooksLimit = 500;
const int toMyReadersLimit = 300;

class ExtrasProfileForm extends StatefulWidget {
  const ExtrasProfileForm({
    super.key,
    required this.user,
    required this.onSaved,
  });

  final UserApiModel user;
  final Future<void> Function({
    String? location,
    String? language,
    String? availability,
    String? aboutMyBooks,
    String? toMyReaders,
  })
  onSaved;

  @override
  State<ExtrasProfileForm> createState() => _ExtrasProfileFormState();
}

class _ExtrasProfileFormState extends State<ExtrasProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController aboutMyBooksController =
      TextEditingController(text: widget.user.aboutMyBooks);
  late final TextEditingController toMyReadersController =
      TextEditingController(text: widget.user.toMyReaders);

  /// Shows the country NAME; [_locationValue] turns it back into the exact
  /// string the server and website store ("Afghanistan" -> "Afganistan").
  late final TextEditingController myLocationController =
      TextEditingController(text: _locationName(widget.user.location));
  late final TextEditingController languageController = TextEditingController(
    text: widget.user.language,
  );
  late final TextEditingController imActiveController = TextEditingController(
    text: widget.user.availability,
  );
  bool isSaving = false;

  static String _locationName(String value) => locations
      .firstWhere((l) => l.$1 == value, orElse: () => (value, value))
      .$2;

  /// A value not in the list (e.g. saved by an older app) goes back
  /// unchanged rather than being blanked.
  static String _locationValue(String name) => locations
      .firstWhere((l) => l.$2 == name, orElse: () => (name, name))
      .$1;

  Future<void> _save() async {
    final books = aboutMyBooksController.text.trim();
    final readers = toMyReadersController.text.trim();
    if (books.length > aboutMyBooksLimit || readers.length > toMyReadersLimit) {
      AppSnackbar.error(
        context,
        'About My Books can be up to $aboutMyBooksLimit characters and To My '
        'Readers up to $toMyReadersLimit. Please shorten it.',
      );
      return;
    }
    setState(() => isSaving = true);
    try {
      await widget.onSaved(
        location: _locationValue(myLocationController.text),
        language: languageController.text,
        availability: imActiveController.text,
        aboutMyBooks: books,
        toMyReaders: readers,
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Widget _counter(TextEditingController controller, int limit) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '${value.text.length}/$limit characters',
            style: TextStyle(
              color: value.text.length > limit
                  ? Color(0xFFC23B3B)
                  : Color(0xFF9D8AC5),
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
      child: Form(
        key: _formKey,
        child: Column(
          spacing: 16,
          children: [
            // MY LOCATION
            Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Location',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                CustomDropdown(
                  controller: myLocationController,
                  items: [for (final l in locations) l.$2],
                ),
              ],
            ),

            // MY PRIMARY LANGUAGE
            Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Primary Language',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                CustomDropdown(
                  controller: languageController,
                  items: languages,
                ),
              ],
            ),

            // I'M ACTIVE
            Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'I\'m Active',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                CustomDropdown(
                  controller: imActiveController,
                  items: imActiveItems,
                ),
              ],
            ),

            // ABOUT MY BOOKS
            Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About My Books',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                CustomTextField(
                  controller: aboutMyBooksController,
                  maxLines: 3,
                  maxLength: aboutMyBooksLimit,
                  placeholder: '',
                  hideText: false,
                  hasPrefixIcon: false,
                  hasSuffixIcon: false,
                  onSubmitted: () {},
                  suffixAction: () {},
                  onChange: (value){},
                ),
                _counter(aboutMyBooksController, aboutMyBooksLimit),
              ],
            ),

            // TO MY READERS
            Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'To My Readers',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                CustomTextField(
                  controller: toMyReadersController,
                  maxLines: 2,
                  maxLength: toMyReadersLimit,
                  placeholder: '',
                  hideText: false,
                  hasPrefixIcon: false,
                  hasSuffixIcon: false,
                  onSubmitted: () {},
                  suffixAction: () {},
                  onChange: (value){},
                ),
                _counter(toMyReadersController, toMyReadersLimit),
              ],
            ),

            // BUTTON
            GradientButton(
              label: isSaving ? 'Saving...' : 'Save',
              hasIcon: true,
              icon: Remix.checkbox_circle_line,
              onPressed: isSaving ? () {} : _save,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    aboutMyBooksController.dispose();
    toMyReadersController.dispose();
    myLocationController.dispose();
    languageController.dispose();
    imActiveController.dispose();
    super.dispose();
  }
}
