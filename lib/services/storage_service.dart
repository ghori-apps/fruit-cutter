import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyUnlockedLevel = 'unlocked_level';
  static const String _keyLevelStars = 'level_stars';
  static const String _keyCoins = 'coins';
  static const String _keyArcadeHighScore = 'arcade_high_score';
  static const String _keyZenHighScore = 'zen_high_score';
  static const String _keySelectedBlade = 'selected_blade';
  static const String _keyUnlockedBlades = 'unlocked_blades';
  static const String _keySelectedDojo = 'selected_dojo';
  static const String _keyUnlockedDojos = 'unlocked_dojos';
  static const String _keyMusicEnabled = 'music_enabled';
  static const String _keySfxEnabled = 'sfx_enabled';
  static const String _keyHapticsEnabled = 'haptics_enabled';
  static const String _keyBgmVolume = 'bgm_volume';
  static const String _keySfxVolume = 'sfx_volume';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // --- Levels & Progression ---
  int get unlockedLevel => _prefs.getInt(_keyUnlockedLevel) ?? 1;

  Future<void> setUnlockedLevel(int level) async {
    if (level > unlockedLevel) {
      await _prefs.setInt(_keyUnlockedLevel, level);
    }
  }

  Map<int, int> get levelStars {
    final raw = _prefs.getString(_keyLevelStars);
    if (raw == null) return {};
    try {
      final Map<String, dynamic> decoded = jsonDecode(raw);
      return decoded.map((k, v) => MapEntry(int.parse(k), v as int));
    } catch (_) {
      return {};
    }
  }

  int getStarsForLevel(int level) {
    return levelStars[level] ?? 0;
  }

  Future<void> saveLevelStars(int level, int stars) async {
    final currentMap = Map<int, int>.from(levelStars);
    final previousStars = currentMap[level] ?? 0;
    if (stars > previousStars) {
      currentMap[level] = stars;
      final encoded = jsonEncode(currentMap.map((k, v) => MapEntry(k.toString(), v)));
      await _prefs.setString(_keyLevelStars, encoded);
    }
  }

  int get totalStarsEarned {
    return levelStars.values.fold(0, (sum, stars) => sum + stars);
  }

  // --- Coins Currency ---
  int get coins => _prefs.getInt(_keyCoins) ?? 150; // Starting bonus coins

  Future<void> addCoins(int amount) async {
    final updated = coins + amount;
    await _prefs.setInt(_keyCoins, updated);
  }

  Future<bool> spendCoins(int amount) async {
    if (coins >= amount) {
      await _prefs.setInt(_keyCoins, coins - amount);
      return true;
    }
    return false;
  }

  // --- High Scores ---
  int get arcadeHighScore => _prefs.getInt(_keyArcadeHighScore) ?? 0;

  Future<void> saveArcadeHighScore(int score) async {
    if (score > arcadeHighScore) {
      await _prefs.setInt(_keyArcadeHighScore, score);
    }
  }

  int get zenHighScore => _prefs.getInt(_keyZenHighScore) ?? 0;

  Future<void> saveZenHighScore(int score) async {
    if (score > zenHighScore) {
      await _prefs.setInt(_keyZenHighScore, score);
    }
  }

  // --- Blades Customization ---
  String get selectedBladeId => _prefs.getString(_keySelectedBlade) ?? 'blade_classic';

  Future<void> setSelectedBladeId(String bladeId) async {
    await _prefs.setString(_keySelectedBlade, bladeId);
  }

  List<String> get unlockedBladeIds {
    return _prefs.getStringList(_keyUnlockedBlades) ?? ['blade_classic'];
  }

  Future<void> unlockBlade(String bladeId) async {
    final list = List<String>.from(unlockedBladeIds);
    if (!list.contains(bladeId)) {
      list.add(bladeId);
      await _prefs.setStringList(_keyUnlockedBlades, list);
    }
  }

  // --- Dojo Themes Customization ---
  String get selectedDojoId => _prefs.getString(_keySelectedDojo) ?? 'dojo_classic';

  Future<void> setSelectedDojoId(String dojoId) async {
    await _prefs.setString(_keySelectedDojo, dojoId);
  }

  List<String> get unlockedDojoIds {
    return _prefs.getStringList(_keyUnlockedDojos) ?? ['dojo_classic'];
  }

  Future<void> unlockDojo(String dojoId) async {
    final list = List<String>.from(unlockedDojoIds);
    if (!list.contains(dojoId)) {
      list.add(dojoId);
      await _prefs.setStringList(_keyUnlockedDojos, list);
    }
  }

  // --- Settings ---
  bool get isMusicEnabled => _prefs.getBool(_keyMusicEnabled) ?? true;
  Future<void> setMusicEnabled(bool val) => _prefs.setBool(_keyMusicEnabled, val);

  bool get isSfxEnabled => _prefs.getBool(_keySfxEnabled) ?? true;
  Future<void> setSfxEnabled(bool val) => _prefs.setBool(_keySfxEnabled, val);

  bool get isHapticsEnabled => _prefs.getBool(_keyHapticsEnabled) ?? true;
  Future<void> setHapticsEnabled(bool val) => _prefs.setBool(_keyHapticsEnabled, val);

  double get bgmVolume => _prefs.getDouble(_keyBgmVolume) ?? 0.6;
  Future<void> setBgmVolume(double val) => _prefs.setDouble(_keyBgmVolume, val);

  double get sfxVolume => _prefs.getDouble(_keySfxVolume) ?? 0.9;
  Future<void> setSfxVolume(double val) => _prefs.setDouble(_keySfxVolume, val);
}
