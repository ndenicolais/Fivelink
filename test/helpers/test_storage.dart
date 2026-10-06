import 'dart:convert';

import 'package:fivelink/data/models.dart';
import 'package:fivelink/data/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage su preferenze simulate in memoria, inizializzate con [values].
Future<Storage> createStorage([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  return Storage(await SharedPreferences.getInstance());
}

/// Valori iniziali con la guida già vista, per i test che non la riguardano.
Map<String, Object> get helpSeenValues => {
  Storage.settingsKey: jsonEncode(const Settings(helpSeen: true)),
};
