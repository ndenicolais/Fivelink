// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Fivelink';

  @override
  String puzzleTitle(int number) {
    return 'Fivelink #$number';
  }

  @override
  String get startLabel => 'Partenza';

  @override
  String get targetLabel => 'Obiettivo';

  @override
  String attemptCounter(int current, int max) {
    return 'Tentativo $current di $max';
  }

  @override
  String get historyHint =>
      'Metti in ordine le 5 tessere per trasformare il numero di partenza nell\'obiettivo. Ogni tessera si usa una volta.';

  @override
  String get clearButton => 'Svuota';

  @override
  String get checkButton => 'Verifica';

  @override
  String get alreadyTried => 'Hai già provato questo ordine';

  @override
  String get outcomeBroken => 'Catena spezzata';

  @override
  String outcomeWrongResult(int value) {
    return 'Arrivato a $value';
  }

  @override
  String get outcomeSolved => 'Risolto';

  @override
  String attemptSemantics(int number, String tiles, String outcome) {
    return 'Tentativo $number: $tiles. $outcome';
  }

  @override
  String get wonTitle => 'Risolto!';

  @override
  String wonSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count tentativi',
      one: 'Al primo tentativo',
    );
    return '$_temp0';
  }

  @override
  String get lostTitle => 'Tentativi esauriti';

  @override
  String get solutionLabel => 'Soluzione';

  @override
  String nextPuzzleIn(String time) {
    return 'Prossimo rompicapo tra $time';
  }

  @override
  String opAdd(int n) {
    return 'più $n';
  }

  @override
  String opSubtract(int n) {
    return 'meno $n';
  }

  @override
  String opMultiply(int n) {
    return 'per $n';
  }

  @override
  String opDivide(int n) {
    return 'diviso $n';
  }

  @override
  String get opReverse => 'inverti le cifre';

  @override
  String get tileHint => 'inserisci nella prima casella libera';

  @override
  String slotEmpty(int index) {
    return 'Casella $index, vuota';
  }

  @override
  String slotFilled(int index, String tile) {
    return 'Casella $index: $tile';
  }

  @override
  String get slotHint => 'togli la tessera';
}
