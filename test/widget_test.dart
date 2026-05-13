import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ledgerlearn/main.dart';
import 'package:ledgerlearn/data/services/database_service.dart';
import 'package:ledgerlearn/modules/settings/controllers/theme_controller.dart';

class MockDatabaseService extends DatabaseService {
  @override
  Future<void> init() async {}

  @override
  String getLocale() => 'zh_CN';

  @override
  String getColorScheme() => 'blue';

  @override
  String getThemeMode() => 'system';
}

void main() {
  testWidgets('App loads and shows home', (WidgetTester tester) async {
    Get.put<DatabaseService>(MockDatabaseService(), permanent: true);
    Get.put(ThemeController(), permanent: true);

    await tester.pumpWidget(const LedgerLearnApp());
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
