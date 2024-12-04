import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  _AppPageState createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  late VideoPlayerController _controller;
  bool _webcamStarted = false;
  static const String viewType = 'videoElement';

  @override
  void initState() {
    super.initState();

    // Initialize the video player
    _controller = VideoPlayerController.asset('assets/videos/videoplayback.mp4')
      ..initialize().then((_) {
        setState(() {
          _controller.setLooping(true);
        });
      });

    // Register the viewType for the webcam only once
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      return _createVideoElement();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TrackFit - App Page')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _webcamStarted = true;
                });
              },
              child: const Text('Start Webcam'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Webcam
                Container(
                  width: 480, // Adjust dimensions
                  height: 360,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                  ),
                  child: _webcamStarted
                      ? const HtmlElementView(viewType: viewType)
                      : const Center(child: Text('Press Start Webcam')),
                ),
                // Video
                Container(
                  width: 480, // Adjust dimensions
                  height: 360,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                  ),
                  child: _controller.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        )
                      : const Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_controller.value.isInitialized) {
                  _controller.play();
                }
              },
              child: const Text('Play Video'),
            ),
          ],
        ),
      ),
    );
  }

  // Method to create the webcam element
  html.VideoElement _createVideoElement() {
    final videoElement = html.VideoElement()
      ..width = 480 // Adjust dimensions
      ..height = 360
      ..autoplay = true
      ..controls = false; // Hide native controls

    // Access the webcam
    html.window.navigator.mediaDevices?.getUserMedia({'video': true}).then((stream) {
      videoElement.srcObject = stream;
    }).catchError((error) {
      debugPrint('Error accessing webcam: $error');
    });

    return videoElement;
  }
}
