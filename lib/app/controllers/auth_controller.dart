import 'package:core_kit/app/models/auth.dart';
import 'package:core_kit/app/models/user.dart';
import 'package:core_kit/core/api/api.dart';
import 'package:core_kit/core/https/my_apis.dart';
import 'package:core_kit/core/https/storage/storage.dart';

class AuthController {
  final Api api;
  final StorageService storage;

  AuthController(this.api, this.storage);

  Future<User> login({
    required String email,
    required String password,
  }) async {
    final auth = await api.post<Auth>(
      ApiAuthRoutes.login,
      data: {
        'email': email,
        'password': password,
      },
      model: Auth.new,
    );

    storage.saveToken(auth.token);

    return auth.user;
  }
}