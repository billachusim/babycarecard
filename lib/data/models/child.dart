import 'dart:convert';

class Child {
  final String id;
  final String name;
  final String ageGroup;
  final String? allergies;
  final String? sex;
  final DateTime? birthDate;
  final double? weight;
  final String? photoPath;
  final String? personality;
  final String? importantNotes;

  Child({
    required this.id,
    required this.name,
    required this.ageGroup,
    this.allergies,
    this.sex,
    this.birthDate,
    this.weight,
    this.photoPath,
    this.personality,
    this.importantNotes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ageGroup': ageGroup,
      'allergies': allergies,
      'sex': sex,
      'birthDate': birthDate?.toIso8601String(),
      'weight': weight,
      'photoPath': photoPath,
      'personality': personality,
      'importantNotes': importantNotes,
    };
  }

  factory Child.fromMap(Map<String, dynamic> map) {
    return Child(
      id: map['id'],
      name: map['name'],
      ageGroup: map['ageGroup'],
      allergies: map['allergies'],
      sex: map['sex'],
      birthDate: map['birthDate'] != null ? DateTime.parse(map['birthDate']) : null,
      weight: map['weight']?.toDouble(),
      photoPath: map['photoPath'],
      personality: map['personality'],
      importantNotes: map['importantNotes'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Child.fromJson(String source) => Child.fromMap(json.decode(source));
}
