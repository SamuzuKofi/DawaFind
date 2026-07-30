part of 'search_bloc.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  SearchSuccess({required this.results});
  final List<MedicineSearchResultEntity> results;
}

class SearchEmpty extends SearchState {}

class SearchError extends SearchState {
  SearchError({required this.message});
  final String message;
}
