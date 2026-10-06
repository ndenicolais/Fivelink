# Fivelink — Documentation

Technical documentation of Fivelink: game rules, puzzle generation, data model, screens and build. For an overview see the [README](README.md); for data handling see the [privacy policy](PRIVACY.md).

---

## 1. The game

Every day the player gets a **start number**, a **target** and **5 operation tiles**. Applying the tiles to the start number one after another, each exactly once, must give the target.

Example (unique solution): start `17`, target `163`, tiles `×3 +7 −8 ×2 +9`. Solution `+7 → ×2 → +9 → ×3 → −8`, that is `17 → 24 → 48 → 57 → 171 → 163`.

### Tiles

| Tile | Effect | Breaks the chain when |
|---|---|---|
| `+n`, n from 1 to 9 | addition | the result is out of range |
| `−n`, n from 1 to 9 | subtraction | the result is out of range |
| `×2`, `×3` | multiplication | the result is out of range |
| `÷2`, `÷3` | division | the value is not exactly divisible |
| `⇄` | reverses the digits (`36 → 63`) | the value is below 10, ends in 0 or is a palindrome |

Every intermediate and final value must be an integer from 1 to 999. The `⇄` tile is drawn with the Material icon `swap_horiz`, because the `⇄` glyph is missing from many fonts.

### Rules

- The player fills the 5 slots by tapping tiles (a tile goes to the first free slot, tapping a filled slot puts the tile back) and taps **Check**. There is no preview while arranging.
- On check, the chain is revealed one value at a time (`chainStepDuration`, 380 ms per step) up to the result or the break point. Input is locked meanwhile.
- An attempt is correct when the chain is complete and the result equals the target: the result is validated, not compared with the stored solution.
- At most **6 attempts**. The same order cannot be checked twice. After a wrong check the slots are emptied for the next attempt (a game in progress also restarts with empty slots).
- At the end: outcome, the solution if lost, statistics, countdown to the next puzzle and **Share**.

Share text, without the solution: `Fivelink #12 · 3/6` (or `X/6` when lost) followed by one square per attempt: 🟥 broken chain, 🟧 complete chain with the wrong result, 🟩 solved.

---

## 2. Puzzle generation

Generation is local and deterministic: same date, same puzzle on every device (`lib/core/puzzle_generator.dart`).

- **Random generator**: xorshift32 in pure Dart (`lib/core/prng.dart`), every operation masked to 32 bits. `dart:math Random` is not used because its sequence for a seed is not guaranteed stable across SDK versions.
- **Seed**: `year * 10000 + month * 100 + day`, combined with `generatorVersion` and mixed with a multiplication and several xorshift rounds. Never 0.
- **Algorithm**, repeated with a candidate counter that enters the seed:
  1. Draw the start number from 2 to 20.
  2. Draw 5 distinct tiles from the 23-tile pool, with 2 to 4 tiles among `×`, `÷` and `⇄`.
  3. Apply them in the drawn order; discard if the chain breaks.
  4. The target is the result; discard if it is not between 10 and 300 or equals the start.
  5. Try all 120 permutations; accept only if exactly one reaches the target.
  6. Shuffle the presentation order with the same generator, reshuffling if the tiles would appear already in the order of a solution.
- After 20,000 candidates (never reached in 10 simulated years) up to 2 solutions are accepted.

10 years of puzzles take about 1 second to generate.

> [!IMPORTANT]
> **The generator is frozen.** Any change to the pool, its order, the seed, the draws or the constraints changes the puzzles of every day. `generatorVersion` is 1. The test `snapshot of fixed dates is unchanged` fails if the output changes: update it only for an intended change, and increment `generatorVersion`.

---

## 3. Days and puzzle number

`lib/core/daily.dart`.

- **Launch date** (puzzle #1): 10 October 2026. Earlier dates give numbers ≤ 0 without errors.
- The puzzle number is computed between dates built with `DateTime.utc(year, month, day)`: a difference between local dates can lose a day at a daylight saving change.
- The current time is never read with `DateTime.now()` inside the logic: an injectable `Clock` is passed (`SystemClock` in the app, fake clocks in tests).
- **Day change**: the date is checked when the app returns to the foreground (`AppLifecycleState.resumed`) and by a timer just after midnight while the app is open.

---

## 4. Data and persistence

Everything is stored in SharedPreferences as JSON with versioned keys (`lib/data/`). Corrupt or missing values never crash the app: they fall back to the defaults.

| Key | Content |
|---|---|
| `stats_v1` | Games played and won, current and best streak, wins by attempt (1 to 6), last completed date, last won date |
| `day_v1_<yyyy-mm-dd>` | Attempts of that day (each as a list of tile indices) and status (playing, won, lost). Keys older than 7 days are deleted |
| `settings_v1` | Theme (system, light, dark), language (system, Italian, English), vibration, guide already seen |

### Statistics and streaks

- A win increases the streak by 1 if the last win was yesterday, otherwise sets it to 1. A loss resets it.
- The streak shown is reset if a day was skipped (`Stats.streakOn`).
- **Statistics only move forward in time** (`Stats.countsFor`): a game counts only if its day comes after the last counted one. Moving the device clock back, or changing time zone, never counts a game twice or breaks the streak. Playing ahead by moving the clock forward counts those days, and the real day no longer counts.
- If the app is closed between saving the day and saving the statistics, the result is recorded at the next start.

---

## 5. Screens

| Screen | File | Content |
|---|---|---|
| Game | `lib/game/game_screen.dart` | Puzzle number, start and target, attempt history, slots, tiles, Clear and Check, end-of-game panel |
| How to play | `lib/help/help_screen.dart` | Shown on first launch without a back arrow, then from the `?` button. Animated example with **Watch again**, tile rules, break rules, outcome icons. **Play** is pinned at the bottom |
| Info and settings | `lib/info/info_screen.dart` | From the gear button: statistics, theme, language, vibration, description, version, developer, privacy policy |
| Statistics | `lib/stats/stats_screen.dart` | Full page; the same view appears in the end-of-game panel |
| Privacy policy | `lib/info/privacy_screen.dart` | Native, offline, localized; same text as `PRIVACY.md` |

Links and addresses (email, website, online privacy policy) are copied to the clipboard rather than opened, to avoid extra dependencies.

### Accessibility

- `Semantics` labels on tiles and slots, with spoken names for the operations (`plus 7`, `reverse digits`).
- Touch targets of 56 dp.
- Every outcome has an icon as well as a color.
- Tiles and rows scale down instead of overflowing with large text.
- The chain animation is skipped when the system disables animations.

---

## 6. Theme and localization

- **Palette** (`lib/app_theme.dart`), derived from the icon: cobalt `#2747D4` / `#8FA3FF` as primary, yellow `#FFCB3D` only as the fill of the target box, cool neutral backgrounds `#F6F7FB` / `#0F1430`. Both `ColorScheme`s are defined by hand (`ColorScheme.fromSeed` would dull the cobalt). Accent and outcome colors live in the `GameColors` theme extension. Tiles stay neutral; cobalt marks only the placed ones.
- **Localization**: ARB files in `lib/l10n/` (template `app_en.arb`), generated code in `lib/l10n/generated/` (committed). No strings are written directly in widgets. With the **System** language the app follows the device and falls back to English for unsupported languages.

---

## 7. Android

- `applicationId` and namespace `com.ndn21.fivelink` (final).
- `compileSdk` and `targetSdk` 36, as required by Google Play for new apps and updates from 31 August 2026. `minSdk` 24 (Android 7.0).
- Portrait only (manifest and `SystemChrome`).
- **No `INTERNET` permission** in the main manifest and no network calls (debug and profile builds have it by default, for the Flutter tools).
- **App icon**: adaptive icon with background `#1A2147`, the foreground from `assets/images/fivelink-foreground-1024.png` with a 7% inset, and a monochrome version for themed icons on Android 13+. **Launch screen**: background color only (`#F6F7FB` / `#0F1430`); from Android 12 the system shows the app icon. `main()` defers the first Flutter frame until at least 1.2 s after start, so the launch screen stays visible instead of flashing by. Both are generated into `android/app/src/main/res/` with `flutter_launcher_icons` and `flutter_native_splash`. The configuration files were removed after generation. To regenerate, add the two packages as dev dependencies again and recreate the configuration. Keep `android_screen_orientation: portrait` in the splash configuration, or the tool removes the portrait lock from the manifest.

---

## 8. Build and release

### Signing

Release builds read `android/key.properties` (excluded from git):

```properties
storePassword=<keystore password>
keyPassword=<key password>
keyAlias=upload
storeFile=<absolute path to upload-keystore.jks, with forward slashes>
```

Without the file, release builds fall back to the debug key with a Gradle warning: fine for testing, rejected by Google Play.

```bash
flutter build appbundle --release
# build/app/outputs/bundle/release/app-release.aab
```

### Versioning

Before every upload, increment `version:` in `pubspec.yaml` (the number after `+` must always grow) and update `AppInfo.version` and `AppInfo.buildNumber` in `lib/app_info.dart`. The test `AppInfo version matches pubspec.yaml` fails if they differ.

### Previews and store graphics

The images below are generated by a local script, kept outside the repository. It renders the real app with fixed data (15 January 2028, puzzle #463, far from launch so no current solution is spoiled) and writes:

| Output | Content |
|---|---|
| `images/fivelink_preview.png` | README banner 2400×1350: 5 tilted phones (help, solved, game, settings, statistics) with a drawn status bar |
| `images/screenshots/<name>.png` | README gallery, 540 px wide, no system bars: `game`, `win`, `help`, `stats`, `settings` |
| `store/screenshots/<lang>/<n>.png` | Play Store screenshots 1080×1920 in Italian and English |
| `store/feature_graphic_<lang>.png` | Play Store feature graphic 1024×500 |

Images are saved as 24-bit PNG without alpha, as Google Play requires. No device screenshots are needed, so there are no raw files or system bar heights to measure. It is not part of the test suite.

---

## 9. Tests

```bash
flutter analyze --fatal-infos --fatal-warnings
flutter test
```

- `test/core/`: every tile and break case, range limits, xorshift32 reference values, 730 consecutive days of valid puzzles with exactly one solution, snapshot of fixed dates, puzzle number across daylight saving changes, year end and leap days.
- `test/data/`: JSON round trips and corrupt data, storage and pruning, streak rules, settings.
- `test/game/`: game controller (placing tiles, duplicates, win, loss, persistence, day change, clock moved back and forward), share text.
- `test/widget_test.dart`: full game flow (arrange, check, win and lose), guide on first launch and its animation, info and settings, language and theme switching, privacy policy, resume after restart, day change on resume, large text, English fallback.
