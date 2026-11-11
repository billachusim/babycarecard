/// Care-card details pulled out of a spoken description.
///
/// Mirrors `ParsedCareDetails` in the Baby Care Cards web app
/// (src/features/voice/voice-types.ts), so the phone and the website share
/// one shape. Every field is optional: null means "not mentioned".
library;

const voiceAgeGroups = ['Newborn', 'Infant', 'Toddler', 'Preschooler', 'School age', 'Other'];
const voiceSexes = ['Boy', 'Girl', 'Prefer not to say'];

/// A labelled group of text fields (child, feeding, routine, ...).
///
/// Kept as an ordered map so the review screen can show and edit every
/// field without a hand-written form per section.
class FieldGroup {
  final Map<String, String?> values;

  FieldGroup(Map<String, String?> values) : values = Map.of(values);

  FieldGroup.empty(List<String> keys)
      : values = {for (final key in keys) key: null};

  String? operator [](String key) => values[key];

  void operator []=(String key, String? value) {
    final trimmed = value?.trim();
    values[key] = (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  bool get isEmpty => values.values.every((v) => v == null);
  bool get isNotEmpty => !isEmpty;

  static FieldGroup fromJson(Object? json, List<String> keys) {
    final source = json is Map ? json : const {};
    final group = FieldGroup.empty(keys);
    for (final key in keys) {
      group[key] = cleanString(source[key]);
    }
    return group;
  }

  Map<String, String?> toJson() => Map.of(values);
}

class ParsedMedication {
  String name;
  String? dosage;
  String? time;
  String? frequency;
  String? notes;

  ParsedMedication({
    required this.name,
    this.dosage,
    this.time,
    this.frequency,
    this.notes,
  });

  factory ParsedMedication.fromJson(Map json) => ParsedMedication(
        name: cleanString(json['name']) ?? '',
        dosage: cleanString(json['dosage']),
        time: cleanString(json['time']),
        frequency: cleanString(json['frequency']),
        notes: cleanString(json['notes']),
      );

  Map<String, String?> toJson() => {
        'name': name,
        'dosage': dosage,
        'time': time,
        'frequency': frequency,
        'notes': notes,
      };
}

class ParsedCareDetails {
  static const childKeys = [
    'name',
    'ageGroup',
    'sex',
    'approximateAge',
    'weight',
    'allergies',
    'personality',
    'thingsToKnow',
  ];
  static const feedingKeys = [
    'foodName',
    'amount',
    'times',
    'mealsPerDay',
    'snacks',
    'foodsToAvoid',
    'notes',
  ];
  static const routineKeys = [
    'outdoorTime',
    'playtime',
    'sleepRoutine',
    'diaperingRoutine',
    'soothingInstructions',
    'screenTimeNotes',
    'other',
  ];
  static const emergencyKeys = [
    'primaryName',
    'primaryPhone',
    'secondaryName',
    'secondaryPhone',
    'specialInstructions',
  ];
  static const pediatricianKeys = ['doctorName', 'clinicName', 'phone', 'address'];

  final FieldGroup child;
  final FieldGroup feeding;
  final FieldGroup routine;
  final List<ParsedMedication> medications;
  final FieldGroup emergency;
  final FieldGroup pediatrician;

  ParsedCareDetails({
    required this.child,
    required this.feeding,
    required this.routine,
    required this.medications,
    required this.emergency,
    required this.pediatrician,
  });

  factory ParsedCareDetails.empty() => ParsedCareDetails(
        child: FieldGroup.empty(childKeys),
        feeding: FieldGroup.empty(feedingKeys),
        routine: FieldGroup.empty(routineKeys),
        medications: [],
        emergency: FieldGroup.empty(emergencyKeys),
        pediatrician: FieldGroup.empty(pediatricianKeys),
      );

  /// Reads the JSON the web app's parser returns, tolerating missing or
  /// malformed parts the same way the server's `normalize()` does.
  factory ParsedCareDetails.fromJson(Map json) {
    final details = ParsedCareDetails(
      child: FieldGroup.fromJson(json['child'], childKeys),
      feeding: FieldGroup.fromJson(json['feeding'], feedingKeys),
      routine: FieldGroup.fromJson(json['routine'], routineKeys),
      medications: [
        if (json['medications'] is List)
          for (final med in json['medications'] as List)
            if (med is Map) ParsedMedication.fromJson(med),
      ]..removeWhere((med) => med.name.isEmpty),
      emergency: FieldGroup.fromJson(json['emergency'], emergencyKeys),
      pediatrician: FieldGroup.fromJson(json['pediatrician'], pediatricianKeys),
    );
    details.child['ageGroup'] = oneOf(details.child['ageGroup'], voiceAgeGroups);
    details.child['sex'] = oneOf(details.child['sex'], voiceSexes);
    return details;
  }

  Map<String, Object?> toJson() => {
        'child': child.toJson(),
        'feeding': feeding.toJson(),
        'routine': routine.toJson(),
        'medications': [for (final med in medications) med.toJson()],
        'emergency': emergency.toJson(),
        'pediatrician': pediatrician.toJson(),
      };

  bool get isEmpty =>
      child.isEmpty &&
      feeding.isEmpty &&
      routine.isEmpty &&
      medications.isEmpty &&
      emergency.isEmpty &&
      pediatrician.isEmpty;
}

String? cleanString(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String? oneOf(String? value, List<String> allowed) {
  if (value == null) return null;
  for (final option in allowed) {
    if (option.toLowerCase() == value.toLowerCase()) return option;
  }
  return null;
}
