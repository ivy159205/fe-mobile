// daily_log_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyLogScreen extends StatefulWidget {
  const DailyLogScreen({super.key});

  @override
  State<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> {
  int _selectedIndex = 0;
  final List<String> _healthMetricTypes = ['Blood Pressure', 'Blood Sugar', 'Cholesterol'];
  String? _selectedMetricType;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, {required bool isFromTime}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isFromTime) {
          _fromTime = picked;
        } else {
          _toTime = picked;
        }
      });
    }
  }

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
          'Enter your daily log',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLogEntry(
                'Date',
                InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(_selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildLogEntry('Sleep', Row(
                children: [
                  Expanded(child: _buildTimePicker(context, isFrom: true)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('to'),
                  ),
                  Expanded(child: _buildTimePicker(context, isFrom: false)),
                ],
              )),
              const SizedBox(height: 16),
              _buildLogEntry('Weight', _buildTextField(suffixText: 'Kg', keyboardType: TextInputType.number)),
              const SizedBox(height: 16),
              _buildLogEntry('Exercise time', _buildTextField(suffixText: 'mins', keyboardType: TextInputType.number)),
              const SizedBox(height: 16),
              _buildLogEntry('Health metric type', _buildDropdown()),
              const SizedBox(height: 16),
              _buildLogEntry('Metric value', _buildTextField(hint: 'Value')),
              const SizedBox(height: 16),
              const TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Heart rate: ...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              _buildLogEntry('Notes', _buildTextField(hint: '')),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Submit', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.timer_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.help_outline), label: ''),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }

  Widget _buildLogEntry(String label, Widget inputWidget) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(child: inputWidget),
      ],
    );
  }

  Widget _buildTextField({String? hint, String? suffixText, TextInputType? keyboardType}) {
    return SizedBox(
      height: 48,
      child: TextField(
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          suffixText: suffixText,
        ),
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context, {required bool isFrom}) {
    final time = isFrom ? _fromTime : _toTime;
    final hintText = isFrom ? 'From' : 'To';

    return InkWell(
      onTap: () => _selectTime(context, isFromTime: isFrom),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Text(
            time?.format(context) ?? hintText,
            style: TextStyle(
              fontSize: 16,
              color: time == null ? Colors.grey.shade600 : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return SizedBox(
      height: 48,
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(),
        hint: const Text('Type'),
        value: _selectedMetricType,
        items: _healthMetricTypes.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _selectedMetricType = newValue;
          });
        },
      ),
    );
  }
}