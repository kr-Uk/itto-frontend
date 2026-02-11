import 'package:flutter_test/flutter_test.dart';
import 'package:itto/app.dart';

void main() {
  testWidgets('App starts without error', (WidgetTester tester) async {
    await tester.pumpWidget(const IttoApp());
  });
}
