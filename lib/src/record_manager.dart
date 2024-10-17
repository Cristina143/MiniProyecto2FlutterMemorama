import 'package:shared_preferences/shared_preferences.dart';

class RecordManager {
  static Future<void> saveRecord(int numPairs, int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    int? currentRecord = prefs.getInt('record_$numPairs');

    if (currentRecord == null || seconds < currentRecord) {
      prefs.setInt('record_$numPairs', seconds);
    }
  }

  static Future<int?> getRecord(int numPairs) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('record_$numPairs');
  }
}
