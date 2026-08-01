import 'package:flutter_test/flutter_test.dart';
import 'package:easy_book/main.dart';

void main() {
  testWidgets('App load test', (WidgetTester tester) async {
    await tester.pumpWidget(const EasyBookApp());
  });
}
