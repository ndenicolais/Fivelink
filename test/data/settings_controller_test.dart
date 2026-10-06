import 'package:fivelink/data/models.dart';
import 'package:fivelink/data/settings_controller.dart';
import 'package:fivelink/data/storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_storage.dart';

void main() {
  test('changes are saved and notified once', () async {
    final Storage storage = await createStorage();
    final SettingsController c = SettingsController(storage);
    int calls = 0;
    c.addListener(() => calls++);

    c.setTheme(ThemePreference.light);
    c.setTheme(ThemePreference.light);
    c.setHaptics(false);
    c.markHelpSeen();

    expect(calls, 3);
    final Settings saved = storage.loadSettings();
    expect(saved.theme, ThemePreference.light);
    expect(saved.haptics, isFalse);
    expect(saved.helpSeen, isTrue);
  });

  test('starts from the saved settings', () async {
    final Storage storage = await createStorage(helpSeenValues);
    expect(SettingsController(storage).settings.helpSeen, isTrue);
  });
}
