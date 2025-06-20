import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // ✅ إضافة هذه المكتبة
import 'screens/home_screen.dart';
import 'services/hive_service.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ تهيئة دعم التنسيق للغة العربية
  await initializeDateFormatting('ar', null);

  // ✅ تهيئة Hive
  await HiveService.init();

  runApp(FlashCardApp());
}

class FlashCardApp extends StatelessWidget {
  const FlashCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'بطاقات تعليمية',
      theme: AppTheme.lightTheme,
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
