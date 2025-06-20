import 'package:flash_card_app/models/deck_model.dart';
import 'package:flash_card_app/screens/deck_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_card_app/screens/add_deck_screen.dart';
import 'package:flash_card_app/screens/test_screen.dart';
import 'package:flash_card_app/services/hive_service.dart';
import 'package:flash_card_app/widgets/deck_widget.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key}); // ✅ إضافة super.key

  @override
  HomeScreenState createState() => HomeScreenState(); // ✅ كلاس عام
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مجموعات البطاقات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.quiz),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TestScreen()),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: HiveService.decksBox.listenable(),
        builder: (context, Box<Deck> box, _) {
          final decks = box.values.toList();

          if (decks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.collections_bookmark,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد مجموعات بطاقات',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: decks.length,
            itemBuilder: (context, index) {
              final deck = decks[index];
              return DeckWidget(
                deck: deck,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeckScreen(deckId: deck.id),
                    ),
                  );
                },
                onDelete: () {
                  _deleteDeck(deck.id);
                },
              ).animate().fadeIn(delay: (100 * index).ms);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDeckScreen()),
          );
        },
      ),
    );
  }

  void _deleteDeck(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المجموعة'),
        content: const Text('هل أنت متأكد أنك تريد حذف هذه المجموعة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              HiveService.decksBox.delete(id);
              Navigator.pop(context);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
