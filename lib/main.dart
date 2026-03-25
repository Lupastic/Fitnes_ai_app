import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:developer' as developer;

import 'models/daily_summary.dart';
import 'models/history_entry.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/summary_provider.dart';
import 'providers/step_counter_provider.dart';
import 'services/settings_repository.dart';
import 'services/local_repository.dart';
import 'services/sync_service.dart';
import 'services/user_data_service.dart';
import 'screens/auth_gate.dart';
import 'screens/auth_page.dart';
import 'screens/history_page.dart';
import 'screens/navigation_wrapper.dart';
import 'screens/pin_code_screen.dart';
import 'screens/leaderboard_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  developer.log("🚀 Запуск приложения...", name: "Main");
  
  try {
    // Load environment variables
    await dotenv.load(fileName: ".env");

    developer.log("🔥 Инициализация Firebase...", name: "Main");
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
    developer.log("✅ Firebase готов", name: "Main");

    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(HistoryEntryAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(DailySummaryAdapter());

    await _openHiveBox<HistoryEntry>('history');
    await _openHiveBox<DailySummary>('dailyBox');

    final localRepo = LocalRepository();
    await localRepo.init();

    final syncService = SyncService(localRepo);
    final prefs = await SharedPreferences.getInstance();
    final settingsRepo = SettingsRepository(prefs);

    developer.log("🏁 Запуск runApp", name: "Main");
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => AppAuthProvider()),
          Provider<SettingsRepository>.value(value: settingsRepo),
          Provider<LocalRepository>.value(value: localRepo),
          Provider<SyncService>.value(value: syncService),
          Provider<UserDataService>(create: (_) => UserDataService()),
          ChangeNotifierProvider(create: (context) => SettingsProvider(
            context.read<SettingsRepository>(),
            context.read<UserDataService>(),
          )),
          ChangeNotifierProvider(create: (context) => SummaryProvider(context.read<LocalRepository>())),
          ChangeNotifierProvider(create: (context) => StepCounterProvider(context.read<SummaryProvider>())),
          ChangeNotifierProvider(create: (context) => ConnectivityProvider(context.read<SyncService>())),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e, stack) {
    developer.log("❌ КРИТИЧЕСКАЯ ОШИБКА: $e", name: "Main", error: e, stackTrace: stack);
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(child: Text("Ошибка запуска: $e")),
      ),
    ));
  }
}

Future<void> _openHiveBox<T>(String name) async {
  try {
    if (!Hive.isBoxOpen(name)) {
      await Hive.openBox<T>(name);
    }
  } catch (e) {
    developer.log("⚠️ Ошибка открытия бокса $name: $e", name: "Hive");
    await Hive.deleteBoxFromDisk(name);
    await Hive.openBox<T>(name);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Health App',
      themeMode: themeProvider.themeMode,
      
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        primaryColor: Colors.teal,
        colorScheme: const ColorScheme.light(
          primary: Colors.teal,
          secondary: Colors.blueAccent,
          surface: Colors.white,
          onSurface: Color(0xFF333333),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: Color(0xFF424242)),
        ),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0C12),
        primaryColor: Colors.tealAccent,
        colorScheme: const ColorScheme.dark(
          primary: Colors.tealAccent,
          secondary: Colors.blueAccent,
          surface: Color(0xFF161A22),
          onSurface: Colors.white,
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF161A22),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
      ),

      locale: localeProvider.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      routes: {
        '/history': (context) => const HistoryPage(),
        '/auth_page': (context) => const AuthPage(),
        '/pin': (context) => const PinCodeScreen(),
        '/home': (context) => const NavigationWrapper(),
        '/leaderboard': (context) => const LeaderboardPage(),
      },
      home: const AuthGate(),
    );
  }
}
