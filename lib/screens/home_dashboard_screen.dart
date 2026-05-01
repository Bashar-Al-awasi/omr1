import 'package:flutter/material.dart';
import 'package:omr1/screens/create_exam_screen.dart';
import 'package:omr1/screens/omr_scan_screen.dart';
import 'package:omr1/screens/results_overview_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../db/database_helper.dart';
import '../providers/auth_provider.dart';
import '../providers/sync_provider.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  Future<Map<String, dynamic>>? _statsFuture;
  Future<List<Map<String, dynamic>>>? _recentScansFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
    // Auto-sync on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final sync = Provider.of<SyncProvider>(context, listen: false);
      sync.autoSync(auth.userId);
    });
  }

  void _refreshData() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _statsFuture = DatabaseHelper().getDashboardStats(auth.userId);
      _recentScansFuture = DatabaseHelper().getRecentScans(5, auth.userId);
    });
    // Trigger auto-sync after refresh
    Provider.of<SyncProvider>(context, listen: false).autoSync(auth.userId);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final auth = Provider.of<AuthProvider>(context);
    final userName = auth.user?.displayName ?? loc.teacher;
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
            Text(loc.smartOmr, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          Consumer<SyncProvider>(
            builder: (context, syncProv, _) {
              if (syncProv.isSyncing) {
                return const Center(child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                ));
              }
              return PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'logout') {
                    auth.signOut();
                  }
                },
                icon: CircleAvatar(
                  backgroundColor: const Color(0xFFEEEEEE),
                  backgroundImage: auth.user?.photoURL != null ? NetworkImage(auth.user!.photoURL!) : null,
                  child: auth.user?.photoURL == null ? const Icon(Icons.person, color: Colors.black) : null,
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.black54),
                        SizedBox(width: 12),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _refreshData();
          },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: const LinearGradient(
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
                          Text("${loc.homeScreenTitle}, $userName!", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 6),
                          Text("${loc.date}: $dateString", style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                    const Icon(Icons.waving_hand, color: Colors.white, size: 36),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Summary Cards
              FutureBuilder<Map<String, dynamic>>(
                future: _statsFuture,
                builder: (context, snapshot) {
                  final stats = snapshot.data ?? {'totalExams': 0, 'totalSheets': 0, 'avgScore': 0.0};
                  return SizedBox(
                    height: 110,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _SummaryCardModern(
                          icon: Icons.assignment,
                          value: '${stats['totalExams']}',
                          label: loc.totalExams,
                          color: const Color(0xFF007BFF),
                        ),
                        _SummaryCardModern(
                          icon: Icons.document_scanner,
                          value: '${stats['totalSheets']}',
                          label: loc.sheets,
                          color: const Color(0xFF43A047),
                        ),
                        _SummaryCardModern(
                          icon: Icons.bar_chart,
                          value: '${(stats['avgScore'] as double).toStringAsFixed(1)}%',
                          label: loc.avgScore,
                          color: const Color(0xFFFB8C00),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              // Quick Actions
              Text(loc.coreActions, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
                childAspectRatio: 1.2,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _QuickActionModern(
                    icon: Icons.add_circle_outline,
                    label: loc.createExam,
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CreateExamScreen()),
                      );
                      _refreshData();
                    },
                  ),
                  _QuickActionModern(
                    icon: Icons.qr_code_scanner,
                    label: loc.scanOmrSheet,
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const OmrScanScreen()),
                      );
                      _refreshData();
                    },
                  ),
                  _QuickActionModern(
                    icon: Icons.list_alt,
                    label: loc.resultsButton,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ResultsOverviewScreen()),
                      ).then((_) => _refreshData());
                    },
                  ),
                  _QuickActionModern(
                    icon: Icons.person_search,
                    label: loc.students,
                    onTap: () {
                      Navigator.of(context).pushNamed('/students').then((_) => _refreshData());
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Recent Activity
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(loc.recentScans, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {},
                    child: Text(loc.viewAll, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _recentScansFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ));
                  }
                  final scans = snapshot.data ?? [];
                  if (scans.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          loc.noScansYet,
                          style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: scans.map((scan) {
                      return _RecentExamCard(
                        title: scan['exam_title'] ?? 'Unknown Exam',
                        date: scan['date']?.toString().split('T').first ?? '',
                        status: loc.graded,
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
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
        boxShadow: const [
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
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
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
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
    Color statusColor = status == 'Graded' ? const Color(0xFF43A047) : const Color(0xFFFB8C00);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Icon(Icons.description, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
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
