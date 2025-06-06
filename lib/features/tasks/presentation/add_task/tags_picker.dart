import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:moji_todo/features/tasks/data/models/tag_model.dart';
import 'package:moji_todo/features/tasks/presentation/add_project_and_tags/add_tag_screen.dart';
import '../../data/models/project_tag_repository.dart';

class TagsPicker extends StatefulWidget {
  final List<String> initialTags;
  final ProjectTagRepository repository;
  final ValueChanged<List<String>> onTagsSelected;

  const TagsPicker({
    super.key,
    required this.initialTags,
    required this.repository,
    required this.onTagsSelected,
  });

  @override
  State<TagsPicker> createState() => _TagsPickerState();
}

class _TagsPickerState extends State<TagsPicker> {
  late List<String> selectedTags;

  @override
  void initState() {
    super.initState();
    selectedTags = List.from(widget.initialTags);
  }

  void _updateTags(String tag) {
    setState(() {
      if (selectedTags.contains(tag)) {
        selectedTags.remove(tag);
      } else {
        selectedTags.add(tag);
      }
    });
    widget.onTagsSelected(selectedTags);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tags',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.red),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddTagScreen(
                          repository: widget.repository,
                          onTagAdded: () {
                            // Không cần setState vì ValueListenableBuilder sẽ tự rebuild
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder(
              valueListenable: widget.repository.tagBox.listenable(),
              builder: (context, Box<Tag> box, _) {
                final availableTags = box.values
                    .where((tag) => !tag.isArchived)
                    .toList(); // SỬA: Lấy danh sách Tag thay vì chỉ tên
                return SizedBox(
                  height: 252, // Giới hạn 4.5 dòng (56dp * 4.5)
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: availableTags.length,
                    itemBuilder: (context, index) {
                      final tag = availableTags[index];
                      final isSelected = selectedTags.contains(tag.name);
                      return ListTile(
                        leading: Icon(
                          Icons.local_offer,
                          color: tag.textColor, // SỬA: Lấy màu từ Tag.textColor
                          size: 24,
                        ),
                        title: Text(tag.name),
                        trailing: isSelected ? const Icon(Icons.check, color: Colors.red) : null,
                        onTap: () {
                          _updateTags(tag.name);
                        },
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('OK'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}