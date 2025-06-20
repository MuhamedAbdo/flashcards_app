import 'package:flash_card_app/services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flash_card_app/models/card_type.dart';
import 'package:flash_card_app/models/card_model.dart';
import 'package:flash_card_app/models/test_result_model.dart';
import 'package:flash_card_app/services/deck_service.dart';
import 'package:flash_card_app/widgets/answer_option.dart';
import 'package:flash_card_app/widgets/card_widget.dart';
import 'results_screen.dart';

class TestScreen extends StatefulWidget {
  final String? deckId;

  const TestScreen({super.key, this.deckId});

  @override
  TestScreenState createState() => TestScreenState();
}

class TestScreenState extends State<TestScreen> {
  late List<CardModel> _testCards;
  late List<CardModel> _allCards;
  int _currentIndex = 0;

  final bool _isTestMode = true;
  String? _selectedAnswer;
  int _correctAnswers = 0;
  List<String> _options = [];

  @override
  void initState() {
    super.initState();
    _initializeTest();
  }

  void _initializeTest() {
    final deck =
        widget.deckId != null ? DeckService.getDeck(widget.deckId!) : null;

    _allCards = deck?.cards ?? [];

    if (widget.deckId == null) {
      _allCards =
          DeckService.getAllDecks().expand((deck) => deck.cards).toList();
    }

    _allCards.shuffle();

    int totalAvailable = _allCards.length;
    int count = 0;
    if (totalAvailable >= 20) {
      count = 20;
    } else if (totalAvailable >= 5) {
      count = (totalAvailable ~/ 5) * 5;
    } else {
      count = totalAvailable;
    }

    _testCards = _allCards.take(count).toList();

    _generateOptions();
  }

  void _generateOptions() {
    if (_testCards.isEmpty) return;

    final currentCard = _testCards[_currentIndex];
    final correctAnswer = currentCard.backText;

    final otherBackTexts = _allCards
        .where((c) => c.id != currentCard.id)
        .map((c) => c.backText)
        .toSet()
        .toList();

    otherBackTexts.shuffle();
    final wrongAnswers = otherBackTexts.take(3).toList();

    _options = [...wrongAnswers, correctAnswer];
    _options.shuffle();
    _selectedAnswer = null;
  }

  @override
  Widget build(BuildContext context) {
    if (_testCards.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('لا توجد بطاقات كافية لبدء الاختبار'),
        ),
      );
    }

    final currentCard = _testCards[_currentIndex];
    final deck =
        widget.deckId != null ? DeckService.getDeck(widget.deckId!) : null;
    final cardType = deck?.cardType ?? CardType.other;

    return Scaffold(
      appBar: AppBar(
        title: Text(deck?.title ?? 'اختبار عام'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.3, // 50% من ارتفاع الشاشة
              child: CardWidget(
                card: currentCard,
                isFront: true,
                cardType: cardType,
                isTestMode: _isTestMode,
              ),
            ),
            const SizedBox(height: 20),
            if (_isTestMode) ...[
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'اختر الإجابة الصحيحة:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
            ],
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ..._getAnswerOptions(currentCard),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'السؤال ${_currentIndex + 1} من ${_testCards.length}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        ElevatedButton(
                          onPressed: _nextQuestion,
                          child: Text(_currentIndex < _testCards.length - 1
                              ? 'التالي'
                              : 'إنهاء الاختبار'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _getAnswerOptions(CardModel currentCard) {
    return _options.map((option) {
      final isCorrect = option == currentCard.backText;
      final isSelected = _selectedAnswer == option;
      final isWrongSelected = isSelected && !isCorrect;

      return AnswerOption(
        text: option,
        isSelected: isSelected,
        isCorrect: isCorrect && _selectedAnswer != null,
        isWrong: isWrongSelected,
        onTap: () => _selectAnswer(option),
      );
    }).toList();
  }

  void _selectAnswer(String option) {
    if (_selectedAnswer != null) return;

    setState(() {
      _selectedAnswer = option;
      if (option == _testCards[_currentIndex].backText) {
        _correctAnswers++;
      }
    });
  }

  void _nextQuestion() {
    if (_selectedAnswer == null && _isTestMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار إجابة')),
      );
      return;
    }

    if (_currentIndex < _testCards.length - 1) {
      setState(() {
        _currentIndex++;
        _generateOptions();
      });
    } else {
      _finishTest();
    }
  }

  void _finishTest() {
    final result = TestResult(
      id: DeckService.generateId(),
      deckId: widget.deckId ?? 'all',
      correctAnswers: _correctAnswers,
      totalQuestions: _testCards.length,
    );

    HiveService.testResultsBox.put(result.id, result);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsScreen(
          correctAnswers: _correctAnswers,
          totalQuestions: _testCards.length,
        ),
      ),
    );
  }
}
