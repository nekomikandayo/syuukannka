import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/habit_model.dart';

/// 習慣リストのモックデータを提供するプロバイダー。
/// 将来はFirebase等のリポジトリに差し替え可能。
final habitsProvider = Provider<List<Habit>>((ref) {
  return _mockHabits;
});

/// 仮の習慣データ（3件）。
final List<Habit> _mockHabits = [
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
