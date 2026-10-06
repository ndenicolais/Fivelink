import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'core/daily.dart';
import 'data/models.dart';
import 'data/settings_controller.dart';
import 'data/storage.dart';
import 'game/game_screen.dart';
import 'l10n/generated/app_localizations.dart';

class FivelinkApp extends StatefulWidget {
  const FivelinkApp({
    super.key,
    required this.storage,
    this.clock = const SystemClock(),
  });

  final Storage storage;

  /// Sostituibile nei test per simulare un giorno preciso.
  final Clock clock;

  @override
  State<FivelinkApp> createState() => _FivelinkAppState();
}

class _FivelinkAppState extends State<FivelinkApp> {
  late final SettingsController _settings = SettingsController(widget.storage);

  @override
  void dispose() {
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) => MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: switch (_settings.settings.theme) {
          ThemePreference.system => ThemeMode.system,
          ThemePreference.light => ThemeMode.light,
          ThemePreference.dark => ThemeMode.dark,
        },
        home: GameScreen(
          storage: widget.storage,
          settings: _settings,
          clock: widget.clock,
        ),
      ),
    );
  }
}
