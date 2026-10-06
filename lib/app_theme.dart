import 'package:flutter/material.dart';

/// Palette dell'app, ricavata dai colori dell'icona: cobalto come colore
/// principale, giallo come accento, fondi neutri leggermente freddi.
///
/// Regole d'uso:
/// - il giallo solo come riempimento del riquadro obiettivo, con testo scuro;
/// - tessere neutre, cobalto solo per quelle piazzate negli slot;
/// - ogni stato ha anche un'icona, mai solo il colore.
abstract final class AppPalette {
  static const Color lightBackground = Color(0xFFF6F7FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF141A33);
  static const Color lightTextSecondary = Color(0xFF5B6380);
  static const Color lightBorder = Color(0xFFC3C9DD);
  static const Color lightPrimary = Color(0xFF2747D4);
  static const Color lightSolved = Color(0xFF127A4F);
  static const Color lightWrong = Color(0xFFB8520A);
  static const Color lightBroken = Color(0xFFCF2F45);

  static const Color darkBackground = Color(0xFF0F1430);
  static const Color darkSurface = Color(0xFF1A2147);
  static const Color darkText = Color(0xFFEEF0FA);
  static const Color darkTextSecondary = Color(0xFFA3AACB);
  static const Color darkBorder = Color(0xFF3A4478);
  static const Color darkPrimary = Color(0xFF8FA3FF);
  static const Color darkSolved = Color(0xFF3DDC97);
  static const Color darkWrong = Color(0xFFFF9A4D);
  static const Color darkBroken = Color(0xFFFF6B7A);

  static const Color accent = Color(0xFFFFCB3D);
}

/// Colori che il ColorScheme non prevede: accento e stati dei tentativi.
@immutable
class GameColors extends ThemeExtension<GameColors> {
  const GameColors({
    required this.accent,
    required this.onAccent,
    required this.solved,
    required this.wrongResult,
    required this.broken,
  });

  /// Riempimento del riquadro obiettivo.
  final Color accent;
  final Color onAccent;
  final Color solved;
  final Color wrongResult;
  final Color broken;

  static const GameColors light = GameColors(
    accent: AppPalette.accent,
    onAccent: AppPalette.lightText,
    solved: AppPalette.lightSolved,
    wrongResult: AppPalette.lightWrong,
    broken: AppPalette.lightBroken,
  );

  static const GameColors dark = GameColors(
    accent: AppPalette.accent,
    onAccent: AppPalette.darkBackground,
    solved: AppPalette.darkSolved,
    wrongResult: AppPalette.darkWrong,
    broken: AppPalette.darkBroken,
  );

  static GameColors of(BuildContext context) =>
      Theme.of(context).extension<GameColors>() ?? light;

  @override
  GameColors copyWith({
    Color? accent,
    Color? onAccent,
    Color? solved,
    Color? wrongResult,
    Color? broken,
  }) {
    return GameColors(
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      solved: solved ?? this.solved,
      wrongResult: wrongResult ?? this.wrongResult,
      broken: broken ?? this.broken,
    );
  }

  @override
  GameColors lerp(GameColors? other, double t) {
    if (other == null) return this;
    return GameColors(
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      solved: Color.lerp(solved, other.solved, t)!,
      wrongResult: Color.lerp(wrongResult, other.wrongResult, t)!,
      broken: Color.lerp(broken, other.broken, t)!,
    );
  }
}

// Definiti a mano: ColorScheme.fromSeed restituirebbe un cobalto smorzato.
const ColorScheme _lightScheme = ColorScheme(
  brightness: Brightness.light,
  primary: AppPalette.lightPrimary,
  onPrimary: Colors.white,
  primaryContainer: AppPalette.lightPrimary,
  onPrimaryContainer: Colors.white,
  secondary: AppPalette.lightPrimary,
  onSecondary: Colors.white,
  tertiary: AppPalette.accent,
  onTertiary: AppPalette.lightText,
  error: AppPalette.lightBroken,
  onError: Colors.white,
  surface: AppPalette.lightBackground,
  onSurface: AppPalette.lightText,
  onSurfaceVariant: AppPalette.lightTextSecondary,
  surfaceContainerLowest: AppPalette.lightSurface,
  surfaceContainerLow: AppPalette.lightSurface,
  surfaceContainer: AppPalette.lightSurface,
  surfaceContainerHigh: AppPalette.lightSurface,
  surfaceContainerHighest: AppPalette.lightSurface,
  outline: AppPalette.lightBorder,
  outlineVariant: AppPalette.lightBorder,
  surfaceTint: Colors.transparent,
);

const ColorScheme _darkScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: AppPalette.darkPrimary,
  onPrimary: AppPalette.darkBackground,
  primaryContainer: AppPalette.darkPrimary,
  onPrimaryContainer: AppPalette.darkBackground,
  secondary: AppPalette.darkPrimary,
  onSecondary: AppPalette.darkBackground,
  tertiary: AppPalette.accent,
  onTertiary: AppPalette.darkBackground,
  error: AppPalette.darkBroken,
  onError: AppPalette.darkBackground,
  surface: AppPalette.darkBackground,
  onSurface: AppPalette.darkText,
  onSurfaceVariant: AppPalette.darkTextSecondary,
  surfaceContainerLowest: AppPalette.darkSurface,
  surfaceContainerLow: AppPalette.darkSurface,
  surfaceContainer: AppPalette.darkSurface,
  surfaceContainerHigh: AppPalette.darkSurface,
  surfaceContainerHighest: AppPalette.darkSurface,
  outline: AppPalette.darkBorder,
  outlineVariant: AppPalette.darkBorder,
  surfaceTint: Colors.transparent,
);

ThemeData _build(ColorScheme scheme, GameColors game) {
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    extensions: [game],
    appBarTheme: const AppBarTheme(scrolledUnderElevation: 0),
    dividerTheme: DividerThemeData(color: scheme.outline),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outline),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLowest,
    ),
  );
}

final ThemeData lightTheme = _build(_lightScheme, GameColors.light);
final ThemeData darkTheme = _build(_darkScheme, GameColors.dark);
