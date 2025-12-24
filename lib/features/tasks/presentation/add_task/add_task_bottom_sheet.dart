import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/project_tag_repository.dart';
import '../../data/models/task_model.dart';
import '../../domain/task_cubit.dart';
import 'due_date_picker.dart';
import 'priority_picker.dart';
import 'tags_picker.dart';
import 'project_picker.dart';

class AddTaskBottomSheet extends StatefulWidget {
  final ProjectTagRepository repository;

  const AddTaskBottomSheet({super.key, required this.repository});

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  int _estimatedPomodoros = 1;
  DateTime? _dueDate;
  String? _priority;
  List<String> _tagIds = [];
  String? _projectId;
  String? _titleError;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 300),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Add a Task...',
                  border: InputBorder.none,
                  errorText: _titleError,
                  errorStyle: const TextStyle(color: Colors.red),
                ),
                onChanged: (value) {
                  if (_titleError != null && value.isNotEmpty) {
                    setState(() {
                      _titleError = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text('Estimated Pomodoros', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(8, (index) {
                    final pomodoros = index + 1;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text('$pomodoros'),
                        selected: _estimatedPomodoros == pomodoros,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _estimatedPomodoros = pomodoros;
                            });
                          }
                        },
                        selectedColor: Colors.red,
                        backgroundColor: Colors.grey[200],
                        labelStyle: TextStyle(
                          color:
                              _estimatedPomodoros == pomodoros
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
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
                        backgroundColor: Colors.transparent,
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.75,
                        ),
                        builder:
                            (context) => DueDatePicker(
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
                        builder:
                            (context) => PriorityPicker(
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
                        builder:
                            (context) => TagsPicker(
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
                        builder:
                            (context) => ProjectPicker(
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
                    width: 80,
                    height: 36,
                    child: ElevatedButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () async {
                                if (_titleController.text.isEmpty) {
                                  setState(() {
                                    _titleError = 'Vui lòng nhập tên task!';
                                  });
                                  return;
                                }

                                setState(() {
                                  _isLoading = true;
                                });

                                try {
                                  print(
                                    'Creating task: ${_titleController.text}',
                                  );
                                  final dueDate = _dueDate ?? DateTime.now();
                                  final task = Task(
                                    title: _titleController.text,
                                    estimatedPomodoros: _estimatedPomodoros,
                                    completedPomodoros: 0,
                                    dueDate: dueDate,
                                    priority: _priority,
                                    tagIds: _tagIds.isNotEmpty ? _tagIds : null,
                                    projectId: _projectId,
                                    isCompleted: false,
                                    createdAt: DateTime.now(),
                                  );

                                  await context.read<TaskCubit>().addTask(task);
                                  print('Task created successfully');

                                  if (mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Task đã được tạo thành công!',
                                        ),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  print('Error creating task: $e');
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Lỗi khi tạo task: ${e.toString()}',
                                        ),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      child:
                          _isLoading
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
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
