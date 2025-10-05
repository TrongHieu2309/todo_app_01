import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../controllers/task_controller.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';

class TodoScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TodoScreen();
}

class _TodoScreen extends State<TodoScreen> {
  final ImagePicker _picker = ImagePicker();

  //2 TextField để nhập dữ liệu
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  List<Task> tasks = [];
  String? _keyword;
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskController>().loadTasks();
    });
  }

  void _confirmdelete(int id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete'),
        content: const Text('Delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<TaskController>().deteleTask(id);
              Navigator.pop(context);
              context.read<TaskController>().loadTasks();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Hàm thêm task
  void _addTaskDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add your task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty &&
                  descController.text.isNotEmpty) {
                await context.read<TaskController>().addTask(
                  titleController.text,
                  descController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // Hàm edit
  void _editTask(Task task) async {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty) {
                final updatedTask = task.copyWith(
                  title: titleController.text,
                  description: descriptionController.text,
                  isDone: task.isDone,
                );
                await context.read<TaskController>().updateTask(updatedTask);
                Navigator.pop(context);
                context.read<TaskController>().loadTasks();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Hàm tìm kiêm
  void _searchTasks() {
    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search your tasks'),
        content: TextField(
          controller: searchController,
          decoration: InputDecoration(labelText: 'Title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (searchController.text.isNotEmpty) {
                await context.read<TaskController>().searchTasks(
                  searchController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TaskController>();
    final tasks = controller.tasks;
    return Scaffold(
      body: Form(
        child: Column(
          children: [
            Container(
              height: 300,
              color: Colors.cyan,
              child: Stack(
                children: [
                  Positioned(
                    top: -20,
                    left: -50,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -160,
                    right: -160,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -70,
                    left: 10,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Avatar nằm chính giữa
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/tasks.png",
                            width: 400,
                            height: 200,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 60,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Center(
                    child: Text(
                      'Your tasks list',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Help"),
                          content: const Text(
                            "Swipe a task left to edit or delete",
                          ),
                        ),
                      ),
                      icon: Icon(Icons.help),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: tasks.isEmpty
                  ? const Center(child: Text("No tasks"))
                  : SingleChildScrollView(
                      child: Column(
                        children: tasks.map((task) {
                          return TaskCard(
                            title: task.title,
                            description: task.description,
                            isDone: task.isDone,
                            onEdit: () {
                              // Hàm chỉnh sửa task
                              _editTask(task);
                            },
                            onDelete: () {
                              _confirmdelete(task.id!);
                            },
                            onToggle: (value) async {
                              await context.read<TaskController>().toggleTask(
                                task.copyWith(isDone: value ?? false),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Add your task',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search your task',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.refresh), label: 'Refresh'),
        ],
        backgroundColor: Colors.cyan.shade300,
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.white,

        onTap: (index) {
          if (index == 0) {
            _addTaskDialog();
          } else if (index == 1) {
            _searchTasks();
          } else {
            context.read<TaskController>().loadTasks();
          }
        },
      ),
    );
  }
}
