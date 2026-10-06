import 'dart:async';

import 'package:flutter/foundation.dart';

import 'models.dart';
import 'storage.dart';

/// Impostazioni correnti, salvate a ogni modifica.
class SettingsController extends ChangeNotifier {
  SettingsController(this._storage) : _settings = _storage.loadSettings();

  final Storage _storage;
  Settings _settings;

  Settings get settings => _settings;

  void setTheme(ThemePreference theme) =>
      _update(_settings.copyWith(theme: theme));

  void setLanguage(LanguagePreference language) =>
      _update(_settings.copyWith(language: language));

  void setHaptics(bool enabled) =>
      _update(_settings.copyWith(haptics: enabled));

  void markHelpSeen() => _update(_settings.copyWith(helpSeen: true));

  void _update(Settings next) {
    if (next.theme == _settings.theme &&
        next.language == _settings.language &&
        next.haptics == _settings.haptics &&
        next.helpSeen == _settings.helpSeen) {
      return;
    }
    _settings = next;
    unawaited(_storage.saveSettings(next));
    notifyListeners();
  }
}
