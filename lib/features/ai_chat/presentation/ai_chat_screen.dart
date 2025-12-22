import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:moji_todo/core/services/improved_gemini_service.dart';
import 'package:moji_todo/core/services/unified_notification_service.dart';
import 'package:moji_todo/features/home/domain/home_cubit.dart';
import 'package:moji_todo/features/tasks/domain/task_cubit.dart';
import 'package:moji_todo/features/tasks/data/models/task_model.dart';
import 'package:moji_todo/core/widgets/custom_app_bar.dart';
// import 'package:moji_todo/features/ai_chat/data/services/ai_training_service.dart'; // Tạm thời comment
import 'package:moji_todo/features/ai_chat/presentation/widgets/ai_response_card.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  List<String> _suggestions = [];
  final ImprovedGeminiService _geminiService = ImprovedGeminiService();
  bool _isProcessing = false;
  bool _showFirstTimeGuide = true;
  // final AITrainingService _aiTrainingService = AITrainingService(FirebaseService()); // Tạm thời comment

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _loadSuggestions();
    _messages.add({
      'role': 'assistant',
      'content': 'Chào bạn! Mình là trợ lý AI DNTU-Focus. Bạn có thể trò chuyện với mình như:\n\n• "Làm bài tập toán 25 phút 5 phút nghỉ"\n• "Ngày mai đi chợ lúc 6 sáng"\n• "Bắt đầu Pomodoro 15 phút"\n\nMình sẽ giúp bạn tạo task và bắt đầu Pomodoro ngay!',
    });
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (error) => print('Speech error: $error'),
    );
    setState(() {});
  }

  void _loadSuggestions() async {
    final suggestions = await _geminiService.getSmartSuggestions(context: "đang học toán");
    setState(() {
      _suggestions = suggestions;
    });
  }

  Future<void> _handleMessage(String userMessage) async {
    setState(() {
      _messages.add({'role': 'user', 'content': userMessage});
      _isProcessing = true;
    });

    final commandResult = await _geminiService.parseUserCommand(userMessage);
    String response;
    Task? createdTask;
    String? createdLogId;

    if (commandResult.containsKey('error')) {
      response = commandResult['error'] as String;
      // Hiển thị error feedback widget
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $response'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      });
      
      // Lưu log lỗi vào Firebase (tạm thời bỏ)
      // await _aiTrainingService.logInteraction(...);
    } else {
      final taskCubit = context.read<TaskCubit>();
      if (commandResult['type'] == 'task') {
        final task = Task(
          title: commandResult['title'],
          estimatedPomodoros: (commandResult['duration'] / 25).ceil(),
          dueDate: commandResult['due_date'] != null
              ? DateTime.parse(commandResult['due_date'])
              : null,
          priority: commandResult['priority'],
          projectId: commandResult['project'],
          tagIds: commandResult['tags'] != null ? List<String>.from(commandResult['tags']) : null,
        );
        taskCubit.addTask(task);
        response = 'Đã thêm task: ${task.title}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        createdTask = task;
        createdLogId = DateTime.now().millisecondsSinceEpoch.toString();
      } else if (commandResult['type'] == 'schedule') {
        final task = Task(
          title: commandResult['title'],
          dueDate: DateTime.parse(commandResult['due_date']),
          priority: commandResult['priority'] ?? 'Medium',
          projectId: commandResult['project'],
          tagIds: commandResult['tags'] != null ? List<String>.from(commandResult['tags']) : null,
        );
        taskCubit.addTask(task);

        final reminderTime = DateTime.parse(commandResult['due_date'])
            .subtract(Duration(minutes: commandResult['reminder_before']));
        final notificationService = UnifiedNotificationService();
        await notificationService.scheduleNotification(
          title: 'Nhắc nhở: ${task.title}',
          body: 'Sắp đến giờ ${task.title} vào lúc ${commandResult['due_date']}',
          scheduledTime: reminderTime,
        );
        response = 'Đã lên lịch: ${task.title} vào ${task.dueDate}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        createdTask = task;
        createdLogId = DateTime.now().millisecondsSinceEpoch.toString();
      } else if (commandResult['type'] == 'pomodoro') {
        final homeCubit = context.read<HomeCubit>();
        final workDuration = commandResult['work_duration'] as int? ?? 25;
        final breakDuration = commandResult['break_duration'] as int? ?? 5;
        final sessions = commandResult['sessions'] as int? ?? 1;

        await homeCubit.updateTimerMode(
          timerMode: 'Tùy chỉnh',
          workDuration: workDuration,
          breakDuration: breakDuration,
          soundEnabled: homeCubit.state.soundEnabled,
          autoSwitch: homeCubit.state.autoSwitch,
          notificationSound: homeCubit.state.notificationSound,
          totalSessions: sessions,
        );
        homeCubit.selectTask(null, sessions);
        homeCubit.startTimer();

        response = 'Đã bắt đầu Pomodoro $workDuration phút';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        createdLogId = DateTime.now().millisecondsSinceEpoch.toString();
      } else {
        response = 'Không hiểu câu lệnh. Vui lòng thử lại!';
        // Hiển thị error feedback
        if (mounted) {
          // Hiển thị error snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response),
              backgroundColor: Theme.of(context).colorScheme.error,
              action: SnackBarAction(
                label: 'Thử lại',
                textColor: Theme.of(context).colorScheme.onError,
                onPressed: () => _handleMessage(userMessage),
              ),
            ),
          );

          // Cũng có thể hiển thị error feedback widget
          // ErrorFeedbackWidget(...);
        }
      }
    }

    // Lưu log tương tác thành công vào Firebase (tạm thời bỏ)
    // if (!commandResult.containsKey('error')) {
    //   await _aiTrainingService.logInteraction(...);
    // }

    setState(() {
      _messages.add({
        'role': 'assistant',
        'content': response,
        'taskId': createdTask?.id,
        'logId': createdLogId,
      });
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        padding: const EdgeInsets.only(top: 40), // Ép thêm padding phía trên
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: const CustomAppBar(),
          body: Column(
            children: [
              if (_showFirstTimeGuide)
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Hướng dẫn nhanh',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _showFirstTimeGuide = false;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Bạn có thể thử các câu lệnh sau:',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 5),
                      _buildExampleItem(context, 'Làm bài tập toán 25 phút 5 phút nghỉ'),
                      _buildExampleItem(context, 'Ngày mai đi chợ lúc 6 sáng'),
                      _buildExampleItem(context, 'Bắt đầu Pomodoro 15 phút'),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isUser = message['role'] == 'user';
                    final taskId = message['taskId'] as String?;
                    final logId = message['logId'] as String?;
                    final content = message['content'] as String? ?? '';

                    if (isUser) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            content,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      );
                    } else {
                      // Tin nhắn từ AI
                      if (taskId != null) {
                        // Tìm task tương ứng (trong thực tế cần lấy từ cubit)
                        // Tạm thời hiển thị card với task null (chỉ hiển thị response)
                        return AIResponseCard(
                          task: null, // Ở đây có thể truyền task nếu có
                          response: content,
                          onViewTask: () {
                            // Xử lý xem task
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Mở task $taskId'),
                              ),
                            );
                          },
                          onEditTask: () {
                            // Xử lý chỉnh sửa task
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Chỉnh sửa task $taskId'),
                              ),
                            );
                          },
                          onStartPomodoro: () {
                            // Bắt đầu Pomodoro
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Bắt đầu Pomodoro cho task $taskId'),
                              ),
                            );
                          },
                          onRateResponse: (isHelpful) {
                            // Đánh giá phản hồi
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đánh giá: ${isHelpful ? 'Hữu ích' : 'Không hữu ích'}'),
                              ),
                            );
                          },
                        );
                      } else {
                        // Tin nhắn AI thông thường (không có task)
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              content,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
              if (_isProcessing)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              if (_suggestions.isNotEmpty)
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _suggestions.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: ActionChip(
                            label: Text(
                              'Làm mới gợi ý',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            labelStyle: Theme.of(context).textTheme.bodyMedium,
                            onPressed: () {
                              setState(() {
                                _suggestions = [];
                              });
                              _loadSuggestions();
                            },
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: ActionChip(
                          label: Text(
                            _suggestions[index - 1],
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          labelStyle: Theme.of(context).textTheme.bodyMedium,
                          onPressed: () async {
                            await _handleMessage(_suggestions[index - 1]);
                          },
                        ),
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Nhập câu lệnh...',
                          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () async {
                        if (_controller.text.isNotEmpty) {
                          final message = _controller.text;
                          _controller.clear();
                          await _handleMessage(message);
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        _speechEnabled ? Icons.mic : Icons.mic_off,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        if (_speechEnabled) {
                          _speechToText.listen(
                            onResult: (result) async {
                              if (result.finalResult) {
                                await _handleMessage(result.recognizedWords);
                              }
                            },
                            localeId: 'vi_VN',
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExampleItem(BuildContext context, String example) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showFirstTimeGuide = false;
          });
          _handleMessage(example);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              Icon(
                Icons.play_arrow,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  example,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}