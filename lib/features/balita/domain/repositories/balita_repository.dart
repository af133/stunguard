import '../entities/balita_entity.dart';

abstract class BalitaRepository {
  Future<void> addBalita(BalitaEntity balita);
  Future<void> updateBalita(BalitaEntity balita);
  Future<void> deleteBalita(String id);
  Future<BalitaEntity?> getBalitaById(String id);
  Future<List<BalitaEntity>> getBalitaList({String? searchQuery, String? ageFilter});
}
