import 'dart:convert';

import 'package:ease/src/setting/global_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalizations {
  final Locale locale;
  String? entity;
  AppLocalizations(this.locale, this.entity);

  // Helper method to keep the code in the widgets concise
  // Localizations are accessed using an InheritedWidget "of" syntax
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // Static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();

  late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    // Load the language JSON file from the "lang" folder
    String jsonString =
        await rootBundle.loadString('i18n/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  void updateEntity() async {
    var pref = await SharedPreferences.getInstance();
    if (pref.getString(spkEntity) == null || pref.getString(spkEntity) == "") {
      await pref.setString(spkEntity, "ELIB");
      entity = pref.getString(spkEntity);
    } else {
      entity = pref.getString(spkEntity);
    }
  }

  // This method will be called from every widget which needs a localized text
  String? translate(String key, {bool? ent}) {
    if (ent != null && ent && entity == "EFTB") {
      key = "$key-${entity!}";
      return _localizedStrings[key];
    }
    return _localizedStrings[key];
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  // This delegate instance will never change (it doesn't even have fields!)
  // It can provide a constant constructor.
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Include all of your supported language codes here
    return ['en', 'ms'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    var pref = await SharedPreferences.getInstance();
    String? entity;
    if (pref.getString(spkEntity) == null || pref.getString(spkEntity) == "") {
      await pref.setString(spkEntity, "ELIB");
      entity = pref.getString(spkEntity);
    } else {
      entity = pref.getString(spkEntity);
    }
    // AppLocalizations class is where the JSON loading actually runs
    AppLocalizations localizations = AppLocalizations(locale, entity);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => true;
}
