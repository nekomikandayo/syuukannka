/// 習慣を表すモデル。
/// 「継続する技術」の炎（連続日数）・リマインド時間などを保持する。
class Habit {
  const Habit({
    required this.id,
    required this.title,
    this.currentStreak = 0,
    required this.reminderTime,
    this.isCompletedToday = false,
  });

  final String id;
  final String title;
  final int currentStreak;
  final ReminderTime reminderTime;
  final bool isCompletedToday;

  Habit copyWith({
    String? id,
    String? title,
    int? currentStreak,
    ReminderTime? reminderTime,
    bool? isCompletedToday,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      currentStreak: currentStreak ?? this.currentStreak,
      reminderTime: reminderTime ?? this.reminderTime,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
    );
  }
}

/// リマインド時刻（時・分）を表す値オブジェクト。
class ReminderTime {
  const ReminderTime({required this.hour, required this.minute});

  final int hour;
  final int minute;

  String get formatted => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
