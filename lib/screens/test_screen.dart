import 'package:flutter/material.dart';
import 'package:flash_card_app/models/card_model.dart';
import 'package:flash_card_app/models/card_type.dart';
import 'package:flash_card_app/models/deck_model.dart';
import 'package:flash_card_app/services/deck_service.dart';
import 'package:flash_card_app/utils/extensions.dart';
import 'package:flash_card_app/screens/results_screen.dart';
import 'package:flash_card_app/widgets/answer_option.dart';
import 'package:flash_card_app/widgets/card_widget.dart';

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
  TextDirection _currentTextDirection = TextDirection.rtl;

  @override
  void initState() {
    super.initState();
    _initializeTest();
  }

  void _initializeTest() {
    final deck =
        widget.deckId != null ? DeckService.getDeck(widget.deckId!) : null;

    if (widget.deckId != null) {
      // اختبار محدد لمجموعة معينة
      _allCards = deck?.cards ?? [];
    } else {
      // اختبار عام - نستخدم كل البطاقات
      _allCards =
          DeckService.getAllDecks().expand((deck) => deck.cards).toList();
    }

    _allCards.shuffle();
    int count = _calculateTestCount(_allCards.length);
    _testCards = _allCards.take(count).toList();

    if (_testCards.isNotEmpty) {
      _generateOptions();
    }
  }

  int _calculateTestCount(int totalAvailable) {
    if (totalAvailable >= 20) return 20;
    if (totalAvailable >= 5) return (totalAvailable ~/ 5) * 5;
    return totalAvailable;
  }

  void _generateOptions() {
    if (_testCards.isEmpty) return;

    final currentCard = _testCards[_currentIndex];
    final currentDeck = _getDeckForCard(currentCard);

    // الحصول على البطاقات من نفس المجموعة فقط
    final cardsFromSameDeck = currentDeck?.cards ?? [];

    final correctAnswer = currentCard.backText;
    List<String> wrongAnswers = [];

    if (cardsFromSameDeck.isNotEmpty) {
      // إذا كانت هناك بطاقات كافية في نفس المجموعة
      final otherCards = cardsFromSameDeck
          .where((c) => c.id != currentCard.id && c.backText != correctAnswer)
          .map((c) => c.backText)
          .toSet()
          .toList();

      otherCards.shuffle();
      wrongAnswers = otherCards.take(3).toList();
    } else {
      // إذا لم تكن هناك بطاقات كافية، نستخدم خيارات عامة
      final otherCards = _allCards
          .where((c) => c.id != currentCard.id && c.backText != correctAnswer)
          .map((c) => c.backText)
          .toSet()
          .toList();

      otherCards.shuffle();
      wrongAnswers = otherCards.take(3).toList();
    }

    setState(() {
      _options = [...wrongAnswers, correctAnswer]..shuffle();
      _selectedAnswer = null;
      _currentTextDirection = currentCard.backTextDirection;
    });
  }

  Deck? _getDeckForCard(CardModel card) {
    return DeckService.getAllDecks()
        .firstWhereOrNull((deck) => deck.cards.any((c) => c.id == card.id));
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
              height: MediaQuery.of(context).size.height * 0.3,
              child: CardWidget(
                card: currentCard,
                isFront: true,
                cardType: cardType,
                isTestMode: _isTestMode,
              ),
            ),
            const SizedBox(height: 20),
            if (_isTestMode)
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'اختر الإجابة الصحيحة:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 10),
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
                          child: Text(
                            _currentIndex < _testCards.length - 1
                                ? 'التالي'
                                : 'إنهاء الاختبار',
                          ),
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
        textDirection: _currentTextDirection,
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
    if (widget.deckId != null) {
      DeckService.createTestResult(
        deckId: widget.deckId!,
        correctAnswers: _correctAnswers,
        totalQuestions: _testCards.length,
      );
    }

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
