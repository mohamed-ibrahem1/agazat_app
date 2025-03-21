import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Statistics variables
  int totalAgazat = 0;

  int totalBadalat = 0;
  int totalBadalat2 = 0;

  int totalOzonat = 0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    // Load from datesBox (Agazat)
    final agazatBox = Hive.box('datesBox');
    final agazatDates =
        agazatBox.get('selectedDates', defaultValue: <String>[]);

    // Load from datesBox3 (Badalat)
    final badalatBox = Hive.box('datesBox3');
    final badalatDates =
        badalatBox.get('savedDates', defaultValue: <Map<String, String>>[]);

    // Load from datesBox2 (Badalat.dart)
    final badalatBox2 = Hive.box('datesBox2');
    final badalatDates2 =
        badalatBox2.get('selectedDates', defaultValue: <String>[]);

    // Load from datesBox3 (BadalatMix.dart)
    final badalatBox3 = Hive.box('datesBox3');
    final badalatDates3 =
        badalatBox3.get('savedDates', defaultValue: <Map<String, String>>[]);

    // Load from ozonatBox (Ozonat) - Use the correct key 'savedRecords'
    final ozonatBox = Hive.box('ozonatBox');
    final ozonatData = ozonatBox.get('savedRecords', defaultValue: <dynamic>[]);

    setState(() {
      totalAgazat = agazatDates is List ? agazatDates.length : 0;
      totalBadalat = badalatDates is List ? badalatDates.length : 0;
      totalBadalat2 = badalatDates2 is List ? badalatDates2.length : 0;
      totalBadalat = badalatDates3 is List ? badalatDates3.length : 0;
      totalOzonat = ozonatData is List ? ozonatData.length : 0;

      // Calculate active items (this depends on your actual data structure)
      // This is just an example, adjust according to your actual implementation
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadStatistics,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              const SizedBox(height: 24),

              // Agazat Card
              _buildStatCard(
                title: 'الإجازات',
                total: totalAgazat,
                color: Colors.blue,
                icon: Icons.event,
              ),

              const SizedBox(height: 16),

              // Badalat Card with two values
              _buildStatCardWithTwoValues(
                title: 'البدلات',
                total1: totalBadalat,
                label1: 'بدلات مركبة',
                total2: totalBadalat2,
                label2: 'بدلات مفردة',
                color: Colors.orange,
                icon: Icons.swap_horiz,
              ),

              const SizedBox(height: 16),

              // Ozonat Card
              _buildStatCard(
                title: 'الأذونات',
                total: totalOzonat,
                color: Colors.green,
                icon: Icons.access_time,
              ),

              const SizedBox(height: 24),

              // Recent Activity
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int total,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              total.toString(),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              'إجمالي',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCardWithTwoValues({
    required String title,
    required int total1,
    required String label1,
    required int total2,
    required String label2,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      total1.toString(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      label1,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      total2.toString(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      label2,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
