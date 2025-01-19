import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:dio/dio.dart';

class WebcamProcessor {
  html.VideoElement? videoElement;
  html.MediaRecorder? mediaRecorder;
  List<html.Blob> recordedChunks = [];
  Timer? processingTimer;
  final Function(Map<String, dynamic>) onFeedback;
  final Duration processInterval = Duration(seconds: 3);
  
  WebcamProcessor({required this.onFeedback});

  void startProcessing() {
    videoElement = html.VideoElement()
      ..width = 480
      ..height = 360
      ..autoplay = true;

    html.window.navigator.mediaDevices?.getUserMedia({
      'video': {
        'width': 480,
        'height': 360,
        'frameRate': {'ideal': 30}
      }
    }).then((stream) {
      videoElement!.srcObject = stream;
      startRecording(stream);
      
      processingTimer = Timer.periodic(processInterval, (timer) {
        stopAndProcessRecording();
      });
    });
  }

  void startRecording(html.MediaStream stream) {
    recordedChunks = [];
    final options = {'mimeType': 'video/webm;codecs=vp8'};
    
    mediaRecorder = html.MediaRecorder(stream, options);
    mediaRecorder!.addEventListener('dataavailable', (event) {
      if (event is html.BlobEvent) {
        recordedChunks.add(event.data!);
      }
    });
    
    mediaRecorder!.start();
  }

  Future<void> stopAndProcessRecording() async {
    if (mediaRecorder?.state == 'recording') {
      mediaRecorder!.stop();
      
      await Future.delayed(Duration(milliseconds: 100));
      
      if (recordedChunks.isNotEmpty) {
        final blob = html.Blob(recordedChunks, 'video/webm');
        await sendToServer(blob);
      }
      
      mediaRecorder!.start();
      recordedChunks = [];
    }
  }

  Future<void> sendToServer(html.Blob videoBlob) async {
    try {
      final data = FormData();
      final bytes = await blobToBytes(videoBlob);
      
      data.files.add(MapEntry(
        'video',
        MultipartFile.fromBytes(bytes, filename: 'exercise.webm')
      ));

      final dio = Dio();
      final response = await dio.post(
        'http://localhost:5000/process-exercise',
        data: data,
      );

      if (response.statusCode == 200) {
        onFeedback(response.data);
      }
    } catch (e) {
      print('Error sending video to server: $e');
    }
  }

  Future<List<int>> blobToBytes(html.Blob blob) async {
    final completer = Completer<List<int>>();
    final reader = html.FileReader();
    
    reader.onLoadEnd.listen((e) {
      final bytes = (reader.result as List<int>);
      completer.complete(bytes);
    });
    
    reader.readAsArrayBuffer(blob);
    return completer.future;
  }

  void dispose() {
    processingTimer?.cancel();
    mediaRecorder?.stop();
    videoElement?.srcObject?.getTracks().forEach((track) => track.stop());
  }
}
// ... [Keep the WebcamProcessor class as is] ...

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  _AppPageState createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  late VideoPlayerController _controller;
  late WebcamProcessor _webcamProcessor;
  bool _webcamStarted = false;
  bool _isProcessing = false;
  String _feedback = '';
  double _similarity = 0.0;
  static const String viewType = 'videoElement';

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/videoplayback.mp4')
      ..initialize().then((_) {
        setState(() {
          _controller.setLooping(true);
        });
      });

    _webcamProcessor = WebcamProcessor(
      onFeedback: (results) {
        setState(() {
          _similarity = results['average_similarity'] ?? 0.0;
          _feedback = _generateFeedback(results);
          _isProcessing = false;
        });
      },
    );

    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      return _webcamProcessor.videoElement ?? html.VideoElement();
    });
  }

  String _generateFeedback(Map<String, dynamic> results) {
    final similarity = results['average_similarity'] ?? 0.0;
    final maxDelay = results['max_delay'] ?? 0;
    final idealCalories = results['ideal_calories'] ?? 0.0;
    final actualCalories = results['actual_calories'] ?? 0.0;
    
    String feedback = '';
    if (similarity < 0.7) {
      feedback += 'Try to match the trainer\'s form more closely. ';
    }
    if (maxDelay > 10) {
      feedback += 'You\'re falling behind, try to keep up with the pace. ';
    }
    
    feedback += '\nCalories burned: ${actualCalories.toStringAsFixed(1)} kcal ';
    feedback += '(Ideal: ${idealCalories.toStringAsFixed(1)} kcal)';
    
    return feedback.isEmpty ? 'Good job! Keep it up!' : feedback;
  }

  Widget _buildWebcamSection() {
    return Column(
      children: [
        Container(
          width: 480,
          height: 360,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _webcamStarted
              ? const HtmlElementView(viewType: viewType)
              : const Center(child: Text('Press Start Webcam')),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _webcamStarted ? null : () {
            setState(() {
              _webcamStarted = true;
              _webcamProcessor.startProcessing();
            });
          },
          child: Text(_webcamStarted ? 'Webcam Active' : 'Start Webcam'),
        ),
      ],
    );
  }

  Widget _buildVideoSection() {
    return Column(
      children: [
        Container(
          width: 480,
          height: 360,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : const Center(child: CircularProgressIndicator()),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            setState(() {
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
            });
          },
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
      ],
    );
  }

  Widget _buildControlSection() {
    return _isProcessing
        ? const CircularProgressIndicator()
        : ElevatedButton(
            onPressed: _webcamStarted ? () {} : null,
            child: const Text('Analyze Exercise'),
          );
  }

  Widget _buildFeedbackSection() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'Exercise Feedback',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(_feedback),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _similarity,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              _similarity >= 0.7 ? Colors.green : Colors.orange,
            ),
          ),
          Text('Form Accuracy: ${(_similarity * 100).toStringAsFixed(1)}%'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TrackFit - Exercise Tracking'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildWebcamSection(),
                _buildVideoSection(),
              ],
            ),
            const SizedBox(height: 20),
            _buildControlSection(),
            if (_feedback.isNotEmpty) 
              _buildFeedbackSection(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _webcamProcessor.dispose();
    super.dispose();
  }
}