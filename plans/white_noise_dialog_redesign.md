# Kế hoạch Thiết kế lại White Noise Dialog

## 📋 Tổng quan
Thiết kế lại White Noise dialog thành bottom sheet format giống Strict Mode và Timer Mode, đồng thời cập nhật để sử dụng đúng files âm thanh có sẵn.

## 🎯 Mục tiêu
1. Chuyển từ `showModalBottomSheet` inline sang widget riêng biệt
2. Sử dụng đúng tên files âm thanh từ `assets/sounds/whiteNoise/`
3. Thiết kế UI/UX nhất quán với Strict Mode dialog
4. Thêm đầy đủ 8 white noise options

## 📊 Phân tích hiện tại

### Files âm thanh có sẵn
```
assets/sounds/whiteNoise/
├── bonfire.mp3          → Tiếng lửa bập bùng
├── cafe.mp3             → Tiếng quán cà phê
├── clock_ticking.mp3    → Tiếng đồng hồ tích tắc
├── gentle-rain.mp3      → Tiếng mưa nhẹ
├── library.mp3          → Tiếng thư viện
├── metronome.mp3        → Tiếng metronome
├── small-stream.mp3     → Tiếng suối nhỏ
└── water-stream.mp3     → Tiếng dòng nước
```

### Dialog hiện tại (Vấn đề)
**Vị trí**: [`home_screen.dart`](lib/features/home/presentation/home_screen.dart:714)

**Vấn đề 1**: Hardcoded inline trong `_showWhiteNoiseDialog()`
- Không tái sử dụng được
- Khó maintain
- Không nhất quán với các dialog khác

**Vấn đề 2**: Options không khớp với files thực tế
```dart
// ❌ HIỆN TẠI
- Rain (→ 'rain' - FILE KHÔNG TỒN TẠI)
- Wind (→ 'wind' - FILE KHÔNG TỒN TẠI)  
- Ocean (→ 'ocean' - FILE KHÔNG TỒN TẠI)

// ✅ NÊN LÀ
- Gentle Rain (→ 'gentle-rain')
- Water Stream (→ 'water-stream')
- Small Stream (→ 'small-stream')
- Bonfire (→ 'bonfire')
- Café Ambiance (→ 'cafe')
- Clock Ticking (→ 'clock_ticking')
- Library (→ 'library')
- Metronome (→ 'metronome')
```

**Vấn đề 3**: UI đơn giản, không có icon
- Chỉ có text và checkmark
- Không có icon minh họa
- Không có subtitle mô tả

## 🎨 Thiết kế mới

### Cấu trúc Widget
Tạo file mới: `lib/features/home/presentation/widgets/white_noise_dialog.dart`

```
WhiteNoiseDialog (StatefulWidget)
├── Container (rounded top corners)
│   ├── Column
│   │   ├── Header ("White Noise")
│   │   ├── Divider
│   │   ├── Content (Scrollable)
│   │   │   ├── Option: None
│   │   │   ├── Option: Gentle Rain  
│   │   │   ├── Option: Water Stream
│   │   │   ├── Option: Small Stream
│   │   │   ├── Option: Bonfire
│   │   │   ├── Option: Café Ambiance
│   │   │   ├── Option: Clock Ticking
│   │   │   ├── Option: Library
│   │   │   └── Option: Metronome
│   │   ├── Divider
│   │   └── Action Buttons (Cancel + OK)
```

### White Noise Options Mapping

| Tên hiển thị | File name | Icon | Subtitle |
|--------------|-----------|------|----------|
| None | null | close | Tắt white noise |
| Gentle Rain | gentle-rain | water_drop | Tiếng mưa nhẹ nhàng |
| Water Stream | water-stream | waves | Tiếng dòng nước chảy |
| Small Stream | small-stream | stream | Tiếng suối nhỏ róc rách |
| Bonfire | bonfire | local_fire_department | Tiếng lửa bập bùng |
| Café Ambiance | cafe | coffee | Không khí quán cà phê |
| Clock Ticking | clock_ticking | schedule | Tiếng đồng hồ tích tắc |
| Library | library | menu_book | Tiếng thư viện yên tĩnh |
| Metronome | metronome | music_note | Nhịp metronome đều đặn |

### UI Design (theo Strict Mode pattern)

```dart
_buildWhiteNoiseOption({
  required String title,
  required String? value,  // null for "None"
  required IconData icon,
  required String subtitle,
  required bool isSelected,
  required VoidCallback onTap,
})
```

Mỗi option sẽ có:
- **Icon** bên trái (màu primary nếu selected)
- **Title** (bold nếu selected)
- **Subtitle** (mô tả ngắn)
- **Checkmark** bên phải nếu selected
- **Border highlight** nếu selected

## 🔧 Implementation Plan

### Bước 1: Tạo WhiteNoiseDialog Widget

**File mới**: `lib/features/home/presentation/widgets/white_noise_dialog.dart`

**Cấu trúc**:
```dart
class WhiteNoiseDialog extends StatefulWidget {
  const WhiteNoiseDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WhiteNoiseDialog(),
    );
  }

  @override
  State<WhiteNoiseDialog> createState() => _WhiteNoiseDialogState();
}

class _WhiteNoiseDialogState extends State<WhiteNoiseDialog> {
  String? selectedWhiteNoise;  // null = None, or file name

  @override
  void initState() {
    super.initState();
    final homeState = context.read<HomeCubit>().state;
    selectedWhiteNoise = homeState.isWhiteNoiseEnabled 
        ? homeState.selectedWhiteNoise 
        : null;
  }

  @override
  Widget build(BuildContext context) {
    // Similar structure to StrictModeDialog
  }
}
```

**Options List**:
```dart
final whiteNoiseOptions = [
  WhiteNoiseOption(
    id: null,
    title: 'None',
    subtitle: 'Tắt white noise',
    icon: Icons.close,
  ),
  WhiteNoiseOption(
    id: 'gentle-rain',
    title: 'Gentle Rain',
    subtitle: 'Tiếng mưa nhẹ nhàng',
    icon: Icons.water_drop,
  ),
  // ... 7 options khác
];
```

### Bước 2: Cập nhật home_screen.dart

**Thay đổi dòng 714-785**:

```dart
// ❌ TRƯỚC
void _showWhiteNoiseDialog(BuildContext context, HomeState state) {
  final homeCubit = context.read<HomeCubit>();
  
  showModalBottomSheet(
    context: context,
    // ... 70 dòng code inline
  );
}

// ✅ SAU
void _showWhiteNoiseDialog(BuildContext context, HomeState state) {
  WhiteNoiseDialog.show(context);
}
```

### Bước 3: Cập nhật HomeCubit (nếu cần)

Kiểm tra và cập nhật logic trong HomeCubit để:
- Lưu đúng tên file (không phải tên hiển thị)
- Xử lý case `null` cho "None"
- Toggle white noise on/off dựa trên selection

## 📝 White Noise Options Details

```dart
class WhiteNoiseOption {
  final String? id;          // File name (null for None)
  final String title;        // Display name
  final String subtitle;     // Description
  final IconData icon;       // Icon to display
  
  const WhiteNoiseOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
```

**Full list**:
1. None - null - close - "Tắt white noise"
2. Gentle Rain - gentle-rain - water_drop - "Tiếng mưa nhẹ nhàng"
3. Water Stream - water-stream - waves - "Tiếng dòng nước chảy"
4. Small Stream - small-stream - stream - "Tiếng suối nhỏ róc rách"
5. Bonfire - bonfire - local_fire_department - "Tiếng lửa bập bùng"
6. Café Ambiance - cafe - coffee - "Không khí quán cà phê"
7. Clock Ticking - clock_ticking - schedule - "Tiếng đồng hồ tích tắc"
8. Library - library - menu_book - "Tiếng thư viện yên tĩnh"
9. Metronome - metronome - music_note - "Nhịp metronome đều đặn"

## ✅ Kết quả mong đợi

1. ✅ White Noise dialog hiển thị dưới dạng bottom sheet
2. ✅ Có 9 options (1 None + 8 sounds thực tế)
3. ✅ Sử dụng đúng tên file từ assets
4. ✅ UI đẹp với icon và subtitle
5. ✅ Nhất quán với Strict Mode và Timer Mode dialogs
6. ✅ Code sạch và dễ maintain

## 🔍 Checklist

- [ ] Tạo file `white_noise_dialog.dart`
- [ ] Implement WhiteNoiseOption class
- [ ] Implement WhiteNoiseDialog widget
- [ ] Tạo danh sách 9 options
- [ ] Implement UI cho mỗi option
- [ ] Xử lý logic selection
- [ ] Xử lý action buttons (Cancel/OK)
- [ ] Cập nhật `home_screen.dart` để sử dụng widget mới
- [ ] Test với tất cả options
- [ ] Kiểm tra file âm thanh có load đúng