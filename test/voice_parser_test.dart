import 'package:flutter_test/flutter_test.dart';
import 'package:baby_care_card/core/utils/voice_parser.dart';

void main() {
  group('VoiceParser', () {
    test('extracts a name and a toddler age group', () {
      final result = VoiceParser.parse('This is Mia, our toddler');
      expect(result.name, 'Mia');
      expect(result.ageGroup, 'Toddler');
    });

    test('works out the age group from months', () {
      final result = VoiceParser.parse('Our son is called Leo and he is 8 months old');
      expect(result.name, 'Leo');
      expect(result.ageGroup, 'Infant');
    });

    test('extracts allergies and personality', () {
      final result = VoiceParser.parse(
          'My daughter is named Ada. She is allergic to peanuts. She is very cheerful');
      expect(result.name, 'Ada');
      expect(result.allergies, 'Peanuts');
      expect(result.personality, 'cheerful');
    });

    test('works out the age group from years', () {
      final result = VoiceParser.parse('this is zara and she is 4 years old');
      expect(result.name, 'Zara');
      expect(result.ageGroup, 'Preschooler');
    });
  });
}
