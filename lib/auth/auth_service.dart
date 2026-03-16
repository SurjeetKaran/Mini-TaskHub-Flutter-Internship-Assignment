import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  User? _currentUser;
  bool _isLoading = true;
  StreamSubscription<AuthState>? _authStateSubscription;

  AuthService() {
    // Read any existing session when the app starts.
    _currentUser = _client.auth.currentUser;

    // Listen to login/logout changes so UI can react automatically.
    _authStateSubscription = _client.auth.onAuthStateChange.listen((event) {
      _currentUser = event.session?.user;
      _isLoading = false;
      notifyListeners();
    });

    _isLoading = false;
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<String?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signUp(email: email, password: password);
      return null;
    } on AuthException catch (error) {
      return error.message;
    } catch (_) {
      return 'Something went wrong while creating your account.';
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      return null;
    } on AuthException catch (error) {
      return error.message;
    } catch (_) {
      return 'Unable to login right now. Please try again.';
    }
  }

  Future<String?> signOut() async {
    try {
      await _client.auth.signOut();
      return null;
    } catch (_) {
      return 'Could not sign out. Please try again.';
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
