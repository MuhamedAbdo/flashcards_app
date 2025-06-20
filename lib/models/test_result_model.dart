import 'package:hive/hive.dart';

part 'test_result_model.g.dart';

@HiveType(typeId: 2)
class TestResult {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String deckId;

  @HiveField(2)
  final DateTime testDate;

  @HiveField(3)
  final int correctAnswers;

  @HiveField(4)
  final int totalQuestions;

  TestResult({
    required this.id,
    required this.deckId,
    required this.correctAnswers,
    required this.totalQuestions,
    DateTime? testDate,
  }) : testDate = testDate ?? DateTime.now();

  double get score => (correctAnswers / totalQuestions) * 100;
}
