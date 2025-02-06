import 'package:flutter/material.dart';
import 'welcome_page.dart';
import 'package:firebase_core/firebase_core.dart';

// Firebase configuration for web
const FirebaseOptions firebaseOptions = FirebaseOptions(
    apiKey: "AIzaSyCsnIORnivf-3xeEWLlhIIhsALbStEeOks",
    authDomain: "trackfit-e285e.firebaseapp.com",
    projectId: "trackfit-e285e",
    storageBucket: "trackfit-e285e.firebasestorage.app",
    messagingSenderId: "973473598364",
    appId: "1:973473598364:web:5891dd49f6121c45521659",
    measurementId: "G-SHZ0DVZLPP");

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase with FirebaseOptions
    await Firebase.initializeApp(options: firebaseOptions);
  } catch (e) {
    // If Firebase initialization fails, show an error screen
    runApp(MaterialApp(
      home: ErrorScreen(error: e.toString()),
      debugShowCheckedModeBanner: false,
    ));
    return;
  }

  // Firebase initialization succeeded, run the main app
  runApp(const MaterialApp(
    // Remove const here
    home: TrackFitApp(),
    debugShowCheckedModeBanner: false,
  ));
}

// Error Screen Widget
class ErrorScreen extends StatelessWidget {
  final String error;

  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Error")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 100),
            const SizedBox(height: 20),
            const Text(
              "Failed to initialize Firebase",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              "Error: $error",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Optionally, you can restart the app or close it
                // SystemNavigator.pop(); // Close app (for mobile)
              },
              child: const Text('Exit App'),
            ),
          ],
        ),
      ),
    );
  }
}
