class FeedingSchedule {
  final String id;
  final String childId;
  final String name; // e.g. Breakfast
  final String time; // e.g. 08:00 AM
  final String amount;
  final String? instructions;

  FeedingSchedule({
    required this.id,
    required this.childId,
    required this.name,
    required this.time,
    required this.amount,
    this.instructions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childId': childId,
      'name': name,
      'time': time,
      'amount': amount,
      'instructions': instructions,
    };
  }

  factory FeedingSchedule.fromMap(Map<String, dynamic> map) {
    return FeedingSchedule(
      id: map['id'],
      childId: map['childId'],
      name: map['name'],
      time: map['time'],
      amount: map['amount'],
      instructions: map['instructions'],
    );
  }
}

class CareRoutine {
  final String id;
  final String childId;
  final String title; // e.g. Walk
  final String instructions;
  final String? schedule;

  CareRoutine({
    required this.id,
    required this.childId,
    required this.title,
    required this.instructions,
    this.schedule,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childId': childId,
      'title': title,
      'instructions': instructions,
      'schedule': schedule,
    };
  }

  factory CareRoutine.fromMap(Map<String, dynamic> map) {
    return CareRoutine(
      id: map['id'],
      childId: map['childId'],
      title: map['title'],
      instructions: map['instructions'],
      schedule: map['schedule'],
    );
  }
}

class Medication {
  final String id;
  final String childId;
  final String name;
  final String instructions;
  final String time;
  final String? frequency;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? notes;

  Medication({
    required this.id,
    required this.childId,
    required this.name,
    required this.instructions,
    required this.time,
    this.frequency,
    this.startDate,
    this.endDate,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childId': childId,
      'name': name,
      'instructions': instructions,
      'time': time,
      'frequency': frequency,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'notes': notes,
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'],
      childId: map['childId'],
      name: map['name'],
      instructions: map['instructions'],
      time: map['time'],
      frequency: map['frequency'],
      startDate: map['startDate'] != null ? DateTime.parse(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      notes: map['notes'],
    );
  }
}

class Reminder {
  final String id;
  final String childId;
  final String title;
  final String type; // feeding, medication, walk, other
  final String time;
  final String? repeatRule;
  final bool enabled;

  Reminder({
    required this.id,
    required this.childId,
    required this.title,
    required this.type,
    required this.time,
    this.repeatRule,
    this.enabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childId': childId,
      'title': title,
      'type': type,
      'time': time,
      'repeatRule': repeatRule,
      'enabled': enabled ? 1 : 0,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      childId: map['childId'],
      title: map['title'],
      type: map['type'],
      time: map['time'],
      repeatRule: map['repeatRule'],
      enabled: map['enabled'] == 1,
    );
  }
}

class EmergencyContact {
  final String id;
  final String childId;
  final String name;
  final String phone;
  final String? relationship;

  EmergencyContact({
    required this.id,
    required this.childId,
    required this.name,
    required this.phone,
    this.relationship,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childId': childId,
      'name': name,
      'phone': phone,
      'relationship': relationship,
    };
  }

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['id'],
      childId: map['childId'],
      name: map['name'],
      phone: map['phone'],
      relationship: map['relationship'],
    );
  }
}

class Pediatrician {
  final String id;
  final String childId;
  final String name;
  final String? clinic;
  final String? phone;
  final String? address;

  Pediatrician({
    required this.id,
    required this.childId,
    required this.name,
    this.clinic,
    this.phone,
    this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childId': childId,
      'name': name,
      'clinic': clinic,
      'phone': phone,
      'address': address,
    };
  }

  factory Pediatrician.fromMap(Map<String, dynamic> map) {
    return Pediatrician(
      id: map['id'],
      childId: map['childId'],
      name: map['name'],
      clinic: map['clinic'],
      phone: map['phone'],
      address: map['address'],
    );
  }
}
