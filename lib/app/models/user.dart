import 'package:core_kit/core/kit/kit.dart';

class User extends Kit {
  User(super.data);

  String get id => string('id');
  String get name => string('name');
  String get email => string('email');
  String get phoneNumber => string('phone_number');
}