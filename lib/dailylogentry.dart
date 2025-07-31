import 'package:femobile/api_config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'health_chart.dart';
import 'addTarget.dart';
import 'heath_record_list.dart' as healthrecordlist;
import 'dashboard.dart';
import 'chatbot.dart';
import 'health_info_screen.dart';
import 'login.dart';

class DailyLogScreen extends StatefulWidget {
  const DailyLogScreen({super.key});

  @override
  State<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _exerciseController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _bloodPressureController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _sleepController = TextEditingController();
  final TextEditingController _waterController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  int? userId;
  bool _isUpdateMode = false;

  @override
  void initState() {
    super.initState();
    loadUserIdFromToken();
  }

  Future<void> loadUserIdFromToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        setState(() {
          userId = decodedToken['userId'];
        });
        print("✅ userId from token: $userId");
        await _checkExistingRecord();
      } catch (e) {
        print("❌ Error decoding token: $e");
      }
    } else {
      print("❌ Token not found");
    }
  }

  Future<void> _checkExistingRecord() async {
    if (userId == null) {
      print("⚠️ userId is null, skipping record check");
      return;
    }

    // Đầu tiên, reset form về trạng thái ban đầu
    setState(() {
      _isUpdateMode = false;
      _weightController.clear();
      _bloodPressureController.clear();
      _heartRateController.clear();
      _temperatureController.clear();
      _sleepController.clear();
      _exerciseController.clear();
      _waterController.clear();
      _notesController.clear();
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final response = await http.get(
      Uri.parse('${baseUrl}/api/healthrecords/user/$userId/log/$formattedDate'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    // Thêm điều kiện response.body.isNotEmpty
    if (response.statusCode == 200 && response.body.isNotEmpty && response.body != 'null') {
      print("🟢 API response: ${response.body}");

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> metrics = responseData['metrics'] ?? [];

      setState(() {
        _notesController.text = responseData['notes'] ?? '';

        for (var metric in metrics) {
          final String value = metric['value']?.toString() ?? ''; // An toàn hơn
          final int metricId = metric['metricId'];
          print("📊 Binding metricId=$metricId with value=$value");

          switch (metricId) {
            case 1: _weightController.text = value; break;
            case 2: _bloodPressureController.text = value; break;
            case 3: _heartRateController.text = value; break;
            case 4: _temperatureController.text = value; break;
            case 5: _sleepController.text = value; break;
            case 6: _exerciseController.text = value; break;
            case 7: _waterController.text = value; break;
          }
        }

        _isUpdateMode = true; // Chỉ bật update mode khi có dữ liệu
      });
    } else {
      print("🟡 No existing record for date $formattedDate (or empty response)");
      // Form đã được reset ở trên nên không cần làm gì ở đây nữa
    }
  }


  Future<void> _submitOrUpdateHealthRecord() async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found. Please login again.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = _isUpdateMode
        ? '${baseUrl}/api/healthrecords/by-user-date'
        : '${baseUrl}/api/healthrecords';

    final Map<String, dynamic> data = {
      'userId': userId,
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'notes': _notesController.text,
      'metrics': [
        {'metricId': 1, 'value': _weightController.text},
        {'metricId': 2, 'value': _bloodPressureController.text},
        {'metricId': 3, 'value': _heartRateController.text},
        {'metricId': 4, 'value': _temperatureController.text},
        {'metricId': 5, 'value': _sleepController.text},
        {'metricId': 6, 'value': _exerciseController.text},
        {'metricId': 7, 'value': _waterController.text},
      ]
    };

    try {
      final uri = Uri.parse(url);
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final body = jsonEncode(data);
      print('📝 Notes text: ${_notesController.text}');
      final response = _isUpdateMode
          ? await http.put(uri, headers: headers, body: body)
          : await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isUpdateMode ? 'Updated successfully' : 'Submitted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exception: $e')),
      );
    }
  }


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      await _checkExistingRecord(); // re-check on date change
    }
  }

  void _handleButtonPress(BuildContext context, String name) {
    if (name == "Progress Record") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => HealthChartScreen()));
    } else if (name == "Add Daily Log") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyLogScreen()));
    } else if (name == "Add Target") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => AddTargetScreen()));
    } else if (name == "Health Record List") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => healthrecordlist.HealthRecordListScreen()));
    } else if (name == "Ask AI") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ChatbotScreen()));
    } else if (name == "Dashboard") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardScreen()));
    } else if (name == "My Profile") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => HealthInfoPage()));
    } else if (name == "Logout") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? suffixText,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        suffixText: suffixText,
      ),
      keyboardType: TextInputType.text,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter daily log"),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text("User Name"),
              accountEmail: Text("user@example.com"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage("assets/avatar.jpg"),
              ),
              decoration: BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("My Profile"),
              onTap: () => _handleButtonPress(context, "My Profile"),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
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
                      DateFormat('dd/MM/yyyy').format(_selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildLogEntry('Weight', _buildTextField(controller: _weightController, suffixText: 'Kg')),
              _buildLogEntry('Exercise Time', _buildTextField(controller: _exerciseController, suffixText: 'Hours')),
              _buildLogEntry('Heart Rate', _buildTextField(controller: _heartRateController, suffixText: 'BPM')),
              _buildLogEntry('Blood Pressure', _buildTextField(controller: _bloodPressureController, suffixText: 'mmHg')),
              _buildLogEntry('Temperature', _buildTextField(controller: _temperatureController, suffixText: '°C')),
              _buildLogEntry('Sleep Time', _buildTextField(controller: _sleepController, suffixText: 'Hours')),
              _buildLogEntry('Water', _buildTextField(controller: _waterController, suffixText: 'L')),
              _buildLogEntry('Notes', _buildTextField(controller: _notesController)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitOrUpdateHealthRecord,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(_isUpdateMode ? 'Update' : 'Submit', style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.blue.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(icon: const Icon(Icons.dashboard), onPressed: () => _handleButtonPress(context, "Dashboard")),
              IconButton(icon: const Icon(Icons.bar_chart), onPressed: () => _handleButtonPress(context, "Progress Record")),
              IconButton(icon: const Icon(Icons.add), onPressed: () => _handleButtonPress(context, "Add Daily Log")),
              IconButton(icon: const Icon(Icons.alarm), onPressed: () => _handleButtonPress(context, "Add Target")),
              IconButton(icon: const Icon(Icons.list), onPressed: () => _handleButtonPress(context, "Health Record List")),
              IconButton(icon: const Icon(Icons.help), onPressed: () => _handleButtonPress(context, "Ask AI")),
            ],
          ),
        ),
      ),
    );
  }
}
