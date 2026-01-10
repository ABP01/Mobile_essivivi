import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('fr'); // Default to French as requested by user's initial state
  
  Locale get locale => _locale;
  
  LanguageProvider() {
    _loadLanguageFromPrefs();
  }
  
  void setLocale(Locale locale) {
    if (!['en', 'fr'].contains(locale.languageCode)) return;
    
    _locale = locale;
    _saveLanguageToPrefs();
    notifyListeners();
  }
  
  Future<void> _loadLanguageFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String languageCode = prefs.getString('languageCode') ?? 'fr';
    _locale = Locale(languageCode);
    notifyListeners();
  }
  
  Future<void> _saveLanguageToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', _locale.languageCode);
  }
}
