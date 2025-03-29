// lib/services/storage_service.dart
import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox('datesBox');
    await Hive.openBox('datesBox2');
    await Hive.openBox('datesBox3');
    await Hive.openBox('ozonatBox');
  }

  // Agazat (Vacations) methods
  static List<Map<String, dynamic>> getAgazatList() {
    final box = Hive.box('datesBox');
    return List<Map<String, dynamic>>.from(
        box.get('savedAgazat', defaultValue: <Map<String, dynamic>>[]));
  }

  static Future<void> saveAgazatList(List<Map<String, dynamic>> data) async {
    final box = Hive.box('datesBox');
    await box.put('savedAgazat', data);
  }

  // Badalat (Substitutions) methods
  static List<Map<String, dynamic>> getBadalatList() {
    final box = Hive.box('datesBox3');
    return List<Map<String, dynamic>>.from(
        box.get('savedDates', defaultValue: <Map<String, dynamic>>[]));
  }

  static Future<void> saveBadalatList(List<Map<String, dynamic>> data) async {
    final box = Hive.box('datesBox3');
    await box.put('savedDates', data);
  }

// Add similar methods for ozonat
}
