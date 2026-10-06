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

  @override
  String get helpTooltip => 'Come si gioca';

  @override
  String get statsTooltip => 'Statistiche';

  @override
  String get helpTitle => 'Come si gioca';

  @override
  String get helpGoal =>
      'Ogni giorno ricevi un numero di partenza, un obiettivo e 5 tessere operazione. Mettile in ordine: applicate una dopo l\'altra al numero di partenza, devono arrivare all\'obiettivo. Ogni tessera si usa una sola volta.';

  @override
  String get helpExampleTitle => 'Esempio';

  @override
  String helpExampleIntro(int start, int target) {
    return 'Partenza $start, obiettivo $target. L\'ordine giusto è:';
  }

  @override
  String get helpTilesTitle => 'Le tessere';

  @override
  String get helpTileAddSubtract => 'Somma o sottrae un numero da 1 a 9.';

  @override
  String get helpTileMultiply => 'Moltiplica per 2 o per 3.';

  @override
  String get helpTileDivide =>
      'Divide per 2 o per 3. La divisione deve essere esatta.';

  @override
  String get helpTileReverse => 'Inverte le cifre: 36 diventa 63.';

  @override
  String get helpBreakTitle => 'Quando la catena si spezza';

  @override
  String get helpBreakRange =>
      'Ogni numero lungo la catena deve restare tra 1 e 999.';

  @override
  String get helpBreakDivide =>
      'Una divisione non esatta spezza la catena: 7 ÷ 2 non si può fare.';

  @override
  String get helpBreakReverse =>
      'L\'inversione non funziona sui numeri di una cifra, su quelli che finiscono per 0 e sui palindromi come 121.';

  @override
  String get helpAttemptsTitle => 'Tentativi';

  @override
  String get helpAttempts =>
      'Tocca una tessera per metterla nella prima casella libera, tocca una casella per toglierla. Hai 6 tentativi e non puoi verificare due volte lo stesso ordine. Dopo ogni verifica vedi tutti i valori intermedi, fino al risultato o al punto in cui la catena si è spezzata.';

  @override
  String get helpOutcomeBroken => 'un\'operazione non era possibile';

  @override
  String get helpOutcomeWrong =>
      'la catena è completa ma il risultato è sbagliato';

  @override
  String get helpOutcomeSolved => 'hai raggiunto l\'obiettivo';

  @override
  String get helpDaily =>
      'Un rompicapo nuovo ogni giorno a mezzanotte, uguale per tutti.';

  @override
  String get helpPlayButton => 'Gioca';

  @override
  String get statsTitle => 'Statistiche';

  @override
  String get statsPlayed => 'Giocate';

  @override
  String get statsWinPercent => '% vittorie';

  @override
  String get statsCurrentStreak => 'Serie attuale';

  @override
  String get statsMaxStreak => 'Serie migliore';

  @override
  String get statsDistribution => 'Vittorie per tentativo';

  @override
  String statsBarSemantics(int attempt, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vittorie',
      one: '1 vittoria',
    );
    return 'Tentativo $attempt: $_temp0';
  }

  @override
  String get shareButton => 'Condividi';
}
