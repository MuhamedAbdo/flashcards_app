import 'package:flutter/material.dart';

class AnswerOption extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback onTap;
  final TextDirection? textDirection;

  const AnswerOption({
    super.key,
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.onTap,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.grey;
    Color backgroundColor = Colors.white;
    Color textColor = Colors.black;
    IconData? icon;
    Color? iconColor;

    if (isCorrect) {
      borderColor = Colors.green;
      backgroundColor = Colors.green.withOpacity(0.1);
      textColor = Colors.green.shade900;
      icon = Icons.check;
      iconColor = Colors.green;
    }

    if (isWrong) {
      borderColor = Colors.red;
      backgroundColor = Colors.red.withOpacity(0.1);
      textColor = Colors.red.shade900;
      icon = Icons.close;
      iconColor = Colors.red;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            if (isCorrect || isWrong) Icon(icon, color: iconColor),
            if (isCorrect || isWrong) const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                textDirection: textDirection,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                  fontWeight: (isSelected || isCorrect)
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
