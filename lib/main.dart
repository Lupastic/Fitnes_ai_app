// lib/main.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ─── Screens ──────────────────────────────────────────────────────────────
import 'screens/auth_gate.dart';
import 'screens/auth_page.dart';
import 'screens/history_page.dart';
import 'screens/navigation_wrapper.dart';
import 'screens/pin_code_screen.dart';

// ─── Firebase ─────────────────────────────────────────────────────────────
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// ─── Localization ─────────────────────────────────────────────────────────
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ─── SharedPreferences ────────────────────────────────────────────────────
import 'package:shared_preferences/shared_preferences.dart';

// ─── Hive ─────────────────────────────────────────────────────────────────
import 'package:hive_flutter/hive_flutter.dart';
import 'models/daily_summary.dart';
import 'models/history_entry.dart';

// ─── Providers ────────────────────────────────────────────────────────────
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/google_sign_in_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/summary_provider.dart';

// ─── Services ─────────────────────────────────────────────────────────────
import 'services/settings_repository.dart';
import 'services/local_repository.dart';
import 'services/sync_service.dart';
import 'services/user_data_service.dart'; // Добавил этот импорт

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Явно включаем персистентность Firestore
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    // cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // Если нужно неограниченный кэш
  );

  await Hive.initFlutter();

  // Регистрация адаптеров Hive
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(HistoryEntryAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(DailySummaryAdapter());
  }

  // Открываем все Box'ы Hive, которые будут использоваться
  await Hive.openBox<HistoryEntry>('history');
  await Hive.openBox<DailySummary>('dailyBox'); // Открываем Box для DailySummary

  final localRepo = LocalRepository();
  await localRepo.init(); // Инициализация LocalRepository

  final syncService = SyncService(localRepo);
  final prefs = await SharedPreferences.getInstance();
  final settingsRepo = SettingsRepository(prefs);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => GoogleSignInProvider()),
        Provider<SettingsRepository>.value(value: settingsRepo), // Добавил SettingsRepository как Provider
        Provider<LocalRepository>.value(value: localRepo), // Добавил LocalRepository как Provider
        Provider<SyncService>.value(value: syncService), // SyncService как Provider
        Provider<UserDataService>(create: (_) => UserDataService()), // UserDataService как Provider
        // SettingsProvider теперь зависит от SettingsRepository и UserDataService
        ChangeNotifierProvider(create: (context) => SettingsProvider(
          context.read<SettingsRepository>(),
          context.read<UserDataService>(),
        )),
        ChangeNotifierProvider(create: (context) => ConnectivityProvider(
          context.read<SyncService>(),
        )),
        ChangeNotifierProvider(create: (context) => SummaryProvider(
          context.read<LocalRepository>(),
        )),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Health App UI',

      themeMode: themeProvider.themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1F1F1F),
        primaryColor: Colors.tealAccent,
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
      },

      home: const AuthGate(),
    );
  }
}