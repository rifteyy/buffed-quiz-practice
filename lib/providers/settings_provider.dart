import 'package:flutter/material.dart';
import '../constants/strings.dart';
import '../constants/theme.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage;
  String _apiKey = '';
  AppLanguage _language = AppLanguage.cs;
  int _themeColorIndex = 0;
  bool _isDarkMode = false;

  SettingsProvider(this._storage) {
    _loadSettings();
  }

  String get apiKey => _apiKey;
  bool get hasApiKey => _apiKey.isNotEmpty;
  AppLanguage get language => _language;
  int get themeColorIndex => _themeColorIndex;
  bool get isDarkMode => _isDarkMode;
  Color get themeColor => AppTheme.presetColors[_themeColorIndex];

  void _loadSettings() {
    _apiKey = _storage.getApiKey() ?? '';
    final langStr = _storage.getLanguage();
    _language = langStr == 'en' ? AppLanguage.en : AppLanguage.cs;
    _themeColorIndex = _storage.getThemeColorIndex();
    _isDarkMode = _storage.getDarkMode();

    AppStrings.setLanguage(_language);
    AppTheme.update(AppTheme.presetColors[_themeColorIndex], _isDarkMode);
    notifyListeners();
  }

  Future<void> saveApiKey(String key) async {
    _apiKey = key;
    await _storage.saveApiKey(key);
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage lang) async {
    _language = lang;
    AppStrings.setLanguage(lang);
    await _storage.saveLanguage(lang.name);
    notifyListeners();
  }

  Future<void> setThemeColorIndex(int index) async {
    _themeColorIndex = index;
    AppTheme.update(AppTheme.presetColors[index], _isDarkMode);
    await _storage.saveThemeColorIndex(index);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    AppTheme.update(AppTheme.presetColors[_themeColorIndex], value);
    await _storage.saveDarkMode(value);
    notifyListeners();
  }

  Future<void> removeApiKey() async {
    _apiKey = '';
    await _storage.removeApiKey();
    notifyListeners();
  }

  Future<void> clearAllData() async {
    await _storage.clearAll();
    _apiKey = '';
    notifyListeners();
  }
}
