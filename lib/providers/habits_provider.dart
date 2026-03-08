import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/habit_model.dart';

// ---------------------------------------------------------------------------
// Auth
// ---------------------------------------------------------------------------

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.uid;
});

// ---------------------------------------------------------------------------
// Firestore 参照
// ---------------------------------------------------------------------------

final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

/// 現在ユーザーの習慣サブコレクション参照。uid が null のときは null。
final userHabitsCollectionProvider = Provider<CollectionReference<Map<String, dynamic>>?>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return null;
  return ref.watch(firestoreProvider).collection('users').doc(uid).collection('habits');
});

// ---------------------------------------------------------------------------
// ストリーク判定（Firestore 書き込み前のロジック）
// ---------------------------------------------------------------------------

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
  if (diffDays == 0) return h.currentStreak;
  if (diffDays == 1) return h.currentStreak + 1;
  return 1;
}

// ---------------------------------------------------------------------------
// 起動時ストリークリセット（main から呼ぶ用）
// ---------------------------------------------------------------------------

/// アプリ起動後、匿名サインイン済みのユーザーに対して
/// 2日以上未達成の習慣のストリークを 0 にリセットする。
Future<void> checkAndResetStreaksForUser(FirebaseFirestore firestore, String uid) async {
  final col = firestore.collection('users').doc(uid).collection('habits');
  final snap = await col.get();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  for (final doc in snap.docs) {
    final data = doc.data();
    if (data.isEmpty) continue;
    try {
      final h = Habit.fromJson(data, id: doc.id);
      if (_shouldResetStreak(h, today)) {
        await doc.reference.update({'currentStreak': 0});
      }
    } catch (_) {
      // 不正ドキュメントはスキップ
    }
  }
}

// ---------------------------------------------------------------------------
// 習慣ストリーム（リアルタイム）
// ---------------------------------------------------------------------------

final habitsStreamProvider = StreamProvider.autoDispose<List<Habit>>((ref) {
  final col = ref.watch(userHabitsCollectionProvider);
  if (col == null) return Stream.value([]);

  return col.snapshots().map((snap) {
    return snap.docs.map((doc) {
      final data = doc.data();
      return Habit.fromJson(data, id: doc.id);
    }).toList();
  });
});

// ---------------------------------------------------------------------------
// 習慣の書き込み（Repository）
// ---------------------------------------------------------------------------

final habitsRepositoryProvider = Provider<HabitsRepository>((ref) {
  return HabitsRepository(ref);
});

class HabitsRepository {
  HabitsRepository(this._ref);

  final Ref _ref;

  CollectionReference<Map<String, dynamic>>? get _col =>
      _ref.read(userHabitsCollectionProvider);

  /// 習慣を追加する。
  Future<void> addHabit(Habit habit) async {
    final col = _col;
    if (col == null) throw StateError('未認証のため習慣を追加できません');
    await col.doc(habit.id).set(habit.toJson());
  }

  /// 指定した習慣を「今日完了」にし、lastCompletedDate と currentStreak を更新する。
  Future<void> completeHabit(String id) async {
    final col = _col;
    if (col == null) throw StateError('未認証のため完了できません');

    final docRef = col.doc(id);
    final doc = await docRef.get();
    if (!doc.exists || doc.data() == null) {
      throw StateError('習慣が見つかりません: $id');
    }

    final h = Habit.fromJson(doc.data()!, id: doc.id);
    final now = DateTime.now();
    final newStreak = _nextStreak(h);

    await docRef.update({
      'lastCompletedDate': Timestamp.fromDate(now),
      'currentStreak': newStreak,
    });
  }
}

// ---------------------------------------------------------------------------
// 互換用: habitsProvider を Stream の内容で提供（既存コードが ref.watch(habitsProvider) を使うため）
// ---------------------------------------------------------------------------

/// 従来の habitsProvider の代わりに使用する。Firestore のリアルタイムリストを返す。
/// 参照時は habitsStreamProvider を watch し、AsyncValue で扱う。
final habitsProvider = habitsStreamProvider;
