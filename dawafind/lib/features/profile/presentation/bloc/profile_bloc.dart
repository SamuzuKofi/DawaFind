import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepositoryImpl(),
      super(ProfileInitial()) {
    on<ProfileLoaded>(_onLoaded);
    on<ProfileLogoutRequested>(_onLogoutRequested);
  }

  final AuthRepository _authRepository;

  Future<void> _onLoaded(
    ProfileLoaded event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      if (user == null) {
        emit(ProfileError(message: 'You are not signed in.'));
        return;
      }
      emit(ProfileReady(name: user.fullName, role: user.role));
    } on AppException catch (e) {
      emit(ProfileError(message: e.message));
    }
  }

  Future<void> _onLogoutRequested(
    ProfileLogoutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    await _authRepository.signOut();
    emit(ProfileLoggedOut());
  }
}
