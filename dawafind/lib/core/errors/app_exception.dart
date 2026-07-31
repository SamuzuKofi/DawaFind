/// A user-facing error message, already translated from whatever
/// Firebase/Firestore threw. Blocs catch this and put .message straight
/// into their Error state.
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}
