import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flash_card_app/models/deck_model.dart';

class DeckWidget extends StatelessWidget {
  final Deck deck;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const DeckWidget({
    super.key,
    required this.deck,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      deck.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                    tooltip: 'حذف المجموعة',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('عدد البطاقات: ${deck.cardCount}'),
              const SizedBox(height: 4),
              Text(
                'تاريخ الإنشاء: ${dateFormat.format(deck.createdAt)}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
