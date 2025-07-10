import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HealthRecordListScreen extends StatefulWidget {
  const HealthRecordListScreen({Key? key}) : super(key: key);

  @override
  State<HealthRecordListScreen> createState() => _HealthRecordListScreenState();
}

class _HealthRecordListScreenState extends State<HealthRecordListScreen> {
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy');

  final List<Map<String, String>> healthRecords = [
    {
      'date': '2025-07-01',
      'overview':
          'Nước: 2200ml, Nhịp: 72bpm\nHuyết áp: 120/80\nNgủ: 7.5 giờ, Đường: 5.6 mmol/L',
    },
    {
      'date': '2025-06-30',
      'overview': 'Heart Rate: 72 bpm',
    },
  ];

  @override
  void initState() {
    super.initState();
    _dateController.text = 'No date selected';
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime initialDate = _selectedDate ?? DateTime.now();
    final DateTime firstDate = DateTime(2000);
    final DateTime lastDate = DateTime(2030);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _dateFormat.format(picked);
      });
    }
  }

  void _clearDate() {
    setState(() {
      _selectedDate = null;
      _dateController.text = 'No date selected';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
    title: const Text('Health record list'),
    leading: IconButton(
      icon: const Icon(Icons.home),
      onPressed: () {
        // Chuyển đến trang Dashboard
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
      },
    ),
    actions: [
      Builder( // Dùng Builder để có context đúng khi gọi Drawer
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
    ],
    backgroundColor: Colors.blue,
  ),
  drawer: Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(color: Colors.blue),
          child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
        ),
        ListTile(
          leading: const Icon(Icons.dashboard),
          title: const Text('Dashboard'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.list),
          title: const Text('Health Records'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthRecordListScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.add),
          title: const Text('Add Record'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddRecordScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () {
            // Thêm trang Settings nếu có
          },
        ),
      ],
    ),
  ),
      body: SingleChildScrollView(
  padding: const EdgeInsets.all(12.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
// Filter section
Row(
  children: [
    const Icon(Icons.filter_alt, color: Colors.blue),
    const SizedBox(width: 8),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Date'),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _dateController, // controller đã khai báo ở State
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Select date',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _pickDate(context),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _clearDate,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Metric type'),
          const SizedBox(height: 4),
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter metric type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
      ),
    ),
  ],
),
      const SizedBox(height: 16),

      // Table with scroll protection
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: const [
                  SizedBox(
                    width: 100,
                    child: Text('Date',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    width: 250,
                    child: Text('Overview',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    width: 100,
                    child: Text('Action',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const Divider(),

              // Table data
              ...healthRecords.map((record) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(record['date'] ?? ''),
                        ),
                        SizedBox(
                          width: 250,
                          child: Text(
                            record['overview'] ?? '',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditRecordScreen(
                                          date: record['date'] ?? ''),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title:
                                          const Text("Confirm Delete"),
                                      content: Text(
                                          "Delete record dated ${record['date']}?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            // TODO: Implement delete logic here
                                            Navigator.pop(ctx);
                                          },
                                          child: const Text("Delete",
                                              style: TextStyle(
                                                  color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    ],
  ),
),

      bottomNavigationBar: BottomNavigationBar(
  type: BottomNavigationBarType.fixed,
  backgroundColor: Colors.blue[50], // Màu nền xanh nhạt
  selectedItemColor: Colors.blue,   // Màu xanh cho icon được chọn
  unselectedItemColor: Colors.blueGrey, 
  onTap: (index) {
    switch (index) {
      case 0:
        // Chuyển đến biểu đồ
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const DetailRecordScreen(date: '2025-07-01')));
        break;
      case 1:
        // Chuyển đến trang thêm
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddRecordScreen()));
        break;
      case 2:
        // Đồng hồ hoặc báo thức - không xử lý
        break;
      case 3:
        // Refresh lại danh sách (hiện tại)
        break;
      case 4:
        // Trợ giúp
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Help"),
            content: const Text("This is a health record management app."),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
            ],
          ),
        );
        break;
    }
  },
  items: const [
    BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: ''),
    BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: ''),
    BottomNavigationBarItem(icon: Icon(Icons.access_alarm), label: ''),
    BottomNavigationBarItem(icon: Icon(Icons.list), label: ''),
    BottomNavigationBarItem(icon: Icon(Icons.help), label: ''),
  ],
),
    );
  }
}

class AddRecordScreen extends StatelessWidget {
  const AddRecordScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Health Record")),
      body: const Center(child: Text("Add Record Page")),
    );
  }
}

// screen_edit.dart
class EditRecordScreen extends StatelessWidget {
  final String date;
  const EditRecordScreen({super.key, required this.date});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Record: $date")),
      body: const Center(child: Text("Edit Record Page")),
    );
  }
}

// screen_detail.dart
class DetailRecordScreen extends StatelessWidget {
  final String date;
  const DetailRecordScreen({super.key, required this.date});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Record Details: $date")),
      body: const Center(child: Text("Details of Record")),
    );
  }
}
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: const Center(child: Text("Welcome to Dashboard")),
    );
  }
}