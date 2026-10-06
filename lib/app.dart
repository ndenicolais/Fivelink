import 'package:flutter/material.dart';

import 'core/daily.dart';
import 'game/game_screen.dart';
import 'l10n/generated/app_localizations.dart';

class FivelinkApp extends StatelessWidget {
  const FivelinkApp({super.key, this.clock = const SystemClock()});

  /// Sostituibile nei test per simulare un giorno preciso.
  final Clock clock;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      home: GameScreen(clock: clock),
    );
  }
}
