import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';
import 'app/i18n/translations.dart';
import 'app/bindings/app_binding.dart';
import 'app/routes/app_pages.dart';
import 'modules/home/views/home_view.dart';
import 'modules/voucher/views/voucher_list_view.dart';
import 'modules/accounts/views/accounts_view.dart';
import 'modules/reports/views/reports_view.dart';
import 'modules/knowledge/views/knowledge_view.dart';
import 'modules/settings/views/settings_view.dart';
import 'modules/settings/controllers/theme_controller.dart';
import 'data/services/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(540, 960),
    minimumSize: Size(360, 640),
    center: true,
    title: 'LedgerLearn',
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAspectRatio(9 / 16);
  });

  // Create a single DatabaseService, init it, and register globally
  final db = DatabaseService();
  await db.init();
  Get.put(db, permanent: true);
  Get.put(ThemeController(), permanent: true);

  runApp(const LedgerLearnApp());
}

class LedgerLearnApp extends StatelessWidget {
  const LedgerLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Get.find<DatabaseService>();
    final savedLocale = db.getLocale();
    final localeParts = savedLocale.split('_');
    final themeCtrl = Get.find<ThemeController>();

    return GetMaterialApp(
      title: 'LedgerLearn',
      theme: themeCtrl.lightTheme,
      darkTheme: themeCtrl.darkTheme,
      themeMode: themeCtrl.currentThemeMode,
      translations: LedgerLearnTranslations(),
      locale: Locale(localeParts[0], localeParts[1]),
      fallbackLocale: const Locale('zh', 'CN'),
      initialBinding: AppBinding(),
      getPages: AppPages.routes,
      home: const MainShell(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeView(),
    VoucherListView(),
    AccountsView(),
    ReportsView(),
    KnowledgeView(),
    SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home,
                color: Theme.of(context).colorScheme.primary),
            label: 'nav_home'.tr,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long,
                color: Theme.of(context).colorScheme.primary),
            label: 'nav_voucher'.tr,
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_outlined),
            selectedIcon: Icon(Icons.account_balance,
                color: Theme.of(context).colorScheme.primary),
            label: 'nav_accounts'.tr,
          ),
          NavigationDestination(
            icon: const Icon(Icons.assessment_outlined),
            selectedIcon: Icon(Icons.assessment,
                color: Theme.of(context).colorScheme.primary),
            label: 'nav_reports'.tr,
          ),
          NavigationDestination(
            icon: const Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books,
                color: Theme.of(context).colorScheme.primary),
            label: 'nav_knowledge'.tr,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings,
                color: Theme.of(context).colorScheme.primary),
            label: 'nav_settings'.tr,
          ),
        ],
      ),
    );
  }
}
