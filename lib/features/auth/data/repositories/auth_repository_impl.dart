import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<void> registerUser(UserEntity user) async {
    // Check for duplicate phone number
    final existing = await localDataSource.getUserByPhone(user.phone);
    if (existing != null) {
      throw Exception('Nomor telepon ${user.phone} sudah terdaftar.');
    }

    final model = UserModel.fromEntity(user);
    await localDataSource.insertUser(model);
  }

  @override
  Future<UserEntity?> getUserByPhone(String phone) async {
    return await localDataSource.getUserByPhone(phone);
  }

  @override
  Future<List<UserEntity>> getAllUsers() async {
    return await localDataSource.getAllUsers();
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    final model = UserModel.fromEntity(user);
    await localDataSource.updateUser(model);
  }
}
