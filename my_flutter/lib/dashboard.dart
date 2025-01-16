import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Import the fl_chart package
import 'app_page.dart';
import 'workout_page.dart';

class FitnessDashboardApp extends StatelessWidget {
  const FitnessDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const FitnessDashboard(),
    );
  }
}

class FitnessDashboard extends StatelessWidget {
  const FitnessDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Dashboard'),
        backgroundColor: Colors.grey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Header Section
            const Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage('assets/avatar.png'), // Add avatar
                  radius: 30,
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello, Gilbert', style: TextStyle(fontSize: 18)),
                    Text('Keep Moving & Stay Healthy', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                Spacer(),
                Text('18 August 2020', style: TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),

            // Stat Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                statCard('6.30 Hours', 'Sleep', Icons.nightlight, Colors.blue),
                statCard('5 Liters', 'Water', Icons.water_drop, Colors.teal),
                statCard('1590 Steps', 'Walking', Icons.directions_walk, Colors.orange),
              ],
            ),
            const SizedBox(height: 16),

            // Activity Chart Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  BarChartWidget(), // Add BarChartWidget
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Map Section (Placeholder for now)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Running Map', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Placeholder(fallbackHeight: 150, color: Colors.grey), // Replace with Map widget later
                ],
              ),
            ),
            const SizedBox(height: 16),

            // New Button Section
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AppPage()),
                  );
                },
                child: const Text('Go to App Page'),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WorkoutPage()),
                  );
                },
                child: const Text('Start a new Exercise!'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget statCard(String value, String label, IconData icon, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class BarChartWidget extends StatelessWidget {
  const BarChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(toY: 6, color: Colors.blue, width: 10),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(toY: 8, color: Colors.red, width: 10),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(toY: 5, color: Colors.green, width: 10),
              ],
            ),
            BarChartGroupData(
              x: 3,
              barRods: [
                BarChartRodData(toY: 9, color: Colors.yellow, width: 10),
              ],
            ),
            BarChartGroupData(
              x: 4,
              barRods: [
                BarChartRodData(toY: 7, color: Colors.orange, width: 10),
              ],
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0:
                      return const Text('Mon', style: TextStyle(color: Colors.white));
                    case 1:
                      return const Text('Tue', style: TextStyle(color: Colors.white));
                    case 2:
                      return const Text('Wed', style: TextStyle(color: Colors.white));
                    case 3:
                      return const Text('Thu', style: TextStyle(color: Colors.white));
                    case 4:
                      return const Text('Fri', style: TextStyle(color: Colors.white));
                    default:
                      return const Text('');
                  }
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
