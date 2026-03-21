import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/daily_summary.dart';
import 'models/history_entry.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/google_sign_in_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/summary_provider.dart';
import 'services/settings_repository.dart';
import 'services/local_repository.dart';
import 'services/sync_service.dart';
import 'services/user_data_service.dart';
import 'screens/auth_gate.dart';
import 'screens/auth_page.dart';
import 'screens/history_page.dart';
import 'screens/navigation_wrapper.dart';
import 'screens/pin_code_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(HistoryEntryAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(DailySummaryAdapter());

  await Hive.openBox<HistoryEntry>('history');
  await Hive.openBox<DailySummary>('dailyBox');

  final localRepo = LocalRepository();
  await localRepo.init();

  final syncService = SyncService(localRepo);
  final prefs = await SharedPreferences.getInstance();
  final settingsRepo = SettingsRepository(prefs);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => GoogleSignInProvider()),
        Provider<SettingsRepository>.value(value: settingsRepo),
        Provider<LocalRepository>.value(value: localRepo),
        Provider<SyncService>.value(value: syncService),
        Provider<UserDataService>(create: (_) => UserDataService()),
        ChangeNotifierProvider(create: (context) => SettingsProvider(
          context.read<SettingsRepository>(),
          context.read<UserDataService>(),
        )),
        ChangeNotifierProvider(create: (context) => ConnectivityProvider(context.read<SyncService>())),
        ChangeNotifierProvider(create: (context) => SummaryProvider(context.read<LocalRepository>())),
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
      title: 'Health App',
      themeMode: themeProvider.themeMode,
      
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F9FD),
        primaryColor: Colors.teal,
        colorScheme: ColorScheme.light(
          primary: Colors.teal,
          secondary: Colors.blueAccent,
          surface: Colors.white,
          onSurface: Colors.black.withOpacity(0.8),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0C12),
        primaryColor: Colors.tealAccent,
        colorScheme: ColorScheme.dark(
          primary: Colors.tealAccent,
          secondary: Colors.blueAccent,
          surface: const Color(0xFF161A22),
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
        '/home': (context) => const NavigationWrapper(), // ВОЗВРАЩАЕМ ЭТОТ МАРШРУТ
      },
      home: const AuthGate(),
    );
  }
}