import 'package:flutter_test/flutter_test.dart';
import 'package:campustrade_upi_yptk/main.dart';

void main() {
  testWidgets('CampusTradeApp smoke test renders catalog screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusTradeApp());
    await tester.pumpAndSettle();

    // Verify presence of title or search bar
    expect(find.text('CampusTrade'), findsWidgets);
  });
}
