const String _coverBaseUrl = 'https://storryca.com/cover';
const String _avatarBaseUrl = 'https://storryca.com/avatar';
const String noAvatarUrl = '$_avatarBaseUrl/no-avatar.png';

String coverUrl(String? filename, {required String fallbackAsset}) {
  if (filename == null || filename.isEmpty) return fallbackAsset;
  return '$_coverBaseUrl/$filename';
}

String avatarUrl(String? filename) {
  if (filename == null || filename.isEmpty) return noAvatarUrl;
  return '$_avatarBaseUrl/$filename';
}
