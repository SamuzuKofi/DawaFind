import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/repositories/medicine_repository_impl.dart';
import '../../domain/entities/medicine_entity.dart';
import '../../domain/repositories/medicine_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({MedicineRepository? medicineRepository})
    : _medicineRepository = medicineRepository ?? MedicineRepositoryImpl(),
      super(SearchInitial()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchCleared>(_onCleared);
  }

  final MedicineRepository _medicineRepository;

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.isEmpty) return emit(SearchInitial());
    emit(SearchLoading());
    try {
      final results = await _medicineRepository.search(event.query);
      emit(results.isEmpty ? SearchEmpty() : SearchSuccess(results: results));
    } on AppException catch (e) {
      emit(SearchError(message: e.message));
    } catch (_) {
      // An uncaught error emits no state at all, which would
      // strand the screen on its loading spinner forever.
      emit(SearchError(message: 'Search failed. Please try again.'));
    }
  }

  void _onCleared(SearchCleared event, Emitter<SearchState> emit) =>
      emit(SearchInitial());
}
