// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Fivelink';

  @override
  String puzzleTitle(int number) {
    return 'Fivelink #$number';
  }

  @override
  String get startLabel => 'Start';

  @override
  String get targetLabel => 'Target';

  @override
  String attemptCounter(int current, int max) {
    return 'Attempt $current of $max';
  }

  @override
  String get historyHint =>
      'Put the 5 tiles in order to turn the start number into the target. Each tile is used once.';

  @override
  String get clearButton => 'Clear';

  @override
  String get checkButton => 'Check';

  @override
  String get alreadyTried => 'You already tried this order';

  @override
  String get outcomeBroken => 'Chain broken';

  @override
  String outcomeWrongResult(int value) {
    return 'Reached $value';
  }

  @override
  String get outcomeSolved => 'Solved';

  @override
  String attemptSemantics(int number, String tiles, String outcome) {
    return 'Attempt $number: $tiles. $outcome';
  }

  @override
  String get wonTitle => 'Solved!';

  @override
  String wonSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count attempts',
      one: 'On the first attempt',
    );
    return '$_temp0';
  }

  @override
  String get lostTitle => 'Out of attempts';

  @override
  String get solutionLabel => 'Solution';

  @override
  String nextPuzzleIn(String time) {
    return 'Next puzzle in $time';
  }

  @override
  String opAdd(int n) {
    return 'plus $n';
  }

  @override
  String opSubtract(int n) {
    return 'minus $n';
  }

  @override
  String opMultiply(int n) {
    return 'times $n';
  }

  @override
  String opDivide(int n) {
    return 'divided by $n';
  }

  @override
  String get opReverse => 'reverse digits';

  @override
  String get tileHint => 'place in the first free slot';

  @override
  String slotEmpty(int index) {
    return 'Slot $index, empty';
  }

  @override
  String slotFilled(int index, String tile) {
    return 'Slot $index: $tile';
  }

  @override
  String get slotHint => 'remove the tile';

  @override
  String get helpTooltip => 'How to play';

  @override
  String get statsTooltip => 'Statistics';

  @override
  String get helpTitle => 'How to play';

  @override
  String get helpGoal =>
      'Every day you get a start number, a target and 5 operation tiles. Put the tiles in order: applied one after another to the start number, they must reach the target. Each tile is used exactly once.';

  @override
  String get helpExampleTitle => 'Example';

  @override
  String helpExampleIntro(int start, int target) {
    return 'Start $start, target $target. The right order is:';
  }

  @override
  String get helpTilesTitle => 'The tiles';

  @override
  String get helpTileAddSubtract => 'Add or subtract a number from 1 to 9.';

  @override
  String get helpTileMultiply => 'Multiply by 2 or 3.';

  @override
  String get helpTileDivide => 'Divide by 2 or 3. The division must be exact.';

  @override
  String get helpTileReverse => 'Reverses the digits: 36 becomes 63.';

  @override
  String get helpBreakTitle => 'When the chain breaks';

  @override
  String get helpBreakRange =>
      'Every number along the chain must stay between 1 and 999.';

  @override
  String get helpBreakDivide =>
      'A division that is not exact breaks the chain: 7 ÷ 2 is not allowed.';

  @override
  String get helpBreakReverse =>
      'Reversing does not work on single digits, numbers ending in 0 or palindromes like 121.';

  @override
  String get helpAttemptsTitle => 'Attempts';

  @override
  String get helpAttempts =>
      'Tap a tile to place it in the first free slot, tap a slot to take it back. You have 6 attempts and cannot check the same order twice. After each check you see every intermediate value, up to the result or the point where the chain broke.';

  @override
  String get helpOutcomeBroken => 'an operation was not possible';

  @override
  String get helpOutcomeWrong =>
      'the chain is complete but the result is wrong';

  @override
  String get helpOutcomeSolved => 'you reached the target';

  @override
  String get helpDaily =>
      'A new puzzle every day at midnight, the same for everyone.';

  @override
  String get helpPlayButton => 'Play';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsPlayed => 'Played';

  @override
  String get statsWinPercent => 'Win %';

  @override
  String get statsCurrentStreak => 'Current streak';

  @override
  String get statsMaxStreak => 'Best streak';

  @override
  String get statsDistribution => 'Wins by attempt';

  @override
  String statsBarSemantics(int attempt, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wins',
      one: '1 win',
    );
    return 'Attempt $attempt: $_temp0';
  }

  @override
  String get shareButton => 'Share';
}
