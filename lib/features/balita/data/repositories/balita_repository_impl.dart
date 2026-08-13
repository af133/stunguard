import '../../domain/entities/balita_entity.dart';
import '../../domain/repositories/balita_repository.dart';
import '../datasources/balita_local_datasource.dart';
import '../models/balita_model.dart';

class BalitaRepositoryImpl implements BalitaRepository {
  final BalitaLocalDataSource localDataSource;

  BalitaRepositoryImpl({required this.localDataSource});

  @override
  Future<void> addBalita(BalitaEntity balita) async {
    final model = BalitaModel.fromEntity(balita);
    await localDataSource.insertBalita(model);
  }

  @override
  Future<void> updateBalita(BalitaEntity balita) async {
    final model = BalitaModel.fromEntity(balita);
    await localDataSource.updateBalita(model);
  }

  @override
  Future<void> deleteBalita(String id) async {
    await localDataSource.deleteBalita(id);
  }

  @override
  Future<BalitaEntity?> getBalitaById(String id) async {
    return await localDataSource.getBalitaById(id);
  }

  @override
  Future<List<BalitaEntity>> getBalitaList({String? searchQuery, String? ageFilter}) async {
    return await localDataSource.getAllBalita(searchQuery: searchQuery, ageFilter: ageFilter);
  }
}
