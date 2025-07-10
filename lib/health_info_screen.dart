import 'package:flutter/material.dart';

class HealthInfoPage extends StatelessWidget {
  const HealthInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Information')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow("Height", "170 cm"),
            _buildInfoRow("Weight", "65 kg"),
            _buildInfoRow("Blood Pressure", "120/80"),
            _buildInfoRow("Heart Rate", "72 bpm"),
            _buildInfoRow("BMI", "22.5"),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
