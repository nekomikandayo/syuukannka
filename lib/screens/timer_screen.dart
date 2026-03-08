import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/habit_model.dart';
import '../providers/habits_provider.dart';
import '../providers/timer_provider.dart';

/// タイマー画面。習慣ごとの実行時間を計測し、完了時に記録する。
class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key, required this.habitId});

  final String habitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final habit = habits.where((h) => h.id == habitId).firstOrNull;
    final timerState = ref.watch(timerProvider);

    if (habit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('タイマー')),
        body: const Center(child: Text('習慣が見つかりません')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // 習慣名（画面上部）
            Text(
              habit.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 48),
            // タイマー表示（MM:SS）
            Expanded(
              child: Center(
                child: Text(
                  timerState.formatted,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                        letterSpacing: 2,
                      ),
                ),
              ),
            ),
            // スタート / 一時停止 / リセット
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ControlButton(
                  icon: Icons.play_arrow,
                  label: 'スタート',
                  onPressed: timerState.isRunning
                      ? null
                      : () => ref.read(timerProvider.notifier).start(),
                ),
                const SizedBox(width: 16),
                _ControlButton(
                  icon: Icons.pause,
                  label: '一時停止',
                  onPressed: !timerState.isRunning
                      ? null
                      : () => ref.read(timerProvider.notifier).pause(),
                ),
                const SizedBox(width: 16),
                _ControlButton(
                  icon: Icons.refresh,
                  label: 'リセット',
                  onPressed: () => ref.read(timerProvider.notifier).reset(),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // 完了して記録する
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: () => _onComplete(context, ref, habit),
                child: const Text('完了して記録する'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _onComplete(BuildContext context, WidgetRef ref, Habit habit) {
    final timer = ref.read(timerProvider.notifier);
    final habits = ref.read(habitsProvider.notifier);

    timer.stop();
    habits.completeHabit(habit.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('記録しました！')),
      );
      context.go('/');
    }
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filled(
          onPressed: onPressed,
          icon: Icon(icon),
          style: IconButton.styleFrom(
            padding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ],
    );
  }
}
