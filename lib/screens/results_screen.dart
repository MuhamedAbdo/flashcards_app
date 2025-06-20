import 'package:flutter/material.dart';
import 'package:flash_card_app/screens/home_screen.dart';

class ResultsScreen extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;

  const ResultsScreen({
    super.key, // ✅ تم إضافة key هنا
    required this.correctAnswers,
    required this.totalQuestions,
  });

  double get score => (correctAnswers / totalQuestions) * 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نتيجة الاختبار'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'انتهى الاختبار!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 10,
              backgroundColor: Colors.grey[300],
              color: _getScoreColor(),
            ),
            const SizedBox(height: 20),
            Text(
              '${score.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'الإجابات الصحيحة: $correctAnswers / $totalQuestions',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              },
              child: const Text('العودة للصفحة الرئيسية'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor() {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}
