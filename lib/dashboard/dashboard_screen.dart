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

  Future<void> _showAddTaskDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
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

                final error = await context.read<TaskProvider>().addTask(
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
                }
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

    controller.dispose();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini TaskHub'),
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

            if (taskProvider.tasks.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No tasks yet. Tap the + button to add your first task.',
                    textAlign: TextAlign.center,
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
                        onDelete: () async {
                          final error = await taskProvider.deleteTask(task.id);

                          if (!context.mounted || error == null) {
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
