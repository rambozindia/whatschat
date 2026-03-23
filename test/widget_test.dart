import 'package:flutter_test/flutter_test.dart';

import 'package:numstatus/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();
  });
}
