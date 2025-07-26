import 'package:flutter/material.dart';
import 'health_chart.dart';
import 'dashboard.dart' as dashboard;
import 'addTarget.dart';
import 'health_info_screen.dart';
import 'heath_record_list.dart';
import 'chatbot.dart';
import 'package:intl/intl.dart';

import 'login.dart'; // <-- Import thư viện intl

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Log UI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 16.0,
          ),
        ),
      ),
      home: const DailyLogScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DailyLogScreen extends StatefulWidget {
  const DailyLogScreen({super.key});

  @override
  State<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> {
  int _selectedIndex = 0;
  final List<String> _healthMetricTypes = ['Blood Pressure', 'Blood Sugar', 'Cholesterol'];
  String? _selectedMetricType;

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

  // --- BIẾN STATE MỚI ĐỂ LƯU TRỮ NGÀY VÀ GIỜ ---
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;

  // --- HÀM MỚI ĐỂ CHỌN NGÀY ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // --- HÀM MỚI ĐỂ CHỌN GIỜ ---
  Future<void> _selectTime(BuildContext context, {required bool isFromTime}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isFromTime) {
          _fromTime = picked;
        } else {
          _toTime = picked;
        }
      });
    }
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Enter daily log"),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- CẬP NHẬT MỤC DATE ---
              _buildLogEntry(
                'Date',
                InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(_selectedDate), // Định dạng ngày
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- CẬP NHẬT MỤC SLEEP ---
              _buildLogEntry('Sleep', Row(
                children: [
                  Expanded(child: _buildTimePicker(context, isFrom: true)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('to'),
                  ),
                  Expanded(child: _buildTimePicker(context, isFrom: false)),
                ],
              )),
              const SizedBox(height: 16),

              _buildLogEntry('Weight', _buildTextField(suffixText: 'Kg', keyboardType: TextInputType.number)),
              const SizedBox(height: 16),

              _buildLogEntry('Exercise time', _buildTextField(suffixText: 'mins', keyboardType: TextInputType.number)),
              const SizedBox(height: 16),

              _buildLogEntry('Health metric type', _buildDropdown()),
              const SizedBox(height: 16),

              _buildLogEntry('Metric value', _buildTextField(hint: 'Value')),
              const SizedBox(height: 16),

              const TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Heart rate: ...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              _buildLogEntry('Notes', _buildTextField(hint: '')),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Submit', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
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

  Widget _buildLogEntry(String label, Widget inputWidget) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(child: inputWidget),
      ],
    );
  }

  Widget _buildTextField({String? hint, String? suffixText, TextInputType? keyboardType}) {
    return SizedBox(
      height: 48,
      child: TextField(
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          suffixText: suffixText,
        ),
      ),
    );
  }

  // --- WIDGET PHỤ MỚI ĐỂ CHỌN GIỜ ---
  Widget _buildTimePicker(BuildContext context, {required bool isFrom}) {
    final time = isFrom ? _fromTime : _toTime;
    final hintText = isFrom ? 'From' : 'To';

    return InkWell(
      onTap: () => _selectTime(context, isFromTime: isFrom),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Text(
            time?.format(context) ?? hintText, // Hiển thị giờ đã chọn hoặc text gợi ý
            style: TextStyle(
              fontSize: 16,
              color: time == null ? Colors.grey.shade600 : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return SizedBox(
      height: 48,
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(),
        hint: const Text('Type'),
        value: _selectedMetricType,
        items: _healthMetricTypes.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _selectedMetricType = newValue;
          });
        },
      ),
    );
  }
}