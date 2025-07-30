import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'dashboard.dart' as dash;
import 'dailylogentry.dart';
import 'addTarget.dart';
import 'health_info_screen.dart';
import 'heath_record_list.dart';
import 'chatbot.dart';
import 'login.dart';

class HealthChartScreen extends StatefulWidget {
  const HealthChartScreen({super.key});

  @override
  State<HealthChartScreen> createState() => _HealthChartScreenState();
}

class _HealthChartScreenState extends State<HealthChartScreen> {
  int? userId;
  String? token;
  bool isLoading = true;
  DateTime? selectedDate;
  int? selectedWeek;

  final List<String> metricNames = [
    'Weight',
    'Blood Pressure',
    'Heart Rate',
    'Temperature',
    'Sleep Time',
    'Excercise Time',
    'Water'
  ];

  Map<String, Map<String, dynamic>> metricsByDate = {'Blood Pressure': {}};

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    selectedWeek = getWeekNumber(selectedDate!);
    loadUserIdAndFetchData();
  }

  int getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysOffset = firstDayOfYear.weekday - 1;
    final firstMonday = firstDayOfYear.subtract(Duration(days: daysOffset));
    return ((date.difference(firstMonday).inDays) / 7).ceil();
  }

  Future<void> loadUserIdAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bạn chưa đăng nhập")),
      );
      return;
    }

    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
      userId = decodedToken['userId'];
      if (userId != null) {
        await fetchHealthData();
      } else {
        print("❌ userId not found in token");
      }
    } catch (e) {
      print("❌ Error decoding token: $e");
    }
  }

  Future<void> fetchHealthData() async {
    if (userId == null || token == null) return;

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8286/api/healthrecords/user/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);

      final weekDates = getCurrentWeekDates();

      metricsByDate.clear();
      for (var name in metricNames) {
        metricsByDate[name] = {
          for (var date in weekDates) date: 0.0,
        };
      }

      for (var e in jsonData) {
        final logDateStr = e['logDate'];
        if (logDateStr == null) continue;

        final date = DateTime.tryParse(logDateStr);
        if (date == null) continue;

        final formattedDate = DateFormat('yyyy-MM-dd').format(date);
        if (!weekDates.contains(formattedDate)) continue;

        void updateMetric(String key, dynamic value) {
          if (metricsByDate.containsKey(key) && value != null) {
            double? parsedValue;
            if (value is String) {
              parsedValue = double.tryParse(value);
            } else if (value is int) {
              parsedValue = value.toDouble();
            } else if (value is double) {
              parsedValue = value;
            }
            if (parsedValue != null) {
              metricsByDate[key]![formattedDate] = parsedValue;
            }
          }
        }

        final metric = e['metricName'];
        final value = e['value'];

        if (metric == 'Blood Pressure' && value != null && value is String && value.contains('/')) {
          final parts = value.split('/');
          if (parts.length == 2) {
            final sys = double.tryParse(parts[0]);
            final dia = double.tryParse(parts[1]);
            if (sys != null && dia != null) {
              metricsByDate['Blood Pressure']![formattedDate] = [sys, dia];
            }
          }
        } else {
          updateMetric(metric, value);
        }
      }

      setState(() {
        isLoading = false;
      });
    } else if (response.statusCode == 401) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Tải dữ liệu thất bại: ${response.statusCode}")),
      );
    }
  }

  List<String> getCurrentWeekDates() {
    final now = selectedDate ?? DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final formatter = DateFormat('yyyy-MM-dd');
    return List.generate(7, (i) => formatter.format(monday.add(Duration(days: i))));
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
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => dash.DashboardScreen()));
    } else if (name == "My Profile") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => HealthInfoPage()));
    } else if (name == "Logout") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
    }
  }

  Widget buildBarChart(String metricName, Map<String, dynamic> data, List<String> weekDates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(metricName, style: const TextStyle(fontSize: 16)),
        SizedBox(
          width: 650,
          height: 200,
          child: BarChart(
            BarChartData(
              barGroups: List.generate(7, (index) {
                final date = weekDates[index];
                final raw = data[date];

                if (metricName == 'Blood Pressure' && raw is List) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(toY: raw[0], color: Colors.red, width: 6),
                      BarChartRodData(toY: raw[1], color: Colors.blue, width: 6),
                    ],
                  );
                } else {
                  final value = raw is double ? raw : 0.0;
                  return BarChartGroupData(
                    x: index,
                    barRods: [BarChartRodData(toY: value, color: Colors.blue)],
                  );
                }
              }),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final date = weekDates[value.toInt()];
                      return Text(DateFormat('E').format(DateTime.parse(date)));
                    },
                  ),
                ),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
            ),
          ),
        ),
        if (metricName == 'Blood Pressure')
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(Icons.square, size: 12, color: Colors.red),
                SizedBox(width: 4),
                Text("Systolic", style: TextStyle(fontSize: 12)),
                SizedBox(width: 12),
                Icon(Icons.square, size: 12, color: Colors.blue),
                SizedBox(width: 4),
                Text("Diastolic", style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = getCurrentWeekDates();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Progress Record"),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text("Chọn tuần từ ngày: ", style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(DateTime.now().year - 1),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                          selectedWeek = getWeekNumber(pickedDate);
                          isLoading = true;
                          metricsByDate.clear();
                        });
                        await fetchHealthData();
                      }
                    },
                    child: Text(
                      selectedDate != null
                          ? 'Tuần $selectedWeek (${DateFormat('dd/MM').format(selectedDate!)})'
                          : 'Chọn ngày',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...metricNames.map((name) => buildBarChart(name, metricsByDate[name] ?? {}, weekDates)).toList(),
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
}
