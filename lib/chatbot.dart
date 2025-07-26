import 'package:flutter/material.dart';
import 'health_chart.dart';
import 'dailylogentry.dart';
import 'addTarget.dart';
import 'health_info_screen.dart';
import 'heath_record_list.dart';
import 'dashboard.dart' as dashboard;
import 'login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthcare Chatbot UI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ChatbotScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Lớp model đơn giản để chứa dữ liệu tin nhắn
class ChatMessage {
  final String text;
  final bool isSentByMe;

  ChatMessage({required this.text, required this.isSentByMe});
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  int _selectedIndex = 0;
  final TextEditingController _textController = TextEditingController();

  // Danh sách tin nhắn mẫu để hiển thị
  final List<ChatMessage> _messages = [
    ChatMessage(text: "Hello! How can I help you today?", isSentByMe: false),
    ChatMessage(text: "I have a headache.", isSentByMe: true),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- AppBar ---
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Ask AI"),
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

      // --- Body ---
      body: Column(
        children: [
          // --- Khu vực hiển thị tin nhắn ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(
                  message: message.text,
                  isSentByMe: message.isSentByMe,
                );
              },
            ),
          ),
          // --- Khu vực nhập liệu ---
          _buildInputArea(),
        ],
      ),

      // --- BottomNavigationBar ---
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

  // Widget cho khu vực nhập liệu ở dưới cùng
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image_outlined, color: Colors.grey),
            onPressed: () {
              // Xử lý đính kèm ảnh
            },
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Type here',
                border: InputBorder.none, // Bỏ đường viền mặc định
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: () {
              // Xử lý gửi tin nhắn
            },
          ),
        ],
      ),
    );
  }
}

// Widget tùy chỉnh cho bong bóng chat
class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSentByMe;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isSentByMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      // Căn chỉnh tin nhắn sang trái hoặc phải
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSentByMe ? Colors.blue : Colors.grey.shade300,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isSentByMe ? 16 : 0),
            bottomRight: Radius.circular(isSentByMe ? 0 : 16),
          ),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isSentByMe ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}