import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_m_system/main.dart';

void main() {
  testWidgets('SMS App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SymbosysApp(),
      ),
    );

    // Verify app title or sign in text exists
    expect(find.textContaining('Symbosys'), findsWidgets);
  });
}
