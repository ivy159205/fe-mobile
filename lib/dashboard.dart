import 'dart:convert';

import 'package:femobile/api_config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../model/HealthRecord.dart';
import 'health_chart.dart';
import 'dailylogentry.dart';
import 'addTarget.dart';
import 'heath_record_list.dart';
import 'chatbot.dart';
import 'login.dart';
import 'health_info_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, String>>? healthData;
  int? userId;

  @override
  void initState() {
    super.initState();
    loadUserIdAndFetchData();
  }

  Future<void> loadUserIdAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    print('🔑 Token: $token');

    if (token != null) {
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        print('🧾 Decoded Token: $decodedToken');

        userId = decodedToken['userId'];
        print('👤 userId from token: $userId');

        if (userId != null) {
          await fetchTodayHealthRecords(token);
        } else {
          print("❌ userId not found in token");
        }
      } catch (e) {
        print("❌ Error decoding token: $e");
      }
    } else {
      print("❌ Token not found in SharedPreferences");
    }
  }

  Future<void> fetchTodayHealthRecords(String token) async {
    try {
      if (userId == null) return;

      print("📡 Fetching records for userId: $userId");

      final response = await http.get(
        Uri.parse('${baseUrl}/api/healthrecords/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("📥 Status code: ${response.statusCode}");
      print("📥 Body: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        List<HealthRecord> allRecords = jsonList.map((e) => HealthRecord.fromJson(e)).toList();

        String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final todayRecords = allRecords.where((e) => e.logDate.startsWith(today)).toList();

        print("📊 Records for today: ${todayRecords.length}");

        setState(() {
          healthData = todayRecords.map((record) {
            return {
              "title": record.metricName,
              "value": "${record.value} ${record.unit}"
            };
          }).toList();
        });
      } else {
        print("❌ Error loading data: ${response.statusCode}");
        setState(() {
          healthData = [];
        });
      }
    } catch (e) {
      print("❌ Exception during fetch: $e");
      setState(() {
        healthData = [];
      });
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
      Navigator.push(context, MaterialPageRoute(builder: (_) => HealthRecordListScreen()));
    } else if (name == "Ask AI") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ChatbotScreen()));
    } else if (name == "My Profile") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => HealthInfoPage()));
    } else if (name == "Logout") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
    } else if (name == "Dashboard") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Health Dashboard"), backgroundColor: Colors.blue),
      drawer: Drawer(
        child: ListView(
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
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hello, User", style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            Expanded(
              child: healthData == null
                  ? Center(child: CircularProgressIndicator())
                  : healthData!.isEmpty
                  ? Center(child: Text("No records today"))
                  : GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: healthData!.map((item) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blue.shade50,
                    ),
                    padding: EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(item["title"]!,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(item["value"]!, style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  );
                }).toList(),
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
