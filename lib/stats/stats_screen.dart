import 'package:flutter/material.dart';

import '../game/game_controller.dart';
import '../l10n/generated/app_localizations.dart';
import 'stats_view.dart';

/// Statistiche a pagina intera, raggiungibili da Info e impostazioni.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).statsTitle)),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              StatsView(
                stats: controller.stats,
                currentStreak: controller.currentStreak,
                highlightAttempts: controller.status == GameStatus.won
                    ? controller.attempts.length
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
