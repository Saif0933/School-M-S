import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

class ApiClient {
  final Dio dio;

  static String get defaultBaseUrl {
    if (kIsWeb) return 'http://localhost:5000/api';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:5000/api';
    } catch (_) {}
    return 'http://localhost:5000/api';
  }

  ApiClient({String? baseUrl}) : dio = Dio(
    BaseOptions(
      baseUrl: baseUrl ?? defaultBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            options.headers['Cookie'] = 'token=$token'; // Cookie fallback for Express
          }
          return handler.next(options);
        },
        onResponse: (response, handler) async {
          // If login or onboard response returns a token, we save it
          if (response.data is Map && response.data['success'] == true) {
            final data = response.data['data'];
            if (data is Map && data.containsKey('token')) {
              final token = data['token'];
              if (token != null) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('token', token.toString());
              }
            }
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          debugPrint('API Error [${e.response?.statusCode}]: ${e.response?.data ?? e.message}');
          return handler.next(e);
        },
      ),
    );
  }
}
