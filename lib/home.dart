import 'package:agazat/badalat.dart';
import 'package:agazat/badalatMix.dart';
import 'package:agazat/dashboard.dart';
import 'package:agazat/main.dart';
import 'package:flutter/material.dart';

import 'ozonat.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  late Agazat agazatPage;
  late Badalat badalatPage;
  late BadalatMix badalatMixPage;
  late DashboardPage dashboardPage;
  final ozonatPage = OzonatPage();

  @override
  void initState() {
    super.initState();
    agazatPage = Agazat();
    badalatPage = Badalat();
    badalatMixPage = BadalatMix();
    dashboardPage = DashboardPage();
  }

  @override
  Widget build(BuildContext context) {
    List pages = [
      agazatPage,
      badalatPage,
      badalatMixPage,
      OzonatPage(),
      dashboardPage,
    ];
    List<String> titles = [
      'الاجازات',
      'البدلات',
      'بدلات مجمعه',
      'الأذونات',
      'احصائيات'
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[selectedIndex],
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: pages[selectedIndex],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromRGBO(46, 29, 61, 1),
              ),
              child: Text(
                'القائمة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.calendar_month_sharp),
              title: Text('الاجازات'),
              onTap: () {
                setState(() {
                  selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.compare_arrows_outlined),
              title: Text('البدلات'),
              onTap: () {
                setState(() {
                  selectedIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.cached),
              title: Text('بدلات مجمعه'),
              onTap: () {
                setState(() {
                  selectedIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.timer),
              title: Text('الأذونات'),
              onTap: () {
                setState(() {
                  selectedIndex =
                      3; // Make sure to update other indices if needed
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.stacked_bar_chart),
              title: Text('احصائيات'),
              onTap: () {
                setState(() {
                  selectedIndex =
                      4; // Make sure to update other indices if needed
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
