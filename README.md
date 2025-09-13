<p align="center">
  <a href="https://github.com/Tung204/dntu_focus">
    <img src="assets/images/logo_moji.png" width="120" alt="DNTU-Focus logo"/>
  </a>
</p>

<h1 align="center">DNTU-Focus</h1>

<p align="center">
  Ứng dụng Pomodoro hỗ trợ học tập, tích hợp AI ChatBot và quản lý công việc thông minh.
</p>

<p align="center">
  <a href="https://github.com/Tung204/dntu_focus">
    <img alt="Awesome" src="https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg"/>
  </a>
  <a href="https://github.com/Tung204/dntu_focus/blob/master/LICENSE">
    <img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-yellow.svg"/>
  </a>
</p>

---

## Nhóm dự án

- [Nguyễn Sơn Tùng](https://github.com/Tung204) – Chủ nhiệm dự án  
- [Võ Văn Tín](https://github.com/TINVO04) – Nhà phát triển

---

## 📝 Giới thiệu

**[DNTU-Focus](https://github.com/Tung204/dntu_focus)** là ứng dụng di động được phát triển bằng [Flutter](https://flutter.dev/), sử dụng kỹ thuật [Pomodoro](https://en.wikipedia.org/wiki/Pomodoro_Technique) và tích hợp ChatBot AI để nâng cao hiệu suất học tập. Ứng dụng được phát triển bởi sinh viên [Đại học Công nghệ Đồng Nai (DNTU)](https://dntu.edu.vn/), hỗ trợ quản lý công việc, lịch học, và tạo môi trường học tập tập trung.

📱 Nếu bạn thấy dự án hữu ích, hãy **⭐ Star**, **👍 Like**, hoặc **👏 Share** nhé!

---

<p align="center">
  <em>Phát triển như một dự án nghiên cứu tại Đại học Công nghệ Đồng Nai – kết hợp công nghệ hiện đại và trải nghiệm người dùng.</em>
</p>

---

## Trình diễn

<div style="text-align: center"><table><tr>
<td style="text-align: center; width: 180">
<a href="https://github.com/Tung204/dntu_focus">
Bộ đếm Pomodoro
</a>
Chu kỳ làm việc/nghỉ tùy chỉnh với Chế độ nghiêm ngặt và Âm thanh nền.
</td>
<td style="text-align: center; width: 180">
<a href="https://github.com/Tung204/dntu_focus">
ChatBot AI
</a>
Quản lý công việc và lịch học bằng lệnh ngôn ngữ tự nhiên qua văn bản/giọng nói.
</td>
<td style="text-align: center; width: 180">
<a href="https://github.com/Tung204/dntu_focus">
Quản lý công việc
</a>
Sắp xếp công việc với dự án và thẻ, đồng bộ qua Firestore.
</td>
</tr></table></div>

## Mục lục

- [Tổng quan](#tổng-quan)
- [Tính năng](#tính-năng)
- [Hướng dẫn sử dụng](#hướng-dẫn-sử-dụng)
- [Thành phần](#thành-phần)
- [Yêu cầu môi trường](#yêu-cầu-môi-trường)
- [Cài đặt và chạy dự án](#cài-đặt-và-chạy-dự-án)
- [Tài khoản Demo](#tài-khoản-demo)
- [Màn hình đăng nhập giả lập](#màn-hình-đăng-nhập-giả-lập)
- [Chạy nhanh](#chạy-nhanh)
- [Kiến trúc](#kiến-trúc)
- [Đóng góp](#đóng-góp)
- [Giấy phép](#giấy-phép)
- [Liên hệ](#liên-hệ)

## Tổng quan

**DNTU-Focus** là ứng dụng năng suất giúp sinh viên quản lý thời gian và công việc hiệu quả. Được xây dựng bằng [Flutter](https://flutter.dev/), ứng dụng áp dụng kỹ thuật [Pomodoro](https://en.wikipedia.org/wiki/Pomodoro_Technique) để tăng cường tập trung, tích hợp các tính năng như Chế độ nghiêm ngặt, Âm thanh nền, và ChatBot AI sử dụng [Gemini Service](https://ai.google.dev/). Dữ liệu được đồng bộ với [Firebase Firestore](https://firebase.google.com/products/firestore) và lưu cục bộ bằng [Hive](https://pub.dev/packages/hive), đảm bảo truy cập cả khi online và offline.

## Tính năng

- **Bộ đếm Pomodoro** [🔗](https://en.wikipedia.org/wiki/Pomodoro_Technique): Chu kỳ làm việc/nghỉ tùy chỉnh (mặc định: 25/5 phút).
    - **Chế độ nghiêm ngặt**: Chặn ứng dụng gây phân tâm, yêu cầu lật điện thoại, hoặc ngăn thoát ứng dụng.
    - **Âm thanh nền**: Âm thanh môi trường (ví dụ: mưa, quán cà phê) để tăng tập trung.
    - **Chuyển tự động**: Chuyển đổi tự động giữa làm việc và nghỉ.
- **Quản lý công việc** [🔗](https://github.com/Tung204/dntu_focus/tree/master/lib/features/tasks): Sắp xếp công việc với dự án và thẻ, đồng bộ qua Firestore.
- **ChatBot AI** [🔗](https://ai.google.dev/): Lệnh ngôn ngữ tự nhiên (ví dụ: "Học toán 25 phút") với đầu vào văn bản/giọng nói sử dụng [speech_to_text](https://pub.dev/packages/speech_to_text).
- **Chế độ tối**: Giao diện thân thiện với mắt, đồng bộ trên mọi màn hình.
- **Thông báo** [🔗](https://firebase.google.com/products/cloud-messaging): Nhắc nhở công việc và lịch học qua Firebase Messaging.
- **Lịch biểu**: Hiển thị công việc và lịch học trực quan.

## Hướng dẫn sử dụng

### Bắt đầu
- **Thiết lập phiên Pomodoro**:
    - Mở `HomeScreen` và nhấn "Bắt đầu tập trung" để khởi động phiên 25 phút.
    - Tùy chỉnh thời gian trong `TimerModeMenu` (ví dụ: 30 phút làm, 10 phút nghỉ).
- **Sử dụng Chế độ nghiêm ngặt** [🔗](https://github.com/Tung204/dntu_focus/tree/master/lib/features/home/presentation/strict_mode_menu.dart):
    - Bật qua `StrictModeMenu` để chặn ứng dụng hoặc áp dụng quy tắc tập trung.
- **Âm thanh nền** [🔗](https://github.com/Tung204/dntu_focus/tree/master/lib/features/home/presentation/white_noise_menu.dart):
    - Chọn âm thanh môi trường (ví dụ: "Mưa") trong `WhiteNoiseMenu`.

### Quản lý công việc
- **Thêm công việc** [🔗](https://github.com/Tung204/dntu_focus/tree/master/lib/features/tasks):
    - Sử dụng `TaskManageScreen` để tạo công việc với dự án và thẻ.
    - Xem trong `CalendarScreen` hoặc `TaskListScreen`.
- **Đồng bộ dữ liệu**:
    - Công việc được đồng bộ lên Firestore mỗi 15 phút (xem `BackupService` [🔗](https://github.com/Tung204/dntu_focus/tree/master/lib/core/services/backup_service.dart)).

### ChatBot AI
- **Tương tác với ChatBot** [🔗](https://github.com/Tung204/dntu_focus/tree/master/lib/features/ai_chat):
    - Mở `AIChatScreen` và sử dụng lệnh văn bản/giọng nói (ví dụ: "Lên lịch ôn thi ngày mai").
    - Nhận thông báo cho công việc đã lên lịch.

## Thành phần

### Giao diện
- **CustomAppBar** [🔗](https://github.com/Tung204/dntu_focus/blob/master/lib/core/widgets/custom_app_bar.dart) [⭐]: Thanh ứng dụng responsive với tiêu đề gradient và cài đặt.
- **CustomButton** [🔗](https://github.com/Tung204/dntu_focus/blob/master/lib/core/widgets/custom_button.dart) [⭐]: Nút động với hiệu ứng gradient tùy chọn.
- **CustomBottomNavBar** [🔗](https://github.com/Tung204/dntu_focus/blob/master/lib/core/widgets/custom_bottom_nav_bar.dart) [⭐]: Thanh điều hướng động cho chuyển đổi màn hình mượt mà.

### Widget
- **PomodoroTimer** [🔗](https://github.com/Tung204/dntu_focus/blob/master/lib/features/home/presentation/widgets/pomodoro_timer.dart) [⭐]: Bộ đếm chính với Chế độ nghiêm ngặt và Chuyển tự động.
- **WhiteNoiseMenu** [🔗](https://github.com/Tung204/dntu_focus/blob/master/lib/features/home/presentation/white_noise_menu.dart) [⭐]: Bộ chọn âm thanh môi trường để tập trung.
- **TaskCard** [🔗](https://github.com/Tung204/dntu_focus/blob/master/lib/features/home/presentation/widgets/task_card.dart) [⭐]: Hiển thị công việc với hỗ trợ dự án/thẻ.

## Yêu cầu môi trường

### Backend (Express.js)
- **Node.js**: Phiên bản 16.0.0 trở lên
- **npm**: Phiên bản 8.0.0 trở lên
- **MongoDB**: Phiên bản 4.4 trở lên (hoặc MongoDB Atlas)
- **Firebase Admin SDK**: Để xác thực và quản lý người dùng

### Mobile (Flutter)
- **Flutter**: Phiên bản 3.10.0 trở lên
- **Dart**: Phiên bản 3.0.0 trở lên
- **Android Studio**: Phiên bản 2022.1 trở lên
- **VS Code**: Với Flutter extension
- **Firebase CLI**: Để cấu hình Firebase

### Công cụ phát triển
- **Git**: Phiên bản 2.30 trở lên
- **Postman**: Để test API (tùy chọn)
- **MongoDB Compass**: Để quản lý database (tùy chọn)

## Cài đặt và chạy dự án

### 1. Sao chép kho mã nguồn
```bash
git clone https://github.com/Tung204/dntu_focus.git
cd dntu_focus
```

### 2. Cấu hình môi trường

#### Tạo file .env từ .env.example
```bash
# Sao chép file mẫu
cp .env.example .env

# Chỉnh sửa các giá trị trong .env
nano .env
```

#### Nội dung file .env.example
```env
# Firebase Configuration
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY_ID=your-private-key-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nyour-private-key\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=your-client-email
FIREBASE_CLIENT_ID=your-client-id
FIREBASE_AUTH_URI=https://accounts.google.com/o/oauth2/auth
FIREBASE_TOKEN_URI=https://oauth2.googleapis.com/token

# Database
MONGODB_URI=mongodb://localhost:27017/dntu_focus
# Hoặc MongoDB Atlas: mongodb+srv://username:password@cluster.mongodb.net/dntu_focus

# Server Configuration
PORT=3000
NODE_ENV=development

# JWT Secret
JWT_SECRET=your-super-secret-jwt-key

# Gemini AI API
GEMINI_API_KEY=your-gemini-api-key

# Email Configuration (tùy chọn)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-password
```

### 3. Chạy Backend (Express.js)

```bash
# Di chuyển vào thư mục backend
cd functions

# Cài đặt dependencies
npm install

# Chạy server development
npm run dev

# Hoặc chạy production
npm start
```

**Backend sẽ chạy tại:** `http://localhost:3000`

### 4. Chạy Mobile (Flutter)

```bash
# Quay lại thư mục gốc
cd ..

# Cài đặt Flutter dependencies
flutter pub get

# Cấu hình Firebase
flutterfire configure

# Chạy ứng dụng
flutter run

# Hoặc chạy trên thiết bị cụ thể
flutter run -d chrome  # Web
flutter run -d android # Android
flutter run -d ios     # iOS
```

### 5. Cấu hình Firebase

1. **Tạo dự án Firebase**:
   - Truy cập [Firebase Console](https://console.firebase.google.com/)
   - Tạo dự án mới hoặc sử dụng dự án hiện có

2. **Cấu hình Authentication**:
   - Bật Email/Password authentication
   - Bật Google Sign-In (tùy chọn)

3. **Cấu hình Firestore**:
   - Tạo database Firestore
   - Cập nhật quy tắc bảo mật:
   ```firestore
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /tasks/{taskId} {
         allow read, write: if request.auth != null && request.auth.uid == resource.data.uid;
       }
       match /projects/{projectId} {
         allow read, write: if request.auth != null && request.auth.uid == resource.data.uid;
       }
       match /tags/{tagId} {
         allow read, write: if request.auth != null && request.auth.uid == resource.data.uid;
       }
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

4. **Tải file cấu hình**:
   - Tải `google-services.json` cho Android và đặt vào `android/app/`
   - Tải `GoogleService-Info.plist` cho iOS và đặt vào `ios/Runner/`

## Tài khoản Demo

### Tài khoản mặc định
```
Email: demo@dntu.edu.vn
Password: demo123456
```

### Tài khoản test
```
Email: test@dntu.edu.vn
Password: test123456
```

### Tạo tài khoản mới
- Sử dụng tính năng đăng ký trong ứng dụng
- Hoặc tạo qua Firebase Console

## Màn hình đăng nhập giả lập

Ứng dụng có màn hình đăng nhập giả lập với các tính năng:

### Tính năng đăng nhập
- **Đăng nhập bằng Email/Password**
- **Đăng ký tài khoản mới**
- **Quên mật khẩu** (gửi email reset)
- **Đăng nhập bằng Google** (tùy chọn)
- **Lưu thông tin đăng nhập** (Remember me)

### Giao diện
- **Thiết kế Material Design 3**
- **Hỗ trợ Dark/Light mode**
- **Responsive design** cho mọi kích thước màn hình
- **Animation mượt mà** khi chuyển đổi
- **Validation form** real-time

### Bảo mật
- **Mã hóa mật khẩu** bằng bcrypt
- **JWT token** cho xác thực
- **Rate limiting** chống brute force
- **Input validation** và sanitization

## Chạy nhanh

### Backend + Mobile cùng lúc
```bash
# Terminal 1: Chạy Backend
cd functions
npm install
npm run dev

# Terminal 2: Chạy Mobile
cd ..
flutter pub get
flutter run
```

### Kiểm tra kết nối
- **Backend API**: `http://localhost:3000/api/health`
- **Mobile App**: Mở ứng dụng và đăng nhập bằng tài khoản demo
- **Database**: Kiểm tra kết nối MongoDB

5. **Chạy kiểm thử**:
   ```bash
   flutter test
   ```

## Kiến trúc

### Công nghệ

#### Backend (Express.js)
- **Framework**: [Express.js](https://expressjs.com/) với [Node.js](https://nodejs.org/)
- **Database**: [MongoDB](https://www.mongodb.com/) với [Mongoose](https://mongoosejs.com/)
- **Authentication**: [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)
- **API**: RESTful API với JWT authentication
- **Validation**: [Joi](https://joi.dev/) cho input validation
- **Security**: [bcrypt](https://www.npmjs.com/package/bcrypt) cho mã hóa mật khẩu

#### Mobile (Flutter)
- **Giao diện**: [Flutter](https://flutter.dev/) với [Dart](https://dart.dev/)
- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc) và [provider](https://pub.dev/packages/provider)
- **Hậu cần**: [Firebase Firestore](https://firebase.google.com/products/firestore) để đồng bộ
- **Lưu trữ cục bộ**: [Hive](https://pub.dev/packages/hive) cho dữ liệu offline
- **AI**: [Gemini Service](https://ai.google.dev/) để xử lý ngôn ngữ tự nhiên
- **Thư viện**: [google_fonts](https://pub.dev/packages/google_fonts), [speech_to_text](https://pub.dev/packages/speech_to_text), [flutter_dotenv](https://pub.dev/packages/flutter_dotenv)

### Cấu trúc thư mục

#### Backend (Express.js)
```
functions/
├── src/
│   ├── controllers/    # AuthController, TaskController, UserController
│   ├── models/         # User, Task, Project models
│   ├── routes/         # API routes
│   ├── middleware/     # Auth, Validation middleware
│   ├── services/       # Firebase, Email services
│   └── utils/          # Helpers, constants
├── package.json
└── .env.example
```

#### Mobile (Flutter)
```
lib/
├── core/
│   ├── services/        # BackupService, NotificationService
│   ├── themes/         # Theme, ThemeProvider
│   ├── widgets/        # CustomAppBar, CustomButton
├── features/
│   ├── auth/           # LoginScreen, RegisterScreen
│   ├── home/           # HomeScreen, PomodoroTimer, WhiteNoiseMenu
│   ├── tasks/          # TaskManageScreen, TaskCubit
│   ├── ai_chat/        # AIChatScreen
│   ├── splash/         # SplashScreen
├── routes/             # AppRoutes
└── main.dart
```

## Đóng góp

Chúng tôi hoan nghênh mọi đóng góp để cải thiện DNTU-Focus! Để đóng góp:

1. Fork kho mã nguồn [🔗](https://github.com/Tung204/dntu_focus).
2. Tạo nhánh tính năng:
   ```bash
   git checkout -b feature/your-feature
   ```
3. Commit thay đổi:
   ```bash
   git commit -m 'Thêm tính năng của bạn'
   ```
4. Đẩy lên nhánh:
   ```bash
   git push origin feature/your-feature
   ```
5. Mở Pull Request [🔗](https://github.com/Tung204/dntu_focus/pulls).

### Hướng dẫn
- Tuân theo [hướng dẫn phong cách Flutter](https://dart.dev/guides/language/effective-dart/style).
- Sử dụng `Theme.of(context)` cho giao diện để hỗ trợ Chế độ tối.
- Kiểm tra với [Firebase Emulator](https://firebase.google.com/docs/emulator-suite).
- Ghi chú thay đổi trong Pull Request.

## Giấy phép

Được cấp phép theo [Giấy phép MIT](LICENSE) [🔗](https://github.com/Tung204/dntu_focus/blob/master/LICENSE).

## Liên hệ

**GitHub**: [github.com/Tung204/dntu_focus](https://github.com/Tung204/dntu_focus)  
**Email**: [nst874@gmail.com](mailto:nst874@gmail.com), [tinvo.bh2018@gmail.com](mailto:tinvo.bh2018@gmail.com)

---

Phát triển với ❤️ bởi Sinh viên DNTU
