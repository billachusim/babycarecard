/// What the on-device fallback parser can pick out of a spoken description
/// when the voice service can't be reached.
class ParsedChildInfo {
  final String? name;
  final String? ageGroup;
  final String? allergies;
  final String? personality;

  ParsedChildInfo({this.name, this.ageGroup, this.allergies, this.personality});

  @override
  String toString() =>
      'Name: $name, Age group: $ageGroup, Allergies: $allergies, Personality: $personality';
}

class VoiceParser {
  static ParsedChildInfo parse(String text) {
    final lowerText = text.toLowerCase();

    String? name;
    String? ageGroup;
    String? allergies;
    String? personality;

    // Age group, from the words parents use or from a stated age.
    if (RegExp(r'\bnewborn\b').hasMatch(lowerText)) {
      ageGroup = 'Newborn';
    } else if (RegExp(r'\btoddler\b').hasMatch(lowerText)) {
      ageGroup = 'Toddler';
    } else if (RegExp(r'\bpre-?school(?:er)?\b').hasMatch(lowerText)) {
      ageGroup = 'Preschooler';
    } else if (RegExp(r'\b(?:infant|baby)\b').hasMatch(lowerText)) {
      ageGroup = 'Infant';
    } else {
      final months = RegExp(r'\b(\d{1,2})[\s-]*months?\b').firstMatch(lowerText);
      final years = RegExp(r'\b(\d{1,2})[\s-]*years?\b').firstMatch(lowerText);
      if (months != null) {
        final m = int.parse(months.group(1)!);
        ageGroup = m < 2 ? 'Newborn' : (m < 12 ? 'Infant' : 'Toddler');
      } else if (years != null) {
        final y = int.parse(years.group(1)!);
        ageGroup = y < 3 ? 'Toddler' : (y < 5 ? 'Preschooler' : 'School age');
      }
    }

    // Name: "name is X", "named X", "called X" or "this is X".
    final nameMatch =
        RegExp(r'\b(?:name is|named|called|this is)\s+([a-zA-Z]+)\b').firstMatch(lowerText);
    if (nameMatch != null) {
      name = _capitalize(nameMatch.group(1)!);
    }

    // Allergies: "allergic to X" or "X allergy".
    final allergicTo =
        RegExp(r'\ballergic to\s+([a-zA-Z\s,]+?)(?:\.|$|\band\b(?!\s+[a-z]+,))').firstMatch(lowerText);
    final allergyTo = RegExp(r'\b([a-zA-Z]+)\s+allerg(?:y|ies)\b').firstMatch(lowerText);
    if (allergicTo != null) {
      allergies = _capitalize(allergicTo.group(1)!.trim());
    } else if (allergyTo != null && allergyTo.group(1) != 'no') {
      allergies = _capitalize(allergyTo.group(1)!);
    }

    // Personality: only from "he/she/they is|seems [very] X", so phrases
    // like "our pediatrician is Green Lane" are never picked up.
    const notPersonality = {
      'a', 'an', 'the', 'allergic', 'about', 'around', 'on', 'at', 'in',
      'our', 'my', 'not', 'usually', 'always', 'asleep', 'awake', 'called', 'named',
    };
    final traits = RegExp(
      r"\b(?:he|she|they)(?:'s|\s+is|\s+are|\s+seems|\s+seem)\s+(?:very\s+|really\s+|super\s+|extremely\s+|so\s+)?([a-z]+)\b",
    )
        .allMatches(lowerText)
        .map((m) => m.group(1)!)
        .where((word) => !notPersonality.contains(word) && !RegExp(r'^\d').hasMatch(word))
        .toList();
    if (traits.isNotEmpty) personality = traits.last;

    return ParsedChildInfo(
      name: name,
      ageGroup: ageGroup,
      allergies: allergies,
      personality: personality,
    );
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
