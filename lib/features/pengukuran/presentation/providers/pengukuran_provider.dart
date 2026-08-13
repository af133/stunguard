import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/pengukuran_local_datasource.dart';
import '../../data/repositories/pengukuran_repository_impl.dart';
import '../../domain/entities/pengukuran_entity.dart';
import '../../domain/repositories/pengukuran_repository.dart';

final pengukuranLocalDataSourceProvider = Provider<PengukuranLocalDataSource>((ref) {
  return PengukuranLocalDataSourceImpl();
});

final pengukuranRepositoryProvider = Provider<PengukuranRepository>((ref) {
  final localDataSource = ref.watch(pengukuranLocalDataSourceProvider);
  return PengukuranRepositoryImpl(localDataSource: localDataSource);
});

class PengukuranState {
  final List<PengukuranEntity> items;
  final bool isLoading;
  final String? error;

  PengukuranState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  PengukuranState copyWith({
    List<PengukuranEntity>? items,
    bool? isLoading,
    String? error,
  }) {
    return PengukuranState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PengukuranNotifier extends Notifier<PengukuranState> {
  @override
  PengukuranState build() => PengukuranState();

  Future<void> loadPengukuranList(String childId) async {
    final repository = ref.read(pengukuranRepositoryProvider);
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await repository.getPengukuranByChildId(childId);
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addPengukuran(PengukuranEntity me) async {
    final repository = ref.read(pengukuranRepositoryProvider);
    try {
      await repository.addPengukuran(me);
      await loadPengukuranList(me.childId);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final pengukuranProvider = NotifierProvider<PengukuranNotifier, PengukuranState>(PengukuranNotifier.new);
