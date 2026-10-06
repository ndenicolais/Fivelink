import 'package:flutter/material.dart';

import '../app_info.dart';
import '../data/models.dart';
import '../data/settings_controller.dart';
import '../game/game_controller.dart';
import '../l10n/generated/app_localizations.dart';
import '../stats/stats_screen.dart';
import 'copy_row.dart';
import 'privacy_screen.dart';

/// Statistiche, impostazioni, informazioni sull'app e privacy policy.
class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key, required this.settings, required this.game});

  final SettingsController settings;
  final GameController game;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.infoTitle)),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: settings,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Card(
                child: ListTile(
                  key: const ValueKey('info-stats'),
                  leading: const Icon(Icons.bar_chart),
                  title: Text(l10n.statsTitle),
                  subtitle: Text(l10n.infoStatsSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => StatsScreen(controller: game),
                    ),
                  ),
                ),
              ),
              _Heading(l10n.settingsSection),
              Text(l10n.settingsTheme, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 8),
              SegmentedButton<ThemePreference>(
                key: const ValueKey('theme-selector'),
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: ThemePreference.system,
                    icon: const Icon(Icons.brightness_auto),
                    label: Text(l10n.themeSystem),
                  ),
                  ButtonSegment(
                    value: ThemePreference.light,
                    icon: const Icon(Icons.light_mode),
                    label: Text(l10n.themeLight),
                  ),
                  ButtonSegment(
                    value: ThemePreference.dark,
                    icon: const Icon(Icons.dark_mode),
                    label: Text(l10n.themeDark),
                  ),
                ],
                selected: {settings.settings.theme},
                onSelectionChanged: (selection) =>
                    settings.setTheme(selection.single),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                key: const ValueKey('haptics-switch'),
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.settingsHaptics),
                subtitle: Text(l10n.settingsHapticsSubtitle),
                value: settings.settings.haptics,
                onChanged: settings.setHaptics,
              ),
              _Heading(l10n.infoAboutSection),
              Text(l10n.appDescription),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.infoVersion),
                subtitle: const Text('${AppInfo.version} (${AppInfo.buildNumber})'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.infoDeveloper),
                subtitle: const Text(AppInfo.developerName),
              ),
              CopyRow(label: l10n.infoEmail, value: AppInfo.developerEmail),
              CopyRow(label: l10n.infoWebsite, value: AppInfo.developerWebsite),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  key: const ValueKey('info-privacy'),
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(l10n.privacyTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PrivacyScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
