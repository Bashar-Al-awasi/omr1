import 'package:flutter/material.dart';
import 'package:omr1/screens/home_dashboard_screen.dart';
import 'package:omr1/screens/create_exam_screen.dart';
import 'package:omr1/screens/results_overview_screen.dart';
import 'package:omr1/screens/profile_screen.dart';
import 'package:omr1/screens/omr_scan_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  
  final GlobalKey<HomeDashboardScreenState> _homeKey = GlobalKey();
  final GlobalKey<CreateExamScreenState> _createExamKey = GlobalKey();
  final GlobalKey<ResultsOverviewScreenState> _resultsKey = GlobalKey();
  
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeDashboardScreen(
        key: _homeKey,
        onTabChange: (index) {
          _changeTab(index);
        },
      ),
      CreateExamScreen(
        key: _createExamKey,
        onTabChange: (index) {
          _changeTab(index);
        },
      ),
      ResultsOverviewScreen(
        key: _resultsKey,
        onTabChange: (index) {
          _changeTab(index);
        },
      ),
      const ProfileScreen(),
    ];
  }

  void _changeTab(int index) {
    setState(() => _currentIndex = index);
    if (index == 0) {
      _homeKey.currentState?.refreshData();
    } else if (index == 1) {
      _createExamKey.currentState?.loadExistingExams();
    } else if (index == 2) {
      _resultsKey.currentState?.loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const OmrScanScreen()),
          ).then((_) {
            // Refresh current tab on returning from scan in case data changed
            _changeTab(_currentIndex);
          });
        },
        backgroundColor: Colors.blue,
        elevation: 8,
        child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(0, Icons.home_rounded, loc.navHome),
              _buildNavItem(1, Icons.assignment_rounded, loc.navExams),
              const SizedBox(width: 40), // Space for FAB
              _buildNavItem(2, Icons.bar_chart_rounded, loc.navResults),
              _buildNavItem(3, Icons.person_rounded, loc.navAccount),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => _changeTab(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.grey,
            size: 26,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
