import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Add this dependency for better charts

class ResultsPage extends StatelessWidget {
  final Map<String, dynamic> results;
  final int exerciseDuration; // in seconds

  const ResultsPage({
    Key? key, 
    required this.results,
    required this.exerciseDuration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final similarity = results['average_similarity'] ?? 0.0;
    final maxDelay = results['max_delay'] ?? 0;
    final idealCalories = results['ideal_calories'] ?? 0.0;
    final actualCalories = results['actual_calories'] ?? 0.0;
    final flowSimilarity = results['flow_similarity'] ?? 0.0;
    
    // Calculate efficiency score (weighted average of metrics)
    final efficiencyScore = (similarity * 0.6) + (flowSimilarity * 0.4);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Results'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Exercise Analysis Complete!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Exercise Duration: ${_formatDuration(exerciseDuration)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 32),
            
            // Overall score display
            _buildScoreCard(context, efficiencyScore),
            const SizedBox(height: 24),
            
            // Detailed metrics
            Text(
              'Detailed Metrics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Form accuracy
            _buildMetricRow(
              context, 
              'Form Accuracy', 
              similarity, 
              description: 'How well your form matched the reference exercise',
              icon: Icons.accessibility_new,
              threshold: 0.7,
            ),
            
            // Flow similarity
            _buildMetricRow(
              context, 
              'Movement Fluidity', 
              flowSimilarity,
              description: 'How smoothly you performed the exercise',
              icon: Icons.waves,
              threshold: 0.65,
            ),
            
            // Timing
            _buildTimingMetric(context, maxDelay),
            
            // Calories
            _buildCalorieMetric(context, actualCalories, idealCalories),
            
            const SizedBox(height: 32),
            
            // Recommendations
            _buildRecommendations(context, similarity, flowSimilarity, maxDelay),
            
            const SizedBox(height: 24),
            
            // Button to try again
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Try Another Exercise'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildScoreCard(BuildContext context, double score) {
    Color scoreColor;
    String scoreText;
    
    if (score >= 0.8) {
      scoreColor = Colors.green;
      scoreText = 'Excellent!';
    } else if (score >= 0.6) {
      scoreColor = Colors.orange;
      scoreText = 'Good';
    } else {
      scoreColor = Colors.red;
      scoreText = 'Needs Improvement';
    }
    
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Overall Performance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: score,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${(score * 100).toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      scoreText,
                      style: TextStyle(
                        color: scoreColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMetricRow(
    BuildContext context, 
    String title, 
    double value, 
    {required String description, 
    required IconData icon, 
    required double threshold}
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: value >= threshold ? Colors.green : Colors.orange),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(description),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: value,
            minHeight: 10,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              value >= threshold ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text('${(value * 100).toStringAsFixed(1)}%'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimingMetric(BuildContext context, int maxDelay) {
    String description;
    Color color;
    
    if (maxDelay <= 5) {
      description = 'Excellent timing! You stayed in sync with the reference.';
      color = Colors.green;
    } else if (maxDelay <= 10) {
      description = 'Good timing with minor delays. Keep practicing for better synchronization.';
      color = Colors.orange;
    } else {
      description = 'You had significant timing issues. Focus on keeping pace with the reference.';
      color = Colors.red;
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timer, color: color),
                const SizedBox(width: 8),
                Text(
                  'Timing Accuracy',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Maximum delay: $maxDelay frames'),
            const SizedBox(height: 4),
            Text(description, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCalorieMetric(BuildContext context, double actual, double ideal) {
    final efficiency = ideal > 0 ? actual / ideal : 0.0;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calories Burned',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCalorieItem(context, 'Actual', actual, Colors.blue),
                _buildCalorieItem(context, 'Ideal', ideal, Colors.green),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Calorie Efficiency: ${(efficiency * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: efficiency >= 0.8 ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCalorieItem(BuildContext context, String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(1)}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text('kcal', style: TextStyle(color: color)),
      ],
    );
  }
  
  Widget _buildRecommendations(BuildContext context, double similarity, double flowSimilarity, int maxDelay) {
    List<String> recommendations = [];
    
    if (similarity < 0.7) {
      recommendations.add('Focus on matching the trainer\'s form more precisely. Pay attention to positioning.');
    }
    
    if (flowSimilarity < 0.65) {
      recommendations.add('Work on smoother transitions between movements. Try to maintain consistent speed.');
    }
    
    if (maxDelay > 10) {
      recommendations.add('Practice keeping pace with the reference exercise to improve timing.');
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('Great job! Keep maintaining your excellent form and technique.');
    }
    
    return Card(
      color: Colors.blue.shade50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                Text(
                  'Recommendations',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recommendations.map((recommendation) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(recommendation)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
  
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}