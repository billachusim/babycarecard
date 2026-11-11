import 'package:uuid/uuid.dart';

import '../../../data/models/care_entities.dart';
import '../../../data/models/child.dart';
import '../../../data/repositories/child_repository.dart';
import 'parsed_care_details.dart';

const _uuid = Uuid();

const _routineTitles = {
  'sleepRoutine': 'Naps and bedtime',
  'diaperingRoutine': 'Diapering / potty',
  'soothingInstructions': 'Soothing',
  'playtime': 'Playtime',
  'outdoorTime': 'Outdoor time',
  'screenTimeNotes': 'Screen time',
  'other': 'Other',
};

/// Writes reviewed voice-fill details into the local database.
///
/// Mirrors the web app's apply-parsed-details.ts, mapped onto the mobile
/// app's tables. Pass [existing] to add to a child that's already saved
/// (its name is never changed, and blanks never overwrite saved values);
/// leave it null to create a new child. Returns the child's id.
Future<String> applyParsedDetails(
  ChildRepository repository,
  ParsedCareDetails details, {
  Child? existing,
}) async {
  final childId = existing?.id ?? _uuid.v4();
  final p = details.child;

  final weightText = p['weight'];
  final weight = parseWeight(weightText);

  final extraNotes = <String>[
    if (p['approximateAge'] != null) 'Age: ${p['approximateAge']}',
    // The card doesn't show the numeric weight yet, so keep the spoken one.
    if (weightText != null) 'Weight: $weightText',
    if (p['thingsToKnow'] != null) p['thingsToKnow']!,
    if (details.emergency['specialInstructions'] != null)
      'In an emergency: ${details.emergency['specialInstructions']}',
  ];

  if (existing == null) {
    await repository.insertChild(Child(
      id: childId,
      name: p['name'] ?? 'My child',
      ageGroup: p['ageGroup'] ?? 'Other',
      allergies: p['allergies'],
      sex: p['sex'],
      weight: weight,
      personality: p['personality'],
      importantNotes: extraNotes.isEmpty ? null : extraNotes.join('\n'),
    ));
  } else {
    final notes = [
      if (existing.importantNotes != null) existing.importantNotes!,
      ...extraNotes,
    ];
    await repository.updateChild(Child(
      id: existing.id,
      name: existing.name,
      ageGroup: p['ageGroup'] ?? existing.ageGroup,
      allergies: p['allergies'] ?? existing.allergies,
      sex: p['sex'] ?? existing.sex,
      birthDate: existing.birthDate,
      weight: weight ?? existing.weight,
      photoPath: existing.photoPath,
      personality: p['personality'] ?? existing.personality,
      importantNotes: notes.isEmpty ? null : notes.join('\n'),
    ));
  }

  final f = details.feeding;
  if (f.isNotEmpty) {
    final instructions = [
      if (f['foodName'] != null) f['foodName']!,
      if (f['snacks'] != null) 'Snacks: ${f['snacks']}',
      if (f['foodsToAvoid'] != null) 'Avoid: ${f['foodsToAvoid']}',
      if (f['notes'] != null) f['notes']!,
    ];
    await repository.insertFeedingSchedule(FeedingSchedule(
      id: _uuid.v4(),
      childId: childId,
      name: 'Daily Food',
      time: f['times'] ??
          (f['mealsPerDay'] != null ? '${f['mealsPerDay']} meals a day' : 'Scheduled'),
      amount: f['amount'] ?? 'Normal',
      instructions: instructions.isEmpty ? null : instructions.join('\n'),
    ));
  }

  for (final entry in _routineTitles.entries) {
    final value = details.routine[entry.key];
    if (value == null) continue;
    await repository.insertCareRoutine(CareRoutine(
      id: _uuid.v4(),
      childId: childId,
      title: entry.value,
      instructions: value,
    ));
  }

  for (final med in details.medications) {
    if (med.name.trim().isEmpty) continue;
    await repository.insertMedication(Medication(
      id: _uuid.v4(),
      childId: childId,
      name: med.name.trim(),
      instructions: med.dosage ?? '',
      time: med.time ?? '',
      frequency: med.frequency,
      notes: med.notes,
    ));
  }

  final e = details.emergency;
  for (final prefix in const ['primary', 'secondary']) {
    final name = e['${prefix}Name'];
    final phone = e['${prefix}Phone'];
    if (name == null && phone == null) continue;
    await repository.insertEmergencyContact(EmergencyContact(
      id: _uuid.v4(),
      childId: childId,
      name: name ?? 'Emergency contact',
      phone: phone ?? '',
    ));
  }

  final v = details.pediatrician;
  if (v.isNotEmpty) {
    await repository.insertPediatrician(Pediatrician(
      id: _uuid.v4(),
      childId: childId,
      name: v['doctorName'] ?? v['clinicName'] ?? 'Pediatrician',
      clinic: v['clinicName'],
      phone: v['phone'],
      address: v['address'],
    ));
  }

  return childId;
}

/// Kilograms from "12", "12.5 kg" or "about 30 kilos"; pounds are
/// converted. Anything else (ranges, "a bit chubby") gives null.
double? parseWeight(String? text) {
  if (text == null) return null;
  final match = RegExp(
    r'^(?:about|around|roughly|nearly|almost)?\s*(\d+(?:\.\d+)?)\s*(kg|kgs|kilos?|kilograms?|lbs?|pounds?)?$',
    caseSensitive: false,
  ).firstMatch(text.trim());
  if (match == null) return null;
  final value = double.parse(match.group(1)!);
  final unit = match.group(2)?.toLowerCase() ?? '';
  if (unit.startsWith('lb') || unit.startsWith('pound')) {
    return double.parse((value * 0.45359237).toStringAsFixed(1));
  }
  return value;
}
