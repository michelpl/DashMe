import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/task.dart';
import 'widgets/task_item.dart';

void main() {
  runApp(const DashMeApp());
}

class DashMeApp extends StatefulWidget {
  const DashMeApp({super.key});

  @override
  State<DashMeApp> createState() => _DashMeAppState();
}

class _DashMeAppState extends State<DashMeApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskList(),
      child: MaterialApp(
        title: 'DashMe',
        debugShowCheckedModeBanner: false,
        themeMode: _themeMode,
        theme: ThemeData(
          brightness: Brightness.light,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        home: HomePage(onToggleTheme: _toggleTheme),
      ),
    );
  }
}

enum TaskSort { creation, alphabetical }

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  TaskSort _sort = TaskSort.creation;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addTaskDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Task title'),
            onSubmitted: (_) => _submit(controller),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => _submit(controller),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editTaskDialog(BuildContext context, Task task) {
    final TextEditingController controller = TextEditingController(text: task.title);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: controller,
            autofocus: true,
            onSubmitted: (_) => _editSubmit(task, controller),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => _editSubmit(task, controller),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _submit(TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    final task = Task(id: UniqueKey().toString(), title: text);
    context.read<TaskList>().add(task);
    Navigator.of(context).pop();
  }

  void _editSubmit(Task task, TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    context.read<TaskList>().update(task, text);
    Navigator.of(context).pop();
  }

  void _onSortChange(TaskSort? sort) {
    if (sort == null) return;
    setState(() {
      _sort = sort;
    });
    final list = context.read<TaskList>();
    switch (sort) {
      case TaskSort.creation:
        list.sortByCreation();
        break;
      case TaskSort.alphabetical:
        list.sortAlphabetically();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DashMe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.onToggleTheme,
          ),
          PopupMenuButton<TaskSort>(
            initialValue: _sort,
            onSelected: _onSortChange,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: TaskSort.creation,
                child: Text('Creation order'),
              ),
              PopupMenuItem(
                value: TaskSort.alphabetical,
                child: Text('Alphabetical'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<TaskList>(
        builder: (context, list, _) {
          final tasks = list.tasks
              .where((task) =>
                  task.title.toLowerCase().contains(_searchController.text.toLowerCase()))
              .toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Expanded(
                child: ReorderableListView(
                  onReorder: list.reorder,
                  buildDefaultDragHandles: false,
                  children: [
                    for (final task in tasks)
                      ReorderableDragStartListener(
                        key: ValueKey(task.id),
                        index: list.tasks.indexOf(task),
                        child: TaskItem(
                          task: task,
                          onEdit: () => _editTaskDialog(context, task),
                          onDelete: () => list.remove(task),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
