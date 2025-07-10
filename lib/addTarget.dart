import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MaterialApp(
    home: AddTargetScreen(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
  ));
}

class AddTargetScreen extends StatefulWidget {
  @override
  _AddTargetScreenState createState() => _AddTargetScreenState();
}

class _AddTargetScreenState extends State<AddTargetScreen> {
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();

  final _startDateController = TextEditingController(text: 'No date selected');
  final _finishDateController = TextEditingController(text: 'No date selected');

  DateTime? _startDate;
  DateTime? _finishDate;

  String _formatDate(DateTime? date) {
    if (date == null) return "No date selected";
    return DateFormat('dd MMMM yyyy').format(date);
  }

  void _selectDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart ? (_startDate ?? now) : (_finishDate ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2500),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          _startDateController.text = _formatDate(picked);
        } else {
          _finishDate = picked;
          _finishDateController.text = _formatDate(picked);
        }
      });
    }
  }

  void _clearDate(bool isStart) {
    setState(() {
      if (isStart) {
        _startDate = null;
        _startDateController.text = 'No date selected';
      } else {
        _finishDate = null;
        _finishDateController.text = 'No date selected';
      }
    });
  }

  void _submitTarget() {
    print("Title: ${_titleController.text}");
    print("Start: ${_startDate.toString()}");
    print("Finish: ${_finishDate.toString()}");
    print("Target: ${_targetController.text}");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Target submitted!")),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _startDateController.dispose();
    _finishDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            Icon(Icons.home),
            SizedBox(width: 10),
            Text("Add Target"),
            Spacer(),
            Icon(Icons.menu),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            Text("Please enter your title"),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "e.g. Exercise more",
              ),
            ),
            SizedBox(height: 16),

            // Start Date Field
            TextField(
              controller: _startDateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Start Date",
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(isStart: true),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () => _clearDate(true),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Finish Date Field
            TextField(
              controller: _finishDateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Finish Date",
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(isStart: false),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () => _clearDate(false),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            Text("Target"),
            TextField(
              controller: _targetController,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "e.g. Walk 10,000 steps/day",
              ),
            ),
            SizedBox(height: 24),

            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: _submitTarget,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[100],
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Submit",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        color: Colors.blue.shade50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.analytics),
              tooltip: "Access Record",
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.add),
              tooltip: "Add Daily Log",
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.track_changes),
              tooltip: "Add Target",
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.list),
              tooltip: "Health Record List",
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.help),
              tooltip: "Ask AI",
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
