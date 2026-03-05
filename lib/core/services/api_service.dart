import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;

  ApiService() : _dio = Dio() {
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
  }

  Future<Response> get(String url, {Map<String, dynamic>? params}) async {
    try {
      return await _dio.get(url, queryParameters: params);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout');
      case DioExceptionType.connectionError:
        return Exception('No internet connection');
      default:
        return Exception(e.message ?? 'Something went wrong');
    }
  }
}
