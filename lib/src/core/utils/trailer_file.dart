import 'dart:io';

import 'package:flutter/services.dart';

/// A trailer video the author just picked, checked against the server's
/// rules before it is uploaded — so a 50MB upload on a mobile connection is
/// never spent on a file the server will refuse. The server checks the same
/// things itself; when this side can't read the file, it has the last word.
class PickedTrailer {
  PickedTrailer._({
    required this.path,
    required this.name,
    required this.bytes,
    required this.width,
    required this.height,
    required this.mime,
    required this.header,
  });

  static const int maxBytes = 50 * 1024 * 1024;
  static const MethodChannel _channel = MethodChannel('storryca/video');

  final String path;
  final String name;
  final int bytes;

  /// The size it PLAYS at (rotation applied); 0 when unreadable.
  final int width;
  final int height;

  /// The container type, e.g. "video/mp4"; empty when unreadable.
  final String mime;

  /// The file's first 12 bytes — its container signature.
  final List<int> header;

  String get sizeLabel => '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';

  static Future<PickedTrailer> inspect(String path, String name) async {
    final file = File(path);
    final bytes = await file.length();
    final header = await file
        .openRead(0, 12)
        .fold<List<int>>([], (all, chunk) => all..addAll(chunk));
    Map<String, dynamic>? meta;
    try {
      meta = await _channel.invokeMapMethod<String, dynamic>('metadata', {
        'path': path,
      });
    } catch (_) {
      // No reader on this platform — the server will check it.
    }
    return PickedTrailer._(
      path: path,
      name: name,
      bytes: bytes,
      width: (meta?['width'] as num?)?.toInt() ?? 0,
      height: (meta?['height'] as num?)?.toInt() ?? 0,
      mime: meta?['mime'] as String? ?? '',
      header: header,
    );
  }

  /// What is wrong with the file, worded like the server's own refusals,
  /// or null when it looks fine.
  String? get problem {
    if (!_isMp4OrWebm) {
      return 'A trailer must be an MP4 or WebM file. An iPhone .mov will not '
          'play for everyone — export it as MP4 and upload that.';
    }
    if (bytes > maxBytes) {
      return 'That video is $sizeLabel. The limit is 50MB, so please export '
          'a smaller one.';
    }
    if (width <= 0 || height <= 0) return null;
    if (height > width) {
      return 'A trailer must be landscape, not portrait. That video is '
          '$width by $height.';
    }
    if ((width / height - 16 / 9).abs() > 0.02) {
      final d = _gcd(width, height);
      return 'A trailer must be 16:9, like a YouTube video. That one is '
          '$width by $height (${width ~/ d}:${height ~/ d}). Try 1920 by '
          '1080, or 1280 by 720.';
    }
    return null;
  }

  /// Judged by the file's own header first: the gallery picker renames
  /// files ("45.mp4") and Android files a QuickTime .mov as video/mp4, but a
  /// .mov's header still says "qt  ".
  bool get _isMp4OrWebm {
    final h = header;
    if (h.length >= 4 &&
        h[0] == 0x1A && h[1] == 0x45 && h[2] == 0xDF && h[3] == 0xA3) {
      return true; // WebM (EBML)
    }
    if (h.length >= 12 && String.fromCharCodes(h.sublist(4, 8)) == 'ftyp') {
      return String.fromCharCodes(h.sublist(8, 12)) != 'qt  ';
    }
    if (mime.isNotEmpty) return mime == 'video/mp4' || mime == 'video/webm';
    final lower = name.toLowerCase();
    return lower.endsWith('.mp4') || lower.endsWith('.webm');
  }

  static int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);
}
