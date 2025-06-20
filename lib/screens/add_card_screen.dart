import 'package:flutter/material.dart';
import 'package:flash_card_app/models/card_model.dart';
import 'package:flash_card_app/models/card_type.dart';
import 'package:flash_card_app/services/deck_service.dart';

class AddCardScreen extends StatefulWidget {
  final String deckId;
  final CardModel? cardToEdit;
  final CardType? suggestedCardType;
  final String? defaultFrontPrefix;

  const AddCardScreen({
    super.key,
    required this.deckId,
    this.cardToEdit,
    this.suggestedCardType,
    this.defaultFrontPrefix,
  });

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _frontController;
  final TextEditingController _backController = TextEditingController();
  late CardType? _selectedType;

  @override
  void initState() {
    super.initState();
    final initialFrontText = widget.cardToEdit?.frontText ??
        (widget.defaultFrontPrefix != null
            ? '${widget.defaultFrontPrefix} '
            : '');
    _frontController = TextEditingController(text: initialFrontText);
    _backController.text = widget.cardToEdit?.backText ?? '';
    _selectedType = widget.cardToEdit?.cardType ?? widget.suggestedCardType;
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }

  void _saveCard() {
    if (_formKey.currentState!.validate()) {
      final card = CardModel(
        id: widget.cardToEdit?.id ?? DeckService.generateId(),
        frontText: _frontController.text,
        backText: _backController.text,
        cardType: _selectedType ?? CardType.other,
        createdAt: widget.cardToEdit?.createdAt ?? DateTime.now(),
        deckFrontPrefix: widget.defaultFrontPrefix,
      );

      if (widget.cardToEdit != null) {
        DeckService.updateCardInDeck(widget.deckId, card);
      } else {
        DeckService.addCardToDeck(widget.deckId, card);
      }

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cardToEdit == null ? 'إضافة بطاقة' : 'تعديل بطاقة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (widget.defaultFrontPrefix != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'المقدمة: ${widget.defaultFrontPrefix}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              TextFormField(
                controller: _frontController,
                decoration: InputDecoration(
                  labelText: widget.defaultFrontPrefix != null
                      ? 'النص الرئيسي'
                      : 'الوجه الأمامي',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'هذا الحقل مطلوب' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _backController,
                decoration: const InputDecoration(
                  labelText: 'الوجه الخلفي',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'هذا الحقل مطلوب' : null,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _saveCard,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('حفظ البطاقة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
