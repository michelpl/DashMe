import 'package:flutter/foundation.dart';

class Task {
  Task({required this.id, required this.title, DateTime? createdAt})
      : createdAt = createdAt ?? DateTime.now();

  final String id;
  String title;
  final DateTime createdAt;
  bool isDone = false;
}

class TaskList extends ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => List.unmodifiable(_tasks);

  void add(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void remove(Task task) {
    _tasks.remove(task);
    notifyListeners();
  }

  void toggle(Task task) {
    task.isDone = !task.isDone;
    notifyListeners();
  }

  void update(Task task, String title) {
    task.title = title;
    notifyListeners();
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Task task = _tasks.removeAt(oldIndex);
    _tasks.insert(newIndex, task);
    notifyListeners();
  }

  void sortByCreation() {
    _tasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    notifyListeners();
  }

  void sortAlphabetically() {
    _tasks.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    notifyListeners();
  }
}
