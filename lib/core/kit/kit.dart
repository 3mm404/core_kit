abstract class Kit {
  final Map<String, dynamic> data;

  Kit(this.data);

  dynamic get(String key) => data[key];

  String string(String key, [String fallback = '']) {
    final value = data[key];
    if (value == null) return fallback;
    return value.toString();
  }

  int intValue(String key, [int fallback = 0]) {
    final value = data[key];

    if (value == null) return fallback;
    if (value is int) return value;

    return int.tryParse(value.toString()) ?? fallback;
  }

  bool boolValue(String key, [bool fallback = false]) {
    final value = data[key];

    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is num) return value != 0;

    if (value is String) {
      return value.toLowerCase() == 'true';
    }

    return fallback;
  }

  Map<String, dynamic> only(List<String> keys) {
    return {
      for (final key in keys)
        if (data.containsKey(key)) key: data[key],
    };
  }

  Map<String, dynamic> toJson() => data;
}