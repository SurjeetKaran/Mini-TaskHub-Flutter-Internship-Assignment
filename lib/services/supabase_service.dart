import 'package:supabase_flutter/supabase_flutter.dart';

import '../dashboard/task_model.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<TaskModel>> fetchTasks({required String userId}) async {
    // We filter by user_id so each user only sees their own tasks.
    final response = await _client
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final rows = List<Map<String, dynamic>>.from(response);
    return rows.map(TaskModel.fromJson).toList();
  }

  Future<TaskModel> insertTask({
    required String title,
    required String userId,
  }) async {
    final response = await _client
        .from('tasks')
        .insert({'title': title, 'is_completed': false, 'user_id': userId})
        .select()
        .single();

    return TaskModel.fromJson(response);
  }

  Future<void> deleteTask({
    required String taskId,
    required String userId,
  }) async {
    await _client.from('tasks').delete().eq('id', taskId).eq('user_id', userId);
  }

  Future<void> updateTaskCompletion({
    required String taskId,
    required String userId,
    required bool isCompleted,
  }) async {
    await _client
        .from('tasks')
        .update({'is_completed': isCompleted})
        .eq('id', taskId)
        .eq('user_id', userId);
  }

  Future<void> updateTaskTitle({
    required String taskId,
    required String userId,
    required String title,
  }) async {
    await _client
        .from('tasks')
        .update({'title': title})
        .eq('id', taskId)
        .eq('user_id', userId);
  }
}
