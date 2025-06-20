import 'package:hive/hive.dart';
import 'card_model.dart';
import 'card_type.dart';

part 'deck_model.g.dart';

@HiveType(typeId: 0)
class Deck extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final CardType cardType;

  @HiveField(4)
  final List<CardModel> cards;

  @HiveField(5)
  final String? frontPrefix;

  Deck({
    required this.id,
    required this.title,
    required this.cardType,
    required this.cards,
    this.frontPrefix,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int get cardCount => cards.length;

  Deck copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    CardType? cardType,
    List<CardModel>? cards,
    String? frontPrefix,
  }) {
    return Deck(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      cardType: cardType ?? this.cardType,
      cards: cards ?? this.cards,
      frontPrefix: frontPrefix ?? this.frontPrefix,
    );
  }
}
