import 'package:flutter/material.dart';
import 'package:flash_card_app/models/card_type.dart';
import 'package:flash_card_app/models/card_model.dart';
import 'package:flash_card_app/services/deck_service.dart';
import 'package:uuid/uuid.dart';

class AddCardScreen extends StatefulWidget {
  final String deckId;
  final CardType suggestedCardType;
  final String? defaultFrontPrefix;
  final CardModel? cardToEdit;

  const AddCardScreen({
    super.key,
    required this.deckId,
    required this.suggestedCardType,
    this.defaultFrontPrefix,
    this.cardToEdit,
  });

  @override
  _AddCardScreenState createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _frontController = TextEditingController();
  final _backController = TextEditingController();
  late TextDirection _frontDirection;
  late TextDirection _backDirection;

  @override
  void initState() {
    super.initState();

    if (widget.cardToEdit != null) {
      _frontController.text = widget.cardToEdit!.frontText;
      _backController.text = widget.cardToEdit!.backText;
      _frontDirection =
          widget.cardToEdit?.frontTextDirection ?? TextDirection.ltr;
      _backDirection =
          widget.cardToEdit?.backTextDirection ?? TextDirection.rtl;
    } else {
      _frontDirection = TextDirection.ltr;
      _backDirection = TextDirection.rtl;
    }
  }

  void _saveCard() {
    if (_formKey.currentState!.validate()) {
      final newCard = CardModel(
        id: widget.cardToEdit?.id ?? const Uuid().v4(),
        frontText: _frontController.text,
        backText: _backController.text,
        cardType: widget.suggestedCardType,
        deckFrontPrefix: widget.defaultFrontPrefix,
        frontTextDirection: _frontDirection,
        backTextDirection: _backDirection,
      );

      if (widget.cardToEdit != null) {
        DeckService.updateCardInDeck(widget.deckId, newCard);
      } else {
        DeckService.addCardToDeck(widget.deckId, newCard);
      }

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.cardToEdit != null ? 'تعديل البطاقة' : 'إضافة بطاقة جديدة'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _frontController,
                decoration: const InputDecoration(labelText: 'الوجه الأمامي'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال نص للوجه الأمامي';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _backController,
                decoration: const InputDecoration(labelText: 'الوجه الخلفي'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال نص للوجه الخلفي';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text("اتجاه الكتابة للوجه الأمامي"),
              DropdownButton<TextDirection>(
                isExpanded: true,
                value: _frontDirection,
                items: const [
                  DropdownMenuItem(
                      value: TextDirection.ltr,
                      child: Text('LTR - من اليسار لليمين')),
                  DropdownMenuItem(
                      value: TextDirection.rtl,
                      child: Text('RTL - من اليمين لليسار')),
                ],
                onChanged: (value) {
                  setState(() {
                    _frontDirection = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              const Text("اتجاه الكتابة للوجه الخلفي"),
              DropdownButton<TextDirection>(
                isExpanded: true,
                value: _backDirection,
                items: const [
                  DropdownMenuItem(
                      value: TextDirection.ltr,
                      child: Text('LTR - من اليسار لليمين')),
                  DropdownMenuItem(
                      value: TextDirection.rtl,
                      child: Text('RTL - من اليمين لليسار')),
                ],
                onChanged: (value) {
                  setState(() {
                    _backDirection = value!;
                  });
                },
              ),
              const Spacer(), // لدفع الزر إلى الأسفل
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _saveCard,
                icon: const Icon(Icons.save),
                label: const Text('حفظ البطاقة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
