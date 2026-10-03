import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';
import 'package:storryca/src/core/network/models/notification_api_model.dart';
import 'package:storryca/src/core/widgets/error_state.dart';
import 'package:storryca/src/core/widgets/loading_state.dart';
import 'package:storryca/src/features/inbox/presentation/widgets/inbox_item.dart';
import 'package:storryca/src/features/inbox/presentation/widgets/no_inboxes.dart';

class Inbox extends StatefulWidget {
  const Inbox({super.key});

  @override
  State<Inbox> createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  List<NotificationApiModel>? _notifications;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    // A push is the same record as an Inbox entry — reload when one lands.
    pushService.inboxChanged.addListener(_load);
  }

  @override
  void dispose() {
    pushService.inboxChanged.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _error = null);
    final token = await authService.getToken();
    if (!mounted) return;
    if (token == null) {
      setState(() => _notifications = []);
      return;
    }
    try {
      final notifications = await usersRepository.notifications(token);
      if (mounted) setState(() => _notifications = notifications);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _open(NotificationApiModel n) async {
    if (n.storyId != null) context.push('/story/${n.storyId}');
    if (n.isRead) return;
    final token = await authService.getToken();
    if (token == null) return;
    try {
      await usersRepository.markNotificationRead(n.id, token);
      // Also refreshes the unread badge on Profile.
      pushService.inboxChanged.value++;
    } on ApiException {
      // Stays marked unread; harmless.
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          context.pop();
                        },
                        icon: Icon(Remix.arrow_left_s_line),
                        color: Colors.white,
                        iconSize: 24,
                      ),
                      Text(
                        'Inbox',
                        style: GoogleFonts.playfair(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // NOTIFICATIONS OFF — with permission denied nothing arrives
                // and nothing errors, so say so here rather than fail silently.
                ValueListenableBuilder<bool?>(
                  valueListenable: pushService.permissionGranted,
                  builder: (context, granted, _) => granted != false
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GestureDetector(
                            onTap: pushService.enable,
                            child: Text.rich(
                              TextSpan(
                                text:
                                    'Notifications are turned off, so new '
                                    'updates only appear here. ',
                                style: TextStyle(
                                  color: Color(primaryTextCOLR),
                                  fontSize: 12,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Turn on',
                                    style: TextStyle(
                                      color: Color(secondaryCOLR),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),

                // INBOX ITEMS
                if (_error != null)
                  ErrorState(message: _error!, onRetry: _load, height: 300)
                else if (_notifications == null)
                  const LoadingState(height: 300)
                else if (_notifications!.isEmpty)
                  const NoInboxes()
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      spacing: 16,
                      children: [
                        ..._notifications!.map(
                          (n) => InboxItem(
                            notification: n,
                            onTap: () => _open(n),
                          ),
                        ),
                      ],
                    ),
                  ),

                // SPACING
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
