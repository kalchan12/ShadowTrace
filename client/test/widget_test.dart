import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadowtrace_client/main.dart';

void main() {
  testWidgets('ShadowTraceApp renders splash screen branding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: ShadowTraceApp()));

    expect(find.text('SHADOWTRACE'), findsOneWidget);
    expect(find.text('SECURE REALTIME TELEMETRY'), findsOneWidget);

    // Settle transition timer to avoid pending timers error
    await tester.pumpAndSettle(const Duration(milliseconds: 1500));
  });
}
