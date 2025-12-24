# Kế Hoạch Sửa Lỗi Bottom Sheet Không Hiển thị

## 🔍 Phân Tích Vấn Đề

### Triệu chứng
- Khi ấn nút "+" trong [`TaskManageScreen`](lib/features/tasks/presentation/task_manage_screen.dart:427), màn hình tối đi một chút nhưng bottom sheet không hiển thị
- Console log cho thấy FAB được ấn và AddTaskBottomSheet được build, nhưng có lỗi rendering

### Nguyên nhân chính xác
Lỗi **BoxConstraints forces an infinite width** tại dòng 192 trong [`add_task_bottom_sheet.dart`](lib/features/tasks/presentation/add_task/add_task_bottom_sheet.dart:192)

```
BoxConstraints(w=Infinity, 56.0<=h<=Infinity)
The offending constraints were provided to ElevatedButton
```

### Phân tích chi tiết

Trong [`add_task_bottom_sheet.dart`](lib/features/tasks/presentation/add_task/add_task_bottom_sheet.dart:107), cấu trúc layout hiện tại:

```dart
Row(
  children: [
    IconButton(...),  // 4 icon buttons
    IconButton(...),
    IconButton(...),
    IconButton(...),
    const Spacer(),   // ← VẤN ĐỀ Ở ĐÂY!
    ElevatedButton(   // ← Button này bị lỗi
      ...
    ),
  ],
)
```

**Vấn đề:**
1. [`Spacer()`](lib/features/tasks/presentation/add_task/add_task_bottom_sheet.dart:191) trong [`Row`](lib/features/tasks/presentation/add_task/add_task_bottom_sheet.dart:107) sẽ chiếm toàn bộ không gian còn lại
2. [`ElevatedButton`](lib/features/tasks/presentation/add_task/add_task_bottom_sheet.dart:192) không có width cố định, Flutter cố gắng cho nó width vô hạn
3. Điều này tạo ra **unconstrained layout**, gây lỗi rendering và bottom sheet không hiển thị được

## ✅ Giải Pháp

### Giải pháp 1: Wrap ElevatedButton với SizedBox (KHUYẾN NGHỊ)
Đặt width cố định cho button để tránh infinite width constraint:

```dart
Row(
  children: [
    IconButton(...),
    IconButton(...),
    IconButton(...),
    IconButton(...),
    const Spacer(),
    SizedBox(
      width: 80,  // hoặc width phù hợp
      child: ElevatedButton(
        onPressed: ...,
        style: ...,
        child: ...,
      ),
    ),
  ],
)
```

### Giải pháp 2: Sử dụng Expanded thay vì Spacer
```dart
Row(
  children: [
    IconButton(...),
    IconButton(...),
    IconButton(...),
    IconButton(...),
    Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton(...),
      ),
    ),
  ],
)
```

### Giải pháp 3: Sử dụng MainAxisAlignment
Bỏ Spacer và dùng alignment của Row:

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Row(
      children: [
        IconButton(...),
        IconButton(...),
        IconButton(...),
        IconButton(...),
      ],
    ),
    ElevatedButton(...),
  ],
)
```

## 📋 Các Bước Thực Hiện (Giải pháp 1 - Khuyến nghị)

### Bước 1: Sửa layout trong add_task_bottom_sheet.dart
Thay đổi từ dòng 107-275:

**TRƯỚC:**
```dart
Row(
  children: [
    IconButton(...),
    IconButton(...),
    IconButton(...),
    IconButton(...),
    const Spacer(),
    ElevatedButton(...),
  ],
)
```

**SAU:**
```dart
Row(
  children: [
    IconButton(
      icon: Icon(
        Icons.wb_sunny,
        color: _dueDate != null ? Colors.green : Colors.grey,
      ),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => DueDatePicker(
            initialDate: _dueDate,
            onDateSelected: (date) {
              setState(() {
                _dueDate = date;
              });
            },
          ),
        );
      },
    ),
    IconButton(
      icon: Icon(
        Icons.flag,
        color: _priority != null ? Colors.orange : Colors.grey,
      ),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => PriorityPicker(
            initialPriority: _priority,
            onPrioritySelected: (priority) {
              setState(() {
                _priority = priority;
              });
            },
          ),
        );
      },
    ),
    IconButton(
      icon: Icon(
        Icons.local_offer,
        color: _tagIds.isNotEmpty ? Colors.blue : Colors.grey,
      ),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => TagsPicker(
            initialTagIds: _tagIds,
            repository: widget.repository,
            onTagsSelected: (selectedTagIds) {
              setState(() {
                _tagIds = selectedTagIds;
              });
            },
          ),
        );
      },
    ),
    IconButton(
      icon: Icon(
        Icons.work,
        color: _projectId != null ? Colors.red : Colors.grey,
      ),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => ProjectPicker(
            initialProjectId: _projectId,
            repository: widget.repository,
            onProjectSelected: (selectedProjectId) {
              setState(() {
                _projectId = selectedProjectId;
              });
            },
          ),
        );
      },
    ),
    const Spacer(),
    SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () async {
          // ... existing code ...
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text('Add'),
      ),
    ),
  ],
)
```

### Bước 2: Test lại ứng dụng
1. Chạy app trong debug mode
2. Navigate đến Task Manage Screen
3. Ấn nút "+" (FAB)
4. Xác nhận bottom sheet hiển thị đúng
5. Test các chức năng trong bottom sheet

### Bước 3: Kiểm tra các trường hợp khác
- Test trên các kích thước màn hình khác nhau
- Test với keyboard hiển thị/ẩn
- Test với dark mode/light mode

## 🎯 Kết Quả Mong Đợi

Sau khi sửa:
- Bottom sheet hiển thị bình thường khi ấn nút "+"
- Không còn lỗi constraint trong console
- UI hiển thị đúng với button "Add" có kích thước phù hợp
- Tất cả chức năng hoạt động bình thường

## 📝 Ghi Chú Kỹ Thuật

### Tại sao lỗi này xảy ra?
- Flutter's layout system yêu cầu mọi widget phải có bounded constraints
- Khi sử dụng `Spacer()` trong `Row`, nó sẽ expand để lấp đầy không gian
- `ElevatedButton` mặc định không có width constraint
- Kết hợp hai yếu tố này tạo ra infinite width constraint
- Flutter không thể render widget với infinite constraints → Bottom sheet fail to display

### Best Practices
1. Luôn đảm bảo widgets có bounded constraints trong Flex layouts (Row/Column)
2. Sử dụng `SizedBox` hoặc `Container` với explicit dimensions khi cần
3. Test layout với Flutter DevTools để phát hiện constraint issues sớm
4. Đọc error messages trong console - Flutter thường cho thông tin rất chi tiết

## 🔗 Files Liên Quan

- [`lib/features/tasks/presentation/add_task/add_task_bottom_sheet.dart`](lib/features/tasks/presentation/add_task/add_task_bottom_sheet.dart) - File cần sửa
- [`lib/features/tasks/presentation/task_manage_screen.dart`](lib/features/tasks/presentation/task_manage_screen.dart:427) - Nơi gọi bottom sheet
- [`lib/features/tasks/domain/task_cubit.dart`](lib/features/tasks/domain/task_cubit.dart) - Logic xử lý task

## ⚠️ Lưu Ý

- Đây là lỗi layout constraint, không phải lỗi logic
- Bottom sheet đang được build nhưng fail khi render
- Lỗi này sẽ crash silent (không throw exception), chỉ prevent rendering
- Console log rất quan trọng để debug loại lỗi này