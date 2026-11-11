import 'package:flutter_test/flutter_test.dart';
import 'package:baby_care_card/data/local/database_service.dart';
import 'package:baby_care_card/data/models/care_entities.dart';
import 'package:baby_care_card/data/models/child.dart';
import 'package:baby_care_card/data/repositories/child_repository.dart';
import 'package:baby_care_card/features/voice/data/apply_parsed_details.dart';
import 'package:baby_care_card/features/voice/data/parsed_care_details.dart';
import 'package:baby_care_card/features/voice/data/voice_fill_service.dart';

/// In-memory stand-in for the sqflite repository.
class FakeRepository extends ChildRepository {
  FakeRepository() : super(DatabaseService.instance);

  final children = <String, Child>{};
  final feeding = <FeedingSchedule>[];
  final routines = <CareRoutine>[];
  final meds = <Medication>[];
  final contacts = <EmergencyContact>[];
  final pediatricians = <Pediatrician>[];

  @override
  Future<void> insertChild(Child child) async => children[child.id] = child;
  @override
  Future<void> updateChild(Child child) async => children[child.id] = child;
  @override
  Future<void> insertFeedingSchedule(FeedingSchedule s) async => feeding.add(s);
  @override
  Future<void> insertCareRoutine(CareRoutine r) async => routines.add(r);
  @override
  Future<void> insertMedication(Medication m) async => meds.add(m);
  @override
  Future<void> insertEmergencyContact(EmergencyContact c) async => contacts.add(c);
  @override
  Future<void> insertPediatrician(Pediatrician v) async => pediatricians.add(v);
}

// The shape the web app's /api/public/voice/parse returns.
final serverReply = {
  'child': {
    'name': 'Mia',
    'ageGroup': 'Toddler',
    'allergies': 'Peanuts',
    'sex': 'Girl',
    'approximateAge': '14 months',
    'weight': '10 kg',
    'personality': 'Cheerful, loves stacking cups',
    'thingsToKnow': null,
  },
  'feeding': {
    'foodName': 'Formula',
    'amount': '6 oz',
    'times': '7am, noon and 6pm',
    'mealsPerDay': null,
    'snacks': null,
    'foodsToAvoid': 'Honey, whole nuts',
    'notes': null,
  },
  'routine': {
    'outdoorTime': null,
    'playtime': null,
    'sleepRoutine': '  ',
    'diaperingRoutine': 'Change before every nap',
    'soothingInstructions': null,
    'screenTimeNotes': null,
    'other': null,
  },
  'medications': [
    {'name': 'Vitamin D drops', 'dosage': 'Half a dropper', 'time': 'Morning', 'frequency': 'Daily', 'notes': null},
    {'name': '', 'dosage': 'ignored'},
  ],
  'emergency': {
    'primaryName': 'Sarah',
    'primaryPhone': '555 0100',
    'secondaryName': null,
    'secondaryPhone': null,
    'specialInstructions': null,
  },
  'pediatrician': {
    'doctorName': null,
    'clinicName': 'Green Lane Pediatrics',
    'phone': '555 0134',
    'address': null,
  },
};

void main() {
  group('ParsedCareDetails.fromJson', () {
    test('reads the server reply and drops blanks', () {
      final d = ParsedCareDetails.fromJson(serverReply);
      expect(d.child['name'], 'Mia');
      expect(d.routine['sleepRoutine'], isNull);
      expect(d.medications, hasLength(1));
      expect(d.medications.first.dosage, 'Half a dropper');
      expect(d.isEmpty, isFalse);
    });

    test('rejects unknown ageGroup and sex, tolerates junk', () {
      final d = ParsedCareDetails.fromJson({
        'child': {'ageGroup': 'teenager', 'sex': 'girl'},
        'medications': 'nope',
        'feeding': 42,
      });
      expect(d.child['ageGroup'], isNull);
      expect(d.child['sex'], 'Girl');
      expect(d.medications, isEmpty);
      expect(d.feeding.isEmpty, isTrue);
    });
  });

  group('parseWeight', () {
    test('handles kilos, pounds and plain numbers', () {
      expect(parseWeight('12 kg'), 12);
      expect(parseWeight('about 7.5 kilos'), 7.5);
      expect(parseWeight('22 pounds'), 10.0);
      expect(parseWeight('30'), 30);
      expect(parseWeight('a bit chubby'), isNull);
      expect(parseWeight('10-12 kg'), isNull);
    });
  });

  group('applyParsedDetails', () {
    test('creates a full care card for a new child', () async {
      final repo = FakeRepository();
      final id = await applyParsedDetails(repo, ParsedCareDetails.fromJson(serverReply));

      final child = repo.children[id]!;
      expect(child.name, 'Mia');
      expect(child.ageGroup, 'Toddler');
      expect(child.allergies, 'Peanuts');
      expect(child.sex, 'Girl');
      expect(child.weight, 10);
      expect(child.importantNotes, contains('Age: 14 months'));
      expect(repo.feeding.single.time, '7am, noon and 6pm');
      expect(repo.feeding.single.instructions, contains('Avoid: Honey, whole nuts'));
      expect(repo.routines.single.title, 'Diapering / potty');
      expect(repo.meds.single.name, 'Vitamin D drops');
      expect(repo.contacts.single.phone, '555 0100');
      expect(repo.pediatricians.single.name, 'Green Lane Pediatrics');
    });

    test('adds to an existing child without overwriting its name or saved values', () async {
      final repo = FakeRepository();
      final existing = Child(
        id: 'p1',
        name: 'Leo',
        ageGroup: 'Infant',
        allergies: 'Penicillin',
        importantNotes: 'Shy with strangers',
      );
      repo.children['p1'] = existing;

      final details = ParsedCareDetails.empty();
      details.child['name'] = 'Someone else';
      details.child['personality'] = 'Sleepy';
      details.routine['playtime'] = 'Tummy time after breakfast';

      final id = await applyParsedDetails(repo, details, existing: existing);

      expect(id, 'p1');
      final child = repo.children['p1']!;
      expect(child.name, 'Leo');
      expect(child.ageGroup, 'Infant');
      expect(child.allergies, 'Penicillin');
      expect(child.personality, 'Sleepy');
      expect(child.importantNotes, 'Shy with strangers');
      expect(repo.routines.single.title, 'Playtime');
      expect(repo.feeding, isEmpty);
    });
  });

  test('offline parser fills the basics', () {
    final d = VoiceFillService.offlineParse('This is Max, our toddler, and he is playful');
    expect(d.child['name'], 'Max');
    expect(d.child['ageGroup'], 'Toddler');
  });
}
