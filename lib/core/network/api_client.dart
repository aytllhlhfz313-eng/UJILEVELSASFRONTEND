import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient._() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {'Accept': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenStorage.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));
  }

  static final ApiClient instance = ApiClient._();
  late final Dio _dio;

  Dio get dio => _dio;

  static ApiException handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return ApiException('Koneksi ke server timeout. Periksa koneksi internet Anda.');
    }
    if (e.type == DioExceptionType.connectionError) {
      return ApiException('Tidak dapat terhubung ke server. Pastikan server backend aktif.');
    }

    final res = e.response;
    if (res != null) {
      final data = res.data;
      String message = 'Terjadi kesalahan pada server';
      List<Map<String, dynamic>>? errors;
      if (data is Map) {
        message = (data['message'] as String?) ?? message;
        final err = data['errors'];
        if (err is List) {
          errors = err
              .map((x) => x is Map ? Map<String, dynamic>.from(x) : <String, dynamic>{})
              .toList();
        }
      }
      if (res.statusCode == 401) {
        // token kadaluarsa / tidak valid
      }
      return ApiException(message, statusCode: res.statusCode, errors: errors);
    }
    return ApiException(e.message ?? 'Terjadi kesalahan');
  }
}