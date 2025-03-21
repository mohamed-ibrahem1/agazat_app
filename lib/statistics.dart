import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatisticsPage extends StatefulWidget {
  final int listTileCount;

  const StatisticsPage({super.key, required this.listTileCount});

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int _count = 0;
  int _editableCount = 0;
  int _difference = 0;
  final TextEditingController _controller = TextEditingController();

  final TextEditingController _textController = TextEditingController();
  String _savedText = '';

  void _loadText() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedText = prefs.getString('savedText') ?? '';
      _textController.text = _savedText;
    });
  }

  void _saveText() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('savedText', _savedText);
  }

  void _updateText(String value) {
    setState(() {
      _savedText = value;
    });
    _saveText();
  }

  @override
  void initState() {
    super.initState();
    _loadCount();
    _loadText();
  }

  void _loadCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _count = prefs.getInt('count') ?? 0;
      _editableCount = prefs.getInt('editableCount') ?? 0;
      _controller.text = _editableCount.toString();
      _difference = _editableCount - widget.listTileCount;
    });
  }

  void _saveCount() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('count', _count);
    prefs.setInt('editableCount', _editableCount);
  }

  void _increment() {
    setState(() {
      _count++;
    });
    _saveCount();
  }

  void _decrement() {
    setState(() {
      if (_count > 0) {
        _count--;
      }
    });
    _saveCount();
  }

  void _updateEditableCount(String value) {
    setState(() {
      _editableCount = int.tryParse(value) ?? 0;
      _difference = _editableCount - widget.listTileCount;
    });
    _saveCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              color: Color.fromRGBO(46, 29, 61, 1),
              margin: EdgeInsets.all(16.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'اذونات',
                          style: TextStyle(fontSize: 23.0),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: _decrement,
                        ),
                        Text(
                          '$_count',
                          style: TextStyle(fontSize: 30.0),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: _increment,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Card(
              color: Color.fromRGBO(46, 29, 61, 1),
              margin: EdgeInsets.all(16.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'رصيد الاجازات الاساسي',
                          style: TextStyle(fontSize: 23.0),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 30.0),
                            onChanged: _updateEditableCount,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Card(
              color: Color.fromRGBO(46, 29, 61, 1),
              margin: EdgeInsets.all(16.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'يوم التفرغ',
                          style: TextStyle(fontSize: 23.0),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            keyboardType: TextInputType.text,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 30.0),
                            onChanged: _updateText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ------------------------   the difference card ---------------------------------------------------------

            // Card(
            //   color: Color.fromRGBO(46, 29, 61, 1),
            //   margin: EdgeInsets.all(16.0),
            //   child: Padding(
            //     padding: EdgeInsets.all(16.0),
            //     child: Column(
            //       mainAxisSize: MainAxisSize.min,
            //       children: <Widget>[
            //         Row(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: <Widget>[
            //             Text(
            //               'رصيد الاجازات المتبقي',
            //               style: TextStyle(fontSize: 23.0),
            //             ),
            //           ],
            //         ),
            //         SizedBox(height: 16.0),
            //         Row(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: <Widget>[
            //             Text(
            //               '$_difference',
            //               style: TextStyle(fontSize: 30.0),
            //             ),
            //           ],
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
