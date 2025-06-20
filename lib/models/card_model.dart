import 'package:flash_card_app/models/card_type.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

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
  final String? deckFrontPrefix;

  @HiveField(6)
  final TextDirection frontTextDirection;

  @HiveField(7)
  final TextDirection backTextDirection;

  CardModel({
    required this.id,
    required this.frontText,
    required this.backText,
    DateTime? createdAt,
    required this.cardType,
    this.deckFrontPrefix,
    this.frontTextDirection = TextDirection.ltr,
    this.backTextDirection = TextDirection.rtl,
  }) : createdAt = createdAt ?? DateTime.now();

  CardModel copyWith({
    String? id,
    String? frontText,
    String? backText,
    DateTime? createdAt,
    CardType? cardType,
    String? deckFrontPrefix,
    TextDirection? frontTextDirection,
    TextDirection? backTextDirection,
  }) {
    return CardModel(
      id: id ?? this.id,
      frontText: frontText ?? this.frontText,
      backText: backText ?? this.backText,
      createdAt: createdAt ?? this.createdAt,
      cardType: cardType ?? this.cardType,
      deckFrontPrefix: deckFrontPrefix ?? this.deckFrontPrefix,
      frontTextDirection: frontTextDirection ?? this.frontTextDirection,
      backTextDirection: backTextDirection ?? this.backTextDirection,
    );
  }
}
