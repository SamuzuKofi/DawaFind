import 'package:dawafind/core/constants/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression tests for role-based landing screens.
///
/// The login and splash screens each made this decision themselves with a
/// `role == 'pharmacist' ? ... : homePatient` ternary, so an admin fell
/// through to the patient home and the admin dashboard was unreachable —
/// nothing else in the app navigated to it.
void main() {
  group('AppRoutes.homeFor', () {
    test('sends an admin to the admin dashboard', () {
      expect(AppRoutes.homeFor('admin'), AppRoutes.admin);
    });

    test('sends a pharmacist to the pharmacist home', () {
      expect(AppRoutes.homeFor('pharmacist'), AppRoutes.homePharmacist);
    });

    test('sends a patient to the patient home', () {
      expect(AppRoutes.homeFor('patient'), AppRoutes.homePatient);
    });

    // getUserType() defaults to 'patient', but a stale or hand-edited
    // preference must not strand the user on a blank screen.
    test('falls back to the patient home for an unknown role', () {
      expect(AppRoutes.homeFor(''), AppRoutes.homePatient);
      expect(AppRoutes.homeFor('pharmicist'), AppRoutes.homePatient);
      expect(AppRoutes.homeFor('Admin'), AppRoutes.homePatient);
    });
  });
}
