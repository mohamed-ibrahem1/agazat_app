import 'package:agazat/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('datesBox');
  await Hive.openBox('datesBox2');
  await Hive.openBox('datesBox3');
  await Hive.openBox('ozonatBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(), // Set the theme to dark mode
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', ''), // Arabic locale
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', ''),
      ],
      // Remove the debug banner
      home: HomePage(),
    );
  }
}

class Agazat extends StatefulWidget {
  const Agazat({super.key});

  @override
  AgazatState createState() => AgazatState();
}

class AgazatState extends State<Agazat> {
  DateTime? _selectedDate;
  final List<DateTime> _selectedDates = [];
  final TextEditingController _dateController = TextEditingController();
  int _listTileCount = 0;
  final List<Color> _tileColors = [];

  @override
  void initState() {
    super.initState();
    _loadSelectedDates();
  }

  int get listTileCount => _listTileCount;

  _loadSelectedDates() {
    final box = Hive.box('datesBox');
    final savedData =
        box.get('savedAgazat', defaultValue: <Map<String, dynamic>>[]);
    if (savedData is List) {
      setState(() {
        _selectedDates.clear();
        _tileColors.clear();

        for (var item in savedData) {
          _selectedDates.add(DateTime.parse(item['date']));
          _tileColors.add(item['isActive'] == true
              ? Color.fromRGBO(46, 29, 61, 1)
              : Colors.red);
        }
        _listTileCount = _selectedDates.length;
      });
    }
  }

  // In your Agazat class
  void _addDate() {
    if (_selectedDate != null) {
      setState(() {
        _selectedDates.add(_selectedDate!);
        _tileColors.add(Colors.red); // Default to inactive (red)
        _listTileCount = _selectedDates.length;
        _selectedDate = null;
        _dateController.clear();
      });
      _saveSelectedDates();
    }
  }

  _saveSelectedDates() {
    final box = Hive.box('datesBox');
    final List<Map<String, dynamic>> savedData = [];

    for (int i = 0; i < _selectedDates.length; i++) {
      savedData.add({
        'date': _selectedDates[i].toIso8601String(),
        'isActive': _tileColors[i] == Color.fromRGBO(46, 29, 61, 1),
      });
    }

    box.put('savedAgazat', savedData);
  }

  _removeDate(int index) {
    setState(() {
      _selectedDates.removeAt(index);
      _tileColors.removeAt(index);
      _listTileCount = _selectedDates.length;
    });
    _saveSelectedDates();
  }

  _changeTileColor(int index) {
    setState(() {
      _tileColors[index] = _tileColors[index] == Colors.red
          ? Color.fromRGBO(46, 29, 61, 1)
          : Colors.red;
    });
    _saveSelectedDates(); // Save the state change
  }

  void clearListView() {
    setState(() {
      _selectedDates.clear();
      _tileColors.clear();
      _listTileCount = 0;
    });
    _saveSelectedDates();
  }

  void _showClearConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تأكيد'),
          content: Text('هل أنت متأكد من أنك تريد مسح جميع البيانات؟'),
          actions: <Widget>[
            TextButton(
              child: Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('مسح'),
              onPressed: () {
                clearListView();
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
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'اختر تاريخ الاجازة',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                      _selectedDates.add(pickedDate);
                      _tileColors.add(Colors.red);
                      _listTileCount = _selectedDates.length;
                      _dateController.text = '';
                    });
                    _saveSelectedDates();
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'عدد الاجازات : $_listTileCount',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  ElevatedButton(
                    onPressed: _showClearConfirmationDialog,
                    child: Row(
                      children: [
                        Text('مسح الكل', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _selectedDates.length,
                itemBuilder: (context, index) {
                  return Slidable(
                      key: ValueKey(_selectedDates[index]),
                      startActionPane: ActionPane(
                        motion: ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) => _changeTileColor(index),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            icon: Icons.check,
                            label: 'تفعيل',
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ],
                      ),
                      endActionPane: ActionPane(
                        motion: ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) => _removeDate(index),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'حذف',
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ],
                      ),
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: _tileColors[index],
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          // Remove the tileColor property here
                          title: Text(
                            DateFormat('EEE, MMM d, yyyy')
                                .format(_selectedDates[index]),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
