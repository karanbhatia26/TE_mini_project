import 'package:flutter/material.dart';
import 'arms_workout.dart'; // Import the ArmsWorkoutPage
import 'back_workout.dart'; // Import the BackWorkoutPage
import 'chest_workout.dart'; // Import the ChestWorkoutPage
import 'legs_workout.dart'; // Import the LegsWorkoutPage
import 'core_workout.dart'; // Import the CoreWorkoutPage
import 'cardio_workout.dart'; // Import the CardioWorkoutPage

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Workouts"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Row(
              children: [
                // Arms button with navigation
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to ArmsWorkoutPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ArmsWorkoutPage(),
                        ),
                      );
                    },
                    child: WorkoutCard(
                      title: "Arms",
                      subtitle: "Biceps, Triceps, Shoulders and more",
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Chest button with navigation
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to ChestWorkoutPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChestWorkoutPage(),
                        ),
                      );
                    },
                    child: WorkoutCard(
                      title: "Chest",
                      subtitle: "Pectoralis Major, Pectoralis Minor",
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Legs button with navigation
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to LegsWorkoutPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LegsWorkoutPage(),
                        ),
                      );
                    },
                    child: WorkoutCard(
                      title: "Legs",
                      subtitle: "Quads, Hamstrings, Glutes, Calves",
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Core button with navigation
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to CoreWorkoutPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CoreWorkoutPage(),
                        ),
                      );
                    },
                    child: WorkoutCard(
                      title: "Core",
                      subtitle: "Abs, Obliques and more",
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Back button with navigation
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to BackWorkoutPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BackWorkoutPage(),
                        ),
                      );
                    },
                    child: WorkoutCard(
                      title: "Back",
                      subtitle: "Lats, Traps, Rhomboids and more",
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Cardio button with navigation
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to CardioWorkoutPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CardioWorkoutPage(),
                        ),
                      );
                    },
                    child: WorkoutCard(
                      title: "Cardio",
                      subtitle: "Heart, Lungs, Stamina and Health",
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const WorkoutCard({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black, // Black background for the card
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[700]!), // Optional border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }
}
