import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    // Giả sử giá trị mặc định
    nameController.text = "John Doe";
    dobController.text = "1990-01-01";
    heightController.text = "170";
    weightController.text = "65";
    selectedGender = 'M';
  }

  void _selectGender(String gender) {
    setState(() {
      selectedGender = gender;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Profile Detail', style:TextStyle(color: Colors.white)),
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
            _buildTextField("Date of Birth", dobController),
            _buildGenderSelector(),
            _buildTextField("Height (cm)", heightController),
            _buildTextField("Weight (kg)", weightController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Bạn có thể xử lý lưu ở đây
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
