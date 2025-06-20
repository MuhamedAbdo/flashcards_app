import 'package:hive/hive.dart';
import 'card_type.dart';

part 'card_model.g.dart';

@HiveType(typeId: 1)
class CardModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String frontText;

  @HiveField(2)
  final String backText;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final CardType cardType;

  @HiveField(5)
  final String? deckFrontPrefix; // إضافة الحقل الجديد

  CardModel({
    required this.id,
    required this.frontText,
    required this.backText,
    DateTime? createdAt,
    required this.cardType,
    this.deckFrontPrefix, // إضافته كمعلمة اختيارية
  }) : createdAt = createdAt ?? DateTime.now();

  CardModel copyWith({
    String? id,
    String? frontText,
    String? backText,
    DateTime? createdAt,
    CardType? cardType,
    String? deckFrontPrefix, // إضافته في copyWith
  }) {
    return CardModel(
      id: id ?? this.id,
      frontText: frontText ?? this.frontText,
      backText: backText ?? this.backText,
      createdAt: createdAt ?? this.createdAt,
      cardType: cardType ?? this.cardType,
      deckFrontPrefix: deckFrontPrefix ?? this.deckFrontPrefix,
    );
  }
}
