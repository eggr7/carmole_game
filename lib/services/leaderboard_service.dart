import 'package:shared_preferences/shared_preferences.dart';

class LeaderboardService {
  static const String _key = 'leaderboard_scores';

  Future<SharedPreferences> _prefs() async {
    return SharedPreferences.getInstance();
  }

  Future<List<int>> loadScores() async {
    final prefs = await _prefs();
    final list = prefs.getStringList(_key) ?? <String>[];
    final scores = <int>[];
    for (final s in list) {
      final parsed = int.tryParse(s);
      if (parsed != null) {
        if (parsed > 0) {
          scores.add(parsed);
        }
      }
    }
    scores.sort((a, b) => b.compareTo(a));
    if (scores.length > 10) {
      return scores.sublist(0, 10);
    }
    return scores;
  }

  Future<void> addScore(int score) async {
    if (score <= 0) {
      return; // Do not store zero or negative scores
    }
    final prefs = await _prefs();
    final existing = await loadScores();
    existing.add(score);
    existing.sort((a, b) => b.compareTo(a));
    final trimmed = existing.length > 10 ? existing.sublist(0, 10) : existing;
    final serialized = trimmed.map((e) => e.toString()).toList();
    await prefs.setStringList(_key, serialized);
  }

  Future<void> clear() async {
    final prefs = await _prefs();
    await prefs.remove(_key);
  }
}


