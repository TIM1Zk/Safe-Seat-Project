import 'package:dio/dio.dart';

class ApiService {
  static late Dio _dio;
  static late String _baseUrl;

  // Initialize the API Service with a base URL
  static void init({required String baseUrl}) {
    _baseUrl = baseUrl;
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
  }

  // Get instance of Dio for custom requests
  static Dio get client => _dio;

  // Generic GET request
  static Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Generic POST request
  static Future<Response> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Generic PUT request
  static Future<Response> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Generic DELETE request
  static Future<Response> delete(String path, {dynamic data}) async {
    try {
      final response = await _dio.delete(path, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
