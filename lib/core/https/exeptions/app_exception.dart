// core/errors/app_exception.dart

/// Base sellada — nadie lanza esto directamente
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

// --- Capa de infraestructura ---
final class NetworkException extends AppException {
  final int? statusCode;
  const NetworkException(super.message, {this.statusCode});
}

final class ServerException extends AppException {
  final int statusCode;
  final String? serverMessage;
  const ServerException(
    super.message, {
    required this.statusCode,
    this.serverMessage,
  });
}

final class CacheException extends AppException {
  const CacheException(super.message);
}

// --- Capa de dominio/negocio ---
final class BusinessException extends AppException {
  final String code; // e.g. "INSUFFICIENT_FUNDS"
  const BusinessException(super.message, {required this.code});
}

// --- Capa de autenticación ---
final class AuthException extends AppException {
  final AuthError type;
  const AuthException(super.message, {required this.type});
}

enum AuthError { unauthorized, forbidden, sessionExpired, invalidCredentials }

// --- Capa de presentación / validación ---
final class ValidationException extends AppException {
  final Map<String, String> fieldErrors; // { "email": "Formato inválido" }
  const ValidationException(super.message, {this.fieldErrors = const {}});
}