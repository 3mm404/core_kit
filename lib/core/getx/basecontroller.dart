import 'package:core_kit/core/enums/view.dart';
import 'package:core_kit/core/https/exeptions/app_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


/// Controlador base abstracto para todos los controladores de la aplicación.
///
/// Extiende [GetxController] y estandariza el manejo de estados de vista,
/// errores y operaciones asíncronas. Todo controlador de la app debe extender
/// esta clase en lugar de [GetxController] directamente.
///
/// ---
///
/// ## Ciclo de vida del estado
///
/// El [viewState] sigue un ciclo predecible en cada operación:
///
/// ```
/// idle → loading → success
///                → error
/// ```
///
/// El estado regresa a `idle` automáticamente al iniciar una nueva operación
/// mediante [clearErrors], que es llamado internamente por [runGuarded].
///
/// ---
///
/// ## Uso básico
///
/// Extiende [BaseControllerV2] e implementa tus métodos de acción usando
/// [runGuarded], que encapsula el ciclo completo de carga y manejo de errores:
///
/// ```dart
/// class ProfileController extends BaseControllerV2 {
///   final ProfileRepository _repository;
///
///   ProfileController(this._repository);
///
///   Future<void> loadProfile() async {
///     await runGuarded(() async {
///       final profile = await _repository.getProfile();
///       // actualizar estado reactivo...
///       setSuccess();
///     });
///   }
/// }
/// ```
///
/// ---
///
/// ## Manejo de errores
///
/// Los errores son resueltos automáticamente por [resolveException], que
/// interpreta las excepciones lanzadas por Dio tras pasar por `ErrorInterceptor`.
/// El interceptor envuelve cada error en [DioException.error] con un tipo concreto:
///
/// | Tipo de excepción     | Causa                                      | Ejemplo de mensaje              |
/// |-----------------------|--------------------------------------------|---------------------------------|
/// | `NetworkException`    | Sin conexión, timeout, cancelación         | "Sin conexión a internet"       |
/// | `ValidationException` | Error 400/422 con errores de campo         | "El campo email es obligatorio" |
/// | `AuthException`       | Error 401/403                              | "Credenciales incorrectas"      |
/// | `ServerException`     | Error 5xx u otros estados no mapeados      | "Error del servidor"            |
///
/// No es necesario capturar excepciones manualmente dentro de [runGuarded];
/// el manejo es automático. Para errores de validación por campo, los mensajes
/// quedan disponibles en [errors] y son accesibles mediante [error].
///
/// ---
///
/// ## Mostrar errores en la vista
///
/// Usa los observables [viewState], [errorMessage] y [errors] para reaccionar
/// al estado en la UI:
///
/// ```dart
/// Obx(() {
///   if (controller.isLoading) return const CircularProgressIndicator();
///   if (controller.hasError) return Text(controller.errorMessage.value);
///   return const MyContent();
/// })
/// ```
///
/// Para errores de campo individuales (útil en formularios):
///
/// ```dart
/// TextFormField(
///   decoration: InputDecoration(
///     errorText: controller.error('email'),
///   ),
/// )
/// ```
abstract class BaseControllerV2 extends GetxController {
  /// Estado reactivo de la vista. Refleja la fase actual de la operación en curso.
  final Rx<ViewState> viewState = ViewState.idle.obs;

  /// Mensaje de error general. Se popula cuando [viewState] es [ViewState.error].
  final RxString errorMessage = ''.obs;

  /// Mapa de errores de validación por campo, equivalente a la bolsa de errores
  /// de Laravel. La clave es el nombre del campo y el valor una lista de mensajes.
  ///
  /// Ejemplo de estructura:
  /// ```dart
  /// {
  ///   'email': ['El email ya está en uso.'],
  ///   'password': ['Mínimo 8 caracteres.'],
  /// }
  /// ```
  final RxMap<String, List<String>> errors = <String, List<String>>{}.obs;

  // ── Métodos de estado ──────────────────────────────────────────────────────

  /// Establece el estado como [ViewState.loading].
  void setLoading() => viewState.value = ViewState.loading;

  /// Establece el estado como [ViewState.success].
  /// Debe llamarse al final de una operación exitosa dentro de [runGuarded].
  void setSuccess() => viewState.value = ViewState.success;

  /// Establece el estado como [ViewState.error] con un mensaje genérico.
  /// Usar cuando el error no proviene de una excepción tipada.
  void setErrorMessage(String message) {
    viewState.value = ViewState.error;
    errorMessage.value = message;
  }

  // ── Manejo de excepciones ──────────────────────────────────────────────────

  /// Punto de entrada único para el manejo de errores en los bloques `catch`.
  ///
  /// Interpreta el tipo de excepción envuelta en [DioException.error] por
  /// `ErrorInterceptor` y delega al método de estado correspondiente.
  /// Si la excepción no es reconocida, delega a [setUnknownError].
  void resolveException(Object e, StackTrace s) {
    if (e is DioException && e.error != null) {
      final appEx = e.error;
      switch (appEx) {
        case NetworkException():
          setErrorMessage(appEx.message);
        case ValidationException():
          viewState.value = ViewState.error;
          errorMessage.value = appEx.message;
          if (appEx.fieldErrors.isNotEmpty) {
            errors.value = appEx.fieldErrors.map((k, v) => MapEntry(k, [v]));
          }
        case AuthException():
          setErrorMessage(appEx.message);
        case ServerException():
          setErrorMessage(appEx.message);
        default:
          setUnknownError(e, s);
      }
    } else {
      setUnknownError(e, s);
    }
  }

  /// Registra una excepción no controlada y muestra un mensaje genérico al usuario.
  ///
  /// Solo imprime en consola en modo debug. No expone detalles técnicos en la UI
  /// para evitar fugas de información sensible.
  void setUnknownError(Object error, StackTrace stackTrace) {
    debugPrint('Unhandled exception: $error');
    debugPrint('$stackTrace');
    setErrorMessage('Ocurrió un error inesperado');
  }

  /// Limpia errores y restablece [viewState] a [ViewState.idle].
  /// Es llamado automáticamente al inicio de cada [runGuarded].
  void clearErrors() {
    viewState.value = ViewState.idle;
    errorMessage.value = '';
    errors.clear();
  }

  // ── Operaciones guardadas ──────────────────────────────────────────────────

  /// Ejecuta [action] dentro de un ciclo estándar de carga y manejo de errores.
  ///
  /// Internamente llama a [clearErrors] y [setLoading] antes de ejecutar la acción,
  /// y captura cualquier excepción delegando a [resolveException]. Elimina el
  /// boilerplate repetitivo de `clearErrors → setLoading → try/catch`.
  ///
  /// **Importante:** siempre llamar a [setSuccess] al final de [action] si la
  /// operación concluye con éxito, ya que [runGuarded] no lo hace automáticamente.
  ///
  /// ```dart
  /// Future<void> submit() async {
  ///   await runGuarded(() async {
  ///     await _repository.save(formData);
  ///     setSuccess(); // ← obligatorio para indicar éxito
  ///   });
  /// }
  /// ```
  Future<void> runGuarded(Future<void> Function() action) async {
    clearErrors();
    setLoading();
    try {
      await action();
    } catch (e, s) {
      resolveException(e, s);
    }
  }

  // ── Helpers de validación ──────────────────────────────────────────────────

  /// Retorna el primer mensaje de error asociado a [key], o `null` si no existe.
  /// Equivalente al helper `@error('campo')` de Blade en Laravel.
  String? error(String key) => errors[key]?.firstOrNull;

  /// Retorna `true` si existe al menos un error asociado al campo [key].
  bool hasErrorFor(String key) => errors[key]?.isNotEmpty ?? false;

  // ── Getters de estado ──────────────────────────────────────────────────────

  /// `true` si [viewState] es [ViewState.loading].
  bool get isLoading => viewState.value == ViewState.loading;

  /// `true` si [viewState] es [ViewState.error].
  bool get hasError => viewState.value == ViewState.error;

  /// `true` si [viewState] es [ViewState.success].
  bool get isSuccess => viewState.value == ViewState.success;

  /// Obtiene el texto de un [TextEditingController] de forma segura.
  ///
  /// Retorna el contenido del [controller] o [defaultValue] si:
  /// - [controller] es `null`
  /// - El texto está vacío (incluso tras aplicar [trim])
  ///
  /// ### Parámetros
  /// - [controller] — Controlador del campo de texto. Puede ser `null`.
  /// - [defaultValue] — Valor de retorno cuando el texto no está disponible. Por defecto `''`.
  /// - [trim] — Si es `true` (default), elimina espacios al inicio y al final.
  ///
  /// ### Ejemplo
  /// ```dart
  /// final nombre = getText(nombreController, defaultValue: 'Sin nombre');
  /// final raw    = getText(controller, trim: false, defaultValue: 'N/A');
  /// ```
  String getText(
    TextEditingController? controller, {
    String defaultValue = '',
    bool trim = true,
  }) {
    final text = trim
        ? (controller?.text.trim() ?? '')
        : (controller?.text ?? '');
    return text.isEmpty ? defaultValue : text;
  }
}