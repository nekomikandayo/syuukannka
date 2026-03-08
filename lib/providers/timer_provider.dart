import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// タイマー画面の状態。
class TimerState {
  const TimerState({
    this.elapsedSeconds = 0,
    this.isRunning = false,
  });

  final int elapsedSeconds;
  final bool isRunning;

  /// MM:SS 形式の表示用文字列。
  String get formatted {
    final m = elapsedSeconds ~/ 60;
    final s = elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

/// ストップウォッチの状態と操作を提供する Notifier。
/// Timer.periodic で1秒ごとに経過秒数を更新する。
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

  void start() {
    if (state.isRunning) return;
    _cancelTimer();
    state = TimerState(elapsedSeconds: state.elapsedSeconds, isRunning: true);
    _periodicTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = TimerState(elapsedSeconds: state.elapsedSeconds + 1, isRunning: true);
    });
  }

  void pause() {
    _cancelTimer();
    state = TimerState(elapsedSeconds: state.elapsedSeconds, isRunning: false);
  }

  void reset() {
    _cancelTimer();
    state = const TimerState();
  }

  /// 停止のみ（経過時間は維持）。完了記録時に使用。
  void stop() {
    _cancelTimer();
    state = TimerState(elapsedSeconds: state.elapsedSeconds, isRunning: false);
  }
}
