import 'package:flutter/material.dart';

// LocaleProvider manages the app's locale and notifies listeners when it changes.
class LocaleProvider extends ChangeNotifier {
  Locale? _locale;
  Locale? get locale => _locale;

  void setLocale(Locale locale) {
    if (!L10n.all.contains(locale)) return;
    _locale = locale;
    notifyListeners();
  }
}

// L10n helper for supported locales
class L10n {
  static const all = [
    Locale('en'),
    Locale('ar'),
  ];
}
