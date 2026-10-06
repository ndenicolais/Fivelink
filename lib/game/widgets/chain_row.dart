import 'package:flutter/material.dart';

import '../../app_theme.dart';
import '../../core/chain.dart';
import '../../core/operation.dart';
import '../../core/puzzle.dart';
import '../../l10n/generated/app_localizations.dart';
import 'tile_view.dart';

/// Durata della comparsa di ogni passaggio della catena.
const Duration chainStepDuration = Duration(milliseconds: 380);

/// Passaggi da mostrare: i valori calcolati più quello della rottura.
int chainSteps(ChainResult result) =>
    result.isComplete ? result.length : result.values.length + 1;

/// Icona dell'esito: l'informazione non è affidata solo al colore.
IconData outcomeIcon(AttemptOutcome outcome) => switch (outcome) {
  AttemptOutcome.broken => Icons.link_off,
  AttemptOutcome.wrongResult => Icons.close,
  AttemptOutcome.solved => Icons.check_circle,
};

Color outcomeColor(BuildContext context, AttemptOutcome outcome) =>
    switch (outcome) {
      AttemptOutcome.broken => GameColors.of(context).broken,
      AttemptOutcome.wrongResult => GameColors.of(context).wrongResult,
      AttemptOutcome.solved => GameColors.of(context).solved,
    };

/// Una catena: per ogni tessera la sua etichetta e il valore ottenuto.
/// Mostra solo i primi [revealed] passaggi; l'esito compare alla fine.
class ChainRow extends StatelessWidget {
  const ChainRow({
    super.key,
    required this.tiles,
    required this.result,
    required this.outcome,
    this.number,
    int? revealed,
  }) : revealed = revealed ?? 1 << 30;

  final List<Operation> tiles;
  final ChainResult result;
  final AttemptOutcome outcome;

  /// Numero del tentativo, o null per la soluzione.
  final int? number;
  final int revealed;

  bool get _done => revealed >= chainSteps(result);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final String outcomeText = switch (outcome) {
      AttemptOutcome.broken => l10n.outcomeBroken,
      AttemptOutcome.wrongResult => l10n.outcomeWrongResult(
        result.finalValue ?? 0,
      ),
      AttemptOutcome.solved => l10n.outcomeSolved,
    };
    final String tilesText = [
      for (final Operation op in tiles) operationSemantics(l10n, op),
    ].join(', ');

    return Semantics(
      label: number == null
          ? '$tilesText. $outcomeText'
          : l10n.attemptSemantics(number!, tilesText, outcomeText),
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 28,
                  child: number == null
                      ? null
                      : Text(
                          '$number',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                ),
                for (int i = 0; i < tiles.length; i++)
                  Expanded(child: _cell(context, i)),
              ],
            ),
            AnimatedOpacity(
              opacity: _done ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.only(left: 28, top: 2),
                child: Row(
                  children: [
                    Icon(
                      outcomeIcon(outcome),
                      size: 18,
                      color: outcomeColor(context, outcome),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        outcomeText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: outcomeColor(context, outcome),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell(BuildContext context, int i) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final GameColors game = GameColors.of(context);
    final bool shown = i < revealed;
    final bool isBreak = result.brokenAt == i;
    final bool afterBreak = result.brokenAt != null && i > result.brokenAt!;

    final Widget value;
    if (!shown || afterBreak) {
      value = Text('·', style: theme.textTheme.titleMedium);
    } else if (isBreak) {
      value = Icon(Icons.close, color: game.broken, size: 22);
    } else {
      final int v = result.values[i];
      final bool hit =
          i == tiles.length - 1 && outcome == AttemptOutcome.solved;
      value = Text(
        '$v',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: hit ? FontWeight.w800 : FontWeight.w500,
          color: hit ? game.solved : null,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Opacity(
        opacity: afterBreak ? 0.45 : 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(8),
                border: isBreak && shown
                    ? Border.all(color: game.broken, width: 2)
                    : Border.all(color: colors.outline),
              ),
              child: TileLabel(tiles[i], style: theme.textTheme.titleSmall),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 26,
              child: FittedBox(fit: BoxFit.scaleDown, child: value),
            ),
          ],
        ),
      ),
    );
  }
}

/// [ChainRow] che svela i passaggi uno alla volta e poi chiama
/// [onRevealed]. Se le animazioni sono disattivate mostra tutto subito.
class AnimatedChainRow extends StatefulWidget {
  const AnimatedChainRow({
    super.key,
    required this.tiles,
    required this.result,
    required this.outcome,
    required this.number,
    required this.onRevealed,
  });

  final List<Operation> tiles;
  final ChainResult result;
  final AttemptOutcome outcome;
  final int number;
  final VoidCallback onRevealed;

  @override
  State<AnimatedChainRow> createState() => _AnimatedChainRowState();
}

class _AnimatedChainRowState extends State<AnimatedChainRow>
    with SingleTickerProviderStateMixin {
  late final int _steps = chainSteps(widget.result);
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: chainStepDuration * _steps,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.isAnimating || _controller.isCompleted) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onRevealed());
    } else {
      _controller.forward().whenCompleteOrCancel(() {
        if (mounted) widget.onRevealed();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => ChainRow(
        tiles: widget.tiles,
        result: widget.result,
        outcome: widget.outcome,
        number: widget.number,
        // Il primo passaggio compare subito, l'ultimo a fine animazione.
        revealed: (_controller.value * _steps).ceil(),
      ),
    );
  }
}
