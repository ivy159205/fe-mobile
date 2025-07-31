import 'package:flutter/material.dart';
import 'chatbot_service.dart';

// Các file điều hướng khác của bạn
// Đảm bảo rằng bạn đã tạo các file này trong dự án của mình
import 'health_chart.dart';
import 'dailylogentry.dart';
import 'addTarget.dart';
import 'health_info_screen.dart';
import 'heath_record_list.dart';
import 'dashboard.dart' as dashboard;
import 'login.dart';

// Lớp model cho tin nhắn
// Bạn có thể giữ lớp này ở đây hoặc chuyển nó sang một file riêng
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
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Lấy thực thể (instance) duy nhất của ChatbotService để lưu trữ chat
  final ChatbotService _chatbotService = ChatbotService();

  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Hàm xử lý khi người dùng gửi tin nhắn
  void _handleSendPressed() async {
    final text = _textController.text;
    if (text.isEmpty || _isLoading) return;

    final userMessage = ChatMessage(text: text, isSentByMe: true);
    _textController.clear();

    // Cập nhật UI ngay lập tức với tin nhắn của người dùng
    setState(() {
      _chatbotService.messages.add(userMessage);
      _isLoading = true;
    });
    _scrollToBottom();

    // Gọi service để xử lý và nhận phản hồi từ AI
    await _chatbotService.sendMessage(text);

    // Cập nhật UI lần nữa với phản hồi từ AI
    setState(() {
      _isLoading = false;
    });
    _scrollToBottom();
  }

  // Hàm tự động cuộn xuống tin nhắn mới nhất
  void _scrollToBottom() {
    // Đợi một chút để ListView cập nhật xong rồi mới cuộn
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Hàm xử lý điều hướng cho các nút bấm
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
      // Không cần làm gì vì đã ở màn hình này
    } else if (name == "Dashboard") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => dashboard.DashboardScreen()));
    } else if (name == "My Profile") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => HealthInfoPage()));
    } else if (name == "Logout") {
      _chatbotService.clearChatHistory();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- AppBar ---
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Ask AI"),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),

      // --- Drawer (Menu bên) ---
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text("User Name"),
              accountEmail: Text("user@example.com"),
              currentAccountPicture: CircleAvatar(
                // Bạn có thể thay bằng NetworkImage nếu ảnh từ internet
                backgroundImage: AssetImage("assets/avatar.jpg"),
              ),
              decoration: BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("My profile"),
              onTap: () => _handleButtonPress(context, "My Profile"),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Log out"),
              onTap: () => _handleButtonPress(context, "Logout"),
            ),
          ],
        ),
      ),

      // --- Thân ứng dụng ---
      body: Column(
        children: [
          // Khu vực hiển thị danh sách tin nhắn
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              // Lấy danh sách tin nhắn từ service
              itemCount: _chatbotService.messages.length,
              itemBuilder: (context, index) {
                final message = _chatbotService.messages[index];
                return ChatBubble(
                  message: message.text,
                  isSentByMe: message.isSentByMe,
                );
              },
            ),
          ),
          // Hiển thị bong bóng "..." khi đang chờ AI trả lời
          if (_isLoading)
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: ChatBubble(message: '...', isSentByMe: false),
              ),
            ),
          // Khu vực nhập liệu
          _buildInputArea(),
        ],
      ),

      // --- Bottom Navigation Bar ---
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
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

  // Widget cho khu vực nhập liệu
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration.collapsed(
                hintText: 'Type everything...',
              ),
              // Gửi tin nhắn khi nhấn enter trên bàn phím
              onSubmitted: _isLoading ? null : (value) => _handleSendPressed(),
            ),
          ),
          // Nút gửi tin nhắn
          IconButton(
            icon: _isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.send, color: Colors.blue),
            // Vô hiệu hóa nút khi đang chờ
            onPressed: _isLoading ? null : _handleSendPressed,
          ),
        ],
      ),
    );
  }
}

// --- Widget để hiển thị bong bóng chat ---
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
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          // Màu sắc của bong bóng chat
          color: isSentByMe ? Colors.blue : Colors.grey.shade200,
          // Bo góc cho đẹp
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isSentByMe ? 20 : 0),
            bottomRight: Radius.circular(isSentByMe ? 0 : 20),
          ),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isSentByMe ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}