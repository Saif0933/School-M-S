import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'domain/entities/user_entity.dart';
import 'data/repositories/mock_auth_repository.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Auth Providers — Riverpod state management
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Auth repository provider
final authRepositoryProvider = Provider<MockAuthRepository>(
  (ref) => MockAuthRepository(),
);

/// Current authenticated user
final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserEntity?>>(
  (ref) => AuthNotifier(ref.read(authRepositoryProvider)),
);

/// Convenience provider: is user logged in?
final isLoggedInProvider = Provider<bool>(
  (ref) => ref.watch(authStateProvider).valueOrNull != null,
);

/// Convenience provider: current user (non-null when logged in)
final currentUserProvider = Provider<UserEntity?>(
  (ref) => ref.watch(authStateProvider).valueOrNull,
);

/// Active branch ID
final activeBranchIdProvider = StateProvider<String?>(
  (ref) {
    final user = ref.watch(currentUserProvider);
    return user?.activeBranchId;
  },
);

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Auth State Notifier
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AuthNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final MockAuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.data(null));

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(email, password);
      if (user != null) {
        state = AsyncValue.data(user);
        return true;
      } else {
        state = const AsyncValue.data(null);
        return false;
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Logout
  void logout() {
    state = const AsyncValue.data(null);
  }

  /// Switch active branch
  void switchBranch(String branchId) {
    final user = state.valueOrNull;
    if (user != null) {
      state = AsyncValue.data(user.copyWith(activeBranchId: branchId));
    }
  }
}
