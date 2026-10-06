import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_info.dart';
import '../l10n/generated/app_localizations.dart';
import 'copy_row.dart';

/// Informativa sulla privacy, leggibile anche offline. Lo stesso testo sta in
/// PRIVACY.md e sulla pagina pubblica [AppInfo.privacyPolicyUrl].
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final String locale = Localizations.localeOf(context).toLanguageTag();
    final String date = DateFormat.yMMMMd(
      locale,
    ).format(AppInfo.privacyPolicyUpdatedAt);

    final List<(String, String)> sections = [
      (
        l10n.privacyControllerTitle,
        l10n.privacyControllerText(
          AppInfo.developerName,
          AppInfo.developerEmail,
        ),
      ),
      (l10n.privacyDataTitle, l10n.privacyDataText),
      (l10n.privacyUseTitle, l10n.privacyUseText),
      (l10n.privacyStorageTitle, l10n.privacyStorageText),
      (l10n.privacyDeviceTitle, l10n.privacyDeviceText),
      (l10n.privacyPermissionsTitle, l10n.privacyPermissionsText),
      (l10n.privacyRetentionTitle, l10n.privacyRetentionText),
      (l10n.privacyRightsTitle, l10n.privacyRightsText(AppInfo.developerEmail)),
      (l10n.privacyChildrenTitle, l10n.privacyChildrenText),
      (l10n.privacyChangesTitle, l10n.privacyChangesText),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(l10n.privacyIntro, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text(
              l10n.privacyLastUpdated(date),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            for (final (String title, String text) in sections)
              Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(title, style: theme.textTheme.titleSmall),
                      ),
                      const SizedBox(height: 6),
                      Text(text),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            CopyRow(label: l10n.privacyOnline, value: AppInfo.privacyPolicyUrl),
          ],
        ),
      ),
    );
  }
}
