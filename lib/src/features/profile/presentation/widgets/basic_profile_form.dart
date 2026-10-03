import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/network/models/user_api_model.dart';
import 'package:storryca/src/core/widgets/custom_field.dart';
import 'package:storryca/src/core/widgets/gradient_button.dart';

class BasicProfileForm extends StatefulWidget {
  const BasicProfileForm({super.key, required this.user, required this.onSaved});

  final UserApiModel user;
  final Future<void> Function({
    required String name,
    required String username,
    required String email,
    String? phone,
    String? aboutMe,
  })
  onSaved;

  @override
  State<BasicProfileForm> createState() => _BasicProfileFormState();
}

class _BasicProfileFormState extends State<BasicProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController nameController = TextEditingController(
    text: widget.user.name ?? '',
  );
  late final TextEditingController emailController = TextEditingController(
    text: widget.user.email,
  );
  late final TextEditingController usernameController = TextEditingController(
    text: widget.user.username ?? '',
  );
  late final TextEditingController phoneNumberController = TextEditingController(
    text: widget.user.phone ?? '',
  );
  late final TextEditingController aboutMeController = TextEditingController(
    text: widget.user.aboutMe ?? '',
  );
  bool isSaving = false;

  Future<void> _save() async {
    setState(() => isSaving = true);
    try {
      await widget.onSaved(
        name: nameController.text.trim(),
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneNumberController.text.trim(),
        aboutMe: aboutMeController.text.trim(),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
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
            // NAME
            Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Name',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                CustomTextField(
                  controller: nameController,
                  placeholder: '',
                  hideText: false,
                  hasPrefixIcon: false,
                  hasSuffixIcon: false,
                  onSubmitted: () {},
                  suffixAction: () {},
                  onChange: (value){},
                ),
              ],
            ),

            // EMAIL
            Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                CustomTextField(
                  controller: emailController,
                  placeholder: '',
                  hideText: false,
                  hasPrefixIcon: false,
                  hasSuffixIcon: false,
                  onSubmitted: () {},
                  suffixAction: () {},
                  onChange: (value){},
                ),
              ],
            ),

            // USERNAME
            Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Username',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                CustomTextField(
                  controller: usernameController,
                  placeholder: '',
                  hideText: false,
                  hasPrefixIcon: false,
                  hasSuffixIcon: false,
                  onSubmitted: () {},
                  suffixAction: () {},
                  onChange: (value){},
                ),
              ],
            ),

            // PHONE NUMBER
            Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phone Number',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                CustomTextField(
                  controller: phoneNumberController,
                  placeholder: '',
                  hideText: false,
                  hasPrefixIcon: false,
                  hasSuffixIcon: false,
                  onSubmitted: () {},
                  suffixAction: () {},
                  onChange: (value){},
                ),
              ],
            ),

            // ABOUT ME
            Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About Me',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                CustomTextField(
                  controller: aboutMeController,
                  maxLines: 3,
                  placeholder: '',
                  hideText: false,
                  hasPrefixIcon: false,
                  hasSuffixIcon: false,
                  onSubmitted: () {},
                  suffixAction: () {},
                  onChange: (value){},
                ),
                Text(
                  'A bit about yourself, personal website',
                  style: TextStyle(color: Color(0xFF9D8AC5), fontSize: 8),
                ),
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
    nameController.dispose();
    emailController.dispose();
    usernameController.dispose();
    phoneNumberController.dispose();
    aboutMeController.dispose();
    super.dispose();
  }
}
