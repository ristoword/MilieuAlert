import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:milieu_alert/screens/map/widgets/transient_alert.dart';

void main() {
  testWidgets('shows one banner then hides it without stacking', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TransientAlertSlot(
            duration: Duration(milliseconds: 50),
            candidates: [
              TransientAlert(
                id: 'zone',
                priority: 60,
                child: Text('Veicolo autorizzato'),
              ),
              TransientAlert(
                id: 'cam',
                priority: 90,
                child: Text('Autovelox'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Autovelox'), findsOneWidget);
    expect(find.text('Veicolo autorizzato'), findsNothing);

    await tester.pump(const Duration(milliseconds: 60));
    await tester.pumpAndSettle();

    expect(find.text('Autovelox'), findsNothing);
    expect(find.text('Veicolo autorizzato'), findsNothing);
  });
}
