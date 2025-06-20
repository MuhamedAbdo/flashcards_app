import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'card_type.g.dart';

@HiveType(typeId: 3)
enum CardType {
  @HiveField(0)
  programming,
  @HiveField(1)
  math,
  @HiveField(2)
  git,
  @HiveField(3)
  text,
  @HiveField(4)
  other;

  String get displayName {
    switch (this) {
      case CardType.programming:
        return 'برمجة';
      case CardType.math:
        return 'رياضيات';
      case CardType.git:
        return 'Git';
      case CardType.text:
        return 'نصي';
      case CardType.other:
        return 'أخرى';
    }
  }

  Color get color {
    switch (this) {
      case CardType.programming:
        return Colors.blueAccent.shade700;
      case CardType.math:
        return Colors.purpleAccent.shade700;
      case CardType.git:
        return Colors.deepOrange.shade700;
      case CardType.text:
        return Colors.teal.shade700;
      case CardType.other:
        return Colors.blueGrey.shade700;
    }
  }
}
