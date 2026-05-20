// core/storage/storage_service.dart
//
// Servicio de almacenamiento local basado en GetStorage.
// Se encarga de persistir el token de autenticación entre sesiones.
// Es inyectado como dependencia permanente desde InitialBinding.

import 'package:get_storage/get_storage.dart';

class StorageService {
  // Instancia única del almacenamiento local
  final _box = GetStorage();

  // Clave usada para guardar y leer el token de autenticación
  static const String tokenKey = 'auth_token';

  // Clave usada para el rol del usuario (cliente o conductor)
  static const String roleKey = 'user_role';

  // ── Token ──────────────────────────────────────────────────────────────────

  /// Guarda el token JWT recibido tras el login / OTP
  void saveToken(String token) => _box.write(tokenKey, token);

  /// Retorna el token guardado, o null si el usuario no ha iniciado sesión
  String? getToken() => _box.read(tokenKey);

  /// Elimina el token al cerrar sesión
  void removeToken() => _box.remove(tokenKey);

  /// Indica si el usuario tiene una sesión activa
  bool get isLoggedIn => getToken() != null;

  //esto es para saber si el usuario es driver
  bool get isDriver => _box.read(roleKey) == 'driver';

  // ── Rol de usuario ──────────────────────────────────────────────────────────

  /// Guarda el rol del usuario (ej: 'client', 'driver')
  void saveRole(String role) => _box.write(roleKey, role);

  /// Retorna el rol del usuario, o null si no se ha guardado
  String? getRole() => _box.read(roleKey);

  // ── Genérico ────────────────────────────────────────────────────────────────

  /// Guarda cualquier valor serializable bajo una clave arbitraria.
  ///
  /// Tipos soportados por GetStorage: String, int, double, bool, List, Map.
  /// Para objetos personalizados, convierte a Map primero (ej: model.toJson()).
  ///
  /// Ejemplo:
  /// ```dart
  /// storage.save('onboarding_done', true);
  /// storage.save('user_prefs', {'theme': 'dark', 'lang': 'es'});
  /// ```
  void save(String key, dynamic value) => _box.write(key, value);

  /// Retorna el valor asociado a [key] casteado al tipo [T], o null si no existe.
  ///
  /// Ejemplo:
  /// ```dart
  /// final done = storage.get<bool>('onboarding_done');       // true / null
  /// final prefs = storage.get<Map>('user_prefs');            // {...} / null
  /// final name  = storage.get<String>('display_name');       // 'Ana' / null
  /// ```
  T? get<T>(String key) => _box.read<T>(key);

  /// Elimina el valor asociado a [key].
  void remove(String key) => _box.remove(key);

  /// Indica si existe un valor guardado para [key].
  bool has(String key) => _box.hasData(key);

  // ── Limpieza completa ───────────────────────────────────────────────────────

  /// Borra todos los datos guardados (se usa al cerrar sesión completamente)
  void clearAll() => _box.erase();
}