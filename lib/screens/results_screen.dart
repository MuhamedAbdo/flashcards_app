import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;

  const ResultsScreen({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final score = ((correctAnswers / totalQuestions) * 100).toInt();

    return Scaffold(
      appBar: AppBar(
        title: const Text('نتائج الاختبار'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$correctAnswers / $totalQuestions',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'نسبة النجاح: $score%',
              style: TextStyle(
                fontSize: 24,
                color: score >= 75
                    ? Colors.green
                    : score >= 50
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('العودة'),
            ),
          ],
        ),
      ),
    );
  }
}
