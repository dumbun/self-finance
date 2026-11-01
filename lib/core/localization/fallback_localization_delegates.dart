import 'package:cupertino_ui/cupertino_ui.dart' as cui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_ui/material_ui.dart' as mui;

/// Fallback delegate for CupertinoLocalizations to gracefully support
/// regional locales (such as Telugu, Hindi, Marathi, etc.) where Cupertino
/// does not ship an iOS localization bundle.
class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      DefaultCupertinoLocalizations.load(locale);

  @override
  bool shouldReload(FallbackCupertinoLocalizationsDelegate old) => false;
}

/// Fallback delegate for MaterialLocalizations to gracefully support
/// any custom or regional locales where full Material bundles are absent.
class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      DefaultMaterialLocalizations.load(locale);

  @override
  bool shouldReload(FallbackMaterialLocalizationsDelegate old) => false;
}

/// Fallback delegate for material_ui MaterialLocalizations to guarantee
/// all material_ui widgets (e.g. Scaffold, AppBar, NavigationDestination, Pinput)
/// always find their required ancestor.
class FallbackMuiMaterialLocalizationsDelegate
    extends LocalizationsDelegate<mui.MaterialLocalizations> {
  const FallbackMuiMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<mui.MaterialLocalizations> load(Locale locale) =>
      mui.DefaultMaterialLocalizations.load(locale);

  @override
  bool shouldReload(FallbackMuiMaterialLocalizationsDelegate old) => false;
}

/// Fallback delegate for cupertino_ui CupertinoLocalizations.
class FallbackMuiCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<cui.CupertinoLocalizations> {
  const FallbackMuiCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<cui.CupertinoLocalizations> load(Locale locale) =>
      cui.DefaultCupertinoLocalizations.load(locale);

  @override
  bool shouldReload(FallbackMuiCupertinoLocalizationsDelegate old) => false;
}

