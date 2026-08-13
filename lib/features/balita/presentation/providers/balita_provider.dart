import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/balita_local_datasource.dart';
import '../../data/repositories/balita_repository_impl.dart';
import '../../domain/entities/balita_entity.dart';
import '../../domain/repositories/balita_repository.dart';

final balitaLocalDataSourceProvider = Provider<BalitaLocalDataSource>((ref) {
  return BalitaLocalDataSourceImpl();
});

final balitaRepositoryProvider = Provider<BalitaRepository>((ref) {
  final localDataSource = ref.watch(balitaLocalDataSourceProvider);
  return BalitaRepositoryImpl(localDataSource: localDataSource);
});

class BalitaState {
  final List<BalitaEntity> items;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String ageFilter; // 'semua', '0-6', '6-24', '24-59'

  BalitaState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.ageFilter = 'semua',
  });

  BalitaState copyWith({
    List<BalitaEntity>? items,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? ageFilter,
  }) {
    return BalitaState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      ageFilter: ageFilter ?? this.ageFilter,
    );
  }
}

class BalitaNotifier extends Notifier<BalitaState> {
  @override
  BalitaState build() {
    // Load balita list when provider is first initialized
    Future.microtask(() => loadBalitaList());
    return BalitaState();
  }

  Future<void> loadBalitaList() async {
    final repository = ref.read(balitaRepositoryProvider);
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await repository.getBalitaList(
        searchQuery: state.searchQuery,
        ageFilter: state.ageFilter,
      );
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadBalitaList();
  }

  void setAgeFilter(String filter) {
    state = state.copyWith(ageFilter: filter);
    loadBalitaList();
  }

  Future<bool> addBalita(BalitaEntity balita) async {
    final repository = ref.read(balitaRepositoryProvider);
    try {
      await repository.addBalita(balita);
      await loadBalitaList();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateBalita(BalitaEntity balita) async {
    final repository = ref.read(balitaRepositoryProvider);
    try {
      await repository.updateBalita(balita);
      await loadBalitaList();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteBalita(String id) async {
    final repository = ref.read(balitaRepositoryProvider);
    try {
      await repository.deleteBalita(id);
      await loadBalitaList();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final balitaProvider = NotifierProvider<BalitaNotifier, BalitaState>(BalitaNotifier.new);
