import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/widgets/app_snackbar.dart';
import 'package:storryca/src/core/widgets/custom_field.dart';
import 'package:storryca/src/core/widgets/gradient_button.dart';

/// Shared "..." menu actions — Mute Updates and Report — used on the story
/// page, the reader, and author/user profiles. Block is intentionally not
/// here: it isn't built server-side yet.
class ModerationActions {
  /// Flips mute for [userId]. Returns the server's resulting state (repaint
  /// from this, not from what was requested), or null if not signed in or
  /// the call failed.
  static Future<bool?> toggleMute(
    BuildContext context, {
    required int userId,
    required bool currentlyMuted,
  }) async {
    final token = await authService.getToken();
    if (!context.mounted) return null;
    if (token == null) {
      AppSnackbar.warning(context, 'Sign in to mute updates.');
      return null;
    }
    try {
      final (muted, message) = await moderationRepository.setMuted(
        userId,
        !currentlyMuted,
        token,
      );
      if (context.mounted) AppSnackbar.success(context, message);
      return muted;
    } on ApiException catch (e) {
      if (context.mounted) AppSnackbar.error(context, e.message);
      return null;
    }
  }

  /// Best-effort read of the current mute state — false on any failure or
  /// when signed out, so the row just shows "Mute Updates".
  static Future<bool> isMuted(int userId) async {
    final token = await authService.getToken();
    if (token == null) return false;
    try {
      return await moderationRepository.isMuted(userId, token);
    } on ApiException {
      return false;
    }
  }

  /// [targetType]: `story`, `user`, `review` or `comment`.
  static Future<void> report(
    BuildContext context, {
    required String targetType,
    required int targetId,
  }) async {
    final token = await authService.getToken();
    if (!context.mounted) return;
    if (token == null) {
      AppSnackbar.warning(context, 'Sign in to send a report.');
      return;
    }
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: const Color.fromRGBO(255, 255, 255, 0.1),
      builder: (_) => _ReportSheet(
        targetType: targetType,
        targetId: targetId,
        token: token,
      ),
    );
  }
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet({
    required this.targetType,
    required this.targetId,
    required this.token,
  });

  final String targetType;
  final int targetId;
  final String token;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  final _noteController = TextEditingController();
  Map<String, String>? _reasons;
  String? _error;
  String? _selected;
  String? _formError;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadReasons();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // Built from the server's list rather than hard-coded.
  Future<void> _loadReasons() async {
    try {
      final reasons = await moderationRepository.reasons();
      if (mounted) setState(() => _reasons = reasons);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _send() async {
    final reason = _selected;
    // Errors are shown inline — a snackbar would sit under the sheet.
    if (reason == null) {
      setState(() => _formError = 'Choose a reason for the report.');
      return;
    }
    setState(() {
      _sending = true;
      _formError = null;
    });
    try {
      final message = await moderationRepository.report(
        targetType: widget.targetType,
        targetId: widget.targetId,
        reason: reason,
        note: _noteController.text.trim(),
        token: widget.token,
      );
      if (!mounted) return;
      context.pop();
      AppSnackbar.success(context, message);
    } on ApiException catch (e) {
      if (mounted) setState(() => _formError = e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reasons = _reasons;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xff0E0318),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Text(
                widget.targetType == 'user' ? 'Report Account' : 'Report',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              if (_error != null)
                Text(_error!, style: TextStyle(color: Color(primaryTextCOLR)))
              else if (reasons == null)
                const Center(child: CircularProgressIndicator())
              else
                RadioGroup<String>(
                  groupValue: _selected,
                  onChanged: (value) => setState(() {
                    _selected = value;
                    _formError = null;
                  }),
                  child: Column(
                    children: [
                      for (final entry in reasons.entries)
                        RadioListTile<String>(
                          value: entry.key,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          activeColor: const Color(0xff9110DE),
                          title: Text(
                            entry.value,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              CustomTextField(
                controller: _noteController,
                placeholder: 'Add details (optional)',
                maxLines: 3,
                maxLength: 1000,
                hideCounter: false,
                hideText: false,
                hasPrefixIcon: false,
                hasSuffixIcon: false,
                onSubmitted: () {},
                suffixAction: () {},
                onChange: (_) {},
              ),
              if (_formError != null)
                Text(
                  _formError!,
                  style: const TextStyle(color: Color(0xffC23B3B)),
                ),
              GradientButton(
                label: _sending ? 'Sending…' : 'Send Report',
                onPressed: _sending ? () {} : _send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
