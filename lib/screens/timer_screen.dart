import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/habits_provider.dart';

/// タイマー画面（Step 1ではプレースホルダー）。
/// 習慣IDを受け取り、該当習慣のタイマー計測を行う画面へ拡張予定。
class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key, required this.habitId});

  final String habitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final habit = habits.where((h) => h.id == habitId).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(habit?.title ?? 'タイマー'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: habit != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    habit.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  const Text('タイマー機能は Step 2 で実装予定です'),
                ],
              )
            : const Text('習慣が見つかりません'),
      ),
    );
  }
}
