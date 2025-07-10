import 'package:flutter/material.dart';
import 'health_chart.dart'; // Đảm bảo đường dẫn này đúng với file của bạn
import 'heath_record_list.dart'; // Đảm bảo đường dẫn này đúng với file của bạn

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ứng dụng Sức khỏe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HealthChartScreen(), // Màn hình mặc định khi khởi động ứng dụng
      routes: {
        '/health_charts': (context) => const HealthChartScreen(),
        '/health_records': (context) => const HealthRecordListScreen(),
        // Bạn có thể thêm các route khác nếu cần
      },
    );
  }
}