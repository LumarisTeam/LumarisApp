import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/state/app_states.dart';

export 'package:ios_club_app/state/app_states.dart'
    show AuthState, AuthStateView;

final authStateNotifierProvider =
    NotifierProvider<AuthStateNotifier, AuthStateView>(AuthStateNotifier.new);

class AuthStateNotifier extends Notifier<AuthStateView> {
  @override
  AuthStateView build() {
    return const AuthStateView();
  }

  AuthState get authState => state.authState;
  String get relogMessage => state.relogMessage;
  bool get isRelogging => state.authState == AuthState.relogging;

  void startRelogging() {
    state = state.copyWith(
      authState: AuthState.relogging,
      relogMessage: '登录已过期，正在重新登录...',
    );
  }

  void relogSuccess() {
    state = state.copyWith(
      authState: AuthState.relogSuccess,
      relogMessage: '重新登录成功',
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (state.authState == AuthState.relogSuccess) {
        reset();
      }
    });
  }

  void relogFailed(String reason) {
    state = state.copyWith(
      authState: AuthState.relogFailed,
      relogMessage: '重新登录失败: $reason',
    );

    Future.delayed(const Duration(seconds: 5), () {
      if (state.authState == AuthState.relogFailed) {
        reset();
      }
    });
  }

  void reset() {
    state = const AuthStateView();
  }
}
