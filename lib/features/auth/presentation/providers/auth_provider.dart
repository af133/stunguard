import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';

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

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  Future<void> login(String phone, String role) async {
    state = state.copyWith(isLoading: true, error: null);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // TODO: Implement actual backend/database login
    // Mock user for now
    state = state.copyWith(
      isLoading: false,
      user: UserEntity(
        id: '1',
        name: 'Ibu Siti',
        phone: phone,
        posyanduName: 'Mawar 1',
        workArea: 'Desa Suka Maju',
        role: role,
      ),
    );
  }

  Future<void> register(UserEntity newUser) async {
    state = state.copyWith(isLoading: true, error: null);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // TODO: Implement actual registration logic
    state = state.copyWith(
      isLoading: false,
      user: newUser,
    );
  }

  void logout() {
    state = AuthState(); // Reset state
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
