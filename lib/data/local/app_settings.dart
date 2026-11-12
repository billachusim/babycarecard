import 'package:sqflite/sqflite.dart';

import 'database_service.dart';

/// Small key/value flags kept in the app's own database.
class AppSettings {
  AppSettings._();

  static const _onboardingDone = 'onboarding_done';

  static Future<Database> _db() async {
    final db = await DatabaseService.instance.database;
    await db.execute(
      'CREATE TABLE IF NOT EXISTS app_settings (key TEXT PRIMARY KEY, value TEXT)',
    );
    return db;
  }

  /// True once the parent has finished onboarding, or already has a card
  /// (so people updating from build 1-3 don't see onboarding again).
  static Future<bool> isOnboardingDone() async {
    try {
      final db = await _db();
      final rows = await db.query('app_settings',
          where: 'key = ?', whereArgs: [_onboardingDone]);
      if (rows.isNotEmpty && rows.first['value'] == 'true') return true;
      final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM children'));
      return (count ?? 0) > 0;
    } catch (_) {
      return false;
    }
  }

  static Future<void> setOnboardingDone() async {
    try {
      final db = await _db();
      await db.insert('app_settings', {'key': _onboardingDone, 'value': 'true'},
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (_) {
      // Not worth blocking the user over; worst case they see onboarding again.
    }
  }
}
