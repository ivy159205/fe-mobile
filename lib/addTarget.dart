import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'health_chart.dart';
import 'dailylogentry.dart';
import 'health_info_screen.dart';
import 'heath_record_list.dart';
import 'chatbot.dart';
import 'dashboard.dart' as dashboard;
import 'login.dart';

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
  const AddTargetScreen({super.key});

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

  void _handleButtonPress(BuildContext context, String name) {
    if (name == "Progress Record") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => HealthChartScreen()));
    } else if (name == "Add Daily Log") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => DailyLogScreen()));
    } else if (name == "Add Target") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => AddTargetScreen()));
    } else if (name == "Health Record List") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => HealthRecordListScreen()));
    } else if (name == "Ask AI") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ChatbotScreen()));
    } else if (name == "Dashboard") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => dashboard.DashboardScreen()));
    } else if (name == "My Profile") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => HealthInfoPage()));
    } else if (name == "Logout") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
    }
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
        title: Text("Add target"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text("User Name"),
              accountEmail: Text("user@example.com"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage("assets/avatar.jpg"), // hoặc dùng NetworkImage
              ),
              decoration: BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("My Profile"),
              onTap: () => _handleButtonPress(context, "My Profile"),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () => _handleButtonPress(context, "Logout"),
            ),
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
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          color: Colors.blue.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(icon: Icon(Icons.dashboard), onPressed: () => _handleButtonPress(context, "Dashboard")),
              IconButton(icon: Icon(Icons.bar_chart), onPressed: () => _handleButtonPress(context, "Progress Record")),
              IconButton(icon: Icon(Icons.add), onPressed: () => _handleButtonPress(context, "Add Daily Log")),
              IconButton(icon: Icon(Icons.alarm), onPressed: () => _handleButtonPress(context, "Add Target")),
              IconButton(icon: Icon(Icons.list), onPressed: () => _handleButtonPress(context, "Health Record List")),
              IconButton(icon: Icon(Icons.help), onPressed: () => _handleButtonPress(context, "Ask AI")),
            ],
          ),
        ),
      ),
    );
  }
}
