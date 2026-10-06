import 'package:fivelink/app.dart';
import 'package:fivelink/core/puzzle.dart';
import 'package:fivelink/core/puzzle_generator.dart';
import 'package:fivelink/data/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_clock.dart';
import 'helpers/test_storage.dart';

/// Rompicapo #1 (10 ottobre 2026): partenza 17, obiettivo 114,
/// tessere `⇄ +4 ÷2 −3 ×3`, soluzione `[0, 3, 2, 1, 4]`.
final DateTime _launchDay = DateTime(2026, 10, 10, 9, 30);

/// Avvia l'app. Senza [storage] parte con la guida già vista.
Future<void> _startGame(
  WidgetTester tester, {
  Storage? storage,
  FakeClock? clock,
}) async {
  final Storage s = storage ?? await createStorage(helpSeenValues);
  await tester.pumpWidget(
    FivelinkApp(storage: s, clock: clock ?? FakeClock(_launchDay)),
  );
  await tester.pumpAndSettle();
}

Future<void> _playOrder(WidgetTester tester, List<int> order) async {
  for (final int tile in order) {
    await tester.tap(find.byKey(ValueKey('tile-$tile')));
    await tester.pump();
  }
  await tester.tap(find.byKey(const ValueKey('check')));
  await tester.pumpAndSettle();
}

Future<void> _clear(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('clear')));
  await tester.pump();
}

FilledButton _checkButton(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byKey(const ValueKey('check')));

void main() {
  testWidgets('shows the daily puzzle', (tester) async {
    await _startGame(tester);
    expect(find.text('Fivelink #1'), findsOneWidget);
    expect(find.text('17'), findsOneWidget);
    expect(find.text('114'), findsOneWidget);
    expect(find.text('Attempt 1 of 6'), findsOneWidget);
    expect(_checkButton(tester).onPressed, isNull);
  });

  testWidgets('arrange the tiles, check and win', (tester) async {
    await _startGame(tester);

    await tester.tap(find.byKey(const ValueKey('tile-0')));
    await tester.pump();
    // Toccando lo slot pieno la tessera torna indietro.
    await tester.tap(find.byKey(const ValueKey('slot-0')));
    await tester.pump();
    expect(find.bySemanticsLabel('Slot 1, empty'), findsOneWidget);

    await _playOrder(tester, [0, 3, 2, 1, 4]);

    expect(find.text('Solved!'), findsOneWidget);
    expect(find.text('On the first attempt'), findsOneWidget);
    expect(find.textContaining('Next puzzle in'), findsOneWidget);
    expect(find.byKey(const ValueKey('check')), findsNothing);
    // I valori intermedi del tentativo restano visibili.
    await tester.drag(find.byType(ListView), const Offset(0, 2000));
    await tester.pumpAndSettle();
    for (final String v in ['71', '68', '34', '38']) {
      expect(find.text(v), findsOneWidget);
    }
  });

  testWidgets('a wrong attempt shows its chain and allows another try', (
    tester,
  ) async {
    await _startGame(tester);
    // 17 → ⇄ 71 → +4 75 → ÷2 si spezza.
    await _playOrder(tester, [0, 1, 2, 3, 4]);

    expect(find.text('Chain broken'), findsOneWidget);
    expect(find.text('Attempt 2 of 6'), findsNothing);
    expect(find.text('You already tried this order'), findsOneWidget);
    expect(_checkButton(tester).onPressed, isNull);

    await _clear(tester);
    expect(find.text('Attempt 2 of 6'), findsOneWidget);
  });

  testWidgets('input is locked while the chain is revealed', (tester) async {
    await _startGame(tester);
    for (final int tile in [0, 1, 2, 3, 4]) {
      await tester.tap(find.byKey(ValueKey('tile-$tile')));
    }
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('check')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Attempt 1 of 6'), findsOneWidget);
    expect(find.text('You already tried this order'), findsNothing);
    // 17 → ⇄ 71 → +4 75 → ÷2 si spezza: per ora si vede solo il primo valore.
    expect(find.text('71'), findsOneWidget);
    expect(find.text('75'), findsNothing);
    expect(
      tester
          .widget<OutlinedButton>(find.byKey(const ValueKey('clear')))
          .onPressed,
      isNull,
    );

    await tester.pumpAndSettle();
    expect(find.text('75'), findsOneWidget);
    expect(find.text('Chain broken'), findsOneWidget);
  });

  testWidgets('six wrong attempts show the solution', (tester) async {
    await _startGame(tester);
    final Puzzle puzzle = generatePuzzleForDate(_launchDay);
    final List<List<int>> wrong = [
      for (final List<int> o in permutations(5))
        if (puzzle.check(o) != AttemptOutcome.solved) o,
    ];

    for (int i = 0; i < maxAttempts; i++) {
      if (i > 0) await _clear(tester);
      await _playOrder(tester, wrong[i]);
    }

    expect(find.text('Out of attempts'), findsOneWidget);
    expect(find.text('Solution'), findsOneWidget);
    expect(find.text('114'), findsWidgets);
    expect(find.byKey(const ValueKey('check')), findsNothing);
  });

  testWidgets('follows the device language', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('it')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await _startGame(tester);
    expect(find.text('Partenza'), findsOneWidget);
    expect(find.text('Obiettivo'), findsOneWidget);
    expect(find.text('Verifica'), findsOneWidget);
    expect(find.text('Tentativo 1 di 6'), findsOneWidget);
  });

  testWidgets('large text does not overflow on a small phone', (tester) async {
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 2;
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _startGame(tester);
    await _playOrder(tester, [0, 1, 2, 3, 4]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the guide opens on first launch only', (tester) async {
    final Storage storage = await createStorage();
    await _startGame(tester, storage: storage);
    expect(find.text('How to play'), findsWidgets);
    expect(find.text('Example'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('help-play')),
      200,
    );
    await tester.tap(find.byKey(const ValueKey('help-play')));
    await tester.pumpAndSettle();
    expect(find.text('Example'), findsNothing);
    expect(storage.loadSettings().helpSeen, isTrue);

    await tester.pumpWidget(const SizedBox());
    await _startGame(tester, storage: storage);
    expect(find.text('Example'), findsNothing);
  });

  testWidgets('the guide can be reopened from the app bar', (tester) async {
    await _startGame(tester);
    await tester.tap(find.byKey(const ValueKey('open-help')));
    await tester.pumpAndSettle();
    expect(find.text('Example'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Example'), findsNothing);
  });

  testWidgets('statistics open from the app bar', (tester) async {
    await _startGame(tester);
    await tester.tap(find.byKey(const ValueKey('open-stats')));
    await tester.pumpAndSettle();
    expect(find.text('Statistics'), findsWidgets);
    expect(find.text('Wins by attempt'), findsOneWidget);
  });

  testWidgets('the game over panel has stats and share', (tester) async {
    await _startGame(tester);
    await _playOrder(tester, [0, 3, 2, 1, 4]);
    await tester.scrollUntilVisible(find.byKey(const ValueKey('share')), 200);
    expect(find.text('Played'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
  });

  testWidgets('a game in progress survives a restart', (tester) async {
    final Storage storage = await createStorage(helpSeenValues);
    await _startGame(tester, storage: storage);
    await _playOrder(tester, [0, 1, 2, 3, 4]);
    expect(find.text('Chain broken'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await _startGame(tester, storage: storage);
    expect(find.text('Chain broken'), findsOneWidget);
    expect(find.text('You already tried this order'), findsOneWidget);
  });

  testWidgets('a new day loads when the app comes back', (tester) async {
    final FakeClock clock = FakeClock(_launchDay);
    await _startGame(tester, clock: clock);
    await _playOrder(tester, [0, 3, 2, 1, 4]);
    expect(find.text('Solved!'), findsOneWidget);

    clock.current = DateTime(2026, 10, 11, 8);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('Fivelink #2'), findsOneWidget);
    expect(find.text('Solved!'), findsNothing);
    expect(find.text('Attempt 1 of 6'), findsOneWidget);
  });
}
