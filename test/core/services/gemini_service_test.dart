import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:moji_todo/core/services/gemini_service.dart';

class MockGenerativeModel extends Mock implements GenerativeModel {}

class FakeGenerateContentResponse extends Fake implements GenerateContentResponse {
  FakeGenerateContentResponse(this._text);
  final String _text;
  @override
  String? get text => _text;
}

void main() {
  group('GeminiService', () {
    late MockGenerativeModel mockModel;
    late GeminiService service;

    setUp(() {
      mockModel = MockGenerativeModel();
      service = GeminiService(model: mockModel);
    });

    group('parseUserCommand', () {
      test('parses valid JSON', () async {
        when(() => mockModel.generateContent(any<List<Content>>())).thenAnswer(
          (_) async => FakeGenerateContentResponse('{"type":"task"}'),
        );

        final result = await service.parseUserCommand('input');
        expect(result, {'type': 'task'});
      });

      test('handles errors', () async {
        when(() => mockModel.generateContent(any<List<Content>>()))
            .thenThrow(Exception('fail'));

        final result = await service.parseUserCommand('input');
        expect(result, {'error': 'Không thể phân tích câu lệnh từ Gemini API'});
      });
    });

    group('getSmartSuggestions', () {
      test('parses list JSON', () async {
        when(() => mockModel.generateContent(any<List<Content>>())).thenAnswer(
          (_) async => FakeGenerateContentResponse('["a","b"]'),
        );

        final result = await service.getSmartSuggestions('ctx');
        expect(result, ['a', 'b']);
      });

      test('handles errors', () async {
        when(() => mockModel.generateContent(any<List<Content>>()))
            .thenThrow(Exception('fail'));

        final result = await service.getSmartSuggestions('ctx');
        expect(result, isEmpty);
      });
    });

    group('classifyTask', () {
      test('returns classification', () async {
        when(() => mockModel.generateContent(any<List<Content>>())).thenAnswer(
          (_) async => FakeGenerateContentResponse('Today'),
        );

        final result = await service.classifyTask('title');
        expect(result, 'Today');
      });

      test('handles errors', () async {
        when(() => mockModel.generateContent(any<List<Content>>()))
            .thenThrow(Exception('fail'));

        final result = await service.classifyTask('title');
        expect(result, 'Planned');
      });
    });
  });
}
