import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/data/models/user_model.dart';
import 'package:mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/data/datasources/auth_local_datasource.dart';

// Mock Datasource
class MockAuthLocalDataSource implements AuthLocalDataSource {
  final List<UserModel> _users = [];

  @override
  Future<void> insertUser(UserModel user) async {
    _users.add(user);
  }

  @override
  Future<UserModel?> getUserByPhone(String phone) async {
    try {
      return _users.firstWhere((u) => u.phone == phone);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    return _users;
  }

  @override
  Future<void> updateUser(UserModel user) async {
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = user;
    }
  }
}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(localDataSource: mockDataSource);
  });

  group('AuthRepository', () {
    final testUser = UserEntity(
      id: '1',
      name: 'Test Kader',
      phone: '08123456789',
      posyanduName: 'Mawar 1',
      workArea: 'Desa A',
      role: 'kader',
    );

    test('registerUser should add user successfully', () async {
      await repository.registerUser(testUser);
      final users = await repository.getAllUsers();
      
      expect(users.length, 1);
      expect(users.first.name, 'Test Kader');
    });

    test('registerUser should throw exception if phone already exists', () async {
      await repository.registerUser(testUser);
      
      expect(
        () => repository.registerUser(testUser),
        throwsException,
      );
    });

    test('getUserByPhone should return user if exists', () async {
      await repository.registerUser(testUser);
      
      final result = await repository.getUserByPhone('08123456789');
      
      expect(result, isNotNull);
      expect(result?.name, 'Test Kader');
    });

    test('getUserByPhone should return null if not exists', () async {
      final result = await repository.getUserByPhone('080000000');
      expect(result, isNull);
    });
  });
}
