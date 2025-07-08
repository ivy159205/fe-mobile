// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'heath_record_list.dart'; // Import màn hình liên quan
//
// class HealthChartScreen extends StatelessWidget {
//   const HealthChartScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final List<Map<String, dynamic>> healthData = [
//       {'date': '07/01', 'water': 2200, 'heartRate': 72, 'sleep': 7.5},
//       {'date': '06/30', 'water': 1800, 'heartRate': 76, 'sleep': 6.8},
//       {'date': '06/29', 'water': 2000, 'heartRate': 70, 'sleep': 8.0},
//     ];
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Health Charts"),
//         backgroundColor: Colors.blue,
//         leading: IconButton(
//           icon: const Icon(Icons.home),
//           onPressed: () {
//             Navigator.push(context,
//                 MaterialPageRoute(builder: (_) => const DashboardScreen()));
//           },
//         ),
//         actions: [
//           Builder(
//             builder: (context) => IconButton(
//               icon: const Icon(Icons.menu),
//               onPressed: () {
//                 Scaffold.of(context).openDrawer();
//               },
//             ),
//           ),
//         ],
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             const DrawerHeader(
//               decoration: BoxDecoration(color: Colors.blue),
//               child: Text('Menu',
//                   style: TextStyle(color: Colors.white, fontSize: 24)),
//             ),
//             ListTile(
//               leading: const Icon(Icons.dashboard),
//               title: const Text('Dashboard'),
//               onTap: () {
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (_) => const DashboardScreen()));
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.bar_chart),
//               title: const Text('Charts'),
//               onTap: () {
//                 Navigator.pop(context); // đóng drawer
//               },
//             ),
//           ],
//         ),
//       ),
//
//       /// ✅ ScrollView both directions
//       body: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: SingleChildScrollView(
//           scrollDirection: Axis.vertical,
//           padding: const EdgeInsets.all(16),
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(minWidth: 700), // Cho đủ chiều ngang
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text("💧 Water Intake (ml)", style: TextStyle(fontSize: 16)),
//                 SizedBox(
//                   width: 650,
//                   height: 200,
//                   child: BarChart(
//                     BarChartData(
//                       alignment: BarChartAlignment.spaceAround,
//                       barGroups: healthData.map((e) {
//                         return BarChartGroupData(
//                           x: healthData.indexOf(e),
//                           barRods: [
//                             BarChartRodData(
//                                 toY: e['water'].toDouble(), color: Colors.blue)
//                           ],
//                         );
//                       }).toList(),
//                       titlesData: FlTitlesData(
//                         bottomTitles: AxisTitles(
//                           sideTitles: SideTitles(
//                             showTitles: true,
//                             getTitlesWidget: (value, meta) {
//                               return Text(healthData[value.toInt()]['date']);
//                             },
//                           ),
//                         ),
//                         leftTitles: AxisTitles(
//                             sideTitles: SideTitles(showTitles: true)),
//                         topTitles: AxisTitles(
//                             sideTitles: SideTitles(showTitles: false)),
//                         rightTitles: AxisTitles(
//                             sideTitles: SideTitles(showTitles: false)),
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 24),
//                 const Text("❤️ Heart Rate (bpm)", style: TextStyle(fontSize: 16)),
//                 SizedBox(
//                   width: 650,
//                   height: 200,
//                   child: LineChart(
//                     LineChartData(
//                       lineBarsData: [
//                         LineChartBarData(
//                           spots: healthData
//                               .asMap()
//                               .entries
//                               .map((e) => FlSpot(e.key.toDouble(),
//                                   e.value['heartRate'].toDouble()))
//                               .toList(),
//                           isCurved: true,
//                           color: Colors.redAccent,
//                           dotData: FlDotData(show: true),
//                         ),
//                       ],
//                       titlesData: FlTitlesData(
//                         bottomTitles: AxisTitles(
//                           sideTitles: SideTitles(
//                             showTitles: true,
//                             getTitlesWidget: (value, meta) {
//                               return Text(healthData[value.toInt()]['date']);
//                             },
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 24),
//                 const Text("😴 Sleep Duration (hours)", style: TextStyle(fontSize: 16)),
//                 SizedBox(
//                   width: 650,
//                   height: 200,
//                   child: LineChart(
//                     LineChartData(
//                       lineBarsData: [
//                         LineChartBarData(
//                           spots: healthData
//                               .asMap()
//                               .entries
//                               .map((e) => FlSpot(
//                                   e.key.toDouble(), e.value['sleep'].toDouble()))
//                               .toList(),
//                           isCurved: true,
//                           color: Colors.green,
//                           dotData: FlDotData(show: true),
//                         ),
//                       ],
//                       titlesData: FlTitlesData(
//                         bottomTitles: AxisTitles(
//                           sideTitles: SideTitles(
//                               showTitles: true,
//                               getTitlesWidget: (value, meta) {
//                                 return Text(healthData[value.toInt()]['date']);
//                               }),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//
//       /// ✅ Bottom Navigation
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: Colors.blue[50],
//         selectedItemColor: Colors.blue,
//         unselectedItemColor: Colors.blueGrey,
//         onTap: (index) {
//           switch (index) {
//             case 0:
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (_) =>
//                           const DetailRecordScreen(date: '2025-07-01')));
//               break;
//             case 1:
//               Navigator.push(context,
//                   MaterialPageRoute(builder: (_) => const AddRecordScreen()));
//               break;
//             case 3:
//               Navigator.push(context,
//                   MaterialPageRoute(builder: (_) => const HealthRecordListScreen()));
//               break;
//             case 4:
//               showDialog(
//                 context: context,
//                 builder: (_) => AlertDialog(
//                   title: const Text("Help"),
//                   content: const Text("This screen shows charts from your health data."),
//                   actions: [
//                     TextButton(
//                         onPressed: () => Navigator.pop(context),
//                         child: const Text("OK"))
//                   ],
//                 ),
//               );
//               break;
//           }
//         },
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: ''),
//           BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: ''),
//           BottomNavigationBarItem(icon: Icon(Icons.access_alarm), label: ''),
//           BottomNavigationBarItem(icon: Icon(Icons.list), label: ''),
//           BottomNavigationBarItem(icon: Icon(Icons.help), label: ''),
//         ],
//       ),
//     );
//   }
// }
