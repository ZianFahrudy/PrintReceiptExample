import 'package:flutter_test/flutter_test.dart';
import 'package:pos_print_example/app/app.dart';
import 'package:pos_print_example/counter/counter.dart';

void main() {
  group('App', () {
    testWidgets('renders CounterPage', (tester) async {
      await tester.pumpWidget(const App());
      expect(find.byType(CounterPage), findsOneWidget);
    });
  });
}
