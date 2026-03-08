import 'package:go_router/go_router.dart';

import '../screens/home_screen.dart';
import '../screens/timer_screen.dart';

/// アプリ全体のルーティング定義。
final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/timer/:habitId',
      name: 'timer',
      builder: (context, state) {
        final habitId = state.pathParameters['habitId']!;
        return TimerScreen(habitId: habitId);
      },
    ),
  ],
);
