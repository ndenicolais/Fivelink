import 'package:flutter/material.dart';

import '../core/puzzle.dart';
import '../data/models.dart';
import '../l10n/generated/app_localizations.dart';

/// Numeri principali e distribuzione delle vittorie per tentativo.
class StatsView extends StatelessWidget {
  const StatsView({
    super.key,
    required this.stats,
    required this.currentStreak,
    this.highlightAttempts,
  });

  final Stats stats;

  /// Serie valida oggi (vedi [Stats.streakOn]).
  final int currentStreak;

  /// Tentativi della vittoria di oggi, evidenziati nel grafico.
  final int? highlightAttempts;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final int maxCount = stats.distribution.fold(1, (a, b) => b > a ? b : a);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Number(value: stats.played, label: l10n.statsPlayed),
            _Number(value: stats.winPercent, label: l10n.statsWinPercent),
            _Number(value: currentStreak, label: l10n.statsCurrentStreak),
            _Number(value: stats.maxStreak, label: l10n.statsMaxStreak),
          ],
        ),
        const SizedBox(height: 16),
        Semantics(
          header: true,
          child: Text(
            l10n.statsDistribution,
            style: theme.textTheme.titleSmall,
          ),
        ),
        const SizedBox(height: 8),
        for (int i = 0; i < maxAttempts; i++)
          _Bar(
            attempt: i + 1,
            count: stats.distribution[i],
            fraction: stats.distribution[i] / maxCount,
            highlight: highlightAttempts == i + 1,
          ),
      ],
    );
  }
}

class _Number extends StatelessWidget {
  const _Number({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Expanded(
      child: Semantics(
        label: '$label: $value',
        excludeSemantics: true,
        child: Column(
          children: [
            Text('$value', style: theme.textTheme.headlineSmall),
            Text(
              label,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.attempt,
    required this.count,
    required this.fraction,
    required this.highlight,
  });

  final int attempt;
  final int count;
  final double fraction;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final Color fill = highlight
        ? colors.primary
        : colors.surfaceContainerHighest;
    final Color onFill = highlight ? colors.onPrimary : colors.onSurface;
    return Semantics(
      label: AppLocalizations.of(context).statsBarSemantics(attempt, count),
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(width: 20, child: Text('$attempt')),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: 28,
                      maxWidth: constraints.maxWidth,
                    ),
                    width: constraints.maxWidth * fraction,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    color: fill,
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$count',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: onFill,
                        fontWeight: highlight ? FontWeight.w700 : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Statistiche in un pannello dal basso, richiamabile dalla barra in alto.
Future<void> showStatsSheet(
  BuildContext context, {
  required Stats stats,
  required int currentStreak,
  int? highlightAttempts,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                AppLocalizations.of(context).statsTitle,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            StatsView(
              stats: stats,
              currentStreak: currentStreak,
              highlightAttempts: highlightAttempts,
            ),
          ],
        ),
      ),
    ),
  );
}
