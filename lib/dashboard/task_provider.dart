import 'package:flutter/foundation.dart';

import '../auth/auth_service.dart';
import '../services/supabase_service.dart';
import 'task_model.dart';

class TaskProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<TaskModel> _tasks = <TaskModel>[];
  bool _isFetching = false;
  String? _errorMessage;
  String? _activeUserId;

  List<TaskModel> get tasks => _tasks;
  bool get isFetching => _isFetching;
  String? get errorMessage => _errorMessage;

  // This is called from ChangeNotifierProxyProvider whenever auth changes.
  // It lets us automatically clear/fetch tasks for the correct user.
  void bindAuth(AuthService authService) {
    final incomingUserId = authService.currentUser?.id;

    if (incomingUserId == _activeUserId) {
      return;
    }

    _activeUserId = incomingUserId;

    if (_activeUserId == null) {
      _tasks = <TaskModel>[];
      _errorMessage = null;
      notifyListeners();
      return;
    }

    fetchTasks();
  }

  Future<void> fetchTasks() async {
    final userId = _activeUserId;
    if (userId == null) {
      return;
    }

    _isFetching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _supabaseService.fetchTasks(userId: userId);
    } catch (_) {
      _errorMessage = 'Could not load tasks. Please check your connection.';
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  Future<String?> addTask(String title) async {
    final userId = _activeUserId;
    if (userId == null) {
      return 'You must be logged in to add tasks.';
    }

    try {
      final task = await _supabaseService.insertTask(
        title: title,
        userId: userId,
      );
      _tasks = [task, ..._tasks];
      notifyListeners();
      return null;
    } catch (_) {
      return 'Unable to add task right now. Please try again.';
    }
  }

  Future<String?> deleteTask(String taskId) async {
    final userId = _activeUserId;
    if (userId == null) {
      return 'You must be logged in to delete tasks.';
    }

    final previousTasks = List<TaskModel>.from(_tasks);
    _tasks = _tasks.where((task) => task.id != taskId).toList();
    notifyListeners();

    try {
      await _supabaseService.deleteTask(taskId: taskId, userId: userId);
      return null;
    } catch (_) {
      _tasks = previousTasks;
      notifyListeners();
      return 'Unable to delete task. Please try again.';
    }
  }

  Future<String?> toggleTaskCompletion(TaskModel task, bool isCompleted) async {
    final userId = _activeUserId;
    if (userId == null) {
      return 'You must be logged in to update tasks.';
    }

    final index = _tasks.indexWhere((item) => item.id == task.id);
    if (index < 0) {
      return 'Task not found.';
    }

    final originalTask = _tasks[index];
    _tasks[index] = originalTask.copyWith(isCompleted: isCompleted);
    notifyListeners();

    try {
      await _supabaseService.updateTaskCompletion(
        taskId: task.id,
        userId: userId,
        isCompleted: isCompleted,
      );
      return null;
    } catch (_) {
      _tasks[index] = originalTask;
      notifyListeners();
      return 'Unable to update task status. Please try again.';
    }
  }

  Future<String?> editTaskTitle(TaskModel task, String updatedTitle) async {
    final userId = _activeUserId;
    if (userId == null) {
      return 'You must be logged in to update tasks.';
    }

    final trimmedTitle = updatedTitle.trim();
    if (trimmedTitle.isEmpty) {
      return 'Task title cannot be empty.';
    }

    final index = _tasks.indexWhere((item) => item.id == task.id);
    if (index < 0) {
      return 'Task not found.';
    }

    // We first update local state so the UI feels instant.
    // If the backend update fails, we rollback to the original value.
    final originalTask = _tasks[index];
    _tasks[index] = originalTask.copyWith(title: trimmedTitle);
    notifyListeners();

    try {
      await _supabaseService.updateTaskTitle(
        taskId: task.id,
        userId: userId,
        title: trimmedTitle,
      );
      return null;
    } catch (_) {
      _tasks[index] = originalTask;
      notifyListeners();
      return 'Unable to update task title. Please try again.';
    }
  }
}
