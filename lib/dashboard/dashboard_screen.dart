import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_service.dart';
import '../utils/validators.dart';
import 'task_provider.dart';
import 'task_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch tasks once the first frame is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().fetchTasks();
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showAddTaskDialog(BuildContext context) async {
    // Keep this controller local to the dialog flow.
    // This prevents the widget tree from reusing a disposed controller.
    final TextEditingController taskController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Add task dialog',
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (_, _, _) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: taskController,
              autofocus: true,
              maxLength: 80,
              decoration: const InputDecoration(
                hintText: 'Task title',
                counterText: '',
              ),
              validator: Validators.taskTitle,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                final error = await context.read<TaskProvider>().addTask(
                  taskController.text.trim(),
                );

                if (!context.mounted) {
                  return;
                }

                Navigator.of(context).pop();

                if (error != null) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(error)));
                  return;
                }

                _showSuccessSnackBar('Task added successfully');
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
      transitionBuilder: (_, animation, _, child) {
        // Combining fade + scale makes dialog opening feel smooth and modern.
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
      },
    );
  }

  Future<void> _showEditTaskDialog(
    BuildContext context,
    String taskId,
    String currentTitle,
  ) async {
    final TextEditingController controller = TextEditingController(
      text: currentTitle,
    );
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Edit task dialog',
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (_, _, _) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              maxLength: 80,
              decoration: const InputDecoration(
                hintText: 'Task title',
                counterText: '',
              ),
              validator: Validators.taskTitle,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                final taskProvider = context.read<TaskProvider>();
                final match = taskProvider.tasks.where(
                  (item) => item.id == taskId,
                );
                if (match.isEmpty) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Task not found.')),
                    );
                  }
                  return;
                }

                final error = await taskProvider.editTaskTitle(
                  match.first,
                  controller.text.trim(),
                );

                if (!context.mounted) {
                  return;
                }

                Navigator.of(context).pop();

                if (error != null) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(error)));
                  return;
                }

                _showSuccessSnackBar('Task updated successfully');
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
      transitionBuilder: (_, animation, _, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final errorMessage = await context.read<AuthService>().signOut();

    if (!context.mounted) {
      return;
    }

    if (errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskCount = context.watch<TaskProvider>().tasks.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Tasks ($taskCount)'),
        actions: [
          IconButton(
            onPressed: () => _handleLogout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<TaskProvider>(
          builder: (context, taskProvider, _) {
            // Show a spinner only while the initial fetch is running.
            if (taskProvider.isFetching) {
              return const Center(child: CircularProgressIndicator());
            }

            if (taskProvider.errorMessage != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    taskProvider.errorMessage!,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            // Friendly empty state helps users understand what to do next.
            if (taskProvider.tasks.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.playlist_add_check_circle_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No tasks yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Tap the + button to add your first task.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return LayoutBuilder(
              builder: (_, constraints) {
                final horizontalPadding = constraints.maxWidth > 700
                    ? 120.0
                    : 16.0;

                return RefreshIndicator(
                  onRefresh: taskProvider.fetchTasks,
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      12,
                      horizontalPadding,
                      90,
                    ),
                    itemCount: taskProvider.tasks.length,
                    itemBuilder: (_, index) {
                      final task = taskProvider.tasks[index];

                      return TaskTile(
                        task: task,
                        onToggle: (value) async {
                          final error = await taskProvider.toggleTaskCompletion(
                            task,
                            value ?? false,
                          );

                          if (!context.mounted || error == null) {
                            return;
                          }

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(error)));
                        },
                        onEdit: () async {
                          await _showEditTaskDialog(
                            context,
                            task.id,
                            task.title,
                          );
                        },
                        onDelete: () async {
                          final error = await taskProvider.deleteTask(task.id);

                          if (!context.mounted) {
                            return;
                          }

                          if (error == null) {
                            _showSuccessSnackBar('Task deleted successfully');
                            return;
                          }

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(error)));
                        },
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
