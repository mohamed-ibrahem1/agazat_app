import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class BadalatMix extends StatefulWidget {
  const BadalatMix({super.key});

  @override
  State<BadalatMix> createState() => _BadalatMixState();
}

class _BadalatMixState extends State<BadalatMix> {
  DateTime? _selectedDate1;
  DateTime? _selectedDate2;
  final TextEditingController _dateController1 = TextEditingController();
  final TextEditingController _dateController2 = TextEditingController();
  final List<Map<String, DateTime?>> _savedDates = [];
  final List<Color> _tileColors = [];

  @override
  void initState() {
    super.initState();
    _loadSavedDates();
  }

  _loadSavedDates() {
    final box = Hive.box('datesBox3');
    final datePairs =
        box.get('savedDates', defaultValue: <Map<String, String>>[]);
    if (datePairs is List) {
      setState(() {
        _savedDates.addAll(datePairs.map((pair) {
          return {
            'date1': DateTime.parse(pair['date1']!),
            'date2': DateTime.parse(pair['date2']!),
          };
        }).toList());
        _tileColors.addAll(List<Color>.filled(_savedDates.length, Colors.red));
      });
    }
  }

  _saveDates() {
    final box = Hive.box('datesBox3');
    final datePairs = _savedDates.map((pair) {
      return {
        'date1': pair['date1']!.toIso8601String(),
        'date2': pair['date2']!.toIso8601String(),
      };
    }).toList();
    box.put('savedDates', datePairs);
  }

  _removeDate(int index) {
    if (index >= 0 && index < _savedDates.length) {
      setState(() {
        _savedDates.removeAt(index);
        _tileColors.removeAt(index);
      });
      _saveDates();
    }
  }

  _changeTileColor(int index) {
    if (index >= 0 && index < _tileColors.length) {
      setState(() {
        _tileColors[index] = _tileColors[index] == Colors.red
            ? Color.fromRGBO(46, 29, 61, 1)
            : Colors.red;
      });
    }
  }

  void clearListView() {
    setState(() {
      _savedDates.clear();
      _tileColors.clear();
    });
    _saveDates();
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
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _dateController1,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'اليوم',
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
                            _selectedDate1 = pickedDate;
                            _dateController1.text =
                                DateFormat('EEE, MMM d, yyyy')
                                    .format(pickedDate);
                          });
                        }
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _dateController2,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'بدل عن يوم',
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
                            _selectedDate2 = pickedDate;
                            _dateController2.text =
                                DateFormat('EEE, MMM d, yyyy')
                                    .format(pickedDate);
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedDate1 != null && _selectedDate2 != null) {
                        setState(() {
                          _savedDates.add({
                            'date1': _selectedDate1,
                            'date2': _selectedDate2,
                          });
                          _tileColors.add(Colors.red);
                          _selectedDate1 = null;
                          _selectedDate2 = null;
                          _dateController1.clear();
                          _dateController2.clear();
                          _saveDates();
                        });
                      }
                    },
                    child: Text('حفظ'),
                  ),
                  SizedBox(width: 8.0),
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
                itemCount: _savedDates.length,
                itemBuilder: (context, index) {
                  final datePair = _savedDates[index];
                  return Slidable(
                    key: ValueKey(datePair),
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
                      margin:
                          EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: _tileColors[index],
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        title: Text(
                          'اليوم : ${DateFormat('EEE, MMM d, yyyy').format(datePair['date1']!)}\n'
                          'بدل عن يوم : ${DateFormat('EEE, MMM d, yyyy').format(datePair['date2']!)}',
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
    );
  }
}
