import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class LocalDbService {
  static final LocalDbService _instance = LocalDbService._internal();
  factory LocalDbService() => _instance;
  LocalDbService._internal();

  static const String _authBox = 'auth_data';

  Box? _auth;

  Future<void> init() async {
    try {
      if (kIsWeb) {
        // Web : init Hive pour IndexedDB
        await Hive.initFlutter();
      } else {
        // Mobile : init Hive avec path_provider
        final dir = await getApplicationDocumentsDirectory();
        await Hive.initFlutter(dir.path);
      }

      // Ouvrir la box
      _auth = await Hive.openBox(_authBox);

      print('✅ LocalDbService initialisé');
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation de Hive: $e');
    }
  }

  Future<void> saveAuth(String key, dynamic value) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      if (value is String) await prefs.setString(key, value);
      if (value is int) await prefs.setInt(key, value);
      if (value is bool) await prefs.setBool(key, value);
    } else {
      await _auth?.put(key, value);
    }
  }

  Future<dynamic> getAuth(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.get(key);
    } else {
      return _auth?.get(key);
    }
  }
}
