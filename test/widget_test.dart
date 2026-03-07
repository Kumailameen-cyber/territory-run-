// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:territory_run/services/offline_storage_service.dart';
import 'package:territory_run/services/connectivity_service.dart';
import 'package:territory_run/services/sync_service.dart';
import 'package:territory_run/services/firestore_service.dart';
import 'package:territory_run/app.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final storage = OfflineStorageService();
    final connectivity = ConnectivityService();
    final firestore = FirestoreService();
    final syncService = SyncService(
      storage: storage,
      firestore: firestore,
      connectivity: connectivity,
    );

    // Note: We need to initialize storage if we want this test to actually run,
    // but for now we're just fixing the compilation error.
    await tester.pumpWidget(TerritoryRunApp(
      storage: storage,
      connectivity: connectivity,
      syncService: syncService,
    ));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
