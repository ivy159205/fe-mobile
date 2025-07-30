import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

// Import các màn hình cần thiết cho việc điều hướng
import '../model/MetricType.dart';
import 'health_chart.dart';
import 'dailylogentry.dart';
import 'heath_record_list.dart';
import 'chatbot.dart';
import 'login.dart';
import 'health_info_screen.dart';
import 'dashboard.dart' as dash;

class AddTargetScreen extends StatefulWidget {
  const AddTargetScreen({super.key});

  @override
  _AddTargetScreenState createState() => _AddTargetScreenState();
}

class _AddTargetScreenState extends State<AddTargetScreen> {
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _targets = [];
  bool _isLoading = true;
  int? _userId;

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _finishDateController = TextEditingController();

  final List<MetricType> _metricTypes = [
    MetricType(id: 1, name: 'Weight'),
    MetricType(id: 2, name: 'Blood Pressure'),
    MetricType(id: 3, name: 'Heart Rate'),
    MetricType(id: 4, name: 'Temperature'),
    MetricType(id: 5, name: 'Sleep Time'),
    MetricType(id: 6, name: 'Exercise Time'),
    MetricType(id: 7, name: 'Water'),
  ];

  DateTime? _startDate;
  DateTime? _finishDate;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchTargets();
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _finishDateController.dispose();
    super.dispose();
  }

  Future<void> _loadUserIdAndFetchTargets() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      try {
        final decoded = JwtDecoder.decode(token);
        _userId = decoded['userId'];
        await _fetchTargets(token);
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
        print("❌ Error decoding token: $e");
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchTargets(String token) async {
    if (_userId == null) return;
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8286/api/targets/user/$_userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (mounted) {
      if (response.statusCode == 200) {
        setState(() {
          _targets = List<Map<String, dynamic>>.from(json.decode(response.body));
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        print('❌ Failed to fetch targets');
      }
    }
  }

  Future<void> _pickDate(TextEditingController controller, {required bool isStartDate}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
      if (isStartDate) {
        _startDate = picked;
      } else {
        _finishDate = picked;
      }
    }
  }

  // --- PHƯƠNG THỨC XÓA ---
  void _confirmDeleteTarget(int targetId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Xác nhận Xóa"),
          content: Text("Bạn có chắc chắn muốn xóa mục tiêu này không?"),
          actions: <Widget>[
            TextButton(
              child: Text("Hủy"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Xóa", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTarget(targetId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTarget(int targetId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final response = await http.delete(
      Uri.parse('http://10.0.2.2:8286/api/targets/$targetId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (mounted) {
      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa mục tiêu thành công!'), backgroundColor: Colors.green),
        );
        _loadUserIdAndFetchTargets();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa mục tiêu.'), backgroundColor: Colors.red),
        );
        print("❌ Failed to delete target: ${response.statusCode}");
      }
    }
  }


  // --- PHƯƠNG THỨC THÊM/SỬA ĐÃ NÂNG CẤP ---
  void _showAddTargetDialog({Map<String, dynamic>? targetToEdit}) {
    final bool isEditMode = targetToEdit != null;

    final titleController = TextEditingController(text: isEditMode ? targetToEdit['title'] : '');
    final statusController = TextEditingController(text: isEditMode ? targetToEdit['status'] : '');

    final details = isEditMode ? targetToEdit['details'][0] : null;
    final comparisonTypeController = TextEditingController(text: isEditMode ? details['comparisonType'] : '');
    final aggregationTypeController = TextEditingController(text: isEditMode ? details['aggregationType'] : '');
    final targetValueController = TextEditingController(text: isEditMode ? details['targetValue'].toString() : '');

    if (isEditMode && targetToEdit['startDate'] != null) {
      _startDate = DateTime.parse(targetToEdit['startDate']);
      _startDateController.text = DateFormat('yyyy-MM-dd').format(_startDate!);
    } else {
      _startDateController.clear();
      _startDate = null;
    }
    if (isEditMode && targetToEdit['endDate'] != null) {
      _finishDate = DateTime.parse(targetToEdit['endDate']);
      _finishDateController.text = DateFormat('yyyy-MM-dd').format(_finishDate!);
    } else {
      _finishDateController.clear();
      _finishDate = null;
    }

    int? selectedMetricIdInDialog = isEditMode ? details['metricId'] : null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditMode ? "Chỉnh sửa Mục tiêu" : "Thêm Mục tiêu Mới"),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter dialogSetState) {
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(controller: titleController, decoration: InputDecoration(labelText: 'Title'), validator: (v) => v!.isEmpty ? 'Title is required' : null),
                    TextFormField(controller: statusController, decoration: InputDecoration(labelText: 'Status'), validator: (v) => v!.isEmpty ? 'Status is required' : null),
                    TextFormField(
                      controller: _startDateController, readOnly: true,
                      decoration: InputDecoration(labelText: 'Start Date'),
                      onTap: () async {
                        final picked = await showDatePicker(context: context, initialDate: _startDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));
                        if(picked != null) {
                          dialogSetState(() {
                            _startDate = picked;
                            _startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
                          });
                        }
                      },
                      validator: (v) => v!.isEmpty ? 'Start date is required' : null,
                    ),
                    TextFormField(
                      controller: _finishDateController, readOnly: true,
                      decoration: InputDecoration(labelText: 'Finish Date'),
                      onTap: () async {
                        final picked = await showDatePicker(context: context, initialDate: _finishDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));
                        if(picked != null) {
                          dialogSetState(() {
                            _finishDate = picked;
                            _finishDateController.text = DateFormat('yyyy-MM-dd').format(picked);
                          });
                        }
                      },
                      validator: (v) => v!.isEmpty ? 'Finish date is required' : null,
                    ),
                    const Divider(),
                    Text("📌 Target Detail:", style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButtonFormField<int>(
                      value: selectedMetricIdInDialog,
                      decoration: InputDecoration(labelText: 'Metric Type'),
                      items: _metricTypes.map((metric) => DropdownMenuItem<int>(value: metric.id, child: Text(metric.name))).toList(),
                      onChanged: (value) => dialogSetState(() => selectedMetricIdInDialog = value),
                      validator: (value) => value == null ? 'Please select a metric type.' : null,
                    ),
                    TextFormField(controller: comparisonTypeController, decoration: InputDecoration(labelText: 'Comparison Type'), validator: (v) => v!.isEmpty ? 'Comparison type is required' : null),
                    TextFormField(
                      controller: targetValueController,
                      decoration: InputDecoration(labelText: 'Target Value'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => v!.isEmpty ? 'Target value is required' : null,
                    ),
                    TextFormField(controller: aggregationTypeController, decoration: InputDecoration(labelText: 'Aggregation Type'), validator: (v) => v!.isEmpty ? 'Aggregation type is required' : null),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('token');
                if (token == null || _userId == null) return;

                final requestBody = json.encode({
                  "title": titleController.text, "status": statusController.text,
                  "startDate": _startDate?.toIso8601String(), "endDate": _finishDate?.toIso8601String(),
                  "user": { "userId": _userId },
                  "details": [{
                    "metricId": selectedMetricIdInDialog,
                    "comparisonType": comparisonTypeController.text,
                    "targetValue": double.tryParse(targetValueController.text) ?? 0,
                    "aggregationType": aggregationTypeController.text,
                  }]
                });

                http.Response response;
                if (isEditMode) {
                  final targetId = targetToEdit['targetId'];
                  response = await http.put(
                    Uri.parse('http://10.0.2.2:8286/api/targets/$targetId'),
                    headers: { 'Authorization': 'Bearer $token', 'Content-Type': 'application/json' },
                    body: requestBody,
                  );
                } else {
                  response = await http.post(
                    Uri.parse('http://10.0.2.2:8286/api/targets'),
                    headers: { 'Authorization': 'Bearer $token', 'Content-Type': 'application/json' },
                    body: requestBody,
                  );
                }

                if (!mounted) return;

                if (response.statusCode == 200 || response.statusCode == 201) {
                  Navigator.pop(context);
                  _loadUserIdAndFetchTargets();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEditMode ? 'Cập nhật thành công!' : 'Thêm mới thành công!'), backgroundColor: Colors.green),
                  );
                } else {
                  print("❌ Failed to save target: ${response.statusCode} ${response.body}");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: ${response.body}'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: Text(isEditMode ? "Lưu" : "Thêm"),
          )
        ],
      ),
    );
  }

  Widget _buildTargetCard(Map<String, dynamic> target) {
    final String title = target['title'] ?? 'No Title';
    final String status = target['status'] ?? 'No Status';
    final String startDateStr = target['startDate'] != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(target['startDate'])) : 'N/A';
    final String endDateStr = target['endDate'] != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(target['endDate'])) : 'N/A';
    final List details = target['details'] ?? [];
    final metricNames = { for (var v in _metricTypes) v.id : v.name };
    final targetId = target['targetId'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🎯 $title", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("📅 Từ: $startDateStr  ➡  Đến: $endDateStr"),
            const SizedBox(height: 4),
            Text("📌 Trạng thái: $status", style: const TextStyle(color: Colors.blue, fontStyle: FontStyle.italic)),
            if (details.isNotEmpty) const Divider(height: 20),
            if (details.isNotEmpty) Text("🔎 Chi tiết:", style: TextStyle(fontWeight: FontWeight.bold)),
            ...details.map((item) {
              final metricId = item['metricId'];
              final metricName = metricNames[metricId] ?? 'Metric $metricId';
              final value = item['targetValue'];
              final comparison = item['comparisonType'] ?? '';
              return Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text("• $metricName: $comparison $value"),
              );
            }).toList(),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.orange.shade700),
                  onPressed: () => _showAddTargetDialog(targetToEdit: target),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red.shade700),
                  onPressed: () => _confirmDeleteTarget(targetId),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _handleButtonPress(BuildContext context, String name) {
    if (name == "Progress Record") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => HealthChartScreen()));
    } else if (name == "Add Daily Log") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => DailyLogScreen()));
    } else if (name == "Add Target") {
      // Current screen
    } else if (name == "Health Record List") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => HealthRecordListScreen()));
    } else if (name == "Ask AI") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ChatbotScreen()));
    } else if (name == "My Profile") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => HealthInfoPage()));
    } else if (name == "Logout") {
      SharedPreferences.getInstance().then((prefs) {
        prefs.remove('token');
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => LoginPage()), (route) => false);
      });
    } else if (name == "Dashboard") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => dash.DashboardScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Targets"), backgroundColor: Colors.blue),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text("User Name"),
              accountEmail: Text("user@example.com"),
              currentAccountPicture: CircleAvatar(backgroundImage: AssetImage("assets/avatar.jpg")),
              decoration: BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("My Profile"),
              onTap: () {
                Navigator.pop(context);
                _handleButtonPress(context, "My Profile");
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () {
                Navigator.pop(context);
                _handleButtonPress(context, "Logout");
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _targets.isEmpty
          ? Center(child: Text("No targets to display."))
          : ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: _targets.length,
        itemBuilder: (context, index) => _buildTargetCard(_targets[index]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTargetDialog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          color: Colors.blue.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(icon: Icon(Icons.dashboard, color: Colors.grey), onPressed: () => _handleButtonPress(context, "Dashboard")),
              IconButton(icon: Icon(Icons.bar_chart, color: Colors.grey), onPressed: () => _handleButtonPress(context, "Progress Record")),
              IconButton(icon: Icon(Icons.add, color: Colors.grey), onPressed: () => _handleButtonPress(context, "Add Daily Log")),
              IconButton(icon: Icon(Icons.alarm, color: Colors.blue), onPressed: () => _handleButtonPress(context, "Add Target")),
              IconButton(icon: Icon(Icons.list, color: Colors.grey), onPressed: () => _handleButtonPress(context, "Health Record List")),
              IconButton(icon: Icon(Icons.help, color: Colors.grey), onPressed: () => _handleButtonPress(context, "Ask AI")),
            ],
          ),
        ),
      ),
    );
  }
}