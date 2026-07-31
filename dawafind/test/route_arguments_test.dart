import 'package:dawafind/app.dart';
import 'package:dawafind/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression test for routes dropping their arguments.
///
/// onGenerateRoute built its MaterialPageRoute without forwarding the incoming
/// RouteSettings, so Navigator.pushNamed(..., arguments: id) handed the id to
/// the generator and it was silently discarded. Every screen reading
/// ModalRoute.of(context).settings.arguments got null, which is why tapping a
/// pharmacy or a search result opened an empty detail screen.
void main() {
  test('every _generateRoute branch forwards its settings', () {
    // Drives the real generator and checks the resulting Route kept the
    // settings it was handed — the exact step that was missing.
    const routes = [
      AppRoutes.splash,
      AppRoutes.onboarding1,
      AppRoutes.onboarding2,
      AppRoutes.login,
      AppRoutes.signup,
      AppRoutes.homePatient,
      AppRoutes.homePharmacist,
      AppRoutes.search,
      AppRoutes.inventory,
      AppRoutes.admin,
      AppRoutes.pharmacyDetail,
      AppRoutes.mapView,
      AppRoutes.drugNotFound,
      AppRoutes.profile,
      AppRoutes.savedPharmacies,
    ];

    for (final name in routes) {
      final settings = RouteSettings(name: name, arguments: 'test-argument');
      final route = DawaFindApp.debugGenerateRoute(settings);

      expect(
        route.settings.arguments,
        'test-argument',
        reason: '$name dropped its arguments',
      );
      expect(route.settings.name, name, reason: '$name dropped its name');
    }
  });
}
