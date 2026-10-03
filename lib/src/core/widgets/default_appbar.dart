import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/core/network/api.dart';
import 'package:storryca/src/core/network/image_url.dart';
import 'package:storryca/src/core/widgets/app_image.dart';

class DefaultNavbar extends StatefulWidget {
  const DefaultNavbar({super.key, required this.label});

  final String label;

  @override
  State<DefaultNavbar> createState() => _DefaultNavbarState();
}

class _DefaultNavbarState extends State<DefaultNavbar> {
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final token = await authService.getToken();
    if (token == null) return;
    try {
      final user = await usersRepository.me(token);
      if (mounted) setState(() => _avatarUrl = avatarUrl(user.image));
    } catch (_) {
      // Keep the placeholder — this is a header icon, not worth an error state.
    }
  }

  String get label => widget.label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (label == 'Discover' || label == 'Library' || label == 'Profile')
            Text(
              label,
              style: GoogleFonts.playfair(color: Colors.white, fontSize: 34),
            ),
          if (label == 'Home') Image.asset(logoIMG, width: 40, height: 42),
          if (label == 'Rank') Image.asset(rankLabelIMG, width: 88, height: 42),
          Row(
            spacing: 16,
            children: [
              IconButton(
                onPressed: () => context.push('/search'),
                icon: Icon(
                  Remix.search_2_line,
                  size: 25,
                  color: Color.fromRGBO(255, 255, 255, 0.3),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Image.asset(languageIMG, width: 40, height: 40),
              ),
              GestureDetector(
                onTap: () => context.push('/main/4'),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: _avatarUrl == null
                      ? Image.asset(noAvatarIMG, width: 40, height: 40)
                      : AppImage(_avatarUrl!, width: 40, height: 40),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
