import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../pharmacy/data/repositories/pharmacy_repository_impl.dart';
import '../../../pharmacy/domain/entities/pharmacy_summary_entity.dart';
import '../../../pharmacy/domain/repositories/pharmacy_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    AuthRepository? authRepository,
    PharmacyRepository? pharmacyRepository,
  }) : _authRepository = authRepository ?? AuthRepositoryImpl(),
       _pharmacyRepository = pharmacyRepository ?? PharmacyRepositoryImpl(),
       super(HomeInitial()) {
    on<HomeLoaded>(_onLoaded);
  }

  final AuthRepository _authRepository;
  final PharmacyRepository _pharmacyRepository;

  Future<void> _onLoaded(HomeLoaded event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      final pharmacies = await _pharmacyRepository.getNearbyPharmacies();
      emit(
        HomeReady(
          userName: user?.fullName ?? '',
          role: user?.role ?? 'patient',
          pharmacies: pharmacies,
        ),
      );
    } on AppException catch (e) {
      emit(HomeError(message: e.message));
    } catch (_) {
      // An uncaught error emits no state at all, which would strand the
      // screen on its loading spinner forever.
      emit(HomeError(message: 'Could not load your home screen.'));
    }
  }
}
