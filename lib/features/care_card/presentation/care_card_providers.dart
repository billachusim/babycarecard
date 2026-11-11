import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/child.dart';
import '../../../data/models/care_entities.dart';
import '../../../data/repositories/providers.dart';

class ChildDetails {
  final Child child;
  final List<FeedingSchedule> feeding;
  final List<CareRoutine> routines;
  final List<Medication> medications;
  final List<EmergencyContact> emergencyContacts;
  final List<Pediatrician> pediatricians;

  ChildDetails({
    required this.child,
    required this.feeding,
    required this.routines,
    required this.medications,
    required this.emergencyContacts,
    required this.pediatricians,
  });
}

final childDetailsProvider = FutureProvider.family<ChildDetails, String>((ref, childId) async {
  final repository = ref.watch(childRepositoryProvider);
  
  final child = await repository.getChildById(childId);
  if (child == null) throw Exception('Child not found');

  final feeding = await repository.getFeedingSchedulesForChild(childId);
  final routines = await repository.getCareRoutinesForChild(childId);
  final medications = await repository.getMedicationsForChild(childId);
  final emergencyContacts = await repository.getEmergencyContactsForChild(childId);
  final pediatricians = await repository.getPediatriciansForChild(childId);

  return ChildDetails(
    child: child,
    feeding: feeding,
    routines: routines,
    medications: medications,
    emergencyContacts: emergencyContacts,
    pediatricians: pediatricians,
  );
});
