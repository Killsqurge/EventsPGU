import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/seed_events.dart';
import '../models/academic_filter.dart';
import '../models/event_item.dart';
import '../models/user_profile.dart';

class StorageService {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async => _prefs ??= await SharedPreferences.getInstance();

  String _userKey(String userId, String key) => 'u_${userId}_$key';

  Future<UserProfile?> loadSession() async {
    final raw = (await prefs).getString('session_user');
    if (raw == null) return null;
    return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveSession(UserProfile user) async {
    await (await prefs).setString('session_user', jsonEncode(user.toJson()));
  }

  Future<void> clearSession() async {
    await (await prefs).remove('session_user');
  }

  Future<List<EventItem>> loadEvents() async {
    final raw = (await prefs).getString('events_cache');
    if (raw == null) return List<EventItem>.of(SeedEvents.all);
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((item) => EventItem.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<void> saveEvents(List<EventItem> events) async {
    final raw = jsonEncode(events.map((event) => event.toJson()).toList());
    await (await prefs).setString('events_cache', raw);
  }

  Future<Set<String>> loadIdSet(String userId, String key) async {
    final values = (await prefs).getStringList(_userKey(userId, key));
    return values?.toSet() ?? {};
  }

  Future<void> saveIdSet(String userId, String key, Set<String> ids) async {
    await (await prefs).setStringList(_userKey(userId, key), ids.toList());
  }

  Future<AcademicFilter> loadFilter(String userId) async {
    final raw = (await prefs).getString(_userKey(userId, 'filter'));
    if (raw == null) return AcademicFilter.empty;
    return AcademicFilter.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveFilter(String userId, AcademicFilter filter) async {
    await (await prefs).setString(_userKey(userId, 'filter'), jsonEncode(filter.toJson()));
  }

  Future<int> loadRemindMinutes(String userId, int fallback) async {
    return (await prefs).getInt(_userKey(userId, 'remind')) ?? fallback;
  }

  Future<void> saveRemindMinutes(String userId, int minutes) async {
    await (await prefs).setInt(_userKey(userId, 'remind'), minutes);
  }

  Future<bool> loadAdmin(String userId) async {
    return (await prefs).getBool(_userKey(userId, 'admin')) ?? false;
  }

  Future<void> saveAdmin(String userId, bool value) async {
    await (await prefs).setBool(_userKey(userId, 'admin'), value);
  }

  Future<bool> loadLightTheme() async => (await prefs).getBool('theme_light') ?? false;

  Future<void> saveLightTheme(bool value) async {
    await (await prefs).setBool('theme_light', value);
  }
}
