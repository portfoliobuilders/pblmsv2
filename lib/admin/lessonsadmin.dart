import 'package:flutter/material.dart';

class AddLessonScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final Function(String name, String url) onAddLesson;

  AddLessonScreen({Key? key, required this.onAddLesson}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Lesson'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Lesson Name'),
          ),
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(labelText: 'Lesson URL'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final String name = _nameController.text;
            final String url = _urlController.text;
            if (name.isNotEmpty && url.isNotEmpty) {
              onAddLesson(name, url);
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter both name and URL')),
              );
            }
          },
          child: const Text('Add Lesson'),
        ),
      ],
    );
  }
}
