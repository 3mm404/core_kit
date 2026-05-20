import 'package:core_kit/app/models/user.dart';
import 'package:core_kit/core/kit/kit.dart';

class Auth extends Kit {
  Auth(super.data);

  User get user => model('user', User.new);

  String get token => string('token');
}