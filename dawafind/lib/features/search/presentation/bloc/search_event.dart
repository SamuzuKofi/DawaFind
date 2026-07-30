part of 'search_bloc.dart';

abstract class SearchEvent {}

class SearchQueryChanged extends SearchEvent {
  SearchQueryChanged({required this.query});
  final String query;
}

class SearchCleared extends SearchEvent {}
