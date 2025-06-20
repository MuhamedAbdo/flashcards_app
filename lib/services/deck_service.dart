import 'package:flutter/material.dart';
import 'package:uuid/Uuid.dart';
import 'package:flash_card_app/models/card_model.dart';
import 'package:flash_card_app/models/deck_model.dart';
import 'package:flash_card_app/models/test_result_model.dart';
import 'package:flash_card_app/services/hive_service.dart';

class DeckService {
  static final Uuid _uuid = const Uuid();

  static List<Deck> getAllDecks() {
    return HiveService.decksBox.values.toList();
  }

  static Deck? getDeck(String id) {
    return HiveService.decksBox.get(id);
  }

  static void addDeck(Deck deck) {
    HiveService.decksBox.put(deck.id, deck);
  }

  static void updateDeck(Deck deck) {
    HiveService.decksBox.put(deck.id, deck);
  }

  static void deleteDeck(String id) {
    HiveService.decksBox.delete(id);
  }

  static void createTestResult({
    required String deckId,
    required int correctAnswers,
    required int totalQuestions,
  }) {
    final result = TestResult(
      id: generateId(),
      deckId: deckId,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
    );

    HiveService.testResultsBox.add(result);
  }

  static Color getCardTypeColor(CardModel card) {
    switch (card.id.hashCode % 5) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  static String generateId() {
    return _uuid.v4();
  }

  // ✅ إضافة بطاقة جديدة داخل مجموعة
  static void addCardToDeck(String deckId, CardModel card) {
    final deck = HiveService.decksBox.get(deckId);
    if (deck != null) {
      final updatedDeck = Deck(
        id: deck.id,
        title: deck.title,
        cardType: deck.cardType,
        cards: [...deck.cards, card],
        createdAt: deck.createdAt,
        frontPrefix: deck.frontPrefix,
      );
      HiveService.decksBox.put(deckId, updatedDeck);
    }
  }

  // ✅ تعديل بطاقة داخل مجموعة
  static void updateCardInDeck(String deckId, CardModel updatedCard) {
    final deck = HiveService.decksBox.get(deckId);
    if (deck == null) return;

    final cards = deck.cards.map((card) {
      if (card.id == updatedCard.id) {
        return updatedCard;
      }
      return card;
    }).toList();

    final newDeck = Deck(
      id: deck.id,
      title: deck.title,
      cardType: deck.cardType,
      cards: cards,
      createdAt: deck.createdAt,
      frontPrefix: deck.frontPrefix,
    );

    HiveService.decksBox.put(deckId, newDeck);
  }

  // ✅ حذف بطاقة من مجموعة
  static void removeCardFromDeck(String deckId, CardModel card) {
    final deck = HiveService.decksBox.get(deckId);
    if (deck == null) return;

    final cards = deck.cards.where((c) => c.id != card.id).toList();

    final updatedDeck = Deck(
      id: deck.id,
      title: deck.title,
      cardType: deck.cardType,
      cards: cards,
      createdAt: deck.createdAt,
      frontPrefix: deck.frontPrefix,
    );

    HiveService.decksBox.put(deckId, updatedDeck);
  }
}
