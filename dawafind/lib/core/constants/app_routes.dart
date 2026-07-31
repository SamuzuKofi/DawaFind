// Named route constants and route generation

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding1 = '/onboarding1';
  static const String onboarding2 = '/onboarding2';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String homePatient = '/home-patient';
  static const String homePharmacist = '/home-pharmacist';
  static const String search = '/search';
  static const String pharmacyDetail = '/pharmacy-detail';
  static const String mapView = '/map-view';
  static const String drugNotFound = '/drug-not-found';
  static const String profile = '/profile';
  static const String savedPharmacies = '/saved-pharmacies';
  static const String inventory = '/inventory';
  static const String admin = '/admin';

  /// The landing screen for a granted role. Kept here because the splash
  /// screen and the login screen both need to make this decision, and when
  /// only one of them knew about admins, an admin signing in was sent to the
  /// patient home and could never reach the dashboard.
  static String homeFor(String role) {
    switch (role) {
      case 'admin':
        return admin;
      case 'pharmacist':
        return homePharmacist;
      default:
        return homePatient;
    }
  }
}
