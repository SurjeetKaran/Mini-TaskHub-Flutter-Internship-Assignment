import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/theme.dart';
import 'auth/auth_service.dart';
import 'auth/login_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'dashboard/task_provider.dart';

// These values tell the app which Supabase project to connect to.
// Replace both placeholders with your real project credentials.
const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase must be initialized before we call any auth or database methods.
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(const MiniTaskHubApp());
}

class MiniTaskHubApp extends StatelessWidget {
  const MiniTaskHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // This provider manages user login/session state for the whole app.
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),

        // This provider manages all task operations and listens to auth changes.
        ChangeNotifierProxyProvider<AuthService, TaskProvider>(
          create: (_) => TaskProvider(),
          update: (_, authService, taskProvider) {
            final provider = taskProvider ?? TaskProvider();
            provider.bindAuth(authService);
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Mini TaskHub',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (_, authService, _) {
        if (authService.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authService.currentUser == null) {
          return const LoginScreen();
        }

        return const DashboardScreen();
      },
    );
  }
}
