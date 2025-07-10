import 'package:flutter/material.dart';

void main() {
  runApp(HealthDashboardApp());
}

class HealthDashboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Dashboard',
      theme: ThemeData.light(), // Giao diện sáng
      home: DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DashboardScreen extends StatelessWidget {
  final List<Map<String, String>> healthData = [
    {"title": "Heart Rate", "value": "72 bpm"},
    {"title": "Blood Pressure", "value": "120/80 mmHg"},
    {"title": "Weight", "value": "65 kg"},
    {"title": "Sleep", "value": "7.5 hours"},
    {"title": "Steps", "value": "8,500 bước"},
    {"title": "Calories", "value": "320 kcal"},
  ];

  void _handleButtonPress(String name) {
    print("Pressed: $name");
    // TODO: Thay thế bằng chức năng thực tế
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.home),
            SizedBox(width: 10),
            Text("Logo"),
            Spacer(),
            Icon(Icons.menu),
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
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        color: Colors.blue.shade50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.analytics),
              tooltip: "Access Record",
              onPressed: () => _handleButtonPress("Access Record"),
            ),
            IconButton(
              icon: Icon(Icons.add),
              tooltip: "Add Daily Log",
              onPressed: () => _handleButtonPress("Add Daily Log"),
            ),
            IconButton(
              icon: Icon(Icons.track_changes),
              tooltip: "Add Target",
              onPressed: () => _handleButtonPress("Add Target"),
            ),
            IconButton(
              icon: Icon(Icons.list),
              tooltip: "Health Record List",
              onPressed: () => _handleButtonPress("Health Record List"),
            ),
            IconButton(
              icon: Icon(Icons.help),
              tooltip: "Ask AI",
              onPressed: () => _handleButtonPress("Ask AI"),
            ),
          ],
        ),
      ),
    );
  }
}
