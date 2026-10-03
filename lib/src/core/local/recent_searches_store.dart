import 'package:shared_preferences/shared_preferences.dart';

/// On-device history of submitted search queries. There's no backend
/// endpoint for this (it's personal, per-device browsing history, same as a
/// browser's), so it's kept locally rather than synced to the API.
class RecentSearchesStore {
  static const _key = 'recent_searches';
  static const _maxEntries = 10;

  static Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  /// Adds [query] to the front of the list, moving it there if it already
  /// exists rather than creating a duplicate.
  static Future<void> add(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? [];
    current.removeWhere((q) => q.toLowerCase() == trimmed.toLowerCase());
    current.insert(0, trimmed);
    await prefs.setStringList(_key, current.take(_maxEntries).toList());
  }

  static Future<void> remove(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? [];
    current.remove(query);
    await prefs.setStringList(_key, current);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
