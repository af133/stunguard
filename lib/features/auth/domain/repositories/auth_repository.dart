import '../entities/user_entity.dart';

/// Repository interface for authentication operations.
/// Follows Clean Architecture — domain layer defines the contract,
/// data layer provides the implementation.
abstract class AuthRepository {
  /// Register a new cadre user
  Future<void> registerUser(UserEntity user);

  /// Find user by phone number for login
  Future<UserEntity?> getUserByPhone(String phone);

  /// Get all registered users (for admin/debug)
  Future<List<UserEntity>> getAllUsers();

  /// Update user profile
  Future<void> updateUser(UserEntity user);
}
