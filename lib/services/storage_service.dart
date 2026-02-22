import 'package:shared_preferences/shared_preferences.dart';
import '../constants/constants.dart';
import '../models/quiz_section_model.dart';
import '../models/quiz_result_model.dart';

class StorageService {
  static StorageService? _instance;
  late SharedPreferences _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // API Key
  Future<void> saveApiKey(String apiKey) async {
    await _prefs.setString(AppConstants.storageKeyApiKey, apiKey);
  }

  String? getApiKey() {
    return _prefs.getString(AppConstants.storageKeyApiKey);
  }

  Future<void> removeApiKey() async {
    await _prefs.remove(AppConstants.storageKeyApiKey);
  }

  // Quiz Sections
  Future<void> saveSections(List<QuizSection> sections) async {
    await _prefs.setString(
        AppConstants.storageKeySections, QuizSection.encode(sections));
  }

  List<QuizSection> getSections() {
    final data = _prefs.getString(AppConstants.storageKeySections);
    if (data == null || data.isEmpty) return [];
    return QuizSection.decode(data);
  }

  // Quiz Results
  Future<void> saveResults(List<QuizResult> results) async {
    await _prefs.setString(
        AppConstants.storageKeyResults, QuizResult.encode(results));
  }

  List<QuizResult> getResults() {
    final data = _prefs.getString(AppConstants.storageKeyResults);
    if (data == null || data.isEmpty) return [];
    return QuizResult.decode(data);
  }

  // Language
  Future<void> saveLanguage(String lang) async {
    await _prefs.setString('language', lang);
  }

  String? getLanguage() {
    return _prefs.getString('language');
  }

  // Theme
  Future<void> saveThemeColorIndex(int index) async {
    await _prefs.setInt('themeColorIndex', index);
  }

  int getThemeColorIndex() {
    return _prefs.getInt('themeColorIndex') ?? 0;
  }

  Future<void> saveDarkMode(bool isDark) async {
    await _prefs.setBool('isDarkMode', isDark);
  }

  bool getDarkMode() {
    return _prefs.getBool('isDarkMode') ?? false;
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
