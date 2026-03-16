import 'package:flutter_test/flutter_test.dart';
import 'package:mini_taskhub/dashboard/task_model.dart';

void main() {
  test('TaskModel converts cleanly between Dart object and JSON', () {
    // Step 1: Create a TaskModel object in Dart.
    // This represents data exactly how the app uses it in memory.
    final task = TaskModel(
      id: 'task-123',
      title: 'Write internship assignment',
      isCompleted: true,
      userId: 'user-456',
      createdAt: DateTime.parse('2026-03-16T10:20:30.000Z').toUtc(),
    );

    // Step 2: Convert the task to JSON.
    // JSON is the format we send to Supabase or receive from APIs.
    final json = task.toJson();

    // Step 3: Convert JSON back to TaskModel.
    // This confirms our fromJson method rebuilds the object correctly.
    final decodedTask = TaskModel.fromJson(json);

    // Step 4: Verify values still match after round-trip conversion.
    expect(decodedTask.id, task.id);
    expect(decodedTask.title, task.title);
    expect(decodedTask.isCompleted, task.isCompleted);
    expect(decodedTask.userId, task.userId);
    expect(decodedTask.createdAt.toUtc(), task.createdAt.toUtc());

    // Extra checks to ensure JSON keys match Supabase column names.
    expect(json['id'], 'task-123');
    expect(json['title'], 'Write internship assignment');
    expect(json['is_completed'], true);
    expect(json['user_id'], 'user-456');
    expect(json['created_at'], '2026-03-16T10:20:30.000Z');
  });
}
