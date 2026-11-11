import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/widgets/app_snackbar.dart';
import 'package:storryca/src/core/widgets/custom_field.dart';
import 'package:storryca/src/features/account/contents/account_settings_content.dart';

class DeleteAccountModal extends StatefulWidget {
  const DeleteAccountModal({super.key});

  @override
  State<DeleteAccountModal> createState() => _DeleteAccountModalState();
}

class _DeleteAccountModalState extends State<DeleteAccountModal> {
  bool _deleting = false;
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  /// Shown inside the dialog — a snackbar would sit hidden behind it.
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    if (_deleting) return;
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim().toUpperCase();
    if (password.isEmpty) {
      setState(() => _error = 'Current password is required.');
      return;
    }
    if (confirm != 'DELETE') {
      setState(() => _error = 'Type DELETE to confirm account deletion.');
      return;
    }
    final token = await authService.getToken();
    if (token == null) return;
    setState(() {
      _deleting = true;
      _error = null;
    });
    try {
      await usersRepository.deleteAccount(
        token,
        currentPassword: password,
        confirm: confirm,
      );
      await authService.logout();
      if (!mounted) return;
      AppSnackbar.success(context, 'Your account has been deleted.');
      context.go('/signin');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _deleting = false;
        _error = e.message;
      });
    }
  }

  Widget _field(
    String label,
    TextEditingController controller,
    String placeholder, {
    bool secret = false,
  }) {
    return Column(
      spacing: 6,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
        CustomTextField(
          controller: controller,
          placeholder: placeholder,
          hideText: secret,
          hasPrefixIcon: false,
          hasSuffixIcon: false,
          enabled: !_deleting,
          onSubmitted: () {},
          suffixAction: () {},
          onChange: (_) {
            if (_error != null) setState(() => _error = null);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(0),
      backgroundColor: Colors.transparent,
      // Scrolls so the fields stay reachable above the keyboard.
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF0D0216),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              spacing: 16,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Icon(
                        Remix.close_large_line,
                        size: 18,
                        color: Color(0xFFB54DE8),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(194, 59, 59, 0.1),
                    border: Border.all(width: 1, color: Color(0xFFC23B3B)),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Icon(
                    Remix.delete_bin_5_line,
                    size: 30,
                    color: Color(0xFFC23B3B),
                  ),
                ),
                Text(
                  'Delete Account?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  deleteAccountCaption,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xff9D8AC5), fontSize: 12),
                ),
                _field(
                  'Current Password',
                  _passwordController,
                  'Enter your current password',
                  secret: true,
                ),
                _field('Type DELETE to confirm', _confirmController, 'DELETE'),
                if (_error != null)
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFFC23B3B), fontSize: 12),
                  ),
                Column(
                  spacing: 8,
                  children: [
                    // DELETE BUTTON
                    GestureDetector(
                      onTap: _delete,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Color(0xffC23B3B),
                          ),
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [Color(0xFFC23B3B), Color(0xFF6A0A0A)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _deleting ? 'Deleting…' : 'Delete My Account',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ),

                    // CANCEL BUTTON
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 0.3,
                            color: Color(0xff9D8AC5),
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.transparent,
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xFF9D8AC5),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
