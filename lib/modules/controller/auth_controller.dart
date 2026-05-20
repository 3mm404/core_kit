import 'package:core_kit/core/api/api.dart';
import 'package:core_kit/core/https/my_apis.dart';
import 'package:core_kit/core/https/storage/storage.dart';
import 'package:core_kit/modules/models/user.dart';

class AuthController {
  final Api api;
  final StorageService storage;

  AuthController(this.api, this.storage);

  Future<void> login(
    String email,
    String password,
  ) async {

    final user = User({
      'email': email,
      'password': password,
    });

    final result = await api.post<User>(
      ApiAuthRoutes.login,

      data: user.only([
        'email',
        'password',
      ]),

      model: User.new,

      dataKey: 'user',

      extras: ['token'],
    );

    storage.saveToken(result.token);
  }
}