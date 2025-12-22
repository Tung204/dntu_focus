
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'cache_service.dart';

/// Service cải tiến cho Gemini với caching, error handling tốt hơn,
/// và nâng cao xử lý ngôn ngữ tự nhiên.
class ImprovedGeminiService {
  static const String _defaultModelName = 'gemini-1.5-flash';
  static const Duration _cacheDuration = Duration(minutes: 30);
  
  late final GenerativeModel _model;
  final CacheService _cache = CacheService.instance;
  
  // System prompt mạnh mẽ hơn cho trợ lý quản lý thời gian
  static const String _systemPrompt = '''
Bạn là trợ lý AI DNTU-Focus - một trợ lý thông minh chuyên về quản lý thời gian và năng suất làm việc. 
Nhiệm vụ chính của bạn là giúp người dùng tạo task, lên lịch, bắt đầu Pomodoro và quản lý thời gian hiệu quả.

# Tính cách:
- Thân thiện, chuyên nghiệp, luôn sẵn sàng h hỗ trợ
- Ngắn gọn nhưng đầy đủ thông tin
- Chủ động đề xuất các cải tiến hiệu suất

# Các loại câu lệnh h hỗ trợ:

1. Tạo task:
   - Format: "tạo task [tên] trong [thời gian] phút"
   - Ví dụ: "tạo task học toán 25 phút"
   - Có thể thêm: ưu tiên, dự án, tags, deadline

2. Lên lịch:
   - Format: "lên lịch [hoạt động] vào [thời gian]"
   - Ví dụ: "lên lịch họp nhóm lúc 2 giờ chiều mai"
   - Hỗ trợ: nhắc nhở, lặp lại, location

3. Pomodoro:
   - Format: "bắt đầu pomodoro [thời gian] phút"
   - Ví dụ: "bắt đầu pomodoro 25 phút"
   - Có thể custom: thời gian làm việc, thời gian nghỉ, số phiên

4. Hỏi đáp:
   - Trả lời câu h hỏi về quản lý thời gian
   - Đề xuất phương pháp làm việc hiệu quả
   - Phân tích thói quen làm việc

# Nguyên tắc xử lý:
1. Luôn xác nhận thông tin quan trọng
2. Hỏi lại khi thông tin không rõ ràng
3. Đề xuất tối ưu hóa tự động
4. Giữ tính nhất quán trong toàn bộ cuộc trò chuyện

# Xử lý ngôn ngữ tự nhiên:
- Hiểu các cách diễn đạt khác nhau của cùng một ý
- Xử lý từ viết tắt và tiếng lóng thông dụng
- Nhận diện context từ các câu h hỏi trước
- Phân tích ngữ cảnh thời gian (sáng/chiều/tối, hôm nay/ngày mai)

# Trả lời:
- Luôn cấu trúc rõ ràng, dễ đọc
- Sử dụng bullet points cho các bước
- Đánh dấu thông tin quan trọng
- Giữ phản hồi trong 2-3 câu ngắn gọn
''';

  ImprovedGeminiService({GenerativeModel? model}) {
    _model = model ?? _createDefaultModel();
  }

  static GenerativeModel _createDefaultModel() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      throw Exception('Gemini API Key không tìm thấy trong .env file');
    }
    return GenerativeModel(
      model: _defaultModelName,
      apiKey: apiKey,
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.low),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
      ],
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topP: 0.95,
        topK: 40,
        maxOutputTokens: 1024,
      ),
    );
  }

  /// Phân tích câu lệnh người dùng với caching và error handling nâng cao
  Future<Map<String, dynamic>> parseUserCommand(
    String command, {
    Map<String, dynamic>? context,
    bool useCache = true,
  }) async {
    // Tạo cache key
    final cacheKey = 'parse_${command.hashCode}_${context?.hashCode ?? 0}';
    
    // Kiểm tra cache
    if (useCache) {
      final cached = _cache.get<Map<String, dynamic>>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    // Tạo prompt nâng cao với context
    String prompt = _systemPrompt;
    
    if (context != null && context.isNotEmpty) {
      prompt += '\n\n# Context hiện tại:\n';
      context.forEach((key, value) {
        prompt += '- $key: $value\n';
      });
    }
    
    prompt += '''
    
# Yêu cầu:
Phân tích câu lệnh sau và trả về JSON với cấu trúc:
{
  "type": "task|schedule|pomodoro|question",
  "title": "tiêu đề task",
  "duration": số phút (nếu có),
  "work_duration": số phút (cho pomodoro),
  "break_duration": số phút (cho pomodoro),
  "sessions": số phiên (cho pomodoro, mặc định 1),
  "priority": "High|Medium|Low",
  "due_date": "ISO 8601",
  "project": "tên dự án",
  "tags": ["tag1", "tag2"],
  "reminder_before": số phút,
  "confidence": 0.0 đến 1.0,
  "needs_clarification": true/false,
  "clarification_question": "câu h hỏi làm rõ (nếu cần)"
}

# Đặc biệt chú  ý:
1. Phân biệt task (có duration) vs schedule (có due_date cụ thể)
2. Xử lý thời gian tự nhiên: "sáng mai", "2 giờ chiều", "tuần sau"
3. Đề xuất priority dựa trên từ khóa: "gấp", "quan trọng" -> High
4. Nhận diện project từ: "cho dự án X", "trong project Y"
5. Extract tags từ: "với tag Z", "thuộc thể loại W"

Câu lệnh: "$command"

Phản hồi chỉ chứa JSON, không có markdown hay giải thích thêm.
''';

    try {
      final response = await _executeWithRetry(() => _model.generateContent([
        Content.text(prompt),
      ]));

      final rawText = response.text?.trim() ?? '{}';
      final cleanedText = _cleanJsonResponse(rawText);
      
      Map<String, dynamic> result;
      try {
        result = jsonDecode(cleanedText) as Map<String, dynamic>;
      } catch (e) {
        // Fallback: sử dụng parsing cơ bản
        result = await _fallbackParsing(command);
      }

      // Thêm metadata
      result['processed_at'] = DateTime.now().toIso8601String();
      result['command'] = command;

      // Lưu vào cache
      _cache.set(cacheKey, result, ttl: _cacheDuration);

      return result;
    } catch (e) {
      debugPrint('Error parsing command: $e');
      
      // Fallback cho trường hợp lỗi
      return {
        'type': 'error',
        'title': 'Không thể phân tích câu lệnh',
        'error': 'Hệ thống đang gặp sự cố. Vui lòng thử lại với câu lệnh đơn giản hơn.',
        'suggestion': 'Bạn có thể thử: "tạo task học toán 25 phút"',
        'confidence': 0.0,
        'needs_clarification': false,
        'processed_at': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Lấy gợi  ý thông minh dựa trên context
  Future<List<String>> getSmartSuggestions({
    required String context,
    int count = 3,
    List<String>? recentCommands,
  }) async {
    final cacheKey = 'suggestions_${context.hashCode}_${recentCommands?.hashCode ?? 0}';
    
    final cached = _cache.get<List<String>>(cacheKey);
    if (cached != null) {
      return cached;
    }

    String prompt = '''
Dựa trên ngữ cảnh làm việc hiện tại, gợi ý $count câu lệnh hữu ích nhất.

Ngữ cảnh: "$context"

${recentCommands != null && recentCommands.isNotEmpty 
  ? 'Các câu lệnh gần đây:\n${recentCommands.map((c) => '- $c').join('\n')}' 
  : ''}

# Nguyên tắc gợi  ý:
1. Phù hợp với ngữ cảnh
2. Đa dạng loại (task, schedule, pomodoro)
3. Cụ thể và có thể thực hiện ngay
4. Bao gồm cả thời gian và tham số c cụ thể

Trả về dạng JSON array của strings.
''';

    try {
      final response = await _executeWithRetry(() => _model.generateContent([
        Content.text(prompt),
      ]));

      String rawText = response.text?.trim() ?? '[]';
      
      // Clean response
      if (rawText.startsWith('```')) {
        final lines = rawText.split('\n');
        rawText = lines.sublist(1, lines.length - 1).join('\n');
      }

      List<String> suggestions;
      try {
        final jsonList = jsonDecode(rawText) as List;
        suggestions = List<String>.from(jsonList.take(count));
      } catch (e) {
        // Fallback suggestions
        suggestions = _getDefaultSuggestions(context);
      }

      // Lưu cache
      _cache.set(cacheKey, suggestions, ttl: Duration(minutes: 15));

      return suggestions;
    } catch (e) {
      debugPrint('Error getting suggestions: $e');
      return _getDefaultSuggestions(context);
    }
  }

  /// Xử lý câu h hỏi chung về quản lý thời gian
  Future<String> answerProductivityQuestion(String question) async {
    final cacheKey = 'question_${question.hashCode}';
    
    final cached = _cache.get<String>(cacheKey);
    if (cached != null) {
      return cached;
    }

    String prompt = '''
Bạn là chuyên gia quản lý thời gian và năng suất làm việc.

Câu hỏi: "$question"

Trả lời với nguyên tắc:
1. Ngắn gọn, thực tế, có thể áp dụng ngay
2. Cấu trúc rõ ràng với bullet points nếu phù hợp
3. Đưa ra ví dụ c cụ thể
4. Khuyến khích phương pháp Pomodoro khi phù hợp
5. Giữ trong 3-5 câu

Trả lời bằng tiếng Việt, không dùng markdown.
''';

    try {
      final response = await _executeWithRetry(() => _model.generateContent([
        Content.text(prompt),
      ]));

      final answer = response.text?.trim() ?? 
        'Xin lỗi, tôi không thể trả lời câu hỏi này ngay lúc này. Bạn có thể thử h hỏi về phương pháp quản lý thời gian hoặc kỹ thuật Pomodoro.';

      // Lưu cache
      _cache.set(cacheKey, answer, ttl: Duration(minutes: 60));

      return answer;
    } catch (e) {
      debugPrint('Error answering question: $e');
      return 'Xin lỗi, có lỗi xảy ra khi xử lý câu h hỏi. Vui lòng thử lại sau.';
    }
  }

  // Helper methods

  Future<T> _executeWithRetry<T>(
    Future<T> Function() action, {
    int maxRetries = 2,
    Duration initialDelay = const Duration(milliseconds: 100),
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (true) {
      try {
        return await action();
      } catch (e) {
        attempt++;
        if (attempt > maxRetries) {
          rethrow;
        }

        // Exponential backoff
        await Future.delayed(delay);
        delay = delay * 2;
      }
    }
  }

  String _cleanJsonResponse(String text) {
    String cleaned = text.trim();
    
    // Remove markdown code blocks
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    }
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    
    cleaned = cleaned.trim();
    
    // Ensure it's valid JSON
    if (!cleaned.startsWith('{') && !cleaned.startsWith('[')) {
      cleaned = '{$cleaned}';
    }
    
    return cleaned;
  }

  Future<Map<String, dynamic>> _fallbackParsing(String command) async {
    // Simple keyword-based parsing as fallback
    final commandLower = command.toLowerCase();
    
    if (commandLower.contains('pomodoro') || 
        commandLower.contains('hẹn giờ') || 
        commandLower.contains('bắt đầu')) {
      return {
        'type': 'pomodoro',
        'work_duration': 25,
        'break_duration': 5,
        'sessions': 1,
        'confidence': 0.6,
        'needs_clarification': true,
        'clarification_question': 'Bạn muốn làm việc trong bao nhiêu phút?',
      };
    } else if (commandLower.contains('lên lịch') || 
               commandLower.contains('hẹn') || 
               commandLower.contains('vào lúc')) {
      return {
        'type': 'schedule',
        'confidence': 0.5,
        'needs_clarification': true,
        'clarification_question': 'Bạn muốn lên lịch cho thời gian nào?',
      };
    } else {
      return {
        'type': 'task',
        'title': command,
        'duration': 25,
        'priority': 'Medium',
        'confidence': 0.5,
        'needs_clarification': true,
        'clarification_question': 'Bạn muốn hoàn thành task này trong bao lâu?',
      };
    }
  }

  List<String> _getDefaultSuggestions(String context) {
    final suggestions = [
      'Tạo task học tập 25 phút',
      'Bắt đầu Pomodoro 25 phút',
      'Lên lịch review công việc 15 phút',
      'Tạo task tập thể dục 30 phút',
    ];
    
    // Context-based suggestions
    if (context.toLowerCase().contains('học') || 
        context.toLowerCase().contains('study')) {
      return [
        'Tạo task ôn tập 45 phút',
        'Bắt đầu Pomodoro học tập 25 phút',
        'Lên lịch học nhóm 2 giờ',
      ];
    } else if (context.toLowerCase().contains('làm việc') || 
               context.toLowerCase().contains('work')) {
      return [
        'Tạo task hoàn thành báo cáo 60 phút',
        'Bắt đầu Pomodoro tập trung 50 phút',
        'Lên lịch họp nhóm 30 phút',
      ];
    }
    
    return suggestions;
  }

  /// Clear cache
  void clearCache() {
    _cache.clear();
  }

  /// Get cache stats
  Map<String, dynamic> getCacheStats() {
    return _cache.stats;
  }
}

// Cache entry không cần thiết nữa vì đã sử dụng CacheService