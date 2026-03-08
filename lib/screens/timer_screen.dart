import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/habit_model.dart';
import '../providers/habits_provider.dart';
import '../providers/timer_provider.dart';

/// タイマー画面。習慣の目標時間でカウントダウンし、0秒で自動完了する。
class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key, required this.habitId});

  final String habitId;

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  /// まだ一度もスタートしていないときは習慣の目標時間を表示する。
  int _displaySeconds(Habit habit, TimerState timerState) {
    if (timerState.isRunning || timerState.remainingSeconds > 0 || timerState.reachedZero) {
      return timerState.remainingSeconds;
    }
    return habit.targetDurationSeconds;
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsStreamProvider);
    final habits = habitsAsync.valueOrNull ?? [];
    final habit = habits.where((h) => h.id == widget.habitId).firstOrNull;
    final timerState = ref.watch(timerProvider);
    final timerNotifier = ref.read(timerProvider.notifier);

    ref.listen<TimerState>(timerProvider, (prev, next) {
      if (!next.reachedZero || habit == null) return;
      timerNotifier.clearReachedZero();
      ref.read(habitsRepositoryProvider).completeHabit(habit.id).then((_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('記録しました！')),
          );
          context.go('/');
        }
      }).catchError((e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('記録に失敗しました: $e')),
          );
        }
      });
    });

    if (habitsAsync.isLoading && habits.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('タイマー')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (habit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('タイマー')),
        body: const Center(child: Text('習慣が見つかりません')),
      );
    }

    final displaySeconds = _displaySeconds(habit, timerState);

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
            Text(
              habit.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 48),
            Expanded(
              child: Center(
                child: Text(
                  timerState.formatSeconds(displaySeconds),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                        letterSpacing: 2,
                      ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ControlButton(
                  icon: Icons.play_arrow,
                  label: 'スタート',
                  onPressed: timerState.isRunning
                      ? null
                      : () => timerNotifier.start(
                            timerState.remainingSeconds == 0
                                ? habit.targetDurationSeconds
                                : null,
                          ),
                ),
                const SizedBox(width: 16),
                _ControlButton(
                  icon: Icons.pause,
                  label: '一時停止',
                  onPressed: !timerState.isRunning
                      ? null
                      : () => timerNotifier.pause(),
                ),
                const SizedBox(width: 16),
                _ControlButton(
                  icon: Icons.refresh,
                  label: 'リセット',
                  onPressed: () => timerNotifier.reset(),
                ),
              ],
            ),
            const SizedBox(height: 32),
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

  Future<void> _onComplete(BuildContext context, WidgetRef ref, Habit habit) async {
    final timer = ref.read(timerProvider.notifier);
    final repo = ref.read(habitsRepositoryProvider);

    timer.pause();
    try {
      await repo.completeHabit(habit.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('記録しました！')),
        );
        context.go('/');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('記録に失敗しました: $e')),
        );
      }
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
