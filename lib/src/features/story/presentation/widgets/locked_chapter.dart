import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/colors.const.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/api_client.dart';

/// What the server sends back for a chapter past the free ones (a 401
/// `sign_in_required` or a 402 `unlock_required`). The preview is already cut
/// on the server — the app never has the rest of the chapter.
class ChapterLock {
  ChapterLock({
    required this.signedIn,
    required this.message,
    required this.title,
    required this.preview,
    required this.price,
  });

  final bool signedIn;
  final String message;
  final String title;
  final String preview;
  final num? price;

  factory ChapterLock.fromException(ApiException e) {
    final data = e.data ?? const <String, dynamic>{};
    return ChapterLock(
      signedIn: e.code == 'unlock_required',
      message: e.message,
      title: '${data['title'] ?? ''}',
      preview: '${data['preview'] ?? ''}',
      price: data['price'] is num
          ? data['price'] as num
          : num.tryParse('${data['price'] ?? ''}'),
    );
  }
}

/// A locked chapter, kept on the reading screen as the client asked: the
/// title, the opening fading out, then "Chapter Locked" with the price, the
/// reader's coins and Unlock — or, signed out, Sign In / Create Account.
/// No listening is offered here.
class LockedChapter extends StatefulWidget {
  const LockedChapter({
    super.key,
    required this.lock,
    required this.fontSize,
    required this.onUnlock,
    this.unlocking = false,
    this.chapterNumber,
  });

  final ChapterLock lock;
  final double fontSize;

  /// Null when the book isn't known here, e.g. opened from a notification.
  final VoidCallback? onUnlock;
  final bool unlocking;

  /// Shown as "CHAPTER n" above the title, like a readable chapter.
  final int? chapterNumber;

  @override
  State<LockedChapter> createState() => _LockedChapterState();
}

class _LockedChapterState extends State<LockedChapter> {
  num? _balance;

  @override
  void initState() {
    super.initState();
    if (widget.lock.signedIn) _loadBalance();
  }

  Future<void> _loadBalance() async {
    final token = await authService.getToken();
    if (token == null) return;
    try {
      final wallet = await walletRepository.getWallet(token);
      if (mounted) setState(() => _balance = wallet.balance);
    } on ApiException {
      // Best-effort — the "You have" line just stays hidden.
    }
  }

  String _coins(num value) => value.toStringAsFixed(1);

  /// The book-with-a-padlock mark above "Chapter Locked".
  Widget _lockMark() {
    return ShaderMask(
      shaderCallback: (bounds) => defaultGradientTTB.createShader(bounds),
      child: SizedBox(
        width: 64,
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Remix.book_open_line, size: 56, color: Colors.white),
            Positioned(
              top: 6,
              child: Icon(Remix.lock_2_fill, size: 22, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  /// The opening of the chapter, fully blurred and fading into the page.
  Widget _preview(String text) {
    final style = GoogleFonts.playfair(
      fontSize: widget.fontSize,
      color: Colors.white,
      height: 1.6,
    );
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white, Colors.white, Colors.transparent],
        stops: [0, 0.6, 1],
      ).createShader(bounds),
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Text(text, style: style),
      ),
    );
  }

  Widget _backToBook(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (context.canPop()) context.pop();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          'Back to the book',
          style: TextStyle(color: Color(secondaryCOLR), fontSize: 13),
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: defaultGradientTTB,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(145, 16, 222, 0.35),
              blurRadius: 16,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            Icon(icon, size: 20, color: Colors.white),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lock = widget.lock;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        spacing: 14,
        children: [
          if (widget.chapterNumber != null) ...[
            ShaderMask(
              shaderCallback: (bounds) =>
                  defaultGradientTTB.createShader(bounds),
              child: Icon(Remix.shining_line, size: 16, color: Colors.white),
            ),
            ShaderMask(
              shaderCallback: (bounds) =>
                  defaultGradientTTB.createShader(bounds),
              child: Text(
                'CHAPTER ${widget.chapterNumber}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
          if (lock.title.isNotEmpty)
            Text(
              lock.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.playfair(fontSize: 18, color: Colors.white),
            ),
          if (lock.preview.isNotEmpty) _preview(lock.preview),
          _lockMark(),
          const Text(
            'Chapter Locked',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (lock.signedIn) ...[
            const Text(
              'This chapter is locked. Unlock the book with coins to '
              'continue reading.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
            ),
            if (lock.price != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(181, 77, 232, 0.15),
                  border: Border.all(
                    width: 1,
                    color: const Color.fromRGBO(181, 77, 232, 0.35),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(aCoinIMG, width: 26),
                      const SizedBox(width: 10),
                      Text(
                        _coins(lock.price!),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: Color.fromRGBO(255, 255, 255, 0.25),
                      ),
                      const SizedBox(width: 16),
                      const Flexible(
                        child: Text(
                          'Coins to unlock\nall chapters',
                          style: TextStyle(
                            color: Color(0xffDFBDFF),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_balance != null)
              Text(
                'You have ${_coins(_balance!)} coins',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xffDFBDFF), fontSize: 14),
              ),
            _primaryButton(
              label: widget.unlocking ? 'Unlocking…' : 'Unlock All Chapters',
              icon: Remix.lock_unlock_line,
              onTap: widget.unlocking ? null : widget.onUnlock,
            ),
          ] else ...[
            Text(
              lock.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            _primaryButton(
              label: 'Sign In',
              icon: Remix.user_3_line,
              onTap: () => context.push('/signin'),
            ),
            GestureDetector(
              onTap: () => context.push('/signup'),
              child: Container(
                width: double.infinity,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: const Color.fromRGBO(195, 132, 255, 0.5),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Create Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          _backToBook(context),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
