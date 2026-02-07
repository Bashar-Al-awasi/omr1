import 'package:flutter/material.dart';
import 'package:omr1/screens/create_exam_screen.dart';
import 'package:omr1/screens/omr_scan_screen.dart';
import 'package:omr1/screens/results_overview_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Localization import

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final userName = loc.teacher; // Localized
    final today = DateTime.now();
    final dateString = "${today.day}/${today.month}/${today.year}";
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.bubble_chart, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(loc.smartOmr, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
            tooltip: loc.notifications,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.person, color: Colors.black),
            ),
          ),
        ],
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(
                  colors: [Color(0xFF007BFF), Color(0xFF90CAF9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${loc.homeScreenTitle}, $userName!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 6),
                        Text("${loc.date}: $dateString", style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  Icon(Icons.waving_hand, color: Colors.white, size: 36),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Summary Cards
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _SummaryCardModern(
                    icon: Icons.assignment,
                    value: '12',
                    label: loc.totalExams,
                    color: Color(0xFF007BFF),
                  ),
                  _SummaryCardModern(
                    icon: Icons.document_scanner,
                    value: '340',
                    label: loc.sheets,
                    color: Color(0xFF43A047),
                  ),
                  _SummaryCardModern(
                    icon: Icons.bar_chart,
                    value: '78%',
                    label: loc.avgScore,
                    color: Color(0xFFFB8C00),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Quick Actions
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              mainAxisSpacing: 18,
              crossAxisSpacing: 18,
              childAspectRatio: 1.2,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _QuickActionModern(
                  icon: Icons.add_circle_outline,
                  label: loc.createExam,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => CreateExamScreen()),
                    );
                  },
                ),
                _QuickActionModern(
                  icon: Icons.qr_code_scanner,
                  label: loc.scanOmrSheet,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => OmrScanScreen()),
                    );
                  },
                ),
                _QuickActionModern(
                  icon: Icons.list_alt,
                  label: loc.resultsButton,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ResultsOverviewScreen()),
                    );
                  },
                ),
                _QuickActionModern(
                  icon: Icons.person_search,
                  label: 'Students',
                  onTap: () {
                    Navigator.of(context).pushNamed('/students');
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Recent Activity
            Text(loc.recentScans, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _RecentExamCard(title: 'Math Final', date: '18/6/2025', status: 'Graded'),
            _RecentExamCard(title: 'Science Quiz', date: '15/6/2025', status: 'Pending'),
            _RecentExamCard(title: 'History Midterm', date: '10/6/2025', status: 'Graded'),
          ],
        ),
      ),
    );
  }
}

class _SummaryCardModern extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _SummaryCardModern({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border(
          left: BorderSide(color: color, width: 6),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      clipBehavior: Clip.hardEdge,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _QuickActionModern extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickActionModern({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 10),
              Text(label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentExamCard extends StatelessWidget {
  final String title;
  final String date;
  final String status;
  const _RecentExamCard({required this.title, required this.date, required this.status});

  @override
  Widget build(BuildContext context) {
    Color statusColor = status == 'Graded' ? Color(0xFF43A047) : Color(0xFFFB8C00);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Icon(Icons.description, color: Theme.of(context).primaryColor),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(date),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
