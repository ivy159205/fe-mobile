import 'package:flutter/material.dart';
import 'health_chart.dart';
import 'dailylogentry.dart';
import 'addTarget.dart';
import 'heath_record_list.dart';
import 'chatbot.dart';
import 'login.dart';
import 'health_info_screen.dart';
import 'auth_service.dart';

class DashboardScreen extends StatelessWidget {
  final List<Map<String, String>> healthData = [
    {"title": "Heart Rate", "value": "72 bpm"},
    {"title": "Blood Pressure", "value": "120/80 mmHg"},
    {"title": "Weight", "value": "65 kg"},
    {"title": "Sleep", "value": "7.5 hours"},
    {"title": "Steps", "value": "8,500 bước"},
    {"title": "Calories", "value": "320 kcal"},
  ];

  DashboardScreen({super.key});

  void _handleButtonPress(BuildContext context, String name) {
    switch (name) {
      case "Progress Record":
        Navigator.push(context, MaterialPageRoute(builder: (_) => HealthChartScreen()));
        break;
      case "Add Daily Log":
        Navigator.push(context, MaterialPageRoute(builder: (_) => DailyLogScreen()));
        break;
      case "Add Target":
        Navigator.push(context, MaterialPageRoute(builder: (_) => AddTargetScreen()));
        break;
      case "Health Record List":
        Navigator.push(context, MaterialPageRoute(builder: (_) => HealthRecordListScreen()));
        break;
      case "Ask AI":
        Navigator.push(context, MaterialPageRoute(builder: (_) => ChatbotScreen()));
        break;
      case "My Profile":
        Navigator.push(context, MaterialPageRoute(builder: (_) => HealthInfoPage()));
        break;
      case "Dashboard":
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardScreen()));
        break;
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Confirm Logout"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop(); // Close dialog
              await AuthService.logout(context); // Proceed with logout
            },
            child: Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Health Dashboard"),
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
              onTap: () => _confirmLogout(context),
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
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: healthData.map((item) {
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
                        Text(
                          item["title"]!,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          item["value"]!,
                          style: TextStyle(fontSize: 16),
                        ),
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
