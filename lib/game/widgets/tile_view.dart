import 'package:flutter/material.dart';

import '../../core/operation.dart';
import '../../l10n/generated/app_localizations.dart';

/// Lato di tessere e slot: sopra i 48 dp minimi per il tocco.
const double tileSize = 56;

/// Nome della tessera per i lettori di schermo: i simboli come ⇄ non vengono
/// letti in modo comprensibile.
String operationSemantics(AppLocalizations l10n, Operation op) {
  return switch (op.kind) {
    OperationKind.add => l10n.opAdd(op.operand),
    OperationKind.subtract => l10n.opSubtract(op.operand),
    OperationKind.multiply => l10n.opMultiply(op.operand),
    OperationKind.divide => l10n.opDivide(op.operand),
    OperationKind.reverse => l10n.opReverse,
  };
}

/// Etichetta della tessera, ridotta se il testo ingrandito non ci sta.
class TileLabel extends StatelessWidget {
  const TileLabel(this.operation, {super.key, this.style});

  final Operation operation;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final TextStyle? effective =
        style ?? Theme.of(context).textTheme.titleLarge;
    return FittedBox(
      fit: BoxFit.scaleDown,
      // ⇄ manca in molti font: per l'inversione si usa un'icona inclusa
      // nell'app.
      child: operation.kind == OperationKind.reverse
          ? Icon(
              Icons.swap_horiz,
              size: (effective?.fontSize ?? 22) * 1.3,
              color: effective?.color,
            )
          : Text(operation.label, style: effective, maxLines: 1),
    );
  }
}

/// Tessera disponibile. Se è già in uno slot resta il suo posto vuoto.
class TileButton extends StatelessWidget {
  const TileButton({
    super.key,
    required this.operation,
    required this.used,
    required this.onTap,
  });

  final Operation operation;
  final bool used;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    if (used) {
      return ExcludeSemantics(
        child: _Box(
          color: Colors.transparent,
          border: BorderSide(color: colors.outlineVariant),
        ),
      );
    }
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: operationSemantics(l10n, operation),
      hint: l10n.tileHint,
      excludeSemantics: true,
      child: _Box(
        color: colors.primaryContainer,
        onTap: onTap,
        child: TileLabel(
          operation,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: colors.onPrimaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Uno dei 5 slot in cui si dispone la catena.
class SlotButton extends StatelessWidget {
  const SlotButton({
    super.key,
    required this.index,
    required this.operation,
    required this.onTap,
  });

  /// Posizione da 0.
  final int index;
  final Operation? operation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Operation? op = operation;
    return Semantics(
      button: op != null,
      label: op == null
          ? l10n.slotEmpty(index + 1)
          : l10n.slotFilled(index + 1, operationSemantics(l10n, op)),
      hint: op == null ? null : l10n.slotHint,
      excludeSemantics: true,
      child: _Box(
        color: op == null
            ? colors.surfaceContainerHighest
            : colors.secondaryContainer,
        border: BorderSide(color: colors.outline, width: op == null ? 1 : 2),
        onTap: op == null ? null : onTap,
        child: op == null
            ? Text(
                '${index + 1}',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: colors.outline),
              )
            : TileLabel(
                op,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colors.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.color, this.border, this.onTap, this.child});

  final Color color;
  final BorderSide? border;
  final VoidCallback? onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final ShapeBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: border ?? BorderSide.none,
    );
    return SizedBox.square(
      dimension: tileSize,
      child: Material(
        color: color,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
