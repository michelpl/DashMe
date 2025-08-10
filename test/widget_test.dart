import 'package:flutter_test/flutter_test.dart';
import 'package:dash_me/main.dart';

void main() {
  testWidgets('App builds', (tester) async {
    await tester.pumpWidget(const DashMeApp());
    expect(find.text('DashMe'), findsOneWidget);
  });
}
