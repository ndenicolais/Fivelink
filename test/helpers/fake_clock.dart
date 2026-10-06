import 'package:fivelink/core/daily.dart';

/// Orologio fermo su [current], spostabile a mano.
final class FakeClock implements Clock {
  FakeClock(this.current);

  DateTime current;

  @override
  DateTime now() => current;
}
