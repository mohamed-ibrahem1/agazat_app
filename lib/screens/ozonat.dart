import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class OzonatPage extends StatefulWidget {
  const OzonatPage({super.key});

  @override
  State<OzonatPage> createState() => _OzonatPageState();
}

class _OzonatPageState extends State<OzonatPage> {
  //**********************************
  // Add this variable to track the total hours
  int _totalHours = 0;
  //**********************************
  int? _selectedNumber;
  String? _selectedTime;
  DateTime? _selectedDate;
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final List<Map<String, dynamic>> _savedRecords = [];
  final List<Color> _cardColors = [];

  @override
  void initState() {
    super.initState();
    _loadSavedRecords();
  }

  _loadSavedRecords() {
    final box = Hive.box('ozonatBox');
    final records =
        box.get('savedRecords', defaultValue: <Map<String, dynamic>>[]);
    if (records is List) {
      setState(() {
        _savedRecords.clear();
        _cardColors.clear();

        for (var record in records) {
          _savedRecords.add({
            'number': record['number'],
            'time': record['time'],
            'note': record['note'],
            'date':
                record['date'] != null ? DateTime.parse(record['date']) : null,
          });
          // Load the card color state (active or inactive)
          _cardColors.add(record['isActive'] == true
              ? Color.fromRGBO(46, 29, 61, 1)
              : Colors.red);
        }
        _calculateTotalHours();
      });
    }
  }

  //*************************************
  // Add method to calculate total hours
  void _calculateTotalHours() {
    _totalHours = 0;
    for (var record in _savedRecords) {
      if (record['number'] is int) {
        _totalHours += record['number'] as int;
      }
    }
  }
  //*************************************

  // Update save method to include card colors
  _saveRecords() {
    final box = Hive.box('ozonatBox');
    final recordsToSave = List<Map<String, dynamic>>.generate(
      _savedRecords.length,
      (index) => {
        'number': _savedRecords[index]['number'],
        'time': _savedRecords[index]['time'],
        'note': _savedRecords[index]['note'],
        'date': _savedRecords[index]['date']?.toIso8601String(),
        'isActive': _cardColors[index] == Color.fromRGBO(46, 29, 61, 1),
      },
    );
    box.put('savedRecords', recordsToSave);
  }

  _removeRecord(int index) {
    if (index >= 0 && index < _savedRecords.length) {
      setState(() {
        _savedRecords.removeAt(index);
        _cardColors.removeAt(index);
        //*************************************
        _calculateTotalHours();
        //*************************************
      });
      _saveRecords();
    }
  }

  _changeTileColor(int index) {
    if (index >= 0 && index < _cardColors.length) {
      setState(() {
        _cardColors[index] = _cardColors[index] == Colors.red
            ? Color.fromRGBO(46, 29, 61, 1)
            : Colors.red;
      });
      _saveRecords(); // Save after changing color
    }
  }

  void clearRecords() {
    setState(() {
      _savedRecords.clear();
      _cardColors.clear();
      //*************************************
      _totalHours = 0;
      //*************************************
    });
    _saveRecords();
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
                clearRecords();
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
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            // Date picker TextField
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'تاريخ الإذن',
                  suffixIcon: const Icon(Icons.calendar_month_rounded),
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
                      _dateController.text =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                    });
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'عدد الساعات',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      value: _selectedNumber,
                      items: List.generate(7, (index) {
                        return DropdownMenuItem<int>(
                          value: index + 1,
                          child: Text('${index + 1}'),
                        );
                      }),
                      onChanged: (value) {
                        setState(() {
                          _selectedNumber = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'الوقت',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      value: _selectedTime,
                      items: [
                        DropdownMenuItem<String>(
                          value: 'صباحي',
                          child: Text('صباحي'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'مسائي',
                          child: Text('مسائي'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedTime = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'ملاحظات',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                maxLines: 1,
              ),
            ),
            //////////////////////////////////////////////////////
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 8),
                Text(
                  'مجموع الساعات: $_totalHours',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            ////////////////////////////////////////////////////
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_selectedNumber != null &&
                        _selectedTime != null &&
                        _selectedDate != null) {
                      setState(() {
                        _savedRecords.add({
                          'number': _selectedNumber,
                          'time': _selectedTime,
                          'note': _noteController.text,
                          'date': _selectedDate,
                        });
                        /////////////////////////////////////////////////////////////////////////////
                        // Update total hours
                        _totalHours += _selectedNumber!;
                        /////////////////////////////////////////////////////////////////////////////

                        _cardColors.add(Colors.red);
                        _selectedNumber = null;
                        _selectedTime = null;
                        _selectedDate = null;
                        _noteController.clear();
                        _dateController.clear();
                        _saveRecords();
                      });
                    } else {
                      // Show an error message if fields are empty
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('برجاء ملء جميع الحقول'),
                          backgroundColor: Colors.red,
                        ),
                      );
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
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _savedRecords.length,
                itemBuilder: (context, index) {
                  final record = _savedRecords[index];
                  return Slidable(
                    key: ValueKey(index),
                    startActionPane: ActionPane(
                      extentRatio: 0.30,
                      motion: const ScrollMotion(),
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
                      extentRatio: 0.30,
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) => _removeRecord(index),
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
                        color: _cardColors[index],
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        title: Text(
                          'عدد الساعات: ${record['number']}',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (record['date'] != null)
                              Text(
                                'التاريخ: ${DateFormat('yyyy-MM-dd').format(record['date'])}',
                                style: TextStyle(color: Colors.white),
                              ),
                            Text(
                              'الوقت: ${record['time']}',
                              style: TextStyle(color: Colors.white),
                            ),
                            if (record['note'].isNotEmpty)
                              Text(
                                'ملاحظات: ${record['note']}',
                                style: TextStyle(color: Colors.white),
                              ),
                          ],
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
