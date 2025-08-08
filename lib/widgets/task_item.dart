import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';

class TaskItem extends StatelessWidget {
  const TaskItem({super.key, required this.task, required this.onEdit, required this.onDelete});

  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey(task.id),
      leading: Checkbox(
        value: task.isDone,
        onChanged: (_) => context.read<TaskList>().toggle(task),
      ),
      title: Text(
        task.title,
        style: TextStyle(
          decoration: task.isDone ? TextDecoration.lineThrough : null,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
