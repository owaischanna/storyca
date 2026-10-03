import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/widgets/custom_dropdown.dart';
import 'package:storryca/src/core/widgets/custom_field.dart';
import 'package:storryca/src/core/widgets/gradient_button.dart';
import 'package:storryca/src/features/profile/presentation/contents/edit_form_content.dart';

class ExtrasProfileForm extends StatefulWidget {
  const ExtrasProfileForm({super.key});

  @override
  State<ExtrasProfileForm> createState() => _ExtrasProfileFormState();
}

class _ExtrasProfileFormState extends State<ExtrasProfileForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController aboutMyBooksController = TextEditingController();
  TextEditingController toMyReadersController = TextEditingController();
  TextEditingController myLocationController = TextEditingController();
  TextEditingController languageController = TextEditingController();
  TextEditingController imActiveController = TextEditingController();

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
                  items: locations,
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
                  placeholder: '',
                  hideText: false,
                  hasPrefixIcon: false,
                  hasSuffixIcon: false,
                  onSubmitted: () {},
                  suffixAction: () {},
                  onChange: (value){},
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '500 characters',
                      style: TextStyle(color: Color(0xFF9D8AC5), fontSize: 8),
                    ),
                  ],
                ),
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
                  placeholder: '',
                  hideText: false,
                  hasPrefixIcon: false,
                  hasSuffixIcon: false,
                  onSubmitted: () {},
                  suffixAction: () {},
                  onChange: (value){},
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '300 characters',
                      style: TextStyle(color: Color(0xFF9D8AC5), fontSize: 8),
                    ),
                  ],
                ),
              ],
            ),

            // BUTTON
            GradientButton(
              label: 'Save',
              hasIcon: true,
              icon: Remix.checkbox_circle_line,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
