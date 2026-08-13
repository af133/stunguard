import '../../domain/entities/pengukuran_entity.dart';
import '../../domain/repositories/pengukuran_repository.dart';
import '../datasources/pengukuran_local_datasource.dart';
import '../models/pengukuran_model.dart';

class PengukuranRepositoryImpl implements PengukuranRepository {
  final PengukuranLocalDataSource localDataSource;

  PengukuranRepositoryImpl({required this.localDataSource});

  @override
  Future<void> addPengukuran(PengukuranEntity me) async {
    final model = PengukuranModel.fromEntity(me);
    await localDataSource.insertPengukuran(model);
  }

  @override
  Future<List<PengukuranEntity>> getPengukuranByChildId(String childId) async {
    return await localDataSource.getPengukuranByChildId(childId);
  }

  @override
  Future<PengukuranEntity?> getLatestPengukuran(String childId) async {
    return await localDataSource.getLatestPengukuran(childId);
  }
}
