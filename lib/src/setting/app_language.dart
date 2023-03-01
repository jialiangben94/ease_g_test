import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AppSettingRepo {
  Future<Locale> fetchLocale();
  Future<Locale> changeLanguage(Locale type);
}

class AppLanguage implements AppSettingRepo {
  Locale _appLocale = const Locale('en');
  Locale get appLocal => _appLocale;

  @override
  Future<Locale> fetchLocale() async {
    var pref = await SharedPreferences.getInstance();
    if (pref.getString('language_code') == null) {
      _appLocale = const Locale('en');
      return _appLocale;
    }
    _appLocale = Locale(pref.getString('language_code')!);
    return _appLocale;
  }

  @override
  Future<Locale> changeLanguage(Locale type) async {
    var pref = await SharedPreferences.getInstance();
    if (type == const Locale("ms")) {
      _appLocale = const Locale("ms");
      await pref.setString('language_code', 'ms');
      await pref.setString('countryCode', 'MY');
    } else {
      _appLocale = const Locale("en");
      await pref.setString('language_code', 'en');
      await pref.setString('countryCode', 'US');
    }
    if (_appLocale == type) {
      return _appLocale;
    }
    return await fetchLocale();
  }
}
