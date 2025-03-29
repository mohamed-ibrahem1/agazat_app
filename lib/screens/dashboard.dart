import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Statistics variables
  int totalAgazat = 0;
  int userDefinedAgazat = 21; // Default value is 21
  int remainingAgazat = 0;

  int totalBadalat = 0;
  int totalBadalat2 = 0;

  int totalOzonatNumber = 0;
  int totalOzonatHours = 0;
  int ozonatRecordCount = 0; // Add this new variable

  // Add to your existing variables
  String selectedDayOfWeek = '';
  final TextEditingController _dayController = TextEditingController();

  // TextEditingController for the dialog input
  final TextEditingController _agazatController =
      TextEditingController(text: '21');

  @override
  void initState() {
    super.initState();
    _loadStatistics();
    _loadSelectedDay();
  }

  Future<void> _loadStatistics() async {
    // Load from datesBox (Agazat)
    final agazatBox = Hive.box('datesBox');
    final agazatData =
        agazatBox.get('savedAgazat', defaultValue: <Map<String, dynamic>>[]);

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

    int ozonatTotalHours = 0;
    int ozonatCount = 0;

    if (ozonatData is List) {
      ozonatCount = ozonatData.length;
      for (var record in ozonatData) {
        if (record is Map && record['number'] is int) {
          ozonatTotalHours += record['number'] as int;
        }
      }
    }

    setState(() {
      totalBadalat = badalatDates is List ? badalatDates.length : 0;
      totalBadalat2 = badalatDates2 is List ? badalatDates2.length : 0;
      totalBadalat = badalatDates3 is List ? badalatDates3.length : 0;
      remainingAgazat = userDefinedAgazat - totalAgazat;
      totalOzonatNumber = ozonatCount;
      totalOzonatHours =
          ozonatTotalHours; // Changed to store total hours instead of count

      // First, count only active records (you already have this elsewhere in the method)
      if (agazatData is List) {
        int activeCount = 0;
        for (var item in agazatData) {
          if (item is Map && item['isActive'] == true) {
            activeCount++;
          }
        }
        totalAgazat = activeCount;
      } else {
        totalAgazat = 0;
      }

      // Rest of your statistics...
      remainingAgazat = userDefinedAgazat - totalAgazat;

      // Calculate active items (this depends on your actual data structure)
      // This is just an example, adjust according to your actual implementation
    });
  }

  Future<void> _loadSelectedDay() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedDayOfWeek = prefs.getString('selectedDayOfWeek') ?? '';
      _dayController.text = selectedDayOfWeek;
    });
  }

  void _showDayPickerDialog() {
    _dayController.text = selectedDayOfWeek;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تعديل يوم التفرغ'),
          content: TextField(
            controller: _dayController,
            decoration: const InputDecoration(
              labelText: 'يوم التفرغ',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('حفظ'),
              onPressed: () async {
                setState(() {
                  selectedDayOfWeek = _dayController.text;
                });
                final prefs = await SharedPreferences.getInstance();
                prefs.setString('selectedDayOfWeek', selectedDayOfWeek);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAgazatInputDialog() {
    _agazatController.text = userDefinedAgazat.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تعديل الإجازات'),
          content: TextField(
            controller: _agazatController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'إجمالي الإجازات المستحقة',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('حفظ'),
              onPressed: () {
                setState(() {
                  userDefinedAgazat =
                      int.tryParse(_agazatController.text) ?? 21;
                  remainingAgazat = userDefinedAgazat - totalAgazat;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
              const SizedBox(height: 24),
              // Day of Week Card
              _buildDayPickerCard(
                title: 'يوم التفرغ',
                selectedDay: selectedDayOfWeek,
                color: Colors.purple,
                icon: Icons.calendar_today,
                onTap: _showDayPickerDialog,
              ),
              const SizedBox(height: 16),

              // Agazat Card with two values
              _buildAgazatCard(
                title: 'الإجازات',
                total: totalAgazat,
                allocated: userDefinedAgazat,
                remaining: remainingAgazat,
                color: Colors.blue,
                icon: Icons.event,
                onTap: _showAgazatInputDialog,
              ),

              const SizedBox(height: 16),

              // Badalat Card with two values
              _buildStatCardWithTwoValues(
                title: 'البدلات',
                total1: totalBadalat,
                label1: 'بدلات مستخدمة',
                total2: totalBadalat2,
                label2: 'بدلات متبقية',
                color: Colors.orange,
                icon: Icons.swap_horiz,
              ),

              const SizedBox(height: 16),

              // Ozonat Card
              _buildStatCard(
                title: 'الأذونات',
                total1: totalOzonatHours,
                label1: 'إجمالي الساعات',
                total2: totalOzonatNumber,
                label2: 'عدد الأذونات',
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

  Widget _buildDayPickerCard({
    required String title,
    required String selectedDay,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
                  const Spacer(),
                  const Icon(Icons.edit, size: 20),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                selectedDay.isEmpty ? 'اضغط للاختيار' : selectedDay,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgazatCard({
    required String title,
    required int total,
    required int allocated,
    required int remaining,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
                  const Spacer(),
                  const Icon(Icons.edit, size: 20),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        total.toString(),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const Text(
                        'المستخدمة',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        allocated.toString(),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const Text(
                        'المستحقة',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        remaining.toString(),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: remaining < 0 ? Colors.red : color,
                        ),
                      ),
                      const Text(
                        'المتبقية',
                        style: TextStyle(
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
      ),
    );
  }

  Widget _buildStatCard({
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
