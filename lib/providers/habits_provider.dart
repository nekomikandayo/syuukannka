import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/habit_model.dart';

/// 習慣リストの初期データ（Notifierの初期状態用）。
List<Habit> _initialHabits() => [
  const Habit(
    id: 'habit_1',
    title: '骨盤底筋呼吸',
    currentStreak: 7,
    reminderTime: ReminderTime(hour: 7, minute: 0),
    isCompletedToday: true,
  ),
  const Habit(
    id: 'habit_2',
    title: '読書',
    currentStreak: 3,
    reminderTime: ReminderTime(hour: 21, minute: 30),
    isCompletedToday: false,
  ),
  const Habit(
    id: 'habit_3',
    title: 'プログラミング学習',
    currentStreak: 14,
    reminderTime: ReminderTime(hour: 20, minute: 0),
    isCompletedToday: false,
  ),
];

/// 習慣リストの状態と更新を提供する Notifier。
/// 将来はFirebase等のリポジトリに差し替え可能。
final habitsProvider = NotifierProvider<HabitsNotifier, List<Habit>>(HabitsNotifier.new);

class HabitsNotifier extends Notifier<List<Habit>> {
  @override
  List<Habit> build() => _initialHabits();

  /// 指定したIDの習慣の「今日の完了」を true にする。
  void completeHabit(String id) {
    state = [
      for (final h in state)
        h.id == id ? h.copyWith(isCompletedToday: true) : h,
    ];
  }
}
