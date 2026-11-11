import 'package:sqflite/sqflite.dart';
import '../models/child.dart';
import '../models/care_entities.dart';
import '../local/database_service.dart';

class ChildRepository {
  final DatabaseService _dbService;

  ChildRepository(this._dbService);

  // --- Child ---

  Future<void> insertChild(Child child) async {
    final db = await _dbService.database;
    await db.insert('children', child.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Child>> getAllChildren() async {
    final db = await _dbService.database;
    final maps = await db.query('children');
    return maps.map((map) => Child.fromMap(map)).toList();
  }

  Future<Child?> getChildById(String id) async {
    final db = await _dbService.database;
    final maps = await db.query('children', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Child.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateChild(Child child) async {
    final db = await _dbService.database;
    await db.update('children', child.toMap(), where: 'id = ?', whereArgs: [child.id]);
  }

  Future<void> deleteChild(String id) async {
    final db = await _dbService.database;
    await db.delete('children', where: 'id = ?', whereArgs: [id]);
  }

  // --- Feeding Schedule ---

  Future<void> insertFeedingSchedule(FeedingSchedule schedule) async {
    final db = await _dbService.database;
    await db.insert('feeding_schedules', schedule.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<FeedingSchedule>> getFeedingSchedulesForChild(String childId) async {
    final db = await _dbService.database;
    final maps = await db.query('feeding_schedules', where: 'childId = ?', whereArgs: [childId]);
    return maps.map((map) => FeedingSchedule.fromMap(map)).toList();
  }

  Future<void> deleteFeedingSchedule(String id) async {
    final db = await _dbService.database;
    await db.delete('feeding_schedules', where: 'id = ?', whereArgs: [id]);
  }

  // --- Care Routine ---

  Future<void> insertCareRoutine(CareRoutine routine) async {
    final db = await _dbService.database;
    await db.insert('care_routines', routine.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<CareRoutine>> getCareRoutinesForChild(String childId) async {
    final db = await _dbService.database;
    final maps = await db.query('care_routines', where: 'childId = ?', whereArgs: [childId]);
    return maps.map((map) => CareRoutine.fromMap(map)).toList();
  }

  Future<void> deleteCareRoutine(String id) async {
    final db = await _dbService.database;
    await db.delete('care_routines', where: 'id = ?', whereArgs: [id]);
  }

  // --- Medication ---

  Future<void> insertMedication(Medication medication) async {
    final db = await _dbService.database;
    await db.insert('medications', medication.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Medication>> getMedicationsForChild(String childId) async {
    final db = await _dbService.database;
    final maps = await db.query('medications', where: 'childId = ?', whereArgs: [childId]);
    return maps.map((map) => Medication.fromMap(map)).toList();
  }

  Future<void> deleteMedication(String id) async {
    final db = await _dbService.database;
    await db.delete('medications', where: 'id = ?', whereArgs: [id]);
  }

  // --- Reminder ---

  Future<void> insertReminder(Reminder reminder) async {
    final db = await _dbService.database;
    await db.insert('reminders', reminder.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Reminder>> getRemindersForChild(String childId) async {
    final db = await _dbService.database;
    final maps = await db.query('reminders', where: 'childId = ?', whereArgs: [childId]);
    return maps.map((map) => Reminder.fromMap(map)).toList();
  }

  Future<void> deleteReminder(String id) async {
    final db = await _dbService.database;
    await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }

  // --- Emergency Contact ---

  Future<void> insertEmergencyContact(EmergencyContact contact) async {
    final db = await _dbService.database;
    await db.insert('emergency_contacts', contact.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<EmergencyContact>> getEmergencyContactsForChild(String childId) async {
    final db = await _dbService.database;
    final maps = await db.query('emergency_contacts', where: 'childId = ?', whereArgs: [childId]);
    return maps.map((map) => EmergencyContact.fromMap(map)).toList();
  }

  // --- Pediatrician ---

  Future<void> insertPediatrician(Pediatrician pediatrician) async {
    final db = await _dbService.database;
    await db.insert('pediatricians', pediatrician.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Pediatrician>> getPediatriciansForChild(String childId) async {
    final db = await _dbService.database;
    final maps = await db.query('pediatricians', where: 'childId = ?', whereArgs: [childId]);
    return maps.map((map) => Pediatrician.fromMap(map)).toList();
  }
}
