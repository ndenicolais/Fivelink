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

  @override
  String get infoTooltip => 'Info e impostazioni';

  @override
  String get infoTitle => 'Info e impostazioni';

  @override
  String get infoStatsSubtitle => 'Partite, vittorie e serie';

  @override
  String get settingsSection => 'Impostazioni';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get settingsHaptics => 'Vibrazione';

  @override
  String get settingsHapticsSubtitle =>
      'Quando inserisci le tessere e vedi il risultato';

  @override
  String get infoAboutSection => 'Informazioni';

  @override
  String get appDescription =>
      'Un rompicapo numerico al giorno: metti in ordine 5 tessere operazione per trasformare il numero di partenza nell\'obiettivo. Funziona interamente offline.';

  @override
  String get infoVersion => 'Versione';

  @override
  String get infoDeveloper => 'Sviluppatore';

  @override
  String get infoEmail => 'Email';

  @override
  String get infoWebsite => 'Sito web';

  @override
  String get copyTooltip => 'Copia';

  @override
  String get copiedMessage => 'Copiato negli appunti';

  @override
  String get privacyTitle => 'Informativa sulla privacy';

  @override
  String privacyLastUpdated(String date) {
    return 'Ultimo aggiornamento: $date';
  }

  @override
  String get privacyOnline => 'Versione online';

  @override
  String get privacyIntro =>
      'Fivelink è un rompicapo che funziona interamente offline. Non richiede un account, non mostra pubblicità, non usa strumenti di analisi e non raccoglie né vende dati personali.';

  @override
  String get privacyControllerTitle => '1. Titolare del trattamento';

  @override
  String privacyControllerText(String name, String email) {
    return '$name\nContatto: $email';
  }

  @override
  String get privacyDataTitle => '2. Dati che raccogliamo';

  @override
  String get privacyDataText =>
      'Fivelink non raccoglie dati personali. Sul dispositivo salva soltanto:\n• i progressi della partita del giorno, per riprenderla se chiudi l\'app;\n• le statistiche di gioco (partite giocate e vinte, serie, tentativi per vittoria);\n• le impostazioni (tema, vibrazione, guida già vista).';

  @override
  String get privacyUseTitle => '3. Come usiamo i dati';

  @override
  String get privacyUseText =>
      'Questi dati servono solo a far funzionare il gioco. Non vengono mai usati per profilazione, pubblicità o altri scopi.';

  @override
  String get privacyStorageTitle => '4. Dove sono conservati';

  @override
  String get privacyStorageText =>
      'Tutto resta nella memoria del tuo dispositivo. L\'app non usa server né servizi esterni e non invia nulla in rete: non ha nemmeno il permesso di accedere a Internet.';

  @override
  String get privacyDeviceTitle => '5. Elaborazione sul dispositivo';

  @override
  String get privacyDeviceText =>
      'Il rompicapo di ogni giorno viene generato sul dispositivo a partire dalla data. Quando tocchi Condividi, il testo del risultato (numero del rompicapo e un simbolo per tentativo, senza la soluzione) viene passato all\'app che scegli tu, secondo le norme di quell\'app.';

  @override
  String get privacyPermissionsTitle => '6. Permessi';

  @override
  String get privacyPermissionsText =>
      'Fivelink non richiede permessi. Non accede a fotocamera, foto, posizione, contatti, microfono o Internet.';

  @override
  String get privacyRetentionTitle => '7. Conservazione e cancellazione';

  @override
  String get privacyRetentionText =>
      'Le partite dei singoli giorni vengono eliminate automaticamente dopo 7 giorni. Statistiche e impostazioni restano finché non le cancelli. Puoi eliminare tutti i dati dalle impostazioni di Android (App > Fivelink > Spazio di archiviazione > Cancella dati) oppure disinstallando l\'app.';

  @override
  String get privacyRightsTitle => '8. I tuoi diritti';

  @override
  String privacyRightsText(String email) {
    return 'Poiché nessun dato lascia il tuo dispositivo, ne hai sempre il pieno controllo. Per qualsiasi domanda puoi scrivere a $email. Hai inoltre il diritto di presentare un reclamo all\'autorità per la protezione dei dati del tuo paese.';
  }

  @override
  String get privacyChildrenTitle => '9. Minori';

  @override
  String get privacyChildrenText =>
      'Fivelink è adatta a tutte le età e non raccoglie dati personali di nessuno, minori compresi.';

  @override
  String get privacyChangesTitle => '10. Modifiche';

  @override
  String get privacyChangesText =>
      'Se questa informativa cambia, la nuova versione sarà disponibile nell\'app e online, con la data di aggiornamento.';
}
