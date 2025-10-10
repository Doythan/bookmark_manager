import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/services/auth_provider.dart';
import '../features/bookmarks/screens/home_screen.dart';

// GoRouter Provider
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      // 로그인 안 했는데 로그인 페이지가 아니면 -> 로그인 페이지로
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      // 로그인 했는데 로그인 페이지에 있으면 -> 홈으로
      if (isLoggedIn && isLoggingIn) {
        return '/';
      }

      return null; // 리다이렉트 없음
    },
    routes: [
      // 로그인 화면
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      // 회원가입 화면
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // 홈 화면 (북마크 목록)
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    ],
  );
});
