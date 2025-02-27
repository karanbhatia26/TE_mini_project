import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'dart:ui';

class ResultsPage extends StatelessWidget {
  final Map<String, dynamic> results;
  final int exerciseDuration;

  const ResultsPage({
    super.key,
    required this.results,
    required this.exerciseDuration,
  });

  @override
  Widget build(BuildContext context) {
    final similarity = results['average_similarity'] ?? 0.0;
    final maxDelay = results['max_delay'] ?? 0;
    final idealCalories = results['ideal_calories'] ?? 0.0;
    final actualCalories = results['actual_calories'] ?? 0.0;
    final flowSimilarity = results['flow_similarity'] ?? 0.0;
    final efficiencyScore = (similarity * 0.6) + (flowSimilarity * 0.4);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Your Results',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                _buildHeaderSection(efficiencyScore),
                const SizedBox(height: 30),
                _buildDetailedMetrics(
                  similarity: similarity,
                  flowSimilarity: flowSimilarity,
                  maxDelay: maxDelay,
                  actualCalories: actualCalories,
                  idealCalories: idealCalories,
                ),
                const SizedBox(height: 30),
                _buildRecommendations(similarity, flowSimilarity, maxDelay),
                const SizedBox(height: 20),
                _buildTryAgainButton(context),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(double efficiencyScore) {
    String performanceText;
    if (efficiencyScore >= 0.8) {
      performanceText = "Excellent Form!";
    } else if (efficiencyScore >= 0.6) {
      performanceText = "Good Form";
    } else {
      performanceText = "Needs Improvement";
    }

    return Column(
      children: [
        Text(
          performanceText,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: _getScoreColor(efficiencyScore),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Exercise Duration: ${_formatDuration(exerciseDuration)}',
          style: const TextStyle(fontSize: 16, color: Colors.white70),
        ),
        const SizedBox(height: 25),
        Hero(
          tag: 'performance_score',
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getScoreColor(efficiencyScore).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CircularPercentIndicator(
              radius: 100,
              lineWidth: 15,
              percent: efficiencyScore.clamp(0.0, 1.0),
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(efficiencyScore * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const Text(
                    'SCORE',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              progressColor: _getScoreColor(efficiencyScore),
              backgroundColor: Colors.grey.shade800.withOpacity(0.5),
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
              animationDuration: 1200,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedMetrics({
    required double similarity,
    required double flowSimilarity,
    required int maxDelay,
    required double actualCalories,
    required double idealCalories,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Performance Metrics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              _buildMetricTile(
                "Form Accuracy",
                similarity,
                Icons.accessibility_new,
                "How well your form matched the reference exercise",
              ),
              const SizedBox(height: 15),
              _buildMetricTile(
                "Movement Fluidity",
                flowSimilarity,
                Icons.waves,
                "Smoothness and consistency of your movements",
              ),
              const SizedBox(height: 15),
              _buildDelayMetric(maxDelay),
              const SizedBox(height: 15),
              _buildCalorieComparisonChart(actualCalories, idealCalories),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(
      String title, double value, IconData icon, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: _getScoreColor(value), size: 22),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              "${(value * 100).toStringAsFixed(1)}%",
              style: TextStyle(
                color: _getScoreColor(value),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          description,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(value)),
          ),
        ),
      ],
    );
  }

  Widget _buildDelayMetric(int maxDelay) {
    // Determine color and message based on delay
    Color delayColor;
    String delayMessage;
    
    if (maxDelay <= 5) {
      delayColor = Colors.green;
      delayMessage = "Excellent timing! You stayed in sync with the reference.";
    } else if (maxDelay <= 12) {
      delayColor = Colors.orange;
      delayMessage = "Good timing with minor delays.";
    } else {
      delayColor = Colors.red;
      delayMessage = "Work on keeping pace with the reference.";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.timer, color: delayColor, size: 22),
            const SizedBox(width: 10),
            const Text(
              "Timing Accuracy",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: delayColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "$maxDelay frames",
                style: TextStyle(
                  color: delayColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          delayMessage,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
        ),
      ],
    );
  }

  Widget _buildCalorieComparisonChart(double actual, double ideal) {
    final maxValue = [actual, ideal].reduce((a, b) => a > b ? a : b);
    final efficiency = ideal > 0 ? (actual / ideal) : 0.0;
    final efficiencyText = "${(efficiency * 100).toStringAsFixed(0)}%";
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.local_fire_department, color: Colors.orange, size: 22),
            const SizedBox(width: 10),
            const Text(
              "Calories Burned",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              "Efficiency: $efficiencyText",
              style: TextStyle(
                color: efficiency >= 0.8 ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 15,
                        height: 100 * (actual / maxValue),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.blue, Colors.lightBlueAccent],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            actual.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "kcal",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "YOUR WORKOUT",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 15,
                        height: 100 * (ideal / maxValue),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.green, Colors.lightGreenAccent],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ideal.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "kcal",
                            style: TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "REFERENCE",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecommendations(
      double similarity, double flowSimilarity, int maxDelay) {
    List<String> recommendations = [];
    
    if (similarity < 0.7) {
      recommendations.add("Focus on matching the trainer's form more precisely. Watch the reference video carefully and practice.");
    }
    
    if (flowSimilarity < 0.65) {
      recommendations.add("Work on smoother transitions and consistent movement speeds. Try not to pause or rush through exercises.");
    }
    
    if (maxDelay > 10) {
      recommendations.add("Improve your timing by keeping pace with the reference exercise. Try counting or using a metronome.");
    }
    
    if (recommendations.isEmpty) {
      recommendations.add("Great job! Keep up the excellent form and technique. Consider increasing intensity in your next workout.");
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.amber, size: 24),
                  SizedBox(width: 10),
                  Text(
                    'Recommendations',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              ...recommendations.map((rec) => Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•  ',
                            style: TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        Expanded(
                          child: Text(
                            rec,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTryAgainButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: -5,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade700],
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () => Navigator.of(context).pop(),
        child: const Text(
          'Try Another Exercise',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}