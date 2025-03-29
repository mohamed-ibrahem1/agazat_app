import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class Badalat extends StatefulWidget {
  const Badalat({super.key});

  @override
  BadalatState createState() => BadalatState();
}

class BadalatState extends State<Badalat> {
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

  _loadSelectedDates() {
    final box = Hive.box('datesBox2');
    final dateStrings = box.get('selectedDates', defaultValue: <String>[]);
    if (dateStrings is List) {
      setState(() {
        _selectedDates.addAll((dateStrings as List<String>)
            .map((date) => DateTime.parse(date))
            .toList());
        _listTileCount = _selectedDates.length;
        _tileColors.addAll(
          List<Color>.filled(
              _selectedDates.length, Color.fromRGBO(46, 29, 61, 1)),
        );
      });
    }
  }

  _saveSelectedDates() {
    final box = Hive.box('datesBox2');
    final dateStrings =
        _selectedDates.map((date) => date.toIso8601String()).toList();
    box.put('selectedDates', dateStrings);
  }

  _removeDate(int index) {
    setState(() {
      _selectedDates.removeAt(index);
      _tileColors.removeAt(index);
      _listTileCount = _selectedDates.length;
    });
    _saveSelectedDates();
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
      body: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'اختر تاريخ البدل ',
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
                        _tileColors.add(Color.fromRGBO(46, 29, 61, 1));
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
                      'عدد البدلات : $_listTileCount',
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
                          title: Text(
                            DateFormat('EEE, MMM d, yyyy')
                                .format(_selectedDates[index]),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
