class TaskModel {
  final String id;
  final String title;
  final bool isCompleted;
  final String userId;
  final DateTime createdAt;

  const TaskModel({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.userId,
    required this.createdAt,
  });

  // fromJson converts raw database JSON into a strongly typed Dart object.
  // This helps us work with fields safely in the UI and business logic.
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // toJson converts this Dart object back to JSON format.
  // Supabase expects this map shape when we insert or update rows.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'is_completed': isCompleted,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    String? userId,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
