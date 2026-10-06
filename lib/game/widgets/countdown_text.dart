import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/daily.dart';
import '../../l10n/generated/app_localizations.dart';

/// Tempo al prossimo rompicapo, aggiornato ogni secondo.
class CountdownText extends StatefulWidget {
  const CountdownText({super.key, required this.clock, this.style});

  final Clock clock;
  final TextStyle? style;

  @override
  State<CountdownText> createState() => _CountdownTextState();
}

class _CountdownTextState extends State<CountdownText> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Duration left = timeUntilNextPuzzle(widget.clock.now());
    return Text(
      AppLocalizations.of(context).nextPuzzleIn(formatCountdown(left)),
      style: widget.style,
      textAlign: TextAlign.center,
    );
  }
}

/// `hh:mm:ss`, senza valori negativi.
String formatCountdown(Duration d) {
  final int total = d.isNegative ? 0 : d.inSeconds;
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(total ~/ 3600)}:${two(total % 3600 ~/ 60)}:${two(total % 60)}';
}
