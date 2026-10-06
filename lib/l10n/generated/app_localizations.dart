import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Fivelink'**
  String get appTitle;

  /// Game screen title with the daily puzzle number
  ///
  /// In en, this message translates to:
  /// **'Fivelink #{number}'**
  String puzzleTitle(int number);

  /// Label above the starting number
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startLabel;

  /// Label above the target number
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get targetLabel;

  /// Which attempt the player is on
  ///
  /// In en, this message translates to:
  /// **'Attempt {current} of {max}'**
  String attemptCounter(int current, int max);

  /// Shown before the first attempt
  ///
  /// In en, this message translates to:
  /// **'Put the 5 tiles in order to turn the start number into the target. Each tile is used once.'**
  String get historyHint;

  /// Empties all slots
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearButton;

  /// Submits the current order
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get checkButton;

  /// Shown when the slots repeat a previous attempt
  ///
  /// In en, this message translates to:
  /// **'You already tried this order'**
  String get alreadyTried;

  /// Attempt result: an invalid step stopped the chain
  ///
  /// In en, this message translates to:
  /// **'Chain broken'**
  String get outcomeBroken;

  /// Attempt result: the chain completed with the wrong number
  ///
  /// In en, this message translates to:
  /// **'Reached {value}'**
  String outcomeWrongResult(int value);

  /// Attempt result: the chain reached the target
  ///
  /// In en, this message translates to:
  /// **'Solved'**
  String get outcomeSolved;

  /// Screen reader summary of a past attempt
  ///
  /// In en, this message translates to:
  /// **'Attempt {number}: {tiles}. {outcome}'**
  String attemptSemantics(int number, String tiles, String outcome);

  /// Game over title after a win
  ///
  /// In en, this message translates to:
  /// **'Solved!'**
  String get wonTitle;

  /// How many attempts the win took
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{On the first attempt} other{In {count} attempts}}'**
  String wonSubtitle(int count);

  /// Game over title after a loss
  ///
  /// In en, this message translates to:
  /// **'Out of attempts'**
  String get lostTitle;

  /// Heading above the solution shown after a loss
  ///
  /// In en, this message translates to:
  /// **'Solution'**
  String get solutionLabel;

  /// Countdown to the next daily puzzle
  ///
  /// In en, this message translates to:
  /// **'Next puzzle in {time}'**
  String nextPuzzleIn(String time);

  /// Screen reader name of an addition tile
  ///
  /// In en, this message translates to:
  /// **'plus {n}'**
  String opAdd(int n);

  /// Screen reader name of a subtraction tile
  ///
  /// In en, this message translates to:
  /// **'minus {n}'**
  String opSubtract(int n);

  /// Screen reader name of a multiplication tile
  ///
  /// In en, this message translates to:
  /// **'times {n}'**
  String opMultiply(int n);

  /// Screen reader name of a division tile
  ///
  /// In en, this message translates to:
  /// **'divided by {n}'**
  String opDivide(int n);

  /// Screen reader name of the digit reversal tile
  ///
  /// In en, this message translates to:
  /// **'reverse digits'**
  String get opReverse;

  /// Screen reader hint for an available tile
  ///
  /// In en, this message translates to:
  /// **'place in the first free slot'**
  String get tileHint;

  /// Screen reader label of an empty slot
  ///
  /// In en, this message translates to:
  /// **'Slot {index}, empty'**
  String slotEmpty(int index);

  /// Screen reader label of a filled slot
  ///
  /// In en, this message translates to:
  /// **'Slot {index}: {tile}'**
  String slotFilled(int index, String tile);

  /// Screen reader hint for a filled slot
  ///
  /// In en, this message translates to:
  /// **'remove the tile'**
  String get slotHint;

  /// App bar button that opens the guide
  ///
  /// In en, this message translates to:
  /// **'How to play'**
  String get helpTooltip;

  /// App bar button that opens the statistics
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTooltip;

  /// Title of the guide screen
  ///
  /// In en, this message translates to:
  /// **'How to play'**
  String get helpTitle;

  /// Guide: the goal of the game
  ///
  /// In en, this message translates to:
  /// **'Every day you get a start number, a target and 5 operation tiles. Put the tiles in order: applied one after another to the start number, they must reach the target. Each tile is used exactly once.'**
  String get helpGoal;

  /// Guide section heading
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get helpExampleTitle;

  /// Guide: introduces the worked example
  ///
  /// In en, this message translates to:
  /// **'Start {start}, target {target}. The right order is:'**
  String helpExampleIntro(int start, int target);

  /// Guide section heading
  ///
  /// In en, this message translates to:
  /// **'The tiles'**
  String get helpTilesTitle;

  /// Guide: addition and subtraction tiles
  ///
  /// In en, this message translates to:
  /// **'Add or subtract a number from 1 to 9.'**
  String get helpTileAddSubtract;

  /// Guide: multiplication tiles
  ///
  /// In en, this message translates to:
  /// **'Multiply by 2 or 3.'**
  String get helpTileMultiply;

  /// Guide: division tiles
  ///
  /// In en, this message translates to:
  /// **'Divide by 2 or 3. The division must be exact.'**
  String get helpTileDivide;

  /// Guide: digit reversal tile
  ///
  /// In en, this message translates to:
  /// **'Reverses the digits: 36 becomes 63.'**
  String get helpTileReverse;

  /// Guide section heading
  ///
  /// In en, this message translates to:
  /// **'When the chain breaks'**
  String get helpBreakTitle;

  /// Guide: range rule
  ///
  /// In en, this message translates to:
  /// **'Every number along the chain must stay between 1 and 999.'**
  String get helpBreakRange;

  /// Guide: division rule
  ///
  /// In en, this message translates to:
  /// **'A division that is not exact breaks the chain: 7 ÷ 2 is not allowed.'**
  String get helpBreakDivide;

  /// Guide: reversal rule
  ///
  /// In en, this message translates to:
  /// **'Reversing does not work on single digits, numbers ending in 0 or palindromes like 121.'**
  String get helpBreakReverse;

  /// Guide section heading
  ///
  /// In en, this message translates to:
  /// **'Attempts'**
  String get helpAttemptsTitle;

  /// Guide: how attempts work
  ///
  /// In en, this message translates to:
  /// **'Tap a tile to place it in the first free slot, tap a slot to take it back. You have 6 attempts and cannot check the same order twice. After each check you see every intermediate value, up to the result or the point where the chain broke.'**
  String get helpAttempts;

  /// Guide: meaning of the broken chain result
  ///
  /// In en, this message translates to:
  /// **'an operation was not possible'**
  String get helpOutcomeBroken;

  /// Guide: meaning of the wrong result
  ///
  /// In en, this message translates to:
  /// **'the chain is complete but the result is wrong'**
  String get helpOutcomeWrong;

  /// Guide: meaning of the solved result
  ///
  /// In en, this message translates to:
  /// **'you reached the target'**
  String get helpOutcomeSolved;

  /// Guide: daily puzzle note
  ///
  /// In en, this message translates to:
  /// **'A new puzzle every day at midnight, the same for everyone.'**
  String get helpDaily;

  /// Closes the guide
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get helpPlayButton;

  /// Title of the statistics panel
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// Number of games played
  ///
  /// In en, this message translates to:
  /// **'Played'**
  String get statsPlayed;

  /// Percentage of games won
  ///
  /// In en, this message translates to:
  /// **'Win %'**
  String get statsWinPercent;

  /// Consecutive daily wins up to today
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get statsCurrentStreak;

  /// Longest run of consecutive daily wins
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get statsMaxStreak;

  /// Heading of the win distribution chart
  ///
  /// In en, this message translates to:
  /// **'Wins by attempt'**
  String get statsDistribution;

  /// Screen reader label of a distribution bar
  ///
  /// In en, this message translates to:
  /// **'Attempt {attempt}: {count, plural, =1{1 win} other{{count} wins}}'**
  String statsBarSemantics(int attempt, int count);

  /// Shares the result as text
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareButton;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
