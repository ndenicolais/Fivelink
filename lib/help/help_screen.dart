import 'package:flutter/material.dart';

import '../core/chain.dart';
import '../core/operation.dart';
import '../core/puzzle.dart';
import '../game/widgets/chain_row.dart';
import '../game/widgets/tile_view.dart';
import '../l10n/generated/app_localizations.dart';

/// Esempio della sezione 2 del piano: 17 → 163.
const int _exampleStart = 17;
const int _exampleTarget = 163;
const List<Operation> _exampleSolution = [
  Operation.add(7),
  Operation.multiply(2),
  Operation.add(9),
  Operation.multiply(3),
  Operation.subtract(8),
];

/// Come si gioca. Mostrata al primo avvio e richiamabile dalla barra in alto.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final ChainResult example = evaluateChain(_exampleStart, _exampleSolution);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(l10n.helpGoal, style: theme.textTheme.bodyLarge),
            _Heading(l10n.helpExampleTitle),
            Text(l10n.helpExampleIntro(_exampleStart, _exampleTarget)),
            const SizedBox(height: 8),
            ChainRow(
              tiles: _exampleSolution,
              result: example,
              outcome: AttemptOutcome.solved,
            ),
            _Heading(l10n.helpTilesTitle),
            _TileRule(
              tiles: const [Operation.add(4), Operation.subtract(4)],
              text: l10n.helpTileAddSubtract,
            ),
            _TileRule(
              tiles: const [Operation.multiply(2), Operation.multiply(3)],
              text: l10n.helpTileMultiply,
            ),
            _TileRule(
              tiles: const [Operation.divide(2), Operation.divide(3)],
              text: l10n.helpTileDivide,
            ),
            _TileRule(
              tiles: const [Operation.reverse()],
              text: l10n.helpTileReverse,
            ),
            _Heading(l10n.helpBreakTitle),
            _Bullet(l10n.helpBreakRange),
            _Bullet(l10n.helpBreakDivide),
            _Bullet(l10n.helpBreakReverse),
            _Heading(l10n.helpAttemptsTitle),
            Text(l10n.helpAttempts),
            const SizedBox(height: 12),
            _OutcomeRule(
              outcome: AttemptOutcome.broken,
              label: l10n.outcomeBroken,
              text: l10n.helpOutcomeBroken,
            ),
            _OutcomeRule(
              outcome: AttemptOutcome.wrongResult,
              label: l10n.outcomeWrongResult(_exampleTarget - 1),
              text: l10n.helpOutcomeWrong,
            ),
            _OutcomeRule(
              outcome: AttemptOutcome.solved,
              label: l10n.outcomeSolved,
              text: l10n.helpOutcomeSolved,
            ),
            const SizedBox(height: 16),
            Text(l10n.helpDaily, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 24),
            FilledButton(
              key: const ValueKey('help-play'),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.helpPlayButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Semantics(
        header: true,
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ExcludeSemantics(child: Text('•  ')),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _TileRule extends StatelessWidget {
  const _TileRule({required this.tiles, required this.text});

  final List<Operation> tiles;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String names = [
      for (final Operation op in tiles) operationSemantics(l10n, op),
    ].join(', ');
    return Semantics(
      label: '$names: $text',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            SizedBox(
              width: 96,
              child: Row(
                children: [
                  for (final Operation op in tiles)
                    Container(
                      width: 40,
                      height: 36,
                      margin: const EdgeInsets.only(right: 6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TileLabel(
                        op,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}

class _OutcomeRule extends StatelessWidget {
  const _OutcomeRule({
    required this.outcome,
    required this.label,
    required this.text,
  });

  final AttemptOutcome outcome;
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = outcomeColor(theme, outcome);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(outcomeIcon(outcome), size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: label,
                    style: TextStyle(color: color, fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ': $text'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
