import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:finpet/domain/models.dart';

class ProfileStore {
  static const _key = 'finni_profile_v1';

  Future<GameProfile?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    return GameProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> write(GameProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profile.toJson()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
