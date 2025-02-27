import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart'; // Add this import for MediaType
import 'results_page.dart';

class WebcamProcessor {
  html.VideoElement? videoElement;
  html.MediaRecorder? mediaRecorder;
  List<html.Blob> recordedChunks = [];
  Timer? processingTimer;
  final Function(Map<String, dynamic>) onFeedback;
  final Duration processInterval = const Duration(seconds: 3);

  WebcamProcessor({required this.onFeedback});

  void startProcessing() {
    videoElement = html.VideoElement()
      ..style.width = '480px'
      ..style.height = '360px'
      ..style.objectFit = 'cover'
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
    }).catchError((error) {
      print('Error accessing webcam: $error');
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

      await Future.delayed(const Duration(milliseconds: 100));

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
      
      print('Preparing to send video of size: ${bytes.length} bytes');
      
      data.files.add(MapEntry(
        'video', 
        MultipartFile.fromBytes(
          bytes,
          filename: 'exercise.webm',
          contentType: MediaType('video', 'webm'), // Now MediaType will be recognized
        )
      ));

      final dio = Dio()
        ..options.connectTimeout = const Duration(seconds: 60)
        ..options.receiveTimeout = const Duration(seconds: 60);
      
      print('Sending request to server...');
      final response = await dio.post(
        'http://localhost:5000/process-exercise',
        data: data,
        options: Options(
          validateStatus: (status) => true, // Accept all status codes
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      print('Server response status: ${response.statusCode}');
      print('Server response data: ${response.data}');

      if (response.statusCode == 200) {
        onFeedback(response.data);
      } else {
        final errorMessage = response.data is Map 
            ? response.data['error'] ?? 'Unknown server error'
            : 'Unknown server error';
        throw Exception('Server error: ${response.statusCode} - $errorMessage');
      }
    } catch (e) {
      print('Error sending video to server: $e');
      onFeedback({
        'error': e.toString(),
        'average_similarity': 0.0,
        'max_delay': 0,
        'ideal_calories': 0.0,
        'actual_calories': 0.0,
      });
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

  int _selectedDuration = 60; // Default 60 seconds
  bool _isTimerActive = false;
  Timer? _exerciseTimer;
  int _remainingTime = 0;
  List<Map<String, dynamic>> _resultsList = [];

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
        if (mounted) { // Add this check
          setState(() {
            _similarity = results['average_similarity'] ?? 0.0;
            _feedback = _generateFeedback(results);
            _isProcessing = false;
            
            // Add to results list for aggregation
            if (_isTimerActive) {
              _resultsList.add(results);
            }
          });
        }
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
          clipBehavior: Clip.antiAlias,
          child: _webcamStarted
              ? const HtmlElementView(viewType: viewType)
              : const Center(child: Text('Press Start Webcam')),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _webcamStarted
              ? null
              : () {
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
            onPressed: _webcamStarted 
                ? () async {
                    setState(() => _isProcessing = true);
                    try {
                      await _webcamProcessor.stopAndProcessRecording();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    } finally {
                      if (mounted) setState(() => _isProcessing = false);
                    }
                  }
                : null,
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

  Widget _buildTimerSection() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exercise Timer',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _isTimerActive
                ? _buildActiveTimer()
                : _buildDurationSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSelector() {
    return Column(
      children: [
        Text('Select exercise duration:'),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [30, 60, 120, 180].map((seconds) {
            final isSelected = _selectedDuration == seconds;
            final minutes = seconds ~/ 60;
            final remainingSecs = seconds % 60;
            final label = remainingSecs == 0
                ? '$minutes min'
                : '$minutes:${remainingSecs.toString().padLeft(2, '0')}';
            
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedDuration = seconds;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _webcamStarted ? _startExerciseTimer : null,
          child: const Text('Start Exercise Timer'),
        ),
      ],
    );
  }

  Widget _buildActiveTimer() {
    final minutes = _remainingTime ~/ 60;
    final seconds = _remainingTime % 60;
    
    return Column(
      children: [
        Text(
          'Time Remaining',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: _remainingTime / _selectedDuration,
          minHeight: 10,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(
            _remainingTime < 10 ? Colors.red : Colors.blue,
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            _exerciseTimer?.cancel();
            setState(() {
              _isTimerActive = false;
            });
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  void _startExerciseTimer() {
    setState(() {
      _isTimerActive = true;
      _remainingTime = _selectedDuration;
      _resultsList = [];
    });
    
    _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime--;
      });
      
      if (_remainingTime <= 0) {
        _endExercise();
      }
    });
  }

  void _endExercise() {
    _exerciseTimer?.cancel();
    
    // Calculate aggregate results
    if (_resultsList.isEmpty) {
      _resultsList.add({
        'average_similarity': 0.0,
        'max_delay': 0,
        'ideal_calories': 0.0,
        'actual_calories': 0.0,
        'flow_similarity': 0.0,
      });
    }
    
    // Calculate average of all results
    final aggregatedResults = <String, dynamic>{};
    final metrics = ['average_similarity', 'max_delay', 'ideal_calories', 
                     'actual_calories', 'flow_similarity'];
    
    for (final metric in metrics) {
      if (metric == 'max_delay') {
        // For max_delay, take the maximum value
        final values = _resultsList.map((r) => r[metric] ?? 0).toList();
        aggregatedResults[metric] = values.reduce((a, b) => a > b ? a : b);
      } else {
        // For other metrics, take the average
        final values = _resultsList.map((r) => r[metric] ?? 0.0).toList();
        final sum = values.reduce((a, b) => a + b);
        aggregatedResults[metric] = sum / values.length;
      }
    }
    
    // Stop webcam recording
    _webcamProcessor.dispose();
    
    // Navigate to results page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResultsPage(
          results: aggregatedResults,
          exerciseDuration: _selectedDuration,
        ),
      ),
    ).then((_) {
      // Reset when returning from results page
      setState(() {
        _isTimerActive = false;
        _webcamStarted = false;
      });
      
      // Reinitialize webcam processor
      _webcamProcessor = WebcamProcessor(
        onFeedback: (results) {
          if (mounted) {
            setState(() {
              _similarity = results['average_similarity'] ?? 0.0;
              _feedback = _generateFeedback(results);
              _isProcessing = false;
              
              // Add to results list for aggregation
              if (_isTimerActive) {
                _resultsList.add(results);
              }
            });
          }
        },
      );
    });
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
            _buildTimerSection(), // Add this line
            if (!_isTimerActive) _buildControlSection(),
            if (_feedback.isNotEmpty && !_isTimerActive) _buildFeedbackSection(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _webcamProcessor.dispose();
    _exerciseTimer?.cancel();
    super.dispose();
  }
}
