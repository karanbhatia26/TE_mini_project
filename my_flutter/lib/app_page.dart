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
  final Duration processInterval = const Duration(seconds: 3); // Define the interval
  final Function(Map<String, dynamic>) onFeedback;
  final Function(bool) onProcessingStateChange;
  final Function(String) onProgressUpdate;
  String viewType = 'webcam-view'; // Add the view type
  
  WebcamProcessor({
    required this.onFeedback,
    required this.onProcessingStateChange,
    required this.onProgressUpdate,
  });

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
    onProcessingStateChange(true);
    onProgressUpdate("Processing video...");

    try {
      final data = FormData();
      final bytes = await blobToBytes(videoBlob);
      
      print('Preparing to send video of size: ${bytes.length} bytes');
      
      data.files.add(MapEntry(
        'video', 
        MultipartFile.fromBytes(
          bytes,
          filename: 'exercise.webm',
          contentType: MediaType('video', 'webm'),
        )
      ));
      
      print('Sending request to server...');
      
      final dio = Dio()
        ..options.connectTimeout = const Duration(seconds: 60)
        ..options.receiveTimeout = const Duration(seconds: 120);
      
      final response = await dio.post(
        'http://localhost:5000/process-exercise',
        data: data,
        onSendProgress: (sent, total) {
          onProgressUpdate("Uploading: ${(sent / total * 100).toStringAsFixed(1)}%");
        },
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgressUpdate("Receiving results: ${(received / total * 100).toStringAsFixed(1)}%");
          }
        }
      );
      
      print('Server response status: ${response.statusCode}');
      print('Server response data: ${response.data}');
      
      if (response.statusCode == 200) {
        final results = response.data;
        onFeedback(results);
      } else {
        throw Exception('Server error: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      print('Error sending video to server: $e');
      onFeedback({
        'average_similarity': 0.0,
        'max_delay': 0,
        'ideal_calories': 0.0,
        'actual_calories': 0.0,
        'flow_similarity': 0.0,
        'error': e.toString()
      });
    } finally {
      onProcessingStateChange(false);
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
    if (mediaRecorder?.state == 'recording') {
      mediaRecorder?.stop();
    }
    
    if (videoElement?.srcObject != null) {
      videoElement?.srcObject?.getTracks().forEach((track) => track.stop());
    }
    
    processingTimer?.cancel();
    
    recordedChunks.clear();
    
    if (videoElement != null) {
      videoElement?.remove();
    }
  }

  void initializeWebcam() {
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      videoElement = html.VideoElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..autoplay = true
        ..muted = true;
        
      return videoElement!;
    });
      
    // Rest of initialization code...
  }
}

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  _AppPageState createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  // Add missing variables 
  late VideoPlayerController _controller;
  late WebcamProcessor _webcamProcessor;
  bool _webcamStarted = false;
  bool _isProcessing = false;
  String _processingText = "";
  double _similarity = 0.0;
  String _feedback = "";
  bool _profVideoLoaded = false;
  bool _checkingProfStatus = true;
  
  // Timer variables
  int _selectedDuration = 60; // Default 60 seconds
  bool _isTimerActive = false;
  Timer? _exerciseTimer;
  int _remainingTime = 0;
  List<Map<String, dynamic>> _resultsList = [];
  
  // New variables for results processing
  bool _processingFinalResults = false;
  Timer? _processingCheckTimer;

  @override
  void initState() {
    super.initState();
    
    _controller = VideoPlayerController.asset('assets/videos/videoplayback.mp4')
      ..initialize().then((_) {
        setState(() {});
      });
      
    _webcamProcessor = WebcamProcessor(
      onFeedback: (results) {
        if (mounted) {
          setState(() {
            _similarity = results['average_similarity'] ?? 0.0;
            _feedback = _generateFeedback(results);
            
            // Add to results list for aggregation
            if (_isTimerActive) {
              _resultsList.add(results);
            }
          });
        }
      },
      onProcessingStateChange: (isProcessing) {
        if (mounted) {
          setState(() {
            _isProcessing = isProcessing;
          });
        }
      },
      onProgressUpdate: (text) {
        if (mounted) {
          setState(() {
            _processingText = text;
          });
        }
      },
    );
    
    // Check professor video status
    _checkProfessorStatus();
  }

  Future<void> _checkProfessorStatus() async {
    setState(() {
      _checkingProfStatus = true;
    });
    
    try {
      final dio = Dio()
        ..options.connectTimeout = const Duration(seconds: 10)
        ..options.receiveTimeout = const Duration(seconds: 10);
        
      final response = await dio.get('http://localhost:5000/prof-status');
      
      if (response.statusCode == 200) {
        final bool initialized = response.data['initialized'] ?? false;
        final int frameCount = response.data['frame_count'] ?? 0;
        
        setState(() {
          _profVideoLoaded = initialized && frameCount > 0;
          _checkingProfStatus = false;
        });
        
        print('Professor status: initialized=$initialized, frames=$frameCount');
        
        if (!_profVideoLoaded) {
          // Retry after a delay
          Future.delayed(const Duration(seconds: 3), _checkProfessorStatus);
        }
      } else {
        setState(() {
          _checkingProfStatus = false;
        });
        print('Status check failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error checking professor status: $e');
      setState(() {
        _checkingProfStatus = false;
      });
      
      // Retry after a delay
      Future.delayed(const Duration(seconds: 3), _checkProfessorStatus);
    }
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
          width: 320,
          height: 240,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _webcamStarted
                ? HtmlElementView(viewType: _webcamProcessor.viewType) // Use the viewType from processor
                : const Center(child: Text('Webcam not started')),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _isTimerActive ? null : _toggleWebcam,
          child: Text(_webcamStarted ? 'Stop Webcam' : 'Start Webcam'),
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
        const Text('Select exercise duration:'),
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
        if (_checkingProfStatus)
          const Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text('Loading reference exercise...'),
            ],
          )
        else
          ElevatedButton(
            onPressed: _webcamStarted && _profVideoLoaded ? _startExerciseTimer : null,
            child: Text(_profVideoLoaded 
                ? 'Start Exercise Timer' 
                : 'Waiting for reference exercise to load...'),
          ),
        if (!_profVideoLoaded && !_checkingProfStatus)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'Reference exercise not loaded. Please wait...',
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildActiveTimer() {
    final minutes = _remainingTime ~/ 60;
    final seconds = _remainingTime % 60;
    
    return Column(
      children: [
        const Text(
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
    
    // Wait for processing to finish before showing results
    if (_isProcessing) {
      setState(() {
        _processingFinalResults = true;
        _processingText = "Finishing analysis... Please wait";
      });
      
      // Check periodically if processing is done
      _processingCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!_isProcessing) {
          timer.cancel();
          _showResultsPage();
        }
      });
      
      // Set a timeout in case processing takes too long
      Future.delayed(const Duration(seconds: 30), () {
        if (_processingCheckTimer?.isActive ?? false) {
          _processingCheckTimer?.cancel();
          _showResultsPage();
        }
      });
    } else {
      _showResultsPage();
    }
  }

  void _showResultsPage() {
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
        _processingFinalResults = false;
      });
      
      // Reinitialize webcam processor
      _webcamProcessor = WebcamProcessor(
        onFeedback: (results) {
          if (mounted) {
            setState(() {
              _similarity = results['average_similarity'] ?? 0.0;
              _feedback = _generateFeedback(results);
              
              // Add to results list for aggregation
              if (_isTimerActive) {
                _resultsList.add(results);
              }
            });
          }
        },
        onProcessingStateChange: (isProcessing) {
          if (mounted) {
            setState(() {
              _isProcessing = isProcessing;
            });
          }
        },
        onProgressUpdate: (text) {
          if (mounted) {
            setState(() {
              _processingText = text;
            });
          }
        },
      );
    });
  }

  void _toggleWebcam() {
    setState(() {
      _webcamStarted = !_webcamStarted;
    });
    
    if (_webcamStarted) {
      // Initialize and start the webcam
      _webcamProcessor.initializeWebcam(); 
      _webcamProcessor.startProcessing();
      
      // Reset feedback
      _similarity = 0.0;
      _feedback = '';
    } else {
      // Stop the webcam
      _webcamProcessor.dispose();
    }
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
