import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import 'data/repositories/auth_repository.dart';
import 'domain/entities/user_entity.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Auth Providers — Riverpod state management
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.read(apiClientProvider)),
);

/// Current authenticated user
final authStateProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserEntity?>>(
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
final activeBranchIdProvider = StateProvider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.activeBranchId;
});

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Auth State Notifier
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AuthNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.data(null)) {
    tryAutoLogin();
  }

  /// Restore session on startup
  Future<void> tryAutoLogin() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.tryAutoLogin();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

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

  /// Onboard a new organization and auto-login
  Future<bool> onboard({
    required String orgName,
    String? registrationNumber,
    String? address,
    required String contactEmail,
    String? contactPhone,
    required String adminName,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.onboard(
        orgName: orgName,
        registrationNumber: registrationNumber,
        address: address,
        contactEmail: contactEmail,
        contactPhone: contactPhone,
        adminName: adminName,
        password: password,
      );
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

  /// Create a branch and refresh the user session
  Future<bool> createBranch({
    required String code,
    required String name,
    String? address,
    String? phone,
    String? email,
    String? affiliationBoard,
    String? recognitionNumber,
  }) async {
    try {
      final result = await _repository.createBranch(
        code: code,
        name: name,
        address: address,
        phone: phone,
        email: email,
        affiliationBoard: affiliationBoard,
        recognitionNumber: recognitionNumber,
      );

      if (result != null) {
        // Refresh session to pull the newly created branch into UserEntity
        final currentUser = state.valueOrNull;
        if (currentUser != null) {
          final refreshedUser = await _repository.refreshSession(currentUser);
          if (refreshedUser != null) {
            state = AsyncValue.data(refreshedUser);
          }
        }
        return true;
      }
    } catch (e) {
      debugPrint('Error creating branch: $e');
    }
    return false;
  }

  /// Logout and clear token storage
  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _repository.logout();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Switch active branch
  void switchBranch(String branchId) {
    final user = state.valueOrNull;
    if (user != null) {
      state = AsyncValue.data(user.copyWith(activeBranchId: branchId));
    }
  }
}
