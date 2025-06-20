import 'package:flutter/material.dart';
import 'package:flash_card_app/models/card_type.dart';
import 'package:flash_card_app/models/deck_model.dart';
import 'package:flash_card_app/services/deck_service.dart';
import 'package:flash_card_app/utils/constants.dart';

class AddDeckScreen extends StatefulWidget {
  final Deck? deckToEdit;
  const AddDeckScreen({super.key, this.deckToEdit});

  @override
  AddDeckScreenState createState() => AddDeckScreenState();
}

class AddDeckScreenState extends State<AddDeckScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _prefixController = TextEditingController();
  CardType _selectedType = CardType.other;
  bool _isEditing = false;

  bool get _isOtherSelected => _selectedType == CardType.other;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.deckToEdit != null;

    if (_isEditing) {
      _selectedType = widget.deckToEdit!.cardType;
      _titleController.text = widget.deckToEdit!.title;
      _prefixController.text = widget.deckToEdit!.frontPrefix ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'تعديل المجموعة' : 'إنشاء مجموعة جديدة'),
        actions: _isEditing
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {}, // سيتم إضافة الوظيفة لاحقاً
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _confirmDeleteDeck,
                ),
              ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<CardType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'نوع البطاقات',
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.cardTypes.map((type) {
                  return DropdownMenuItem<CardType>(
                    value: type,
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          color: type.color,
                        ),
                        const SizedBox(width: 10),
                        Text(type.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              if (_selectedType == CardType.other)
                Column(
                  children: [
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'عنوان المجموعة',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال عنوان للمجموعة';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: _saveDeck,
                child: Text(_isEditing ? 'حفظ التعديلات' : 'إنشاء المجموعة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveDeck() {
    if (_formKey.currentState!.validate()) {
      final deck = Deck(
        id: _isEditing ? widget.deckToEdit!.id : DeckService.generateId(),
        title: _selectedType == CardType.other
            ? _titleController.text
            : _selectedType.displayName,
        cardType: _selectedType,
        frontPrefix:
            _prefixController.text.isEmpty ? null : _prefixController.text,
        cards: _isEditing ? widget.deckToEdit!.cards : [],
      );

      if (_isEditing) {
        DeckService.updateDeck(deck);
      } else {
        DeckService.addDeck(deck);
      }
      Navigator.pop(context);
    }
  }

  void _confirmDeleteDeck() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد أنك تريد حذف هذه المجموعة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteDeck();
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteDeck() {
    DeckService.deleteDeck(widget.deckToEdit!.id);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _prefixController.dispose();
    super.dispose();
  }
}
