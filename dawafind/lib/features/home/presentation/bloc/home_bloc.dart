import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<HomeLoaded>(_onLoaded);
  }

  Future<void> _onLoaded(
    HomeLoaded event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    // call PreferencesService.getUserType() then emit HomeReady
  }
}
