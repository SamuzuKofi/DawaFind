import 'package:flutter_bloc/flutter_bloc.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchInitial()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchCleared>(_onCleared);
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.isEmpty) return emit(SearchInitial());
    emit(SearchLoading());
    // call MedicineRepository.search(event.query)
  }

  void _onCleared(SearchCleared event, Emitter<SearchState> emit) =>
      emit(SearchInitial());
}
