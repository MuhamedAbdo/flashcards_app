import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flash_card_app/models/card_model.dart';
import 'package:flash_card_app/models/card_type.dart';
import 'package:flash_card_app/models/deck_model.dart';
import 'package:flash_card_app/screens/add_card_screen.dart';
import 'package:flash_card_app/screens/test_screen.dart';
import 'package:flash_card_app/widgets/card_widget.dart';

class DeckScreen extends StatefulWidget {
  final String deckId;
  const DeckScreen({super.key, required this.deckId});

  @override
  State<DeckScreen> createState() => _DeckScreenState();
}

class _DeckScreenState extends State<DeckScreen> {
  int _currentIndex = 0;
  bool _isFront = true;
  late final Box<Deck> _decksBox;
  double _dragOffset = 0;
  final PageController _pageController = PageController();
  bool _isDragging = false;
  final List<CardType> colorCycle = CardType.values;

  @override
  void initState() {
    super.initState();
    _decksBox = Hive.box<Deck>('decks');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _decksBox.listenable(keys: [widget.deckId]),
      builder: (context, Box<Deck> box, _) {
        final deck = box.get(widget.deckId);
        if (deck == null) {
          return const Scaffold(
            body: Center(child: Text('المجموعة غير موجودة')),
          );
        }
        final sortedCards = List<CardModel>.from(deck.cards)
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        if (sortedCards.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text(deck.title),
              actions: [
                _buildAddButton(context),
                // _buildEditDeckButton(context, deck),
              ],
            ),
            body: const Center(child: Text('لا توجد بطاقات في هذه المجموعة')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(deck.title),
            actions: [
              _buildAddButton(context),
              _buildTestButton(context),
              // _buildEditDeckButton(context, deck),
              _buildCardMenu(context),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final cardMargin = EdgeInsets.symmetric(
                horizontal: constraints.maxWidth * 0.05,
                vertical: constraints.maxHeight * 0.05,
              );

              return Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onHorizontalDragStart: (_) =>
                          setState(() => _isDragging = true),
                      onHorizontalDragUpdate: _handleHorizontalDrag,
                      onHorizontalDragEnd: _handleHorizontalDragEnd,
                      child: PageView.builder(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sortedCards.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;
                            _isFront = true;
                            _isDragging = false;
                          });
                        },
                        itemBuilder: (context, index) {
                          final currentCard = sortedCards[index];
                          final displayType =
                              colorCycle[index % colorCycle.length];

                          return Container(
                            margin: cardMargin,
                            child: GestureDetector(
                              onTap: () {
                                if (!_isDragging) {
                                  setState(() {
                                    _isFront = !_isFront;
                                  });
                                }
                              },
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                transitionBuilder: (child, animation) {
                                  final offsetAnimation = Tween<Offset>(
                                    begin: _isFront
                                        ? const Offset(0, 1)
                                        : const Offset(0, -1),
                                    end: Offset.zero,
                                  ).animate(animation);

                                  return ClipRect(
                                    child: SlideTransition(
                                      position: offsetAnimation,
                                      child: child,
                                    ),
                                  );
                                },
                                layoutBuilder:
                                    (currentChild, previousChildren) =>
                                        currentChild!,
                                child: KeyedSubtree(
                                  key: ValueKey('${currentCard.id}_$_isFront'),
                                  child: CardWidget(
                                    key:
                                        ValueKey('${currentCard.id}_$_isFront'),
                                    card: currentCard.copyWith(
                                        deckFrontPrefix: deck.frontPrefix),
                                    isFront: _isFront,
                                    cardType: displayType,
                                    margin: EdgeInsets.zero,
                                    heightFactor: 0.75,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      textDirection: TextDirection.rtl,
                      '${_currentIndex + 1} من ${sortedCards.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add),
      onPressed: () => _addNewCard(context),
    );
  }

  Widget _buildTestButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.quiz),
      tooltip: 'اختبار خاص بهذه المجموعة',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TestScreen(deckId: widget.deckId),
          ),
        );
      },
    );
  }

  Widget _buildCardMenu(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleMenuSelection(value, context),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_note, color: Colors.blue),
              SizedBox(width: 8),
              Text('تعديل البطاقة'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('حذف البطاقة'),
            ],
          ),
        ),
      ],
    );
  }

  void _handleHorizontalDrag(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.primaryDelta!;
    });
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    final deck = _getCurrentDeck();
    if (deck == null) return;
    final sortedCards = List<CardModel>.from(deck.cards)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    if (_dragOffset > 100 && _currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isFront = true;
        _isDragging = false;
        _dragOffset = 0;
      });
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_dragOffset < -100 && _currentIndex < sortedCards.length - 1) {
      setState(() {
        _currentIndex++;
        _isFront = true;
        _isDragging = false;
        _dragOffset = 0;
      });
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      setState(() {
        _isDragging = false;
        _dragOffset = 0;
      });
    }
  }

  Future<void> _addNewCard(BuildContext context) async {
    final deck = _getCurrentDeck();
    final nextType = colorCycle[(deck?.cards.length ?? 0) % colorCycle.length];
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCardScreen(
          deckId: widget.deckId,
          suggestedCardType: nextType,
          defaultFrontPrefix: deck?.frontPrefix,
        ),
      ),
    );
    if (result == true) {
      final updatedDeck = _getCurrentDeck();
      if (updatedDeck == null || updatedDeck.cards.isEmpty) return;
      setState(() {
        _currentIndex = updatedDeck.cards.length - 1;
        _isFront = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(_currentIndex);
        }
      });
    }
  }

  void _handleMenuSelection(String value, BuildContext context) {
    switch (value) {
      case 'edit':
        _editCurrentCard(context);
        break;
      case 'delete':
        _confirmDeleteCard(context);
        break;
    }
  }

  Future<void> _editCurrentCard(BuildContext context) async {
    final deck = _getCurrentDeck();
    if (deck == null) return;
    final sortedCards = List<CardModel>.from(deck.cards)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCardScreen(
          deckId: widget.deckId,
          cardToEdit: sortedCards[_currentIndex],
          suggestedCardType: sortedCards[_currentIndex].cardType,
          defaultFrontPrefix: deck.frontPrefix,
        ),
      ),
    );
    if (result == true) {
      setState(() => _isFront = true);
    }
  }

  Future<void> _deleteCurrentCard() async {
    final deck = _getCurrentDeck();
    if (deck == null) return;
    final sortedCards = List<CardModel>.from(deck.cards)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final updatedCards = List<CardModel>.from(sortedCards)
      ..removeAt(_currentIndex);
    final updatedDeck = deck.copyWith(cards: updatedCards);
    await _decksBox.put(widget.deckId, updatedDeck);
    if (!mounted) return;
    setState(() {
      if (_currentIndex >= updatedCards.length && _currentIndex > 0) {
        _currentIndex--;
      }
      _isFront = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients && updatedCards.isNotEmpty) {
          _pageController.jumpToPage(_currentIndex);
        }
      });
    });
  }

  void _confirmDeleteCard(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد أنك تريد حذف هذه البطاقة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCurrentCard();
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Deck? _getCurrentDeck() => _decksBox.get(widget.deckId);
}
