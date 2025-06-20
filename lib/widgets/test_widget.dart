// import 'package:flash_card_app/models/card_type.dart';
// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import 'package:flash_card_app/models/card_model.dart';
// import 'package:flash_card_app/models/deck_model.dart';
// import 'package:flash_card_app/models/test_result_model.dart';
// import 'package:flash_card_app/services/hive_service.dart';
// import 'package:flash_card_app/widgets/card_widget.dart';
// import 'package:flash_card_app/widgets/answer_option.dart';
// import 'package:flash_card_app/utils/constants.dart';

// class TestScreen extends StatefulWidget {
//   final String? deckId;

//   const TestScreen({this.deckId});

//   @override
//   _TestScreenState createState() => _TestScreenState();
// }

// class _TestScreenState extends State<TestScreen> {
//   late List<CardModel> _testCards;
//   late List<CardModel> _allCards;
//   int _currentIndex = 0;
//   bool _isFront = true;
//   bool _isTestMode = true;
//   int? _selectedAnswer;
//   int _correctAnswers = 0;
//   List<int> _correctOptions = [];
//   List<int> _wrongOptions = [];

//   @override
//   void initState() {
//     super.initState();
//     _initializeTest();
//   }

//   void _initializeTest() {
//     final deck =
//         widget.deckId != null ? HiveService.decksBox.get(widget.deckId!) : null;

//     _allCards = deck?.cards ?? [];

//     if (widget.deckId == null) {
//       _allCards =
//           HiveService.decksBox.values.expand((deck) => deck.cards).toList();
//     }

//     _allCards.shuffle();
//     _testCards = _allCards.take(AppConstants.testQuestionCount).toList();
//     _generateOptions();
//   }

//   void _generateOptions() {
//     if (_testCards.isEmpty) return;

//     final currentCard = _testCards[_currentIndex];
//     _correctOptions = [_allCards.indexOf(currentCard)];
//     _wrongOptions = [];
//     _selectedAnswer = null;

//     final otherCards =
//         _allCards.where((card) => card.id != currentCard.id).toList();
//     otherCards.shuffle();

//     for (int i = 0; i < 3 && i < otherCards.length; i++) {
//       _wrongOptions.add(_allCards.indexOf(otherCards[i]));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_testCards.isEmpty) {
//       return Scaffold(
//         appBar: AppBar(),
//         body: Center(
//           child: Text('لا توجد بطاقات كافية لبدء الاختبار'),
//         ),
//       );
//     }

//     final currentCard = _testCards[_currentIndex];
//     final deck =
//         widget.deckId != null ? HiveService.decksBox.get(widget.deckId!) : null;
//     final cardType = deck?.cardType ?? CardType.other;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(deck?.title ?? 'اختبار عام'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Center(
//                 child: GestureDetector(
//                   onTap: _isTestMode ? null : _flipCard,
//                   child: CardWidget(
//                     card: currentCard,
//                     isFront: _isFront,
//                     cardType: cardType,
//                     isTestMode: _isTestMode,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           if (_isTestMode)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Column(
//                 children: [
//                   Text(
//                     'اختر الإجابة الصحيحة:',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 10),
//                   ..._getAnswerOptions(),
//                 ],
//               ),
//             ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'السؤال ${_currentIndex + 1} من ${_testCards.length}',
//                   style: TextStyle(fontSize: 16),
//                 ),
//                 ElevatedButton(
//                   onPressed: _nextQuestion,
//                   child: Text(_currentIndex < _testCards.length - 1
//                       ? 'التالي'
//                       : 'إنهاء الاختبار'),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   List<Widget> _getAnswerOptions() {
//     final options = <int>[..._correctOptions, ..._wrongOptions]..shuffle();
//     return options.map((index) {
//       final isCorrect = _correctOptions.contains(index);
//       final isSelected = _selectedAnswer == index;
//       final isWrongSelected = !isCorrect && isSelected;

//       return AnswerOption(
//         text: _allCards[index].backText,
//         isSelected: isSelected,
//         isCorrect: isCorrect,
//         isWrong: isWrongSelected,
//         onTap: () => _selectAnswer(index),
//       );
//     }).toList();
//   }

//   void _selectAnswer(int index) {
//     if (_selectedAnswer != null) return;

//     setState(() {
//       _selectedAnswer = index;
//       final isCorrect = _correctOptions.contains(index);
//       if (isCorrect) {
//         _correctAnswers++;
//       }
//     });
//   }

//   void _flipCard() {
//     setState(() {
//       _isFront = !_isFront;
//     });
//   }

//   void _nextQuestion() {
//     if (_selectedAnswer == null && _isTestMode) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('الرجاء اختيار إجابة')),
//       );
//       return;
//     }

//     if (_currentIndex < _testCards.length - 1) {
//       setState(() {
//         _currentIndex++;
//         _isFront = true;
//         _isTestMode = true;
//         _generateOptions();
//       });
//     } else {
//       _finishTest();
//     }
//   }

//   void _finishTest() {
//     final result = TestResult(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       deckId: widget.deckId ?? 'all',
//       correctAnswers: _correctAnswers,
//       totalQuestions: _testCards.length,
//     );

//     HiveService.testResultsBox.put(result.id, result);

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ResultsScreen(
//           correctAnswers: _correctAnswers,
//           totalQuestions: _testCards.length,
//         ),
//       ),
//     );
//   }
// }

// class ResultsScreen extends StatelessWidget {
//   final int correctAnswers;
//   final int totalQuestions;

//   const ResultsScreen({
//     required this.correctAnswers,
//     required this.totalQuestions,
//   });

//   double get score => (correctAnswers / totalQuestions) * 100;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('نتيجة الاختبار'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'انتهى الاختبار!',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 20),
//             CircularProgressIndicator(
//               value: score / 100,
//               strokeWidth: 10,
//               backgroundColor: Colors.grey[300],
//               color: _getScoreColor(),
//             ),
//             SizedBox(height: 20),
//             Text(
//               '${score.toStringAsFixed(1)}%',
//               style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Text(
//               'الإجابات الصحيحة: $correctAnswers / $totalQuestions',
//               style: TextStyle(fontSize: 18),
//             ),
//             SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.popUntil(context, (route) => route.isFirst);
//               },
//               child: Text('العودة للصفحة الرئيسية'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Color _getScoreColor() {
//     if (score >= 80) return Colors.green;
//     if (score >= 50) return Colors.orange;
//     return Colors.red;
//   }
// }
