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
    } catch (_) {
      // Nothing may escape a handler: an uncaught error emits no state at
      // all, which strands the screen on its loading spinner forever.
      emit(ProfileError(message: 'Could not load your profile.'));
    }
  }

  Future<void> _onLogoutRequested(
    ProfileLogoutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    // A failed remote sign-out must never trap the user in a signed-in UI,
    // so the local session is cleared either way.
    try {
      await _authRepository.signOut();
    } catch (_) {
      // Ignored on purpose — see above.
    }
    emit(ProfileLoggedOut());
  }
}
