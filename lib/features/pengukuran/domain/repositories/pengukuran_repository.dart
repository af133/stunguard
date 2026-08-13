import '../entities/pengukuran_entity.dart';

abstract class PengukuranRepository {
  Future<void> addPengukuran(PengukuranEntity me);
  Future<List<PengukuranEntity>> getPengukuranByChildId(String childId);
  Future<PengukuranEntity?> getLatestPengukuran(String childId);
}
