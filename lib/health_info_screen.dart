import 'package:femobile/api_config.dart';
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
  // --- NEW: Controller for BMI ---
  final TextEditingController bmiController = TextEditingController();

  String selectedGender = '';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    // --- NEW: Add listeners for height and weight changes to calculate BMI ---
    heightController.addListener(_calculateBmi);
    weightController.addListener(_calculateBmi);
  }

  // --- NEW: Dispose controllers and listeners to prevent memory leaks ---
  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    heightController.removeListener(_calculateBmi);
    weightController.removeListener(_calculateBmi);
    heightController.dispose();
    weightController.dispose();
    bmiController.dispose();
    super.dispose();
  }

  // --- NEW: Function to calculate and update BMI ---
  void _calculateBmi() {
    final heightCm = double.tryParse(heightController.text);
    final weightKg = double.tryParse(weightController.text);

    if (heightCm != null && weightKg != null && heightCm > 0 && weightKg > 0) {
      final heightM = heightCm / 100; // Convert cm to meters
      final bmi = weightKg / (heightM * heightM);
      // Update the controller's text with the BMI rounded to 2 decimal places
      bmiController.text = bmi.toStringAsFixed(2);
    } else {
      // If the information is invalid, leave the BMI field empty
      bmiController.text = '';
    }
  }

  Future<void> _fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      _showMessage("You are not logged in!");
      return;
    }

    final uri = Uri.parse('${baseUrl}/api/users/me');

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
              dobController.text = DateFormat('dd MMMM yyyy', 'en_US').format(_selectedDate!);
            }
          }
        });
        // --- NEW: Calculate BMI after data is loaded successfully ---
        _calculateBmi();
      } else {
        _showMessage("Error loading user profile: ${response.statusCode}");
      }
    } catch (e) {
      _showMessage("Error connecting to the server");
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
        dobController.text = DateFormat('dd MMMM yyyy', 'en_US').format(picked);
      });
    }
  }

  Future<void> _updateUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      _showMessage("You are not logged in!");
      return;
    }

    final uri = Uri.parse('${baseUrl}/api/users/update');

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
      _showMessage("Updated successfully!", isError: false);
    } else {
      _showMessage("Update error: ${response.statusCode}");
    }
  }

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) return; // Check if the widget is still mounted
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

    if (height == null || weight == null || height <= 0 || weight <= 0 || height > 250 || weight > 150) {
      _showMessage("Height and weight must be valid numbers!");
      return;
    }

    if (selectedGender.isEmpty) {
      _showMessage("Please select a gender!");
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
            icon: const Icon(Icons.home, color: Colors.white),
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
            _buildTextField("Height (cm)", heightController, TextInputType.number),
            _buildTextField("Weight (kg)", weightController, TextInputType.number),
            // --- NEW: Widget to display BMI ---
            _buildReadOnlyField("BMI (Body Mass Index)", bmiController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveInfo,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, [TextInputType? keyboardType]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType ?? TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // --- NEW: Widget for a read-only field ---
  Widget _buildReadOnlyField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[200], // Background color to indicate it's a read-only field
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
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['M', 'F', 'O'].map((gender) {
            return ChoiceChip(
              label: Text(gender),
              selected: selectedGender == gender,
              onSelected: (_) => _selectGender(gender),
              selectedColor: Colors.blue,
              labelStyle: TextStyle(
                color: selectedGender == gender ? Colors.white : Colors.black,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}