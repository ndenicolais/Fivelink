import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/storage.dart';

/// Durata minima della schermata di avvio, che resta visibile finché Flutter
/// non disegna il primo frame.
const Duration _minSplash = Duration(milliseconds: 1200);

Future<void> main() async {
  final Stopwatch startup = Stopwatch()..start();
  final WidgetsBinding binding = WidgetsFlutterBinding.ensureInitialized();
  binding.deferFirstFrame();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(FivelinkApp(storage: Storage(prefs)));
  final Duration left = _minSplash - startup.elapsed;
  if (left > Duration.zero) await Future<void>.delayed(left);
  binding.allowFirstFrame();
}
