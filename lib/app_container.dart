// lib/app_container.dart
import 'package:agazat/screens/agazat.dart';
import 'package:agazat/screens/dashboard.dart';
import 'package:flutter/material.dart';

import 'screens/badalat.dart';
import 'screens/badalatMix.dart';
import 'screens/ozonat.dart';

class AppContainer extends StatefulWidget {
  const AppContainer({super.key});

  @override
  _AppContainerState createState() => _AppContainerState();
}

class _AppContainerState extends State<AppContainer> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DashboardPage(),
    Agazat(),
    OzonatPage(),
    Badalat(),
    BadalatMix(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      extendBody: true, // Important to allow content to extend behind nav bar
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(
            8, 0, 8, 0), // Horizontal and bottom margin
        child: Container(
          // Remove the Padding widget completely
          margin:
              const EdgeInsets.only(bottom: 16), // Just keep some bottom margin
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          height: 64,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(30, 20, 40, 1),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.home, 'الرئيسية'),
              _buildNavItem(1, Icons.calendar_today, 'الاجازات'),
              _buildNavItem(2, Icons.access_time, 'الاذونات'),
              _buildNavItem(3, Icons.swap_horiz, 'البدلات'),
              _buildNavItem(4, Icons.compare_arrows, 'بدلات مجمعة'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.purpleAccent : Colors.white,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.purpleAccent : Colors.white,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
