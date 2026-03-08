import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/habit_model.dart';

/// 習慣リストの初期データ（Notifierの初期状態用）。
/// 日付は実行時の now を使用するため const にしない。
List<Habit> _initialHabits() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  return [
    Habit(
      id: 'habit_1',
      title: '骨盤底筋呼吸',
      currentStreak: 7,
      reminderTime: const ReminderTime(hour: 7, minute: 0),
      lastCompletedDate: today,
      targetDurationSeconds: 60,
    ),
    Habit(
      id: 'habit_2',
      title: '読書',
      currentStreak: 3,
      reminderTime: const ReminderTime(hour: 21, minute: 30),
      lastCompletedDate: yesterday,
      targetDurationSeconds: 600,
    ),
    Habit(
      id: 'habit_3',
      title: 'プログラミング学習',
      currentStreak: 14,
      reminderTime: const ReminderTime(hour: 20, minute: 0),
      lastCompletedDate: yesterday,
      targetDurationSeconds: 10,
    ),
  ];
}

/// 現在日付と lastCompletedDate の「日付の差」が2日以上ならストリークを0にリセットする。
List<Habit> _applyStreakResets(List<Habit> habits) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return [
    for (final h in habits)
      _shouldResetStreak(h, today) ? h.copyWith(currentStreak: 0) : h,
  ];
}

bool _shouldResetStreak(Habit h, DateTime today) {
  if (h.lastCompletedDate == null) return true;
  final last = DateTime(
    h.lastCompletedDate!.year,
    h.lastCompletedDate!.month,
    h.lastCompletedDate!.day,
  );
  final diffDays = today.difference(last).inDays;
  return diffDays >= 2;
}

/// 昨日完了なら +1、今日ならそのまま、2日以上前または未完了なら 1 にする。
int _nextStreak(Habit h) {
  if (h.lastCompletedDate == null) return 1;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final last = DateTime(
    h.lastCompletedDate!.year,
    h.lastCompletedDate!.month,
    h.lastCompletedDate!.day,
  );
  final diffDays = today.difference(last).inDays;
  if (diffDays == 0) return h.currentStreak; // 今日すでに完了（二重押し対策）
  if (diffDays == 1) return h.currentStreak + 1; // 昨日完了 → 連続
  return 1; // 2日以上空いた or リセット後
}

/// 習慣リストの状態と更新を提供する Notifier。
/// 将来はFirebase等のリポジトリに差し替え可能。
final habitsProvider = NotifierProvider<HabitsNotifier, List<Habit>>(HabitsNotifier.new);

class HabitsNotifier extends Notifier<List<Habit>> {
  @override
  List<Habit> build() => _applyStreakResets(_initialHabits());

  /// アプリ起動時などに呼び、2日以上未達成の習慣のストリークを0にリセットする。
  void checkAndResetStreaks() {
    state = _applyStreakResets(state);
  }

  /// 指定したIDの習慣を「今日完了」にし、lastCompletedDate と currentStreak を更新する。
  void completeHabit(String id) {
    state = [
      for (final h in state)
        h.id == id
            ? h.copyWith(
                lastCompletedDate: DateTime.now(),
                currentStreak: _nextStreak(h),
              )
            : h,
    ];
  }

  /// 新しい習慣を追加する。
  void addHabit(Habit habit) {
    state = [...state, habit];
  }
}
