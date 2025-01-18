import 'package:flutter/material.dart';
import 'app_page.dart';

class ArmsWorkoutPage extends StatelessWidget {
  const ArmsWorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Arms"),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.count(
          crossAxisCount: 3, // 2 cards per row
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8, // Adjust to make cards smaller
          children: [
            DetailedWorkoutCard(
              title: "Bicep Curls",
              subtitle: "Bicep",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AppPage()),
                );
              },
            ),
            DetailedWorkoutCard(
              title: "Hammer Curls",
              subtitle: "Bicep",
              onTap: () {
              },
            ),
            DetailedWorkoutCard(
              title: "Lateral Raises",
              subtitle: "Shoulders",
              onTap: () {
              },
            ),
            DetailedWorkoutCard(
              title: "Overhead Press",
              subtitle: "Shoulders",
              onTap: () {
              },
            ),
            DetailedWorkoutCard(
              title: "Overhead Tricep Extensions",
              subtitle: "Triceps",
              onTap: () {
              },
            ),
            DetailedWorkoutCard(
              title: "Skullcrushers",
              subtitle: "Triceps",
              onTap: () {
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DetailedWorkoutCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap; // Add a callback for onTap

  const DetailedWorkoutCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap, // Require onTap parameter
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // Wrap with GestureDetector to handle taps
      onTap: onTap, 
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black, // Dark background for consistency
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 4,
            ),
          ],
        ),
        padding: const EdgeInsets.all(8), // Reduced padding for smaller cards
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14, // Reduced font size
                fontWeight: FontWeight.bold,
                color: Colors.white, // White text on dark background
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12, // Reduced font size
                color: Colors.grey[300], // Lighter grey for subtitle
              ),
            ),
          ],
        ),
      ),
    );
  }
}
