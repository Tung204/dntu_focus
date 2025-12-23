import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;
  Future<dynamic> Function(List<Content>)? generateContentOverride;

  GeminiService({GenerativeModel? model, this.generateContentOverride}) {
    if (model != null) {
      _model = model;
      return;
    }
    if (generateContentOverride != null) {
      // Không cần khởi tạo model khi có override
      _model = GenerativeModel(model: 'test', apiKey: 'test');
      return;
    }
    _model = _createDefaultModel();
  }

  static GenerativeModel _createDefaultModel() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) throw Exception('Gemini API Key không tìm thấy');
    return GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.low),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
      ],
    );
  }

  Future<dynamic> generateContent(List<Content> content) async {
    try {
      if (generateContentOverride != null) {
        return await generateContentOverride!(content);
      }
      return await _model.generateContent(content);
    } catch (e) {
      throw Exception('Failed to generate content from Gemini API: $e');
    }
  }

  // Phân tích câu lệnh người dùng để tạo task, lịch trình hoặc bắt đầu Pomodoro
  Future<Map<String, dynamic>> parseUserCommand(String command) async {
    final prompt = '''
    Phân tích câu lệnh sau và trả về thông tin dưới dạng JSON:
    - Nếu là yêu cầu tạo task: trả về title, duration (phút), break_duration (phút), priority (High/Medium/Low), due_date (nếu có, định dạng ISO 8601), project (nếu có), tags (danh sách các tag nếu có).
    - Nếu là yêu cầu lên lịch: trả về title, due_date (định dạng ISO 8601), nhắc nhở trước bao lâu (phút), project (nếu có), tags (danh sách các tag nếu có).
    - Nếu là yêu cầu bắt đầu Pomodoro hoặc hẹn giờ: trả về type "pomodoro", work_duration (phút), break_duration (phút, có thể 0) và sessions (số phiên, mặc định 1).
    - Nhận diện a.m/p.m tự động nếu có thời gian (mặc định a.m nếu không rõ).
    - Gợi ý priority dựa trên ngữ cảnh (ví dụ: "họp nhóm" -> High).
    - Phân tích project từ các từ khóa như "dự án", "project", hoặc các tên project cụ thể.
    - Phân tích tags từ các từ khóa như "tag", "nhãn", hoặc các từ khóa đặc trưng.
    Câu lệnh: "$command"
    Ví dụ: "làm bài tập toán 25 phút 5 phút nghỉ" -> {"type": "task", "title": "Làm bài tập toán", "duration": 25, "break_duration": 5, "priority": "Medium", "project": null, "tags": []}
    Ví dụ: "làm bài tập lớn cho dự án web 2 giờ" -> {"type": "task", "title": "Làm bài tập lớn", "duration": 120, "priority": "High", "project": "web", "tags": ["bài tập lớn"]}
    Ví dụ: "ngày mai đi chợ 6 sáng" -> {"type": "schedule", "title": "Đi chợ", "due_date": "2025-05-04T06:00:00Z", "reminder_before": 15, "project": null, "tags": []}
    Ví dụ: "bắt đầu pomodoro 15 phút" -> {"type": "pomodoro", "work_duration": 15, "break_duration": 5, "sessions": 1}
    Trả về chỉ JSON, không thêm ký tự Markdown như ```json hoặc các ký tự thừa.
    ''';

    String? rawText;
    try {
      final response = await (generateContentOverride != null
          ? generateContentOverride!([Content.text(prompt)])
          : _model.generateContent([Content.text(prompt)]));
      
      // Handle both MockResponse and GenerateContentResponse
      if (response is GenerateContentResponse) {
        rawText = response.text?.trim() ?? '{}';
      } else {
        // MockResponse case - access text property directly
        rawText = (response as dynamic).text?.trim() ?? '{}';
      }

      // Xử lý phản hồi để loại bỏ Markdown (nếu có)
      String jsonString = rawText ?? '{}';
      if (jsonString.startsWith('```json')) {
        jsonString = jsonString.replaceFirst('```json', '').trim();
      }
      if (jsonString.endsWith('```')) {
        jsonString = jsonString.substring(0, jsonString.length - 3).trim();
      }

      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Error parsing command from Gemini API: $e');
      print('Raw response: $rawText');
      return {'error': 'Không thể phân tích câu lệnh từ Gemini API'};
    }
  }

  Future<List<String>> getSmartSuggestions(String context) async {
    final prompt = '''
    Dựa trên ngữ cảnh sau, gợi ý 3 câu lệnh mà người dùng có thể sử dụng để tạo task hoặc lên lịch.
    Ngữ cảnh: "$context"
    Ví dụ: Ngữ cảnh "đang học toán" -> ["làm bài tập toán 25 phút 5 phút nghỉ", "ôn tập toán 30 phút", "xem video bài giảng toán 20 phút"]
    Trả về dưới dạng danh sách các chuỗi, không thêm ký tự Markdown.
    ''';

    String? rawText;
    try {
      final response = await (generateContentOverride != null
          ? generateContentOverride!([Content.text(prompt)])
          : _model.generateContent([Content.text(prompt)]));
      
      // Handle both MockResponse and GenerateContentResponse
      if (response is GenerateContentResponse) {
        rawText = response.text?.trim() ?? '[]';
      } else {
        rawText = (response as dynamic).text?.trim() ?? '[]';
      }
      rawText = rawText?.replaceAll(RegExp(r'[^\x00-\x7F]+'), '') ?? '[]';
      // Xử lý JSON an toàn
      final jsonString = rawText.startsWith('[') ? rawText : '[$rawText]';
      return List<String>.from(jsonDecode(jsonString));

    } catch (e) {
      print('Error getting suggestions from Gemini API: $e');
      print('Raw response: $rawText');
      return [];
    }
  }

  Future<String> classifyTask(String taskTitle) async {
    // Validation: Nếu title rỗng, trả về Planned
    if (taskTitle.trim().isEmpty) {
      print('Empty task title, returning default category: Planned');
      return 'Planned';
    }
    
    final prompt = '''
    Phân loại task sau thành danh mục (Today, Tomorrow, This Week, Planned):
    - Task: "$taskTitle"
    - Nếu không có thời gian cụ thể, mặc định là Planned.
    - QUAN TRỌNG: Trả về CHỈ MỘT TỪ (Today hoặc Tomorrow hoặc This Week hoặc Planned), không thêm gì khác.
    ''';

    String? rawText;
    try {
      final response = await (generateContentOverride != null
          ? generateContentOverride!([Content.text(prompt)])
          : _model.generateContent([Content.text(prompt)]));
      
      // Handle both MockResponse and GenerateContentResponse
      if (response is GenerateContentResponse) {
        rawText = response.text?.trim() ?? 'Planned';
      } else {
        rawText = (response as dynamic).text?.trim() ?? 'Planned';
      }
      
      // Validate response - chỉ chấp nhận các category hợp lệ
      final validCategories = ['Today', 'Tomorrow', 'This Week', 'Planned'];
      if (validCategories.contains(rawText)) {
        return rawText!;
      }
      
      print('Invalid category from Gemini: $rawText, using default: Planned');
      return 'Planned';
    } catch (e) {
      print('Error classifying task from Gemini API: $e');
      print('Raw response: $rawText');
      return 'Planned';
    }
  }
}