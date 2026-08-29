import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadowtrace_client/widgets/tactical_qr_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  group('TacticalQrWidget', () {
    testWidgets('renders QrImageView and label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TacticalQrWidget(
              data: 'shadowtrace://v1/join?gid=test-gid&sec=test-sec',
              label: 'TEST INVITE QR',
            ),
          ),
        ),
      );

      expect(find.text('TEST INVITE QR'), findsOneWidget);
      expect(find.byType(QrImageView), findsOneWidget);
      expect(
        find.text('shadowtrace://v1/join?gid=test-gid&sec=test-sec'),
        findsOneWidget,
      );
    });
  });
}
