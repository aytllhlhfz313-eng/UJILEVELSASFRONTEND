import 'package:dio/dio.dart';
import '../core/network/api_client.dart';

import '../core/constants/api_constants.dart';

class UploadService {
  final Dio _dio = ApiClient.instance.dio;

  Future<Map<String, String>> uploadImage(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath, filename: imagePath.split('/').last),
      });
      final res = await _dio.post(ApiConstants.upload, data: formData);
      final data = res.data as Map<String, dynamic>;
      final d = data['data'] as Map<String, dynamic>;
      return {
        'url': d['url']?.toString() ?? '',
        'public_id': d['public_id']?.toString() ?? '',
      };
    } on DioException catch (e) {
      throw ApiClient.handleError(e);
    }
  }
}