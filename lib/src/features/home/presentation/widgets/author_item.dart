import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:storryca/src/core/widgets/app_image.dart';

class AuthorItem extends StatelessWidget {
  const AuthorItem({
    super.key,
    required this.id,
    required this.name,
    required this.image,
  });

  final int id;
  final String name;
  final String image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/author-profile/$id'),
      child: Container(
        constraints: BoxConstraints(maxWidth: 90),
        child: Column(
          spacing: 8,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: AppImage(image, width: 70, height: 70),
            ),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
