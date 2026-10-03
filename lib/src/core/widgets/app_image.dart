import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Drop-in replacement for `Image.asset(path)` that also renders a network
/// URL when [path] is one — existing widgets keep working unchanged for
/// local asset paths, and now also work for the real cover/avatar URLs
/// returned by the API. Network images are cached to disk so the same
/// cover/avatar isn't re-downloaded every time it scrolls back into view or
/// the screen is revisited.
class AppImage extends StatelessWidget {
  const AppImage(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.fit,
  });

  final String path;
  final double? width;
  final double? height;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    // A fixed-size box (avatar circle, cover thumbnail) should always be
    // filled edge to edge, whatever the uploaded image's aspect ratio —
    // otherwise a wide/tall photo leaves gaps inside the circle.
    final fit = this.fit ??
        (width != null && height != null ? BoxFit.cover : null);
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        width: width,
        height: height,
        fit: fit,
        fadeInDuration: Duration.zero,
        placeholder: (context, url) => SizedBox(
          width: width,
          height: height,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) =>
            Container(width: width, height: height, color: Colors.white10),
      );
    }
    return Image.asset(path, width: width, height: height, fit: fit);
  }
}
