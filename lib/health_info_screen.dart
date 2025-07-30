import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HealthInfoPage extends StatefulWidget {
  const HealthInfoPage({super.key});

  @override
  State<HealthInfoPage> createState() => _HealthInfoPageState();
}

class _HealthInfoPageState extends State<HealthInfoPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  String selectedGender = '';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // Gọi dữ liệu từ backend khi mở trang
  }

  Future<void> _fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      _showMessage("Bạn chưa đăng nhập!");
      return;
    }

    final uri = Uri.parse('http://10.0.2.2:8286/api/users/me');

    try {
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          nameController.text = data['username'] ?? '';
          selectedGender = data['gender'] ?? '';
          heightController.text = data['height']?.toString() ?? '';
          weightController.text = data['weight']?.toString() ?? '';

          if (data['dob'] != null) {
            _selectedDate = DateTime.tryParse(data['dob']);
            if (_selectedDate != null) {
              dobController.text = DateFormat('dd MMMM yyyy').format(_selectedDate!);
            }
          }
        });
      } else {
        _showMessage("Lỗi tải thông tin người dùng: ${response.statusCode}");
      }
    } catch (e) {
      _showMessage("Lỗi kết nối tới máy chủ");
    }
  }

  void _selectGender(String gender) {
    setState(() {
      selectedGender = gender;
    });
  }

  Future<void> _pickDate() async {
    final DateTime firstDate = DateTime(1950, 1, 1);
    final DateTime lastDate = DateTime(2030, 12, 31);
    final DateTime initialDate = _selectedDate ?? DateTime(2000, 1, 1);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        dobController.text = DateFormat('dd MMMM yyyy').format(picked);
      });
    }
  }

  Future<void> _updateUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      _showMessage("Bạn chưa đăng nhập!");
      return;
    }

    final uri = Uri.parse('http://10.0.2.2:8286/api/users/update');

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'username': nameController.text.trim(),
        'dob': _selectedDate?.toIso8601String().substring(0, 10),
        'gender': selectedGender,
        'height': double.tryParse(heightController.text.trim()),
        'weight': double.tryParse(weightController.text.trim()),
      }),
    );

    if (response.statusCode == 200) {
      _showMessage("Đã cập nhật thành công!", isError: false);
    } else {
      _showMessage("Lỗi cập nhật: ${response.statusCode}");
    }
  }

  void _showMessage(String message, {bool isError = true}) {
    final color = isError ? Colors.red : Colors.green;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  void _saveInfo() {
    final height = double.tryParse(heightController.text.trim());
    final weight = double.tryParse(weightController.text.trim());

    if (height == null || weight == null || height <= 0 || weight <= 0) {
      _showMessage("Chiều cao và cân nặng phải là số hợp lệ!");
      return;
    }

    if (selectedGender.isEmpty) {
      _showMessage("Vui lòng chọn giới tính!");
      return;
    }

    _updateUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Profile Detail', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/avatar.jpg'),
            ),
            const SizedBox(height: 24),
            _buildTextField("Name", nameController),
            _buildDatePickerField(),
            _buildGenderSelector(),
            _buildTextField("Height (cm)", heightController),
            _buildTextField("Weight (kg)", weightController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveInfo,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: label.contains("Height") || label.contains("Weight")
            ? TextInputType.number
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDatePickerField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: dobController,
        readOnly: true,
        decoration: const InputDecoration(
          labelText: 'Date of Birth',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        onTap: _pickDate,
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Gender',
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['M', 'F', 'O'].map(_genderChip).toList(),
        ),
      ),
    );
  }

  Widget _genderChip(String label) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedGender == label,
      onSelected: (_) => _selectGender(label),
    );
  }
}
