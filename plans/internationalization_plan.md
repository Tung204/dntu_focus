# Kế hoạch Chuyển đổi Ngôn ngữ: Tiếng Việt → Tiếng Anh

## Tổng quan
Chuyển đổi toàn bộ văn bản hiển thị trong ứng dụng từ tiếng Việt sang tiếng Anh, đảm bảo không còn bất kỳ văn bản tiếng Việt nào trong UI.

## Phân tích hiện trạng

### 1. Các khu vực chứa tiếng Việt

#### A. Task Management Module
**Files cần xử lý:**
- [`lib/features/tasks/presentation/task_manage_screen.dart`](lib/features/tasks/presentation/task_manage_screen.dart)
- [`lib/features/tasks/presentation/task_list_screen.dart`](lib/features/tasks/presentation/task_list_screen.dart)
- [`lib/features/tasks/presentation/task_detail_screen.dart`](lib/features/tasks/presentation/task_detail_screen.dart)
- [`lib/features/tasks/presentation/trash_screen.dart`](lib/features/tasks/presentation/trash_screen.dart)
- [`lib/features/tasks/presentation/completed_tasks_screen.dart`](lib/features/tasks/presentation/completed_tasks_screen.dart)
- [`lib/features/tasks/presentation/widgets/task_item_card.dart`](lib/features/tasks/presentation/widgets/task_item_card.dart)
- [`lib/features/tasks/presentation/widgets/search_bar_widget.dart`](lib/features/tasks/presentation/widgets/search_bar_widget.dart)

**Các chuỗi tiếng Việt:**
- "Hôm nay", "Ngày mai", "Tuần này", "Kế hoạch"
- "Hoàn thành", "Thùng rác", "Dự án"
- "Task không có tiêu đề", "Không có dự án"
- "Tìm kiếm...", "Thêm một task"
- "Đã hoàn thành", "Task đang chờ"
- "Tổng thời gian dự kiến", "Thời gian đã hoàn thành"
- "Sắp xếp theo tiêu đề", "Sắp xếp theo ngày xóa"
- "Khôi phục", "Xóa vĩnh viễn"
- Messages: "Đã khôi phục X task!", "Lỗi khi khôi phục"

#### B. Add Task Module
**Files cần xử lý:**
- [`lib/features/tasks/presentation/add_task/add_task_bottom_sheet.dart`](lib/features/tasks/presentation/add_task/add_task_bottom_sheet.dart)
- [`lib/features/tasks/presentation/add_task/due_date_picker.dart`](lib/features/tasks/presentation/add_task/due_date_picker.dart)
- [`lib/features/tasks/presentation/add_task/priority_picker.dart`](lib/features/tasks/presentation/add_task/priority_picker.dart)
- [`lib/features/tasks/presentation/add_task/project_picker.dart`](lib/features/tasks/presentation/add_task/project_picker.dart)
- [`lib/features/tasks/presentation/add_task/tags_picker.dart`](lib/features/tasks/presentation/add_task/tags_picker.dart)

**Các chuỗi tiếng Việt:**
- "Vui lòng nhập tên task!"
- "Task đã được tạo thành công!"
- "Lỗi khi tạo task"

#### C. Project và Tag Management
**Files cần xử lý:**
- [`lib/features/tasks/presentation/manage_project_and_tags/manage_projects_tags_screen.dart`](lib/features/tasks/presentation/manage_project_and_tags/manage_projects_tags_screen.dart)
- [`lib/features/tasks/presentation/manage_project_and_tags/archived_projects_screen.dart`](lib/features/tasks/presentation/manage_project_and_tags/archived_projects_screen.dart)
- [`lib/features/tasks/presentation/manage_project_and_tags/archived_tags_screen.dart`](lib/features/tasks/presentation/manage_project_and_tags/archived_tags_screen.dart)
- [`lib/features/tasks/presentation/add_project_and_tags/add_project_screen.dart`](lib/features/tasks/presentation/add_project_and_tags/add_project_screen.dart)
- [`lib/features/tasks/presentation/add_project_and_tags/add_tag_screen.dart`](lib/features/tasks/presentation/add_project_and_tags/add_tag_screen.dart)
- [`lib/features/tasks/presentation/manage_project_and_tags/edit_project_and_tags/edit_project_screen.dart`](lib/features/tasks/presentation/manage_project_and_tags/edit_project_and_tags/edit_project_screen.dart)
- [`lib/features/tasks/presentation/manage_project_and_tags/edit_project_and_tags/edit_tag_screen.dart`](lib/features/tasks/presentation/manage_project_and_tags/edit_project_and_tags/edit_tag_screen.dart)

**Các chuỗi tiếng Việt:**
- "Quản lý Dự án và Nhãn"
- "Lưu trữ", "Khôi phục dự án/thẻ"
- "Không có dự án nào được lưu trữ"
- "Vui lòng nhập tên project/tag!"
- "Vui lòng chọn màu cho project!"
- "Vui lòng chọn một icon cho project!"
- "Vui lòng chọn màu chữ cho tag!"
- "Project/Tag đã được thêm thành công!"
- "Lỗi khi thêm/cập nhật project/tag"
- "Tên Project", "Tên Tag", "Màu sắc"
- "Thêm Tag", "Thêm Project"
- "Lưu thay đổi"

#### D. Task Detail Screen
**Files cần xử lý:**
- [`lib/features/tasks/presentation/task_detail_screen.dart`](lib/features/tasks/presentation/task_detail_screen.dart)

**Các chuỗi tiếng Việt:**
- "Trạng thái", "Đã hoàn thành", "Chưa hoàn thành"
- "Ngày đến hạn"
- "Độ ưu tiên", "Không đặt"
- "Dự án", "Nhắc nhở", "Lặp lại"
- "Chưa đặt", "Không"
- "Thẻ", "Ghi chú", "Tệp đính kèm"
- "Chưa có tệp đính kèm"
- "Thêm subtask"
- "Xóa Task", "Xóa vĩnh viễn", "Khôi phục"
- Messages: "Task đã được xóa vĩnh viễn!", "Task đã được chuyển vào Thùng rác!"

#### E. Report Module
**Files cần xử lý:**
- [`lib/features/report/presentation/tab/tasks_report_tab.dart`](lib/features/report/presentation/tab/tasks_report_tab.dart)
- Các file khác trong report module

**Các chuỗi tiếng Việt:**
- "Task Completed Today/This Week/This Month"
- "Top Tasks by Focus Time"
- "Task Completion Trend"

#### F. Domain Layer (Error Messages)
**Files cần xử lý:**
- [`lib/features/tasks/domain/task_cubit.dart`](lib/features/tasks/domain/task_cubit.dart)
- [`lib/features/tasks/data/task_repository.dart`](lib/features/tasks/data/task_repository.dart)
- [`lib/features/tasks/data/models/project_tag_repository.dart`](lib/features/tasks/data/models/project_tag_repository.dart)

**Các chuỗi tiếng Việt trong exceptions:**
- "Người dùng chưa đăng nhập"
- "Bạn không có quyền..."
- "Lỗi khi xóa/cập nhật..."

### 2. Mapping Vietnamese → English

#### Category Names
```dart
"Hôm nay" → "Today"
"Ngày mai" → "Tomorrow"
"Tuần này" → "This Week"
"Kế hoạch" → "Planned"
"Hoàn thành" → "Completed"
"Thùng rác" → "Trash"
"Dự án" → "Projects"
```

#### Common UI Labels
```dart
"Tìm kiếm..." → "Search..."
"Thêm một task" → "Add a task"
"Task không có tiêu đề" → "Untitled Task"
"Không có dự án" → "No Project"
"Không có Project" → "No Project"
"Dự án không tồn tại" → "Project Not Found"
"Dự án không xác định" → "Undefined Project"
"Đã lên kế hoạch" → "Planned"
```

#### Task Detail Labels
```dart
"Trạng thái" → "Status"
"Đã hoàn thành" → "Completed"
"Chưa hoàn thành" → "Not Completed"
"Ngày đến hạn" → "Due Date"
"Độ ưu tiên" → "Priority"
"Không đặt" → "Not Set"
"Chưa đặt" → "Not Set"
"Nhắc nhở" → "Reminder"
"Lặp lại" → "Repeat"
"Không" → "None"
"Thẻ" → "Tags"
"Ghi chú" → "Notes"
"Tệp đính kèm" → "Attachments"
"Chưa có tệp đính kèm" → "No attachments"
"Subtask không có tiêu đề" → "Untitled Subtask"
```

#### Action Buttons
```dart
"Thêm subtask" → "Add subtask"
"Thêm" → "Add"
"Hủy" → "Cancel"
"Xóa" → "Delete"
"Xóa Task" → "Delete Task"
"Xóa vĩnh viễn" → "Delete Permanently"
"Khôi phục" → "Restore"
"Lưu trữ" → "Archive"
"Sửa" → "Edit"
"Lưu thay đổi" → "Save Changes"
"Tìm kiếm" → "Search"
```

#### Sort Options
```dart
"Sắp xếp theo tiêu đề" → "Sort by Title"
"Sắp xếp theo ngày đến hạn" → "Sort by Due Date"
"Sắp xếp theo độ ưu tiên" → "Sort by Priority"
"Sắp xếp theo ngày xóa" → "Sort by Deleted Date"
```

#### Stats Labels
```dart
"Tổng thời gian dự kiến" → "Total Estimated Time"
"Thời gian đã hoàn thành" → "Completed Time"
"Task đang chờ" → "Pending Tasks"
"Task đã hoàn thành" → "Completed Tasks"
"đã chọn" → "selected"
```

#### Project & Tag Management
```dart
"Quản lý Dự án và Nhãn" → "Manage Projects and Tags"
"Tên Project" → "Project Name"
"Tên Tag" → "Tag Name"
"Màu sắc" → "Color"
"Màu sắc Tag" → "Tag Color"
"Không có dự án nào được lưu trữ" → "No archived projects"
"Không có thẻ nào được lưu trữ" → "No archived tags"
"Khôi phục dự án" → "Restore project"
"Khôi phục thẻ" → "Restore tag"
"Archived Projects" → "Archived Projects"
```

#### Success/Error Messages
```dart
// Success Messages
"Task đã được tạo thành công!" → "Task created successfully!"
"Task đã được khôi phục!" → "Task restored successfully!"
"Task đã được xóa vĩnh viễn!" → "Task deleted permanently!"
"Task đã được chuyển vào Thùng rác!" → "Task moved to trash!"
"Đã khôi phục X task!" → "X task(s) restored!"
"Đã xóa vĩnh viễn X task!" → "X task(s) deleted permanently!"
"Project đã được thêm thành công!" → "Project added successfully!"
"Project đã được cập nhật thành công!" → "Project updated successfully!"
"Dự án đã được khôi phục!" → "Project restored successfully!"
"Dự án đã được xóa vĩnh viễn!" → "Project deleted permanently!"
"Tag đã được thêm thành công!" → "Tag added successfully!"
"Tag đã được cập nhật thành công!" → "Tag updated successfully!"
"Thẻ đã được khôi phục!" → "Tag restored successfully!"
"Thẻ đã được xóa vĩnh viễn!" → "Tag deleted permanently!"

// Error Messages
"Vui lòng nhập tên task!" → "Please enter a task name!"
"Vui lòng nhập tên project!" → "Please enter a project name!"
"Vui lòng nhập tên tag!" → "Please enter a tag name!"
"Vui lòng chọn màu cho project!" → "Please select a color for the project!"
"Vui lòng chọn một icon cho project!" → "Please select an icon for the project!"
"Vui lòng chọn màu chữ cho tag!" → "Please select a text color for the tag!"
"Vui lòng đăng nhập để tiếp tục." → "Please login to continue."
"Lỗi khi tạo task:" → "Error creating task:"
"Lỗi khi khôi phục:" → "Error restoring:"
"Lỗi khi xóa:" → "Error deleting:"
"Lỗi khi thêm project:" → "Error adding project:"
"Lỗi khi cập nhật project:" → "Error updating project:"
"Lỗi khi xóa dự án:" → "Error deleting project:"
"Lỗi khi thêm tag:" → "Error adding tag:"
"Lỗi khi cập nhật tag:" → "Error updating tag:"
"Lỗi khi xóa thẻ:" → "Error deleting tag:"
"Lỗi:" → "Error:"

// Exception Messages
"Người dùng chưa đăng nhập" → "User not logged in"
"Bạn không có quyền..." → "You don't have permission..."
"Không thể cập nhật..." → "Cannot update..."
"Không tìm thấy..." → "Not found..."
"Tên project đã tồn tại" → "Project name already exists"
"Tên tag đã tồn tại" → "Tag name already exists"
```

#### Confirmation Dialogs
```dart
"Bạn có chắc muốn xóa vĩnh viễn task ... không?" → "Are you sure you want to permanently delete task ...?"
"Task ... sẽ được chuyển vào Thùng rác. Bạn có muốn tiếp tục?" → "Task ... will be moved to trash. Do you want to continue?"
"Bạn có chắc muốn xóa vĩnh viễn X task không?" → "Are you sure you want to permanently delete X task(s)?"
"Bạn có chắc muốn xóa vĩnh viễn dự án ... không?" → "Are you sure you want to permanently delete project ...?"
"Hành động này không thể hoàn tác và sẽ gỡ bỏ dự án này khỏi tất cả các task liên quan." → "This action cannot be undone and will remove this project from all related tasks."
"Bạn có chắc muốn xóa vĩnh viễn thẻ ... không?" → "Are you sure you want to permanently delete tag ...?"
"Hành động này không thể hoàn tác và sẽ gỡ bỏ thẻ này khỏi tất cả các task liên quan." → "This action cannot be undone and will remove this tag from all related tasks."
```

#### Empty States
```dart
"Thùng rác trống." → "Trash is empty."
"Không có task nào đã hoàn thành." → "No completed tasks."
"Không có task nào trong mục ..." → "No tasks in ..."
```

#### Search & Filter
```dart
"Tìm kiếm trong thùng rác..." → "Search in trash..."
"Tìm kiếm trong ..." → "Search in ..."
"Nhập tên task..." → "Enter task name..."
"Tìm kiếm task đã hoàn thành" → "Search completed tasks"
```

## Chiến lược thực hiện

### Bước 1: Tạo Constants File
Tạo file `lib/core/constants/app_strings.dart` để quản lý tập trung tất cả strings:

```dart
class AppStrings {
  // Categories
  static const String today = 'Today';
  static const String tomorrow = 'Tomorrow';
  static const String thisWeek = 'This Week';
  static const String planned = 'Planned';
  static const String completed = 'Completed';
  static const String trash = 'Trash';
  static const String projects = 'Projects';
  
  // Common Labels
  static const String search = 'Search...';
  static const String addTask = 'Add a task';
  static const String untitledTask = 'Untitled Task';
  static const String noProject = 'No Project';
  
  // ... (tiếp tục với tất cả các strings khác)
}
```

### Bước 2: Chuyển đổi từng module
Thay thế hard-coded strings bằng constants từ `AppStrings`

### Bước 3: Kiểm tra và testing
- Chạy app và kiểm tra tất cả các screens
- Đảm bảo không còn tiếng Việt nào hiển thị
- Test các chức năng CRUD
- Test error messages

## Checklist chi tiết

### Task Management
- [ ] [`task_manage_screen.dart`](lib/features/tasks/presentation/task_manage_screen.dart:202) - Category cards (Hôm nay, Ngày mai, Tuần này, Kế hoạch, Hoàn thành, Thùng rác)
- [ ] [`task_manage_screen.dart`](lib/features/tasks/presentation/task_manage_screen.dart:337) - "Dự án" header
- [ ] [`task_manage_screen.dart`](lib/features/tasks/presentation/task_manage_screen.dart:162) - "Quản lý Dự án và Nhãn"
- [ ] [`task_list_screen.dart`](lib/features/tasks/presentation/task_list_screen.dart:77) - Screen titles
- [ ] [`task_list_screen.dart`](lib/features/tasks/presentation/task_list_screen.dart:216) - Stats labels
- [ ] [`task_list_screen.dart`](lib/features/tasks/presentation/task_list_screen.dart:332) - "Thêm một task"
- [ ] [`task_list_screen.dart`](lib/features/tasks/presentation/task_list_screen.dart:184) - Sort menu items
- [ ] [`task_detail_screen.dart`](lib/features/tasks/presentation/task_detail_screen.dart:228) - All detail labels
- [ ] [`trash_screen.dart`](lib/features/tasks/presentation/trash_screen.dart:68) - "Thùng rác" title
- [ ] [`trash_screen.dart`](lib/features/tasks/presentation/trash_screen.dart:121) - Sort options
- [ ] [`trash_screen.dart`](lib/features/tasks/presentation/trash_screen.dart:232) - Menu items (Khôi phục, Xóa vĩnh viễn)
- [ ] [`completed_tasks_screen.dart`](lib/features/tasks/presentation/completed_tasks_screen.dart:61) - "Đã hoàn thành" title
- [ ] [`task_item_card.dart`](lib/features/tasks/presentation/widgets/task_item_card.dart:131) - "Task không có tiêu đề"
- [ ] [`search_bar_widget.dart`](lib/features/tasks/presentation/widgets/search_bar_widget.dart:20) - "Tìm kiếm..." hint

### Add Task
- [ ] [`add_task_bottom_sheet.dart`](lib/features/tasks/presentation/add_task/add_task_bottom_sheet.dart:208) - Error messages
- [ ] [`add_task_bottom_sheet.dart`](lib/features/tasks/presentation/add_task/add_task_bottom_sheet.dart:242) - Success messages

### Project & Tag Management
- [ ] [`manage_projects_tags_screen.dart`](lib/features/tasks/presentation/manage_project_and_tags/manage_projects_tags_screen.dart:138) - "Lưu trữ" menu
- [ ] [`archived_projects_screen.dart`](lib/features/tasks/presentation/manage_project_and_tags/archived_projects_screen.dart:76) - Empty state
- [ ] [`archived_projects_screen.dart`](lib/features/tasks/presentation/manage_project_and_tags/archived_projects_screen.dart:122) - Tooltips
- [ ] [`archived_tags_screen.dart`](lib/features/tasks/presentation/manage_project_and_tags/archived_tags_screen.dart:131) - Tooltips
- [ ] [`add_project_screen.dart`](lib/features/tasks/presentation/add_project_and_tags/add_project_screen.dart:63) - Validation messages
- [ ] [`add_project_screen.dart`](lib/features/tasks/presentation/add_project_and_tags/add_project_screen.dart:197) - Labels
- [ ] [`add_tag_screen.dart`](lib/features/tasks/presentation/add_project_and_tags/add_tag_screen.dart:48) - Validation messages
- [ ] [`add_tag_screen.dart`](lib/features/tasks/presentation/add_project_and_tags/add_tag_screen.dart:164) - Labels
- [ ] [`edit_project_screen.dart`](lib/features/tasks/presentation/manage_project_and_tags/edit_project_and_tags/edit_project_screen.dart:122) - Validation messages
- [ ] [`edit_tag_screen.dart`](lib/features/tasks/presentation/manage_project_and_tags/edit_project_and_tags/edit_tag_screen.dart:103) - Validation messages

### Domain & Data Layer
- [ ] [`task_cubit.dart`](lib/features/tasks/domain/task_cubit.dart:57) - Exception messages
- [ ] [`task_repository.dart`](lib/features/tasks/data/task_repository.dart:37) - Print/error messages
- [ ] [`project_tag_repository.dart`](lib/features/tasks/data/models/project_tag_repository.dart:35) - Exception messages

### Comments (Optional - for code clarity)
- [ ] Cập nhật các comments tiếng Việt trong code (nếu cần thiết cho team)

## Lưu ý quan trọng

1. **Không thay đổi logic code** - Chỉ thay đổi strings hiển thị
2. **Kiểm tra kỹ error handling** - Đảm bảo exception messages đầy đủ
3. **Test confirmation dialogs** - Đảm bảo messages rõ ràng
4. **Kiểm tra empty states** - Đảm bảo thông báo phù hợp
5. **Database/Backend** - Không thay đổi category values trong database (Today, Tomorrow, etc. đã là tiếng Anh)

## Thời gian ước tính

- Tạo constants file: 30 phút
- Task Management module: 2 giờ
- Project & Tag Management: 1.5 giờ
- Domain & Data layer: 1 giờ
- Testing: 1 giờ
- **Tổng: ~6 giờ**

## Rủi ro và cách xử lý

1. **Breaking changes**: Backup code trước khi thay đổi
2. **Missing translations**: Giữ list tất cả strings cần translate
3. **Inconsistent naming**: Sử dụng constants file để đảm bảo nhất quán