// Collection names, kept in one place so they always match firestore.rules.
class FirestorePaths {
  FirestorePaths._();

  static const String medicines = 'medicines';
  static const String pharmacies = 'pharmacies';
  static const String stock = 'stock';
  static const String pharmacyStaff = 'pharmacyStaff';
  static const String users = 'users';

  // Subcollections
  static const String ratings = 'ratings'; // pharmacies/{id}/ratings
  static const String savedPharmacies =
      'savedPharmacies'; // users/{id}/savedPharmacies
  static const String searchHistory =
      'searchHistory'; // users/{id}/searchHistory
}
