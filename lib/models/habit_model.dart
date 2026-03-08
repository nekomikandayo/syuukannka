import 'package:cloud_firestore/cloud_firestore.dart';

/// 習慣を表すモデル。
/// 「継続する技術」の炎（連続日数）・リマインド時間・目標時間などを保持する。
class Habit {
  const Habit({
    required this.id,
    required this.title,
    this.currentStreak = 0,
    required this.reminderTime,
    this.lastCompletedDate,
    required this.targetDurationSeconds,
  });

  final String id;
  final String title;
  final int currentStreak;
  final ReminderTime reminderTime;
  /// 最後に完了した日時。null は未完了またはリセット後を表す。
  final DateTime? lastCompletedDate;
  final int targetDurationSeconds;

  /// Firestore のドキュメントから復元する。 [id] はドキュメントID（未指定時は map の id を使用）。
  factory Habit.fromJson(Map<String, dynamic> map, {String? id}) {
    final docId = id ?? map['id'] as String?;
    if (docId == null) throw ArgumentError('Habit.fromJson: id or map["id"] is required');
    final rt = map['reminderTime'] as Map<String, dynamic>?;
    if (rt == null) throw ArgumentError('Habit.fromJson: reminderTime is required');
    return Habit(
      id: docId,
      title: map['title'] as String? ?? '',
      currentStreak: (map['currentStreak'] as num?)?.toInt() ?? 0,
      reminderTime: ReminderTime(
        hour: (rt['hour'] as num?)?.toInt() ?? 0,
        minute: (rt['minute'] as num?)?.toInt() ?? 0,
      ),
      lastCompletedDate: _parseTimestamp(map['lastCompletedDate']),
      targetDurationSeconds: (map['targetDurationSeconds'] as num?)?.toInt() ?? 0,
    );
  }

  static DateTime? _parseTimestamp(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    // Firestore Timestamp
    if (v is Timestamp) return v.toDate();
    return null;
  }

  /// Firestore へ保存する用の Map。Timestamp は cloud_firestore で変換する。
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'currentStreak': currentStreak,
      'reminderTime': {'hour': reminderTime.hour, 'minute': reminderTime.minute},
      if (lastCompletedDate != null) 'lastCompletedDate': Timestamp.fromDate(lastCompletedDate!),
      'targetDurationSeconds': targetDurationSeconds,
    };
  }

  /// 今日のタスクが完了しているか。[lastCompletedDate] と現在日付（0時基準）で比較する。
  bool get isCompletedToday {
    if (lastCompletedDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(
      lastCompletedDate!.year,
      lastCompletedDate!.month,
      lastCompletedDate!.day,
    );
    return last == today;
  }

  Habit copyWith({
    String? id,
    String? title,
    int? currentStreak,
    ReminderTime? reminderTime,
    DateTime? lastCompletedDate,
    int? targetDurationSeconds,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      currentStreak: currentStreak ?? this.currentStreak,
      reminderTime: reminderTime ?? this.reminderTime,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      targetDurationSeconds: targetDurationSeconds ?? this.targetDurationSeconds,
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
