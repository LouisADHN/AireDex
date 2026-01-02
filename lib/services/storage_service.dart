import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String visitedKey = 'visited_aires';

  Future<Set<String>> getVisitedAires() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(visitedKey)?.toSet() ?? {};
  }

  Future<void> saveVisitedAires(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(visitedKey, ids.toList());
  }
}
