import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  return AuthRepositoryImpl(localDataSource: localDataSource);
});

// State class for Auth
class AuthState {
  final bool isLoading;
  final UserEntity? user;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    UserEntity? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error, // Can be null to clear error
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => AuthState();

  Future<bool> login(String phone, String role) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.getUserByPhone(phone);
      
      if (user == null) {
        state = state.copyWith(isLoading: false, error: 'Nomor telepon belum terdaftar.');
        return false;
      }

      if (user.role != role) {
        state = state.copyWith(isLoading: false, error: 'Peran tidak sesuai dengan akun Anda.');
        return false;
      }

      state = state.copyWith(
        isLoading: false,
        user: user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register(UserEntity newUser) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.registerUser(newUser);

      state = state.copyWith(
        isLoading: false,
        user: newUser,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void logout() {
    state = AuthState(); // Reset state
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
