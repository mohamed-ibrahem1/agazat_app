// lib/screens/agazat.dart - updated with top spacing
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../services/storage_service.dart';

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
    final savedData = StorageService.getAgazatList();
    setState(() {
      _selectedDates.clear();
      _tileColors.clear();

      for (var item in savedData) {
        _selectedDates.add(DateTime.parse(item['date']));
        _tileColors.add(item['isActive'] == true
            ? const Color.fromRGBO(46, 29, 61, 1)
            : Colors.red);
      }
      _listTileCount = _selectedDates.length;
    });
  }

  void _addDate() {
    if (_selectedDate != null) {
      setState(() {
        _selectedDates.add(_selectedDate!);
        _tileColors.add(Colors.red);
        _listTileCount = _selectedDates.length;
        _selectedDate = null;
        _dateController.clear();
      });
      _saveSelectedDates();
    }
  }

  _saveSelectedDates() {
    final List<Map<String, dynamic>> savedData = [];

    for (int i = 0; i < _selectedDates.length; i++) {
      savedData.add({
        'date': _selectedDates[i].toIso8601String(),
        'isActive': _tileColors[i] == const Color.fromRGBO(46, 29, 61, 1),
      });
    }

    StorageService.saveAgazatList(savedData);
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
          ? const Color.fromRGBO(46, 29, 61, 1)
          : Colors.red;
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
          title: const Text('تأكيد'),
          content: const Text('هل أنت متأكد من أنك تريد ��سح جميع البيانات؟'),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('مسح'),
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

  Future<void> _selectDate(BuildContext context) async {
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
            DateFormat('EEE, MMM d, yyyy').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Wrap in SafeArea for proper spacing
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Add padding around all content
          child: Column(
            children: <Widget>[
              // Add additional space at the top

              // Date selector field with button
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'اختر تاريخ الاجازة',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      onTap: () => _selectDate(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addDate,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('إضافة'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Vacation count and clear all button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'عدد الاجازات : $_listTileCount',
                    style: const TextStyle(fontSize: 20.0),
                  ),
                  ElevatedButton(
                    onPressed: _showClearConfirmationDialog,
                    child: const Text('مسح الكل',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // List of dates
              Expanded(
                child: ListView.builder(
                  itemCount: _selectedDates.length,
                  itemBuilder: (context, index) {
                    return Slidable(
                      key: ValueKey(_selectedDates[index]),
                      startActionPane: ActionPane(
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
                        motion: const ScrollMotion(),
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
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        decoration: BoxDecoration(
                          color: _tileColors[index],
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          title: Text(
                            DateFormat('EEE, MMM d, yyyy')
                                .format(_selectedDates[index]),
                            style: const TextStyle(color: Colors.white),
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
