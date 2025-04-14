import 'package:flutter/material.dart';

class TaskTile extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback onEdit;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task['completed'] ?? false;

    return Dismissible(
      key: UniqueKey(),
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20),
        child: Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onComplete();
          return false;
        } else if (direction == DismissDirection.endToStart) {
          final shouldDelete = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Delete Task'),
              content: Text('Are you sure you want to delete this task?'),
              actions: [
                TextButton(
                  child: Text('No'),
                  onPressed: () => Navigator.pop(context, false),
                ),
                TextButton(
                  child: Text('Yes'),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            ),
          );

          if (shouldDelete == true) {
            onDelete();
          }
          return false;
        }
        return false;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(12),
          color: isCompleted
              ? Colors.green[100]
              : (task['dueDate'] != null &&
                      (task['dueDate'] as DateTime).isBefore(DateTime.now()))
                  ? Colors.red[100]
                  : Colors.blue.shade100,
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(task['title'],
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${task['description']} - ${task['priority']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (task['dueDate'] != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      () {
                        final dueDate = task['dueDate'] as DateTime;
                        return '${dueDate.day.toString().padLeft(2, '0')}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.year}';
                      }(),
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.grey[600]),
                  onPressed: onEdit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
