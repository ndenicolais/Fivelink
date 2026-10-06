import 'package:fivelink/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app starts and shows title', (tester) async {
    await tester.pumpWidget(const FivelinkApp());
    await tester.pumpAndSettle();
    expect(find.text('Fivelink'), findsOneWidget);
  });
}
