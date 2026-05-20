import 'package:core_kit/app/models/auth.dart';
import 'package:core_kit/app/models/user.dart';
import 'package:core_kit/core/api/api.dart';
import 'package:core_kit/core/enums/view.dart';
import 'package:core_kit/core/getx/basecontroller.dart';
import 'package:core_kit/core/https/my_apis.dart';
import 'package:core_kit/core/https/storage/storage.dart';
import 'package:get/get.dart';

class AuthController extends BaseControllerV2 {
  final Api api;
  final StorageService storage;

  AuthController(this.api, this.storage);

  final Rxn<User> user = Rxn<User>();

  bool get isLoggedIn => user.value != null;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await runGuarded(() async {
      final auth = await api.post<Auth>(
        ApiAuthRoutes.login,
        data: {
          'email': email,
          'password': password,
        },
        model: Auth.new,
      );

       storage.saveToken(auth.token);

      user.value = auth.user;

      setSuccess();
    });
  }

  Future<void> logout() async {
     storage.removeToken();

    user.value = null;

    viewState.value = ViewState.idle;
  }
}