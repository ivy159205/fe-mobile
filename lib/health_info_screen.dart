import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    // Giá trị mặc định
    nameController.text = "John Doe";

    // Khởi tạo ngày sinh mặc định và format đẹp
    _selectedDate = DateTime(1990, 1, 1);
    dobController.text = DateFormat('dd MMMM yyyy').format(_selectedDate!);

    heightController.text = "170";
    weightController.text = "65";
    selectedGender = 'M';
  }

  void _selectGender(String gender) {
    setState(() {
      selectedGender = gender;
    });
  }

  Future<void> _pickDate() async {
    final DateTime firstDate = DateTime(2000, 1, 1);
    final DateTime lastDate = DateTime(2030, 12, 31);

    DateTime initialDate = _selectedDate ?? firstDate;
    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    } else if (initialDate.isAfter(lastDate)) {
      initialDate = lastDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        dobController.text = DateFormat('dd MMMM yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Profile Detail',
          style: TextStyle(color: Colors.white),
        ),
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
              backgroundImage: AssetImage('assets/avatar.png'),
            ),
            const SizedBox(height: 24),
            _buildTextField("Name", nameController),
            // Sửa lại TextField Date of Birth thành readonly, mở date picker khi bấm
            Padding(
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
            ),
            _buildGenderSelector(),
            _buildTextField("Height (cm)", heightController),
            _buildTextField("Weight (kg)", weightController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Xử lý lưu dữ liệu ở đây
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Saved successfully!")),
                );
              },
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
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
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
          children: [_genderChip("M"), _genderChip("F"), _genderChip("O")],
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
