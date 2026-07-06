import 'package:budget_planner/screens/settings/categories_screen.dart';
import 'package:budget_planner/services/auth_service.dart';
import 'package:budget_planner/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseService.testDatabasePath = inMemoryDatabasePath;
    await AuthService.instance.register(
      username: 'screentester',
      password: 'abc123',
      securityQuestion: 'q',
      securityAnswer: 'a',
    );
  });

  tearDownAll(() async => DatabaseService.instance.close());

  testWidgets('FAB tür seçtirir ve kategori ekleme diyaloğu açılır', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: CategoriesScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Gider'), findsOneWidget);
    expect(find.text('Gelir'), findsOneWidget);

    await tester.tap(find.text('Gider'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
  });
}
