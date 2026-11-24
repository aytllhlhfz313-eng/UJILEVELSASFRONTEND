import 'package:dio/dio.dart';
import '../core/network/api_client.dart';

import '../core/constants/api_constants.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = ApiClient.instance.dio;

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String role = 'user',
  }) async {
    try {
      final res = await _dio.post(ApiConstants.register, data: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiClient.handleError(e);
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post(ApiConstants.login, data: {
        'email': email,
        'password': password,
      });
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiClient.handleError(e);
    }
  }

  Future<UserModel> me() async {
    try {
      final res = await _dio.get(ApiConstants.me);
      final data = res.data as Map<String, dynamic>;
      return UserModel.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.handleError(e);
    }
  }
}