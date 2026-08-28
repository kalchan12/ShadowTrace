import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadowtrace_client/main.dart';

void main() {
  testWidgets('ShadowTraceApp renders WelcomeScreen with tactical branding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: ShadowTraceApp()));

    expect(find.text('SHADOWTRACE'), findsOneWidget);
    expect(find.text("SEE YOUR PEOPLE. KNOW THEY'RE SAFE."), findsOneWidget);
    expect(find.text('CREATE GROUP'), findsOneWidget);
    expect(find.text('JOIN GROUP'), findsOneWidget);
  });
}
