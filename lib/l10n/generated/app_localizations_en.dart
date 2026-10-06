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
}
