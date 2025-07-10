import 'package:flutter/material.dart';

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
  final _startHourController = TextEditingController();
  final _startMinuteController = TextEditingController();
  final _targetController = TextEditingController();

  DateTime? _startDate;
  DateTime? _finishDate;

  void _selectDate(bool isStart) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _finishDate = picked;
        }
      });
    }
  }

  void _submitTarget() {
    print("📌 Title: ${_titleController.text}");
    print("🕐 Start: ${_startHourController.text}:${_startMinuteController.text} on ${_startDate.toString()}");
    print("🕓 Finish: ${_finishDate.toString()}");
    print("🎯 Target: ${_targetController.text}");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Target submitted!")),
    );
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

            Text("Start time"),
            Row(
              children: [
                Flexible(
                  flex: 1,
                  child: TextField(
                    controller: _startHourController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "h",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Flexible(
                  flex: 1,
                  child: TextField(
                    controller: _startMinuteController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "m",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Flexible(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _selectDate(true),
                    child: Text(
                      _startDate == null
                          ? "Choose start day"
                          : "${_startDate!.month}/${_startDate!.day}/${_startDate!.year}",
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            Text("Finish time"),
            ElevatedButton(
              onPressed: () => _selectDate(false),
              child: Text(
                _finishDate == null
                    ? "Choose finish day"
                    : "${_finishDate!.month}/${_finishDate!.day}/${_finishDate!.year}",
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

            ElevatedButton(
              onPressed: _submitTarget,
              child: Text("Submit"),
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
              onPressed: () {}, // Trang hiện tại
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
