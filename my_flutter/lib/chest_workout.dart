import 'package:flutter/material.dart';

class ChestWorkoutPage extends StatelessWidget {
  const ChestWorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chest"),
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
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 3, // Three cards per row
          crossAxisSpacing: 10, // Spacing between cards
          mainAxisSpacing: 10, // Vertical spacing
          childAspectRatio: 1.75, // Aspect ratio for smaller cards
          children: [
            DetailedWorkoutCard(
              title: "Bench Press",
              subtitle: "Chest",
              onTap: () {
                // Action for Bench Press
              },
            ),
            DetailedWorkoutCard(
              title: "Incline Bench Press",
              subtitle: "Chest",
              onTap: () {
                // Action for Incline Bench Press
              },
            ),
            DetailedWorkoutCard(
              title: "Push-Ups",
              subtitle: "Chest",
              onTap: () {
                // Action for Push-Ups
              },
            ),
            DetailedWorkoutCard(
              title: "Chest Fly",
              subtitle: "Chest",
              onTap: () {
                // Action for Chest Fly
              },
            ),
            DetailedWorkoutCard(
              title: "Chest Dips",
              subtitle: "Chest",
              onTap: () {
                // Action for Chest Dips
              },
            ),
            DetailedWorkoutCard(
              title: "Cable Chest Press",
              subtitle: "Chest",
              onTap: () {
                // Action for Cable Chest Press
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DetailedWorkoutCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const DetailedWorkoutCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<DetailedWorkoutCard> createState() => _DetailedWorkoutCardState();
}

class _DetailedWorkoutCardState extends State<DetailedWorkoutCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
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
          height: 10, // Smaller height for the card
          width: 10, // Smaller width for the card
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12), // Smaller radius
            border: Border.all(color: Colors.blueAccent, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Background image that will emerge on hover
                AnimatedOpacity(
                  opacity: _isHovered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: NetworkImage(
                            'https://via.placeholder.com/400x400'), // Add an image URL here
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 30, // Reduced font size for the title
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize:
                                  20, // Reduced font size for the subtitle
                              color: Colors.grey[300],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: widget.onTap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                              ),
                              child: const Text(
                                'Start',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
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
