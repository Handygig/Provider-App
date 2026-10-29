import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:provider_app/core/constants/app_endpoints.dart';
import 'package:provider_app/core/services/auth_manager.dart';
import 'package:provider_app/core/services/language_manager.dart';

class DioClient {
  DioClient._();

  static Dio? _instance;

  static Dio create() {
    _instance = Dio(
      BaseOptions(
        baseUrl: AppEndpoints.baseUrl,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: {
          'Accept': 'application/json',
        },
        receiveDataWhenStatusError: true,
      ),
    );

    _instance!.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await AuthManager.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          final langCode = await LanguageManager.getLanguageCode();
          options.headers['locale'] = langCode;

          handler.next(options);
        },
        onResponse: (response, handler) async {
          final token = await AuthManager.getAccessToken();
          final isAuthPath =
              response.requestOptions.path.contains(AppEndpoints.providerLogin) ||
              response.requestOptions.path.contains(AppEndpoints.providerRegister);

          if (token != null && response.statusCode == 401 && !isAuthPath) {
            _handleUnauthorized();
          }
          handler.next(response);
        },
        onError: (DioException e, handler) async {
          final token = await AuthManager.getAccessToken();
          final isAuthPath =
              e.requestOptions.path.contains(AppEndpoints.providerLogin) ||
              e.requestOptions.path.contains(AppEndpoints.providerRegister);

          if (token != null && e.response?.statusCode == 401 && !isAuthPath) {
            _handleUnauthorized();
          }
          handler.next(e);
        },
      ),
      _AppLogInterceptor(),
    ]);

    return _instance!;
  }

  static void updateBaseUrl(String newUrl) {
    if (_instance != null) {
      _instance!.options.baseUrl = newUrl;
      debugPrint('DioClient baseUrl updated to: $newUrl');
    }
  }

  static void _handleUnauthorized() async {
    debugPrint('⚠️ [DioClient] Unauthorized (401) — clearing provider session.');
    await AuthManager.logout();
  }
}

class _AppLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('Dio 🚀 [REQUEST] | ${options.method} | Path: ${options.path}');
    if (options.queryParameters.isNotEmpty) {
      debugPrint('Dio      └─ QueryParameters: ${options.queryParameters}');
    }
    if (options.data != null) {
      debugPrint('Dio      └─ Body: ${options.data}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      'Dio ✅ [RESPONSE] | ${response.statusCode} | Path: ${response.requestOptions.path}',
    );
    if (response.data != null) {
      final responseStr = response.data.toString();
      final truncatedStr = responseStr.length > 800
          ? '${responseStr.substring(0, 800)}... [truncated]'
          : responseStr;
      debugPrint('Dio      └─ Body: $truncatedStr');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      'Dio ❌ [ERROR] | ${err.response?.statusCode ?? 'No Code'} | Path: ${err.requestOptions.path}',
    );
    if (err.response?.data != null) {
      debugPrint('Dio      └─ Response Body: ${err.response?.data}');
    }
    debugPrint('Dio      └─ Message: ${err.message}');
    super.onError(err, handler);
  }
}
