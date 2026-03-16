class Validators {
  Validators._();

  static String? email(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) {
      return 'Email is required.';
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(input)) {
      return 'Please enter a valid email address.';
    }

    return null;
  }

  static String? password(String? value) {
    final input = value ?? '';
    if (input.isEmpty) {
      return 'Password is required.';
    }

    if (input.length < 6) {
      return 'Password must be at least 6 characters.';
    }

    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if ((value ?? '').isEmpty) {
      return 'Please confirm your password.';
    }

    if (value != password) {
      return 'Passwords do not match.';
    }

    return null;
  }

  static String? taskTitle(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) {
      return 'Task title cannot be empty.';
    }

    if (input.length < 2) {
      return 'Task title must be at least 2 characters.';
    }

    return null;
  }
}
