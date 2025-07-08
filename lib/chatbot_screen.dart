// chatbot_screen.dart
import 'package:flutter/material.dart';

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

  final List<ChatMessage> _messages = [
    ChatMessage(text: "Hello! How can I help you today?", isSentByMe: false),
    ChatMessage(text: "I have a headache.", isSentByMe: true),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.home_outlined, color: Colors.blue),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/health_records', (route) => false);
          },
        ),
        title: const Text(
          'Healthcare chatbot',
          style: TextStyle(color: Colors.black87, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.blue),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
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
          _buildInputArea(),
        ],
      ),
      // Trong chatbot_screen.dart, tìm BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: 'Daily Log'), // Ví dụ Daily Log
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Add'), // Ví dụ Add Record
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: 'Alarm'), // Ví dụ Alarm
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), label: 'Records'), // Health Records
          BottomNavigationBarItem(icon: Icon(Icons.help_outline), label: 'Chatbot'), // Chatbot (đang ở đây)
        ],
        currentIndex: 4, // Đặt chỉ số hiện tại cho Chatbot nếu đây là trang chính cho item này
        onTap: (index) {
          if (index == 0) { // Daily Log
            Navigator.pushNamed(context, '/daily_log');
          } else if (index == 3) { // Health Records
            Navigator.pushNamed(context, '/health_records');
          } else if (index == 4) {
            // Đã ở màn hình Chatbot, không làm gì hoặc refresh
          }
          // Cập nhật _selectedIndex nếu bạn muốn icon được chọn sáng lên
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }

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
                border: InputBorder.none,
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