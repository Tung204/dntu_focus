# Kế hoạch: Sửa lỗi nút + không hoạt động khi tạo Task

## 🔍 Phân tích vấn đề

### Vấn đề chính
Khi nhấn nút + để tạo task ở màn hình Task Manager, bottom sheet không hiện ra.

### Nguyên nhân gốc rễ
Trong file [`task_manage_screen.dart`](lib/features/tasks/presentation/task_manage_screen.dart:427-460):

1. **Lỗi Scope/Context**: Biến `projectTagRepository` được khai báo bên trong `BlocBuilder` (dòng 81-84) nhưng `FloatingActionButton` được khai báo bên ngoài scope đó (dòng 427-460)
2. **Không có error handling**: Không có try-catch hoặc error handling nào khi mở bottom sheet
3. **Gemini API blocking**: Hàm [`addTask()`](lib/features/tasks/domain/task_cubit.dart:55) gọi [`classifyTask()`](lib/core/services/gemini_service.dart:128) không có timeout, có thể gây treo ứng dụng

## 📋 Kế hoạch khắc phục

### Bước 1: Sửa vấn đề Scope trong FloatingActionButton

**Mục tiêu**: Di chuyển FloatingActionButton vào trong BlocBuilder hoặc tạo repository ở ngoài scope

**Giải pháp được chọn**: Di chuyển FloatingActionButton vào bên trong `BlocBuilder` để có thể truy cập `projectTagRepository`

**Thay đổi trong [`task_manage_screen.dart`](lib/features/tasks/presentation/task_manage_screen.dart:115-461)**:
```dart
// BEFORE (hiện tại - SAI)
return Scaffold(
  body: ...,
  floatingActionButton: Builder(
    builder: (fabContext) {
      return FloatingActionButton(
        onPressed: () {
          // ❌ projectTagRepository không accessible ở đây
          repository: projectTagRepository,
        },
      );
    },
  ),
);

// AFTER (đúng)
return Scaffold(
  body: ...,
  floatingActionButton: _buildFAB(context, projectTagRepository),
);

// Hoặc inline trong BlocBuilder
```

### Bước 2: Thêm Error Handling cho Bottom Sheet

**Mục tiêu**: Bắt và hiển thị lỗi khi mở bottom sheet hoặc khi tạo task

**Thêm try-catch trong onPressed**:
```dart
onPressed: () async {
  try {
    final taskCubit = context.read<TaskCubit>();
    await showModalBottomSheet(
      context: fabContext,
      // ...
    );
  } catch (e) {
    if (fabContext.mounted) {
      ScaffoldMessenger.of(fabContext).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }
}
```

### Bước 3: Thêm Loading State trong AddTaskBottomSheet

**Mục tiêu**: Hiển thị loading indicator khi đang xử lý tạo task

**Thay đổi trong [`add_task_bottom_sheet.dart`](lib/features/tasks/presentation/add_task/add_task_bottom_sheet.dart:186-220)**:
```dart
// Thêm state variable
bool _isLoading = false;

// Trong ElevatedButton onPressed
onPressed: _isLoading ? null : () async {
  setState(() => _isLoading = true);
  try {
    // existing task creation logic
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lỗi tạo task: $e')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}

// Hiển thị loading
child: _isLoading 
  ? SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(color: Colors.white),
    )
  : Text('Add'),
```

### Bước 4: Tối ưu Gemini API với Timeout

**Mục tiêu**: Ngăn ứng dụng treo khi Gemini API chậm hoặc lỗi

**Thay đổi trong [`task_cubit.dart`](lib/features/tasks/domain/task_cubit.dart:55-72)**:
```dart
Future<void> addTask(Task task) async {
  final user = _auth.currentUser;
  if (user == null) throw Exception('Người dùng chưa đăng nhập');

  String category = 'Planned'; // Mặc định
  
  try {
    // Thêm timeout cho Gemini API call
    category = await _geminiService.classifyTask(task.title ?? '')
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            print('Gemini API timeout, dùng category mặc định: Planned');
            return 'Planned';
          },
        );
  } catch (e) {
    print('Lỗi khi gọi Gemini API: $e, dùng category mặc định');
    category = 'Planned';
  }
  
  final taskToAdd = task.copyWith(
    category: category,
    userId: user.uid,
    createdAt: task.createdAt ?? DateTime.now(),
    isCompleted: false,
    completionDate: null,
    isPomodoroActive: false,
    remainingPomodoroSeconds: 0,
  );
  
  await taskRepository.addTask(taskToAdd);
  await loadInitialData();
}
```

**Thay đổi trong [`gemini_service.dart`](lib/core/services/gemini_service.dart:128-155)**:
```dart
Future<String> classifyTask(String taskTitle) async {
  // Thêm validation
  if (taskTitle.trim().isEmpty) {
    return 'Planned';
  }
  
  final prompt = '''
  Phân loại task sau thành danh mục (Today, Tomorrow, This Week, Planned):
  - Task: "$taskTitle"
  - Nếu không có thời gian cụ thể, mặc định là Planned.
  Trả về CHỈ MỘT TỪ (Today/Tomorrow/This Week/Planned), không thêm gì khác.
  ''';

  try {
    final response = await (generateContentOverride != null
        ? generateContentOverride!([Content.text(prompt)])
        : _model.generateContent([Content.text(prompt)]));
    
    String rawText;
    if (response is GenerateContentResponse) {
      rawText = response.text?.trim() ?? 'Planned';
    } else {
      rawText = (response as dynamic).text?.trim() ?? 'Planned';
    }
    
    // Validate response
    final validCategories = ['Today', 'Tomorrow', 'This Week', 'Planned'];
    if (validCategories.contains(rawText)) {
      return rawText;
    }
    
    print('Invalid category from Gemini: $rawText, using Planned');
    return 'Planned';
  } catch (e) {
    print('Error classifying task from Gemini API: $e');
    return 'Planned';
  }
}
```

### Bước 5: Thêm Debug Logging

**Mục tiêu**: Giúp debug dễ dàng hơn trong tương lai

**Thêm logging vào các điểm quan trọng**:
- Khi nhấn FAB
- Khi mở bottom sheet
- Khi bắt đầu tạo task
- Khi gọi Gemini API
- Khi lưu task vào database

## 🎯 Kết quả mong đợi

Sau khi hoàn thành:

1. ✅ Nhấn nút + sẽ mở bottom sheet tạo task
2. ✅ Bottom sheet hiển thị loading khi đang xử lý
3. ✅ Task được tạo thành công ngay cả khi Gemini API chậm/lỗi
4. ✅ Hiển thị thông báo lỗi rõ ràng nếu có vấn đề
5. ✅ Không bị treo ứng dụng khi API timeout

## 🔄 Thứ tự thực hiện

1. **Ưu tiên cao** - Sửa scope issue (Bước 1)
2. **Ưu tiên cao** - Thêm error handling (Bước 2)
3. **Ưu tiên trung bình** - Thêm loading state (Bước 3)
4. **Ưu tiên trung bình** - Tối ưu Gemini API (Bước 4)
5. **Ưu tiên thấp** - Thêm debug logging (Bước 5)

## 📝 Ghi chú

- Cần test kỹ sau mỗi bước để đảm bảo không gây lỗi mới
- Có thể cân nhắc thêm offline mode nếu Gemini API không khả dụng
- Nên thêm retry logic cho Gemini API trong tương lai