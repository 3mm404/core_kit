import 'package:core_kit/core/https/http_service.dart';
import 'package:core_kit/core/kit/kit.dart';

class Api {
  final HttpService http;

  Api(this.http);

  Future<T> post<T extends Kit>(
    String path, {
    Map<String, dynamic>? data,
    required T Function(Map<String, dynamic>) model,
  }) async {
    final response = await http.client.post(path, data: data);

    final body = response.data as Map<String, dynamic>;

    return model(body);
  }
}