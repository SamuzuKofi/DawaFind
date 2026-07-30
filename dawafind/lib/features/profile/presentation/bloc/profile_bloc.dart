import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<ProfileLoaded>(_onLoaded);
    on<ProfileLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoaded(
    ProfileLoaded event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    // call AuthRepository.getCurrentUser() then emit ProfileReady
  }

  Future<void> _onLogoutRequested(
    ProfileLogoutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    // call AuthRepository.signOut()
    emit(ProfileLoggedOut());
  }
}
