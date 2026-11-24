import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/category_model.dart';

class CategoryService {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<CategoryModel>> getAll() async {
    try {
      final res = await _dio.get(ApiConstants.categories);
      final data = res.data as Map<String, dynamic>;
      final list = data['data'] as List;
      return list.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiClient.handleError(e);
    }
  }

  Future<CategoryModel> getById(int id) async {
    try {
      final res = await _dio.get('${ApiConstants.categories}/$id');
      final data = res.data as Map<String, dynamic>;
      return CategoryModel.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.handleError(e);
    }
  }

  Future<CategoryModel> create({
    required String name,
    String? description,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'description': ?(description != null && description.isNotEmpty ? description : null),
        if (imageBytes != null)
          'image': MultipartFile.fromBytes(imageBytes, filename: imageName ?? 'image.jpg'),
      });
      final res = await _dio.post(ApiConstants.categories, data: formData);
      final data = res.data as Map<String, dynamic>;
      return CategoryModel.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.handleError(e);
    }
  }

  Future<CategoryModel> update(
    int id, {
    String? name,
    String? description,
    Uint8List? imageBytes,
    String? imageName,
    bool clearImage = false,
  }) async {
    try {
      final map = <String, dynamic>{};
      if (name != null) map['name'] = name;
      if (description != null) map['description'] = description;
      if (clearImage) map['clear_image'] = true;
      if (imageBytes != null) {
        map['image'] = MultipartFile.fromBytes(imageBytes, filename: imageName ?? 'image.jpg');
      }
      final formData = FormData.fromMap(map);
      final res = await _dio.put('${ApiConstants.categories}/$id', data: formData);
      final data = res.data as Map<String, dynamic>;
      return CategoryModel.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.handleError(e);
    }
  }

  Future<void> delete(int id) async {
    try {
      await _dio.delete('${ApiConstants.categories}/$id');
    } on DioException catch (e) {
      throw ApiClient.handleError(e);
    }
  }
}