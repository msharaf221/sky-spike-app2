import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import 'attendance/daily_attendance_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'finance/finance_screen.dart';
import 'reports/reports_screen.dart';
import 'trainees/trainees_list_screen.dart';

/// Main Shell with Bottom Navigation Bar
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(onNavigateTab: _onTabSelected),
      const TraineesListScreen(),
      const DailyAttendanceScreen(),
      const FinanceScreen(),
      const ReportsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabSelected,
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primaryContainer,
          elevation: 0,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
              label: AppStrings.navDashboard,
            ),
            NavigationDestination(
              icon: Icon(Icons.groups_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.groups, color: AppColors.primary),
              label: AppStrings.navTrainees,
            ),
            NavigationDestination(
              icon: Icon(Icons.fact_check_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.fact_check, color: AppColors.primary),
              label: AppStrings.navAttendance,
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.account_balance_wallet, color: AppColors.primary),
              label: AppStrings.navFinance,
            ),
            NavigationDestination(
              icon: Icon(Icons.analytics_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.analytics, color: AppColors.primary),
              label: AppStrings.navReports,
            ),
          ],
        ),
      ),
    );
  }
}
