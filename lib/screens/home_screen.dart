import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/habit_model.dart';
import '../providers/habits_provider.dart';

/// ホーム画面：登録されている習慣のリストを表示し、タップでタイマー画面へ遷移する。
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('習慣化'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: habits.isEmpty
          ? const Center(child: Text('習慣がまだありません'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return _HabitListTile(habit: habit);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _HabitListTile extends StatelessWidget {
  const _HabitListTile({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          habit.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Text(
                '${habit.currentStreak}日',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(width: 4),
              const Text('🔥'),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: habit.isCompletedToday
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  habit.isCompletedToday ? '完了' : '未完了',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: habit.isCompletedToday
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.schedule,
                size: 14,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(width: 4),
              Text(
                habit.reminderTime.formatted,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/timer/${habit.id}'),
      ),
    );
  }
}
