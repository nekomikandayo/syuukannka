import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// タイマー画面の状態（カウントダウン方式）。
class TimerState {
  const TimerState({
    this.remainingSeconds = 0,
    this.isRunning = false,
    this.reachedZero = false,
  });

  final int remainingSeconds;
  final bool isRunning;
  /// カウントダウンが0秒に到達したことを示す。UIで完了処理後に clearReachedZero する。
  final bool reachedZero;

  /// MM:SS 形式の表示用文字列。
  String formatSeconds(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

/// カウントダウンタイマーの状態と操作を提供する Notifier。
final timerProvider = NotifierProvider<TimerNotifier, TimerState>(TimerNotifier.new);

class TimerNotifier extends Notifier<TimerState> {
  Timer? _periodicTimer;

  @override
  TimerState build() {
    ref.onDispose(_cancelTimer);
    return const TimerState();
  }

  void _cancelTimer() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  /// カウントダウンを開始する。[targetDurationSeconds] が指定された場合はその値から開始し、
  /// 未指定の場合は現在の残り秒数から再開する。
  void start(int? targetDurationSeconds) {
    if (state.isRunning) return;
    _cancelTimer();
    final initial = targetDurationSeconds ?? state.remainingSeconds;
    state = TimerState(
      remainingSeconds: initial,
      isRunning: true,
      reachedZero: false,
    );
    _periodicTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds <= 0) {
        _cancelTimer();
        state = TimerState(
          remainingSeconds: 0,
          isRunning: false,
          reachedZero: true,
        );
        return;
      }
      state = TimerState(
        remainingSeconds: state.remainingSeconds - 1,
        isRunning: true,
        reachedZero: false,
      );
    });
  }

  void pause() {
    _cancelTimer();
    state = TimerState(
      remainingSeconds: state.remainingSeconds,
      isRunning: false,
      reachedZero: state.reachedZero,
    );
  }

  void reset() {
    _cancelTimer();
    state = const TimerState();
  }

  /// 0秒到達フラグをクリアする。完了処理後にUIから呼ぶ。
  void clearReachedZero() {
    state = TimerState(
      remainingSeconds: state.remainingSeconds,
      isRunning: state.isRunning,
      reachedZero: false,
    );
  }
}
