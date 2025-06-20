import 'package:flutter/material.dart';
import 'package:flash_card_app/models/card_model.dart';
import 'package:flash_card_app/models/card_type.dart';

class CardWidget extends StatelessWidget {
  final CardModel card;
  final bool isFront;
  final CardType cardType;
  final bool isTestMode;
  final EdgeInsetsGeometry? margin;
  final double? heightFactor;

  const CardWidget({
    super.key,
    required this.card,
    required this.isFront,
    required this.cardType,
    this.isTestMode = false,
    this.margin,
    this.heightFactor = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    String displayText = isFront ? card.frontText : card.backText;

    // إضافة المقدمة إذا كانت موجودة وليس في وضع الاختبار
    if (isFront && !isTestMode && card.deckFrontPrefix != null) {
      displayText = '${card.deckFrontPrefix} $displayText';
    }

    return Center(
      child: Container(
        margin:
            margin ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardType.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        width: double.infinity,
        height: MediaQuery.of(context).size.height * heightFactor!,
        child: SingleChildScrollView(
          child: Text(
            displayText,
            style: TextStyle(
              fontSize: _calculateFontSize(displayText.length),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
        ),
      ),
    );
  }

  double _calculateFontSize(int textLength) {
    if (isTestMode) return 18;

    if (textLength > 200) return 16;
    if (textLength > 100) return 18;
    if (textLength > 50) return 20;
    return 24;
  }
}
