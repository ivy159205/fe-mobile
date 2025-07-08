// main.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Cần cho DailyLogScreen

// Import tất cả các màn hình của bạn
import 'health_record_list_screen.dart';
import 'daily_log_screen.dart';
import 'chatbot_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthcare App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Theme cho InputDecoration để áp dụng cho cả ứng dụng
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 16.0,
          ),
        ),
      ),
      // Định nghĩa các routes cho ứng dụng
      initialRoute: '/', // Màn hình khởi đầu
      routes: {
        '/': (context) => const HealthRecordListScreen(), // Màn hình danh sách hồ sơ là màn hình chính
        '/health_records': (context) => const HealthRecordListScreen(),
        '/daily_log': (context) => const DailyLogScreen(),
        '/chatbot': (context) => const ChatbotScreen(),
        // Đảm bảo các màn hình phụ cũng có route nếu bạn muốn điều hướng đến chúng trực tiếp
        '/add_record': (context) => const AddRecordScreen(),
        // Lưu ý: EditRecordScreen và DetailRecordScreen cần tham số, nên tốt nhất là push MaterialPageRoute trực tiếp
        // Thay vì sử dụng pushNamed cho các màn hình này nếu chúng yêu cầu đối số.
        '/dashboard': (context) => const DashboardScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}