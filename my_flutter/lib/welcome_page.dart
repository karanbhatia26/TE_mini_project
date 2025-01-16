import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'signup_page.dart';
import 'login_page.dart';

class TrackFitApp extends StatelessWidget {
  const TrackFitApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const TrackFitHomePage(),
    );
  }
}

class TrackFitHomePage extends StatefulWidget {
  const TrackFitHomePage({super.key});

  @override
  _TrackFitHomePageState createState() => _TrackFitHomePageState();
}

class _TrackFitHomePageState extends State<TrackFitHomePage> {
  final ScrollController _scrollController = ScrollController();

  // Scroll to top method
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  // Scroll to sections based on index
  void _scrollToSection(int sectionIndex) {
    double offset = sectionIndex * 500;
    _scrollController.animateTo(
      offset,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNavbar(),
            _buildHomePage(),
            _buildExploreOurProgramSection(),
            _buildVirtualTrainingSection(context),
            _buildTrackFitPassSection(),
            _buildFooterSection(),
          ],
        ),
      ),
    );
  }

  // Navbar with button navigation
  Widget _buildNavbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 50),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'TrackFit',
            style: TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              _buildNavButton('Home', 0),
              const SizedBox(width: 25),
              _buildNavButton('Live Workout Coach', 4),
              const SizedBox(width: 25),
              _buildNavButton('TrackFit-Pass', 5),
              const SizedBox(width: 25),
              _buildNavButton('Our Programs', 1),
              const SizedBox(width: 25),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text(
                  'Register',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Navbar Button for Navigation
  Widget _buildNavButton(String label, int sectionIndex) {
    return TextButton(
      onPressed: () {
        _scrollToSection(sectionIndex);
      },
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  // Homepage Section
  Widget _buildHomePage() {
    return Container(
      height: 500,
      padding: const EdgeInsets.symmetric(horizontal: 50),
      color: Colors.black,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'AI Meets Fitness...\nTrain Smart, Not Hard!',
                      textStyle: const TextStyle(
                        color: Colors.blue,
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                      speed: const Duration(milliseconds: 180),
                    ),
                  ],
                  repeatForever: false,
                  pause: const Duration(milliseconds: 1000),
                  displayFullTextOnTap: true,
                  stopPauseOnTap: true,
                ),
                const SizedBox(height: 20),
                const Text(
                  '"Revolutionizing the Future of Fitness, with live feedback and corrections thereby maximum Efficiency and Results".',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        'Start Training',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpScreen()),
                        );
                      },
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      label: const Text(
                        'Watch Demo',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 500,
            height: 400,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/gym_people.png'),
                fit: BoxFit.fitWidth,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          const RotatedBox(
            quarterTurns: 3,
            child: Padding(
              padding: EdgeInsets.only(top: 50),
              child: Text(
                'TrackFit',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Explore Our Program Section
  Widget _buildExploreOurProgramSection() {
    return Container(
      height: 500,
      color: Colors.black,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'Explore Our Programs',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 32,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildProgramCard('Real-Time Monitoring', Icons.fitness_center,
                  'Track your progress in real-time with accurate insights.'),
              const SizedBox(width: 30),
              _buildProgramCard('Personalized Plans', Icons.list,
                  'Get customized workout plans based on your fitness goals.'),
              const SizedBox(width: 30),
              _buildProgramCard('Live Alerts', Icons.notifications_active,
                  'Receive alerts and feedback during your workouts.'),
              const SizedBox(width: 30),
              _buildProgramCard('Nutrition Tips', Icons.restaurant,
                  'Stay on track with personalized nutrition advice.'),
              const SizedBox(width: 30),
              _buildProgramCard('Recovery Mode', Icons.healing,
                  'Optimize your recovery with guided rest periods and tips.'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgramCard(String title, IconData icon, String description) {
    return Container(
      width: 230,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.blue,
            size: 60,
          ),
          const SizedBox(height: 15),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVirtualTrainingSection(BuildContext context) {
    return Container(
      height: 600,
      color: Colors.black,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Virtual Personal Training',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFeatureCard('Chest Press', Icons.fitness_center),
              _buildFeatureCard('Squats', Icons.directions_run),
              _buildFeatureCard('Deadlifts', Icons.accessibility_new),
              _buildFeatureCard('Leg Press', Icons.account_balance),
              _buildFeatureCard('Muscle Build', Icons.build),
              _buildFeatureCard('Glute Workout', Icons.access_alarm),
            ],
          ),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFeatureCard('Lunges', Icons.directions_walk),
              _buildFeatureCard('Bicep Curls', Icons.fitness_center),
              _buildFeatureCard('Tricep Extensions', Icons.sports_kabaddi),
              _buildFeatureCard('Shoulder Press', Icons.accessibility),
              _buildFeatureCard('Abs', Icons.directions_run),
              _buildFeatureCard('Cardio', Icons.directions_bike),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignUpScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text(
              'Join Now!',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, IconData icon) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.blue,
              size: 40,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackFitPassSection() {
    return Container(
      height: 600,
      color: Colors.black,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'TrackFit Pass',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPassCard(
                title: 'Basic Package',
                price: 'Rs. 199',
                description: [
                  '5 min/day real-time tracking',
                  'Nutrition Tracking',
                  'Personalized fitness plans',
                  '3 Days per week',
                  'No real-time corrections',
                ],
              ),
              const SizedBox(width: 30),
              _buildPassCard(
                title: 'Mid Package',
                price: 'Rs. 499',
                description: [
                  '15 min/day real-time tracking',
                  'Nutrition Tracking',
                  'Personalized fitness plans',
                  '5 Days per week',
                  'Real-time Corrections',
                ],
              ),
              const SizedBox(width: 30),
              _buildPassCard(
                title: 'Pro Package',
                price: 'Rs. 999',
                description: [
                  '30 min/day real-time tracking',
                  'Nutrition Tracking',
                  'Personalized fitness plans',
                  'All days of the week',
                  'Real-time Corrections',
                ],
              ),
              const SizedBox(width: 30),
              _buildPassCard(
                title: 'Athlete Package',
                price: 'Rs. 1199',
                description: [
                  'Unlimited Real-Time Tracking',
                  'All Training Programs',
                  'Free Fitness Consultant',
                  'All days of the week',
                  'Real-time Corrections',
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassCard({
    required String title,
    required String price,
    required List<String> description,
  }) {
    return Container(
      width: 240,
      height: 400,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            spreadRadius: 2,
            blurRadius: 8,
          ),

        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            price,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'per month, billed annually',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          const SizedBox(height: 20),

          // Descriptions with Check Icons
          ...description.map(
            (text) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Register Button
          ElevatedButton(
            onPressed: () {
              // Add registration functionality
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Register Now',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  // Footer Section
  Widget _buildFooterSection() {
    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.symmetric(horizontal: 160, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row for Logo, Tagline, and Links
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.directions_bike,
                            color: Colors.blue,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'TrackFit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Highlight benefits of each exercise, both\n'
                    'physical and mental considering real-time\n'
                    'feedbacks',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sitemap',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text('About Us', style: TextStyle(color: Colors.white70)),
                  Text('Promos', style: TextStyle(color: Colors.white70)),
                  Text('News & Blog', style: TextStyle(color: Colors.white70)),
                  Text('Help Center', style: TextStyle(color: Colors.white70)),
                ],
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Support',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text('FAQ', style: TextStyle(color: Colors.white70)),
                  Text('Support Center',
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Social Media',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.instagram,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 15),
                      FaIcon(
                        FontAwesomeIcons.twitter,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 15),
                      FaIcon(
                        FontAwesomeIcons.facebook,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
