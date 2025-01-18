import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:dio/dio.dart';

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  _AppPageState createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  late VideoPlayerController _controller;
  bool _webcamStarted = false;
  bool _isProcessing = false;
  String _feedback = '';
  double _similarity = 0.0;
  static const String viewType = 'videoElement';
  html.MediaRecorder? _mediaRecorder;
  List<html.Blob> _recordedChunks = [];
  html.MediaStream? _stream;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/videoplayback.mp4')
      ..initialize().then((_) {
        setState(() {
          _controller.setLooping(true);
        });
      });

    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      return _createVideoElement();
    });
  }

  Future<void> _startRecording(html.MediaStream stream) async {
    _stream = stream;
    _recordedChunks = [];
    final options = {
      'mimeType': 'video/webm;codecs=vp8,opus'
    };
    
    try {
      _mediaRecorder = html.MediaRecorder(stream, options);
      
      _mediaRecorder?.addEventListener('dataavailable', (event) {
        if (event is html.BlobEvent && event.data != null) {
          _recordedChunks.add(event.data!);
        }
      });

      _mediaRecorder?.start();
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> _stopRecordingAndProcess() async {
    setState(() {
      _isProcessing = true;
      _feedback = 'Processing your exercise...';
    });

    try {
      if (_mediaRecorder?.state == 'recording') {
        _mediaRecorder?.stop();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (_recordedChunks.isEmpty) {
        throw Exception('No video data recorded');
      }

      final blob = html.Blob(_recordedChunks, 'video/webm');
      final data = FormData();
      
      // Convert Blob to File
      final videoFile = await _blobToFile(blob, 'exercise_recording.webm');
      data.files.add(
        MapEntry('video', 
          MultipartFile.fromBytes(
            await _fileToBytes(videoFile),
            filename: 'exercise_recording.webm',
          ),
        ),
      );

      final dio = Dio();
      final response = await dio.post(
        'http://localhost:5000/process-exercise',
        data: data,
      );

      if (response.statusCode == 200) {
        final results = response.data;
        setState(() {
          _similarity = results['average_similarity'] ?? 0.0;
          _feedback = _generateFeedback(results);
        });
      } else {
        setState(() {
          _feedback = 'Error processing exercise. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _feedback = 'Error: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
      
      // Reset recording
      _recordedChunks = [];
      if (_stream != null) {
        await _startRecording(_stream!);
      }
    }
  }

  Future<html.File> _blobToFile(html.Blob blob, String filename) async {
    return html.File([blob], filename);
  }

  Future<List<int>> _fileToBytes(html.File file) async {
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;
    return reader.result as List<int>;
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
            setState(() => _webcamStarted = true);
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
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
            setState(() {});
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
            onPressed: _webcamStarted ? _stopRecordingAndProcess : null,
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

  html.VideoElement _createVideoElement() {
    final videoElement = html.VideoElement()
      ..width = 480
      ..height = 360
      ..autoplay = true
      ..controls = false;

    html.window.navigator.mediaDevices?.getUserMedia({'video': true}).then((stream) {
      videoElement.srcObject = stream;
      _startRecording(stream);
    }).catchError((error) {
      debugPrint('Error accessing webcam: $error');
    });

    return videoElement;
  }

  @override
  void dispose() {
    _controller.dispose();
    _mediaRecorder?.stop();
    _stream?.getTracks().forEach((track) => track.stop());
    super.dispose();
  }
}