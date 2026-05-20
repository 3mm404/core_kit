import 'package:core_kit/core/kit/kit.dart';

class User extends Kit {
  User(super.data);

  String get id => string('id');

  String get name => string('name');

  String get email => string('email');

  String get phoneNumber => string('phone_number');

  String get password => string('password');

  String get token => string('token');

  String get roles => string('roles');
}


class AuthResponse extends Kit {
  AuthResponse(super.data);

  User get user => User(map('user'));
  String get token => string('token');
}