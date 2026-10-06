import 'package:flutter/material.dart';

import '../../core/daily.dart';
import '../../core/puzzle.dart';
import '../../l10n/generated/app_localizations.dart';
import '../game_controller.dart';
import 'chain_row.dart';
import 'countdown_text.dart';

/// Esito della partita, soluzione se persa e conto alla rovescia.
class GameOverPanel extends StatelessWidget {
  const GameOverPanel({
    super.key,
    required this.controller,
    required this.clock,
  });

  final GameController controller;
  final Clock clock;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final bool won = controller.status == GameStatus.won;
    final Puzzle puzzle = controller.puzzle;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                won ? l10n.wonTitle : l10n.lostTitle,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
            if (won) ...[
              const SizedBox(height: 4),
              Text(
                l10n.wonSubtitle(controller.attempts.length),
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ] else ...[
              const SizedBox(height: 16),
              Text(l10n.solutionLabel, style: theme.textTheme.titleSmall),
              ChainRow(
                tiles: puzzle.tilesInOrder(puzzle.solution),
                result: puzzle.evaluate(puzzle.solution),
                outcome: AttemptOutcome.solved,
              ),
            ],
            const SizedBox(height: 16),
            CountdownText(clock: clock, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
