import '../../../../core/database/database_helper.dart';
import '../models/user_model.dart';

/// Local data source contract for auth operations
abstract class AuthLocalDataSource {
  Future<void> insertUser(UserModel user);
  Future<UserModel?> getUserByPhone(String phone);
  Future<List<UserModel>> getAllUsers();
  Future<void> updateUser(UserModel user);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final DatabaseHelper _dbHelper;

  AuthLocalDataSourceImpl({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<void> insertUser(UserModel user) async {
    final db = await _dbHelper.database;
    await db.insert('users', user.toMap());
  }

  @override
  Future<UserModel?> getUserByPhone(String phone) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'users',
      where: 'phone = ?',
      whereArgs: [phone],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return UserModel.fromMap(results.first);
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    final db = await _dbHelper.database;
    final results = await db.query('users', orderBy: 'created_at DESC');
    return results.map((map) => UserModel.fromMap(map)).toList();
  }

  @override
  Future<void> updateUser(UserModel user) async {
    final db = await _dbHelper.database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
}
