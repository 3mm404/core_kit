import 'package:core_kit/core/https/exeptions/app_exception.dart';
import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appException = _handleError(err);

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: appException, // tu AppException queda en e.error
        response: err.response,
        type: DioExceptionType.unknown,
      ),
    );
  }

  AppException _handleError(DioException e) {
    // Sin respuesta = problema de red
    if (e.response == null) {
      return NetworkException(_connectionMessage(e.type));
    }

    final status = e.response!.statusCode ?? 0;
    final body = e.response!.data;

    return switch (status) {
      400 => ValidationException(
        _extractMessage(body, fallback: 'Datos inválidos'),
        fieldErrors: _extractFieldErrors(body),
      ),
      401 => AuthException(
        'Credenciales incorrectas',
        type: AuthError.invalidCredentials,
      ),
      403 => AuthException('Sin permisos', type: AuthError.forbidden),
      404 => ServerException('No encontrado', statusCode: 404),
      422 => ValidationException(
        _extractMessage(body, fallback: 'Error de validación'),
        fieldErrors: _extractFieldErrors(body),
      ),
      >= 500 => ServerException(
        _extractMessage(body, fallback: 'Error del servidor'),
        statusCode: status,
        serverMessage: body?['error']?.toString(),
      ),
      _ => ServerException('Error inesperado ($status)', statusCode: status),
    };
  }

  String _connectionMessage(DioExceptionType type) => switch (type) {
    DioExceptionType.connectionTimeout => 'Tiempo de conexión agotado',
    DioExceptionType.receiveTimeout => 'El servidor tardó demasiado',
    DioExceptionType.cancel => 'Solicitud cancelada',
    _ => 'Sin conexión a internet',
  };

  String _extractMessage(dynamic body, {required String fallback}) =>
      (body is Map ? body['message'] ?? body['error'] : null)?.toString() ??
      fallback;

  Map<String, String> _extractFieldErrors(dynamic body) {
    if (body is! Map) return {};
    final errors = body['errors'];
    if (errors is! Map) return {};
    return errors.map((k, v) => MapEntry(k.toString(), v.toString()));
  }
}