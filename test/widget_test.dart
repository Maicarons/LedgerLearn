import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerlearn/main.dart';

void main() {
  testWidgets('App loads and shows home', (WidgetTester tester) async {
    await tester.pumpWidget(const LedgerLearnApp());
    await tester.pumpAndSettle();
    expect(find.text('LedgerLearn'), findsWidgets);
  });
}
