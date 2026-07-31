import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:firebase_core/firebase_core.dart' show FirebaseException;

/// A user-facing error message, already translated from whatever
/// Firebase/Firestore threw. Blocs catch this and put .message straight
/// into their Error state.
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Runs [action] and guarantees that anything it throws surfaces as an
/// [AppException].
///
/// Repositories are the boundary where backend failures become messages the
/// UI can show. Without this, a non-Firebase error (an ArgumentError from an
/// empty document ID, a platform channel failure) escapes the repository,
/// escapes the bloc's `on AppException` handler, and leaves the bloc stuck on
/// its Loading state forever — a screen that spins and never resolves.
Future<T> guard<T>(Future<T> Function() action, String fallbackMessage) async {
  try {
    return await action();
  } on AppException {
    rethrow;
  } on FirebaseAuthException catch (e) {
    throw AppException(e.message ?? fallbackMessage);
  } on FirebaseException catch (e) {
    throw AppException(e.message ?? fallbackMessage);
  } catch (_) {
    throw AppException(fallbackMessage);
  }
}
