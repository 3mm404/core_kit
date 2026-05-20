// core/constants/api_constants.dart
//
// Constantes centralizadas para la configuración de la API HTTP y WebSocket.
// Modificar aquí afecta toda la capa de red de la aplicación.

class ApiConstants {
  // ── HTTP ────────────────────────────────────────────────────────────────────
  // URL base para todas las peticiones REST. Se prefija automáticamente por Dio.
  static const String baseUrl = 'https://dockploy.cherbyte.com/api';

  // ── WebSocket (Pusher) ───────────────────────────────────────────────────────
  // URL base para la conexión WebSocket segura (wss)
  static const String baseWssUrl = 'wss://dockploy.cherbyte.com';

  // Clave pública de la app Pusher configurada en el backend
  static const String wsAppKey = 'ceDatachas1Aemm';

  // Host del servidor Pusher (mismo que el API)
  static const String wsHost = 'dockploy.cherbyte.com';

  // Puerto WSS (443 = HTTPS/TLS seguro)
  static const int wsPort = 443;

  // Endpoint del backend que autentica canales privados de Pusher
  static const String wsAuthEndpoint = '/api/broadcasting/auth';

  // ── Versión ──────────────────────────────────────────────────────────────────
  // Prefijo de versión que se agrega a cada ruta del API
  static const String version = '/v1';
}

class ApiAuthRoutes {
  static const String login = '${ApiConstants.version}/login';
  static const String register = "${ApiConstants.version}/register";
  static const String verifyEmail = "${ApiConstants.version}/verify-email";
  static const String logout = "${ApiConstants.version}/logout";

  static const String fcmTokens =
      '${ApiConstants.version}/fcm-tokens'; // para el manejo de notificaciones push

  // para eliminar el token de notificaciones push
  static String fcmTokenDestroy(String token) =>
      '${ApiConstants.version}/fcm-tokens/$token';

  // para recuperar la contraseña
  static const String forgotPassword =
      '${ApiConstants.version}/forgot-password';
  static const String resetPassword = '${ApiConstants.version}/reset-password';
}

class ApiProfileRoutes {
  static const String userProfile = '${ApiConstants.version}/profile';
  static const String userAddresses = '${ApiConstants.version}/addresses';
}

//Tipo WebSocket

class ApiNotificationRoutes {
  static const String notifications = '${ApiConstants.version}/notifications';
  static String notificationById(String id) =>
      '${ApiConstants.version}/notifications/$id';

  //Marcar como leído
  static String markAsRead(String id) =>
      '${ApiConstants.version}/notifications/$id/read';

  //Marcar todas como leídas
  static const String markAllAsRead =
      '${ApiConstants.version}/notifications/read';
}

//se dejo pendiente por temas de emulador este se trabaja por mediod e midllwares
class ApiCityRoutes {
  static const String cities = '${ApiConstants.version}/cities';
  static const String detectCity = '${ApiConstants.version}/cities/detect';
  static String cityById(int id) => '${ApiConstants.version}/cities/$id';
}

class ApiProductRoutes {
  static const String products = '${ApiConstants.version}/products';
  static String productId(String id) => '${ApiConstants.version}/products/$id';
}

class ApiCategoryRoutes {
  static const String categories = '${ApiConstants.version}/categories';
  static String categoryId(String id) =>
      '${ApiConstants.version}/categories/$id';
}

class ApiFavoriteRoutes {
  static const String favorites = '${ApiConstants.version}/favorites';
  static const String favoriteToggle =
      '${ApiConstants.version}/favorites/toggle';
}

class ApiBannerRoutes {
  static const String banners = '${ApiConstants.version}/banners';
}

class ApiBusinessRoutes {
  static const String business =
      '${ApiConstants.version}/businesses'; // ← businesses
  static String businessId(String id) =>
      '${ApiConstants.version}/businesses/$id'; // ← businesses
}

//Rutas de reseñas

class ApiReviewRoutes {
  static String submit(int businessId) =>
      '${ApiConstants.version}/businesses/$businessId/reviews';

  static String reply(int reviewId) =>
      '${ApiConstants.version}/reviews/$reviewId/replies';
}

class ApiOrderRoutes {
  // GET/DELETE — ver y vaciar el carrito
  static const String orders = '${ApiConstants.version}/cart';

  // POST — agregar productos al carrito
  static const String addProduct = '${ApiConstants.version}/cart/items';

  // DELETE — quitar un item específico
  static String removeProduct(int id) =>
      '${ApiConstants.version}/cart/items/$id';

  // POST — checkout y pago
  static const String checkout = '${ApiConstants.version}/cart/checkout';
}

//Checkout

class ApiCheckoutRoutes {
  static const String checkout = '${ApiConstants.version}/checkout';
}

//Ordenes

//mis ordenes
class ApiMyOrderRoutes {
  static const String orders = '${ApiConstants.version}/orders';
}