import 'package:flutter/material.dart';

import '../models/task.dart';
import '../models/task_database.dart';

class TaskController extends ChangeNotifier {
  final TaskDatabase db;
  List<Task> tasks = [];
  bool loading = false;

  TaskController ({TaskDatabase? database}) : db = database ?? TaskDatabase.instance;

  Future<void> loadTasks() async {
    loading = true;
    notifyListeners();
    try {
      tasks = await db.getTasks();
    } catch (e) {
      /**/
    }
    loading = false;
    notifyListeners();
  }

  Future<void> addTask(String title, String desc) async {
    await db.insertTask(Task(title: title, description: desc, isDone: false));
    await loadTasks();
  }

  Future<void> updateTask(Task task) async {
    await db.updateTask(task);
    await loadTasks();
  }

  Future<void> deteleTask(int id) async {
    await db.deleteTask(id);
    await loadTasks();
  }

  Future<void> searchTasks(String keyword) async {
    loading = true;
    notifyListeners();
    try {
      tasks =  await db.searchTasks(keyword);
    } catch (e){
      /**/
    }
    loading = false;
    notifyListeners();
  }

  Future<void> toggleTask(Task task) async {
    await db.updateTask(task);
    await loadTasks();
  }
}