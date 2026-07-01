/// Typed exceptions produced by the data layer.
/// Presentation layer catches these to display user-friendly messages.
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// The server returned a 4xx / 5xx with a body we could parse.
final class ServerException extends AppException {
  const ServerException(super.message, {this.statusCode});
  final int? statusCode;
}

/// HTTP 401 — token expired or invalid.
final class UnauthorizedException extends AppException {
  const UnauthorizedException() : super('Session expirée. Veuillez vous reconnecter.');
}

/// HTTP 403 — authenticated but not authorised.
final class ForbiddenException extends AppException {
  const ForbiddenException() : super('Accès refusé.');
}

/// HTTP 404
final class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Ressource introuvable.']);
}

/// No internet / server unreachable.
final class NetworkException extends AppException {
  const NetworkException() : super('Connexion impossible. Vérifiez votre réseau.');
}

/// Request timed out.
final class TimeoutException extends AppException {
  const TimeoutException() : super('La requête a expiré. Réessayez.');
}

/// Anything else we didn't anticipate.
final class UnexpectedException extends AppException {
  const UnexpectedException([super.message = 'Une erreur inattendue est survenue.']);
}
