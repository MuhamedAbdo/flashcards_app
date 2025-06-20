import 'package:flash_card_app/models/card_model.dart';
import 'package:flash_card_app/models/card_type.dart';
import 'package:flash_card_app/models/test_result_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flash_card_app/models/deck_model.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(DeckAdapter());
    Hive.registerAdapter(CardModelAdapter());
    Hive.registerAdapter(CardTypeAdapter());
    Hive.registerAdapter(TestResultAdapter());

    await Hive.openBox<Deck>('decks');
    await Hive.openBox<TestResult>('testResults');
  }

  static Box<Deck> get decksBox => Hive.box<Deck>('decks');
  static Box<TestResult> get testResultsBox =>
      Hive.box<TestResult>('testResults');
}
