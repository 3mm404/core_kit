import 'package:core_kit/core/https/http_service.dart';
import 'package:core_kit/core/kit/kit.dart';

class Api {
  final HttpService http;

  Api(this.http);

  Future<T> post<T extends Kit>(
    String path, {
    required Map<String, dynamic> data,
    required T Function(Map<String, dynamic>) model,
    String? dataKey,
    List<String> extras = const [],
  }) async {
    final response = await http.client.post(path, data: data);

    final body = response.data as Map<String, dynamic>;

    final payload = dataKey == null
        ? body
        : body[dataKey] as Map<String, dynamic>;

    return model({
      ...payload,
      for (final key in extras) key: body[key],
    });
  }
}