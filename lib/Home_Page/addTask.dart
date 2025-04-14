import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddTaskDialog extends StatefulWidget {
  final Map<String, dynamic>? existingTask;

  const AddTaskDialog({super.key, this.existingTask});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _dueDate;
  String _priority = 'Low';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingTask?['title'] ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingTask?['description'] ?? '',
    );
    _dueDate = widget.existingTask?['dueDate'];
    _priority = widget.existingTask?['priority'] ?? 'Low';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingTask != null ? 'Edit Task' : 'Add Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            // Description
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 10),
            // Due Date picker
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dueDate == null
                        ? 'No due date selected'
                        : 'Due Date: ${_dueDate!.day.toString().padLeft(2, '0')}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.year}',
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _dueDate = picked;
                      });
                    }
                  },
                  child: Text('Pick Date'),
                ),
              ],
            ),
            SizedBox(height: 10),
            // Priority dropdown
            DropdownButtonFormField<String>(
              value: _priority,
              items: ['Low', 'Medium', 'High']
                  .map((level) => DropdownMenuItem(
                        value: level,
                        child: Text(level),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _priority = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back,
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final title = _titleController.text.trim();
            final description = _descriptionController.text.trim();

            if (title.isEmpty || description.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Title and Description are required.'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            final user = FirebaseAuth.instance.currentUser;
            if (user == null) return;

            final task = {
              'title': title,
              'description': description,
              'dueDate': _dueDate,
              'priority': _priority,
              'completed': widget.existingTask?['completed'] ?? false,
              'createdAt': Timestamp.now(),
              'userId': user.uid,
            };

            try {
              final taskRef = FirebaseFirestore.instance.collection('tasks');
              if (widget.existingTask != null) {
                await taskRef.doc(widget.existingTask?['id']).update(task);
              } else {
                await taskRef.add(task);
              }
              Navigator.of(context).pop(task);
            } catch (e) {
              print('Failed to save task: $e');
            }
          },
          child: Text('Save'),
        )
      ],
    );
  }
}
