import 'package:flutter/material.dart';
import 'health_chart.dart';
import 'dailylogentry.dart';
import 'addTarget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chatbot.dart';
import 'package:intl/intl.dart';
import '../model/HealthRecord.dart';
import 'health_info_screen.dart';
import 'login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dashboard.dart' as dash;
import 'package:jwt_decoder/jwt_decoder.dart'; // Thêm import

class HealthRecordListScreen extends StatefulWidget {
  const HealthRecordListScreen({Key? key}) : super(key: key);

  @override
  State<HealthRecordListScreen> createState() => _HealthRecordListScreenState();
}

class _HealthRecordListScreenState extends State<HealthRecordListScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _metricController = TextEditingController();
  DateTime? _selectedDate;
  String _metricFilter = '';

  // Thay đổi: Chuyển userId thành biến state, cho phép null
  int? _userId;

  List<HealthRecord> allRecords = [];
  List<HealthRecord> healthRecords = [];
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy');

  @override
  void initState() {
    super.initState();
    // Thay đổi: Gọi hàm mới để lấy userId trước khi tải dữ liệu
    _loadUserIdAndFetchRecords();
  }

  // Thay đổi: Hàm mới để lấy token, giải mã userId, sau đó mới fetch data
  Future<void> _loadUserIdAndFetchRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      try {
        final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        setState(() {
          _userId = decodedToken['userId'];
        });

        if (_userId != null) {
          await fetchHealthRecords();
        }
      } catch (e) {
        print("Lỗi giải mã token: $e");
      }
    }
  }

  // Thay đổi: Sửa lại hàm fetchHealthRecords để dùng _userId từ state
  Future<void> fetchHealthRecords() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không thể xác thực người dùng.")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8286/api/healthrecords/user/$_userId'), // Sử dụng _userId
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      List<HealthRecord> resultList = jsonData.map((json) => HealthRecord.fromJson(json)).toList();
      setState(() {
        allRecords = resultList;
        healthRecords = List.from(allRecords); // Hiển thị tất cả ban đầu
      });
    } else {
      print('Failed to fetch health records. Status: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tải dữ liệu: ${response.statusCode}")),
      );
    }
  }

  Future<void> deleteRecord(int recordId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final url = Uri.parse('http://10.0.2.2:8286/api/healthrecords/$recordId');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      // Tải lại danh sách từ đầu để đảm bảo dữ liệu luôn đúng
      await fetchHealthRecords();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã xóa bản ghi $recordId")),
      );
    } else {
      print("Delete failed. Status: ${response.statusCode}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Xóa thất bại: ${response.statusCode}")),
      );
    }
  }

  void _handleButtonPress(BuildContext context, String name) {
    if (name == "Progress Record") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => HealthChartScreen()));
    } else if (name == "Add Daily Log") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => DailyLogScreen()));
    } else if (name == "Add Target") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => AddTargetScreen()));
    } else if (name == "Health Record List") {
      // Đã ở màn hình này
    } else if (name == "Ask AI") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ChatbotScreen()));
    } else if (name == "Dashboard") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => dash.DashboardScreen()));
    } else if (name == "My Profile") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => HealthInfoPage()));
    } else if (name == "Logout") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _dateFormat.format(picked);
      });
    }
  }

  void applyFilter() {
    setState(() {
      healthRecords = allRecords.where((record) {
        final logDate = DateTime.parse(record.logDate);

        final matchesDate = _selectedDate == null ||
            (logDate.year == _selectedDate!.year &&
                logDate.month == _selectedDate!.month &&
                logDate.day == _selectedDate!.day);

        final matchesMetric = _metricFilter.isEmpty ||
            record.metricName.toLowerCase().contains(_metricFilter);

        return matchesDate && matchesMetric;
      }).toList();
    });
  }

  void _clearDate() {
    setState(() {
      _selectedDate = null;
      _dateController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Health Record List"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text("User Name"),
              accountEmail: Text("user@example.com"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage("assets/avatar.jpg"),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filter section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 5)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Filter Records", style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 12),
                  TextField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Select Date',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                      suffixIcon: _dateController.text.isNotEmpty ? IconButton(icon: Icon(Icons.close), onPressed: _clearDate) : null,
                    ),
                    onTap: () => _pickDate(context),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _metricController,
                    decoration: InputDecoration(
                      labelText: 'Metric Type',
                      hintText: 'e.g., Weight',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.monitor_heart),
                    ),
                    onChanged: (value) => _metricFilter = value.trim().toLowerCase(),
                  ),
                  SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: ElevatedButton.icon(
                    icon: const Icon(Icons.search),
                    label: const Text("Apply Filter"),
                    onPressed: applyFilter,
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: healthRecords.isEmpty
                  ? Center(child: Text("No records found."))
                  : ListView.builder(
                itemCount: healthRecords.length,
                itemBuilder: (context, index) {
                  final record = healthRecords[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(child: Icon(Icons.favorite_border)),
                      title: Text("${record.metricName}: ${record.value} ${record.unit}"),
                      subtitle: Text(DateFormat('dd MMMM yyyy, hh:mm a').format(DateTime.parse(record.logDate))),
                      trailing: IconButton( // <-- THAY ĐỔI: Chỉ còn lại nút xóa
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Confirm Delete"),
                              content: Text("Delete record ${record.healthRecordId}?"),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    deleteRecord(record.healthRecordId);
                                  },
                                  child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
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
              IconButton(icon: Icon(Icons.list, color: Colors.blue), onPressed: () => _handleButtonPress(context, "Health Record List")), // Active
              IconButton(icon: Icon(Icons.help), onPressed: () => _handleButtonPress(context, "Ask AI")),
            ],
          ),
        ),
      ),
    );
  }
}