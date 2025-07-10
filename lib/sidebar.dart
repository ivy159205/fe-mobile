import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: SidebarWithBottomNav(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
  ));
}

class SidebarWithBottomNav extends StatefulWidget {
  @override
  _SidebarWithBottomNavState createState() => _SidebarWithBottomNavState();
}

class _SidebarWithBottomNavState extends State<SidebarWithBottomNav> {
  bool _isDrawerOpen = false;

  void _handleMenuClick(String name) {
    print("Clicked: $name");
    Navigator.pop(context); // Đóng drawer
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
            Text("Health Charts"),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue.shade100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.person, size: 40),
                  SizedBox(height: 10),
                  Text("Hduc", style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text("AI Chatbot"),
              onTap: () => _handleMenuClick("AI Chatbot"),
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text("Add New Record"),
              onTap: () => _handleMenuClick("Add New Record"),
            ),
            ListTile(
              leading: Icon(Icons.analytics),
              title: Text("Progress Record"),
              onTap: () => _handleMenuClick("Progress Record"),
            ),
            ListTile(
              leading: Icon(Icons.track_changes),
              title: Text("Add Target"),
              onTap: () => _handleMenuClick("Add Target"),
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text("Health Record List"),
              onTap: () => _handleMenuClick("Health Record List"),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Setting"),
              onTap: () => _handleMenuClick("Setting"),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () => _handleMenuClick("Logout"),
            ),
          ],
        ),
      ),
      onDrawerChanged: (isOpened) {
        setState(() {
          _isDrawerOpen = isOpened;
        });
      },
      body: Center(
        child: Text("Welcome to Sidebar Screen", style: TextStyle(fontSize: 20)),
      ),
      bottomNavigationBar: _isDrawerOpen
          ? null
          : Container(
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
                    tooltip: "Add Log",
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.track_changes),
                    tooltip: "Add Target",
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.list),
                    tooltip: "Health Records",
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
