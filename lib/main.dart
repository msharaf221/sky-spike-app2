import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'providers/attendance_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/finance_provider.dart';
import 'providers/plan_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/team_provider.dart';
import 'providers/trainee_provider.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load persisted branding & appearance settings before building the app.
  final settingsProvider = SettingsProvider();
  await settingsProvider.load();
  final teamProvider = TeamProvider();
  await teamProvider.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: teamProvider),
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
class SkySpikeApp extends StatefulWidget {
  const SkySpikeApp({super.key});

  @override
  State<SkySpikeApp> createState() => _SkySpikeAppState();
}

class _SkySpikeAppState extends State<SkySpikeApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Keep the palette in sync when the OS flips light/dark and the user is on
  /// "follow system" mode.
  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    context.read<SettingsProvider>().reapplyFromStore();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final isDark = settingsProvider.isDarkActive;

        // Rebuild the palette for the active brightness before the themes are
        // read, so brand colors and neutrals stay consistent.
        AppPalette.isDark = isDark;
        AppPalette.apply(
          primary: settingsProvider.settings.primary,
          secondary: settingsProvider.settings.secondary,
        );

        return MaterialApp(
          title: settingsProvider.settings.clubName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settingsProvider.themeMode,

          // Arabic RTL Localization Configuration
          locale: const Locale('ar', 'EG'),
          supportedLocales: const [
            Locale('ar', 'EG'),
            Locale('ar'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          builder: (context, child) {
            // Re-assert the palette for the brightness Flutter actually chose
            // (matters for ThemeMode.system).
            final resolvedDark =
                Theme.of(context).brightness == Brightness.dark;
            if (AppPalette.isDark != resolvedDark) {
              AppPalette.isDark = resolvedDark;
              AppPalette.apply(
                primary: settingsProvider.settings.primary,
                secondary: settingsProvider.settings.secondary,
              );
            }

            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
                systemNavigationBarColor: AppColors.surface,
                systemNavigationBarIconBrightness:
                    resolvedDark ? Brightness.light : Brightness.dark,
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: child ?? const SizedBox(),
              ),
            );
          },

          home: const MainNavigationScreen(),
        );
      },
    );
  }
}
