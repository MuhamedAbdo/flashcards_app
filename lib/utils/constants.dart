import 'package:flash_card_app/models/card_type.dart';
import 'package:flutter/material.dart';

class AppConstants {
  static const List<CardType> cardTypes = CardType.values;

  static const double cardBorderRadius = 16.0;
  static const double cardElevation = 4.0;
  static const EdgeInsets cardMargin = EdgeInsets.all(16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(20.0);

  static const Duration flipDuration = Duration(milliseconds: 500);
  static const Duration testCardFlipDuration = Duration(milliseconds: 300);

  static const int testQuestionCount = 20;
}
