abstract class Kit {
  final Map<String, dynamic> data;

  Kit(Map<String, dynamic>? data) : data = data ?? {};

  dynamic get(String key) => data[key];

  bool has(String key) => data.containsKey(key);

  String string(String key, [String fallback = '']) {
    final value = data[key];

    if (value == null) return fallback;

    return value.toString();
  }

  int intValue(String key, [int fallback = 0]) {
    final value = data[key];

    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString()) ?? fallback;
  }

  double doubleValue(String key, [double fallback = 0]) {
    final value = data[key];

    if (value == null) return fallback;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();

    return double.tryParse(value.toString()) ?? fallback;
  }

  bool boolValue(String key, [bool fallback = false]) {
    final value = data[key];

    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is num) return value != 0;

    if (value is String) {
      final normalized = value.toLowerCase().trim();

      if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
        return true;
      }

      if (normalized == 'false' || normalized == '0' || normalized == 'no') {
        return false;
      }
    }

    return fallback;
  }

  Map<String, dynamic> map(String key) {
    final value = data[key];

    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {};
  }

  List<dynamic> list(String key) {
    final value = data[key];

    if (value is List) {
      return value;
    }

    return [];
  }

  T model<T>(
    String key,
    T Function(Map<String, dynamic>) builder,
  ) {
    return builder(map(key));
  }

  List<T> models<T>(
    String key,
    T Function(Map<String, dynamic>) builder,
  ) {
    return list(key)
        .whereType<Map>()
        .map((item) => builder(Map<String, dynamic>.from(item)))
        .toList();
  }

  DateTime? date(String key) {
    final value = data[key];

    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }

  Map<String, dynamic> only(List<String> keys) {
    return {
      for (final key in keys)
        if (data.containsKey(key)) key: data[key],
    };
  }

  Map<String, dynamic> except(List<String> keys) {
    return {
      for (final entry in data.entries)
        if (!keys.contains(entry.key)) entry.key: entry.value,
    };
  }

  Map<String, dynamic> merge(Map<String, dynamic> values) {
    return {
      ...data,
      ...values,
    };
  }

  Map<String, dynamic> toJson() => data;
}