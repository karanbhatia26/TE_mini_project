import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'workout_page.dart';

class FitnessDashboardApp extends StatelessWidget {
  const FitnessDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          elevation: 4,
          backgroundColor: Colors.blueGrey[900],
        ),
      ),
      home: const FitnessDashboard(),
    );
  }
}

class FitnessDashboard extends StatefulWidget {
  const FitnessDashboard({super.key});

  @override
  _FitnessDashboardState createState() => _FitnessDashboardState();
}

class _FitnessDashboardState extends State<FitnessDashboard> {
  late User? user;
  late DocumentReference userDoc;

  // Map for storing fetched data
  Map<String, dynamic> currentData = {};

  @override
  void initState() {
    super.initState();

    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userDoc = FirebaseFirestore.instance.collection('users').doc(user!.uid);
      _fetchUserData();
    }
  }

  // Fetch user data from Firestore
  void _fetchUserData() async {
    if (user != null) {
      final docSnapshot = await userDoc.get();
      if (docSnapshot.exists) {
        setState(() {
          currentData = docSnapshot.data() as Map<String, dynamic>;
        });
      }
    }
  }

  // Method to handle value updates
  Future<void> _updateValue(String fieldName) async {
    final newValue = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Update $fieldName'),
        content: TextField(
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(hintText: 'Enter new value'),
          onSubmitted: (input) => Navigator.pop(dialogContext, input),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, null),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (newValue != null && newValue.isNotEmpty) {
      await userDoc.update({fieldName: newValue});
      _fetchUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Dashboard'),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Header Section
            user == null
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      const CircleAvatar(
                        backgroundImage: AssetImage('assets/avatar.png'),
                        radius: 30,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hello, ${currentData['name'] ?? "User"}',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600)),
                          const Text('Keep Moving & Stay Healthy',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
            const SizedBox(height: 20),

            // Stat Cards with shadow and more padding
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                statCard(
                  currentData['sleep'] ?? '6.30 Hours',
                  'Sleep',
                  Icons.nightlight,
                  Colors.blue,
                  userDoc,
                  'sleep',
                ),
                statCard(
                  currentData['water'] ?? '5 Liters',
                  'Water',
                  Icons.water_drop,
                  Colors.teal,
                  userDoc,
                  'water',
                ),
                statCard(
                  currentData['walking'] ?? '1590 Steps',
                  'Walking',
                  Icons.directions_walk,
                  Colors.orange,
                  userDoc,
                  'walking',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Activity Chart Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                  SizedBox(height: 8),
                  BarChartWidget(),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Exercise Shortcuts Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Exercise Shortcuts',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      exerciseShortcut('Running', Icons.directions_run),
                      exerciseShortcut('Cycling', Icons.pedal_bike),
                      exerciseShortcut('Yoga', Icons.self_improvement),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Recently Performed Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Recently Performed',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: currentData['recentExercises']?.length ?? 0,
                    itemBuilder: (context, index) {
                      final exercise = currentData['recentExercises'][index];
                      return ListTile(
                        title: Text(exercise['name'],
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text(exercise['date'],
                            style: const TextStyle(color: Colors.grey)),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // New Button Section with custom styling
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WorkoutPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blueAccent, // Button color
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Start a new Exercise!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget statCard(
    String value,
    String label,
    IconData icon,
    Color iconColor,
    DocumentReference userDoc,
    String fieldName,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _updateValue(fieldName),
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: iconColor, size: 30),
              const SizedBox(height: 8),
              Text(value,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget exerciseShortcut(String label, IconData icon) {
    return GestureDetector(
      onTap: () {
        // Handle exercise shortcut tap
      },
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blueGrey[700],
            radius: 30,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class BarChartWidget extends StatelessWidget {
  const BarChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(toY: 6, color: Colors.blue, width: 12),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(toY: 8, color: Colors.red, width: 12),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(toY: 5, color: Colors.green, width: 12),
              ],
            ),
            BarChartGroupData(
              x: 3,
              barRods: [
                BarChartRodData(toY: 9, color: Colors.yellow, width: 12),
              ],
            ),
            BarChartGroupData(
              x: 4,
              barRods: [
                BarChartRodData(toY: 7, color: Colors.orange, width: 12),
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
                      return const Text('Mon',
                          style: TextStyle(color: Colors.white));
                    case 1:
                      return const Text('Tue',
                          style: TextStyle(color: Colors.white));
                    case 2:
                      return const Text('Wed',
                          style: TextStyle(color: Colors.white));
                    case 3:
                      return const Text('Thu',
                          style: TextStyle(color: Colors.white));
                    case 4:
                      return const Text('Fri',
                          style: TextStyle(color: Colors.white));
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
