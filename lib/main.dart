import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/attendance_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/finance_provider.dart';
import 'providers/plan_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/trainee_provider.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load persisted branding settings before building the app.
  final settingsProvider = SettingsProvider();
  await settingsProvider.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => TraineeProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => FinanceProvider()),
        ChangeNotifierProvider(create: (_) => PlanProvider()),
      ],
      child: const SkySpikeApp(),
    ),
  );
}

/// Root Application Widget for Sky Spike Volleyball Academy
class SkySpikeApp extends StatelessWidget {
  const SkySpikeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return MaterialApp(
          title: settingsProvider.settings.clubName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,

          // Arabic RTL Localization Configuration
          locale: const Locale('ar', 'EG'),
          supportedLocales: const [
            Locale('ar', 'EG'),
            Locale('ar'),
          ],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: child ?? const SizedBox(),
            );
          },

          home: const MainNavigationScreen(),
        );
      },
    );
  }
}
