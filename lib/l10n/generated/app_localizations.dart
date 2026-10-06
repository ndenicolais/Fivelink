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
