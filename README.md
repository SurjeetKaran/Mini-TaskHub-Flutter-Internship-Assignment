# Mini TaskHub - Personal Task Tracker

## 1. Project Overview
Mini TaskHub is a personal task tracking app built for an internship assignment.
It allows users to create an account, log in, and manage their own tasks using Supabase as the backend.

The project is intentionally structured in a clean and beginner-friendly way so you can learn:

- How authentication works in Flutter with Supabase
- How Provider manages app state
- How to organize Flutter code into modular folders

## 2. Features

- Email/password authentication (signup, login, logout)
- Task creation
- Task editing (update title from edit dialog)
- Task deletion
- Task completion toggle (checkbox)
- User-specific task list (each user only sees their own tasks)
- Task counter in dashboard title (example: My Tasks (3))
- Friendly empty state with icon and onboarding message
- Loading spinner while tasks are fetched from Supabase
- Success feedback SnackBars for add, edit, and delete actions
- Basic error handling with SnackBar messages

## 3. Tech Stack

- Flutter
- Supabase
- Provider

## 4. Project Structure

```text
lib/
	main.dart
	app/
		theme.dart
	auth/
		auth_service.dart
		login_screen.dart
		signup_screen.dart
	dashboard/
		dashboard_screen.dart
		task_model.dart
		task_provider.dart
		task_tile.dart
	services/
		supabase_service.dart
	utils/
		validators.dart

test/
	task_model_test.dart
```

What each folder does:

- auth: Login/signup UI and authentication logic
- dashboard: Task UI, task state, and model
- services: Supabase database communication
- utils: Shared validation helpers
- test: Unit tests

## 5. Setup Instructions

Prerequisites:

- Flutter SDK installed
- A Supabase account

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

Optional checks:

```bash
flutter analyze
flutter test
```

## 6. Supabase Setup

### A. Create Supabase project

1. Go to Supabase and create a new project.
2. Open Project Settings -> API.
3. Copy:
	 - Project URL
	 - anon public key

### B. Add Supabase URL and anon key in Flutter app

Open lib/main.dart and replace these values:

- supabaseUrl
- supabaseAnonKey

### C. Create tasks table

Run this SQL in Supabase SQL Editor:

```sql
create table if not exists public.tasks (
	id uuid primary key default gen_random_uuid(),
	title text not null,
	is_completed boolean not null default false,
	user_id uuid not null references auth.users (id) on delete cascade,
	created_at timestamptz not null default now()
);
```

Required columns are:

- id
- title
- is_completed
- user_id
- created_at

### D. Enable Row Level Security and policies

```sql
alter table public.tasks enable row level security;

create policy "Users can view their own tasks"
on public.tasks for select
using (auth.uid() = user_id);

create policy "Users can insert their own tasks"
on public.tasks for insert
with check (auth.uid() = user_id);

create policy "Users can update their own tasks"
on public.tasks for update
using (auth.uid() = user_id);

create policy "Users can delete their own tasks"
on public.tasks for delete
using (auth.uid() = user_id);
```

## 7. Hot Reload vs Hot Restart

Hot Reload:

- Updates UI instantly without restarting the app
- Preserves current app state
- Best for quick UI and small logic changes

Hot Restart:

- Completely restarts the app and resets state
- Re-runs initialization code from the start
- Useful when state gets stuck or deep changes are not reflected

## 8. Demo Instructions

Use this flow to demo the assignment:

1. Signup
	 - Open the app
	 - Tap Create account
	 - Enter email/password and submit

2. Login
	 - Return to login page
	 - Enter the same credentials
	 - Tap Log In

3. Add task
	 - On Dashboard, tap the + button
	 - Enter task title and submit

4. Edit task
	 - Tap the edit icon on any task row
	 - Update the title in the dialog
	 - Tap Save

5. Toggle completion
	 - Tap the checkbox next to a task to mark complete/incomplete

6. Delete task
	 - Tap the delete icon on a task row

7. Check task counter and empty state
	 - Verify AppBar title updates like My Tasks (N)
	 - Delete all tasks and confirm the empty state message appears

8. Logout
	 - Tap logout icon in the AppBar

## Unit Test Included

The project includes a unit test for task model serialization:

- test/task_model_test.dart

Run all tests:

```bash
flutter test
```
