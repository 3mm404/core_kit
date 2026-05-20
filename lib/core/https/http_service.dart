
import 'package:core_kit/core/https/my_apis.dart';
import 'package:core_kit/core/https/interseptor/auth_interceptor.dart';
import 'package:core_kit/core/https/interseptor/error_interceptor.dart';
import 'package:core_kit/core/https/storage/storage.dart';
import 'package:dio/dio.dart';


class HttpService {
  late final Dio _dio;
  final StorageService _storage;

  HttpService(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(_storage), // agrega el token
      ErrorInterceptor(), // mapea errores
    ]);
  }

  Dio get client => _dio;
}