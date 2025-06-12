import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mocktail/mocktail.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:moji_todo/core/services/gemini_service.dart';

class MockGenerativeModel extends Mock implements GenerativeModel {}
void main() {
  group('GeminiService', () {
    late MockGenerativeModel mockModel;
    late GeminiService service;

    setUp(() {
      mockModel = MockGenerativeModel();
      service = GeminiService(model: mockModel);
    });
    test('parseUserCommand parses valid JSON', () async {
      when(mockModel.generateContent(any)).thenAnswer(
        (_) async => GenerateContentResponse(
          candidates: [Candidate(content: Content.text('{"type":"task","title":"Test"}'))],
        ),
      );

      final result = await service.parseUserCommand('create');
      expect(result['type'], 'task');
      expect(result['title'], 'Test');
    });

    test('parseUserCommand handles invalid JSON', () async {
      when(mockModel.generateContent(any)).thenAnswer(
        (_) async => GenerateContentResponse(
          candidates: [Candidate(content: Content.text('invalid json'))],
        ),
      );

      final result = await service.parseUserCommand('invalid');
      expect(result.containsKey('error'), true);
    });

    test('getSmartSuggestions parses list', () async {
      when(mockModel.generateContent(any)).thenAnswer(
        (_) async => GenerateContentResponse(
          candidates: [Candidate(content: Content.text('["a","b"]'))],
        ),
      );

      final suggestions = await service.getSmartSuggestions('context');
      expect(suggestions, ['a', 'b']);
    });

    test('classifyTask returns raw text', () async {
      when(mockModel.generateContent(any)).thenAnswer(
        (_) async => GenerateContentResponse(
          candidates: [Candidate(content: Content.text('Today'))],
        ),
      );

      final result = await service.classifyTask('study');
      expect(result, 'Today');
    });
  });
}
