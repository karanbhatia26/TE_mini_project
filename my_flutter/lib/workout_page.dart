import 'package:flutter/material.dart';
import 'arms_workout.dart'; // Import the ArmsWorkoutPage
import 'back_workout.dart'; // Import the BackWorkoutPage
import 'chest_workout.dart'; // Import the ChestWorkoutPage
import 'legs_workout.dart'; // Import the LegsWorkoutPage
import 'core_workout.dart'; // Import the CoreWorkoutPage
import 'cardio_workout.dart'; // Import the CardioWorkoutPage

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Workouts"),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.blue[300]),
            onPressed: () {
              // Add settings action
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Three cards per row
            crossAxisSpacing: 40, // Very reduced spacing
            mainAxisSpacing: 25, // Very reduced vertical spacing
            childAspectRatio: 1.5, // Adjusted for very small height
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return _WorkoutCard(
              title: _getWorkoutTitle(index),
              subtitle: _getWorkoutSubtitle(index),
              imagePath: _getImagePath(index),
              destinationPage: _getDestinationPage(index),
            );
          },
        ),
      ),
    );
  }

  String _getWorkoutTitle(int index) {
    switch (index) {
      case 0:
        return "Arms";
      case 1:
        return "Chest";
      case 2:
        return "Legs";
      case 3:
        return "Core";
      case 4:
        return "Back";
      default:
        return "Cardio";
    }
  }

  String _getWorkoutSubtitle(int index) {
    switch (index) {
      case 0:
        return "Biceps, Triceps";
      case 1:
        return "Pectorals";
      case 2:
        return "Quads, Hamstrings";
      case 3:
        return "Abs, Obliques";
      case 4:
        return "Lats, Traps";
      default:
        return "Cardio";
    }
  }

  String _getImagePath(int index) {
    switch (index) {
      case 0:
        return 'assets/arms.jpeg';
      case 1:
        return 'assets/chest.png';
      case 2:
        return 'assets/legs.png';
      case 3:
        return 'assets/core.png';
      case 4:
        return 'assets/back.png';
      default:
        return 'assets/cardio.png';
    }
  }

  Widget _getDestinationPage(int index) {
    switch (index) {
      case 0:
        return const ArmsWorkoutPage();
      case 1:
        return const ChestWorkoutPage();
      case 2:
        return const LegsWorkoutPage();
      case 3:
        return const CoreWorkoutPage();
      case 4:
        return const BackWorkoutPage();
      default:
        return const CardioWorkoutPage();
    }
  }
}

class _WorkoutCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final Widget destinationPage;

  const _WorkoutCard({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.destinationPage,
  });

  @override
  State<_WorkoutCard> createState() => _WorkoutCardState();
}

class _WorkoutCardState extends State<_WorkoutCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return widget.destinationPage;
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(position: offsetAnimation, child: child);
            },
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() {
          _isHovered = true;
        }),
        onExit: (_) => setState(() {
          _isHovered = false;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 10, // Extremely reduced height
          width: 30, // Reduced width
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(5), // Very small radius
            border: Border.all(
                color: Colors.blueAccent, width: 1.0), // Thinner border
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1), // Lighter shadow
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Stack(
              children: [
                AnimatedOpacity(
                  opacity: _isHovered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(widget.imagePath),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding:
                          const EdgeInsets.all(2.0), // Very reduced padding
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 40, // Extremely reduced font size
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize: 30, // Extremely reduced font size
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
