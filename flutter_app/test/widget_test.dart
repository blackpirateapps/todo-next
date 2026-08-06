import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/main.dart';

void main() {
  testWidgets('TodoNextApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TodoNextApp());
    expect(find.byType(TodoNextApp), findsOneWidget);
  });
}
