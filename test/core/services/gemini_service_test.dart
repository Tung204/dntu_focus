import 'package:flutter_test/flutter_test.dart';
import 'package:moji_todo/core/services/gemini_service.dart';

void main() {
  group('GeminiService', () {
    test('GeminiService constructor works', () {
      // Test constructor với generateContentOverride
      final service = GeminiService(
        generateContentOverride: (content) async {
          return MockResponse('{"type":"task","title":"Test"}');
        },
      );
      
      expect(service, isNotNull);
    });

    test('parseUserCommand handles JSON parsing', () async {
      final service = GeminiService(
        generateContentOverride: (content) async {
          return MockResponse('{"type":"task","title":"Test Task","duration":25}');
        },
      );
      
      final result = await service.parseUserCommand('create task');
      expect(result['type'], 'task');
      expect(result['title'], 'Test Task');
      expect(result['duration'], 25);
    });

    test('parseUserCommand handles invalid JSON', () async {
      final service = GeminiService(
        generateContentOverride: (content) async {
          return MockResponse('invalid json response');
        },
      );
      
      final result = await service.parseUserCommand('invalid command');
      expect(result.containsKey('error'), true);
    });

    test('getSmartSuggestions parses list correctly', () async {
      final service = GeminiService(
        generateContentOverride: (content) async {
          return MockResponse('["Suggestion 1","Suggestion 2","Suggestion 3"]');
        },
      );
      
      final suggestions = await service.getSmartSuggestions('study context');
      expect(suggestions, isA<List<String>>());
      expect(suggestions.length, 3);
      expect(suggestions[0], 'Suggestion 1');
    });

    test('classifyTask returns string result', () async {
      final service = GeminiService(
        generateContentOverride: (content) async {
          return MockResponse('Today');
        },
      );
      
      final result = await service.classifyTask('study math');
      expect(result, 'Today');
    });
  });
}

// Simple mock response class
class MockResponse {
  final String text;
  
  MockResponse(this.text);
}