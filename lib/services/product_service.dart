import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/product_model.dart';

class ProductService {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<ProductModel>> getAll() async {
    try {
      final res = await _dio.get(ApiConstants.products);
      final data = res.data as Map<String, dynamic>;
      final list = data['data'] as List;
      return list
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiClient.handleError(e);
    }
  }

  Future<ProductModel> getById(int id) async {
    try {
      final res = await _dio.get('${ApiConstants.products}/$id');
      final data = res.data as Map<String, dynamic>;
      return ProductModel.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.handleError(e);
    }
  }

  Future<ProductModel> create({
    required String name,
    required int categoryId,
    required double price,
    String? description,
    int stock = 0,
    Uint8List? imageBytes,
    String? imageName,
    String? imageUrl,
    String? imagePublicId,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'category_id': categoryId,
        'price': price,
        'stock': stock,
        'description': ?(description != null && description.isNotEmpty
            ? description
            : null),
        'image_url': ?imageUrl,
        'image_public_id': ?imagePublicId,
        if (imageBytes != null)
          'image': MultipartFile.fromBytes(
            imageBytes,
            filename: imageName ?? 'image.jpg',
          ),
      });
      final res = await _dio.post(ApiConstants.products, data: formData);
      final data = res.data as Map<String, dynamic>;
      return ProductModel.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.handleError(e);
    }
  }

  Future<ProductModel> update(
    int id, {
    String? name,
    int? categoryId,
    double? price,
    String? description,
    int? stock,
    Uint8List? imageBytes,
    String? imageName,
    String? imageUrl,
    String? imagePublicId,
    bool clearImage = false,
  }) async {
    try {
      final map = <String, dynamic>{};
      if (name != null) map['name'] = name;
      if (categoryId != null) map['category_id'] = categoryId;
      if (price != null) map['price'] = price;
      if (description != null) map['description'] = description;
      if (stock != null) map['stock'] = stock;
      if (imageUrl != null) map['image_url'] = imageUrl;
      if (imagePublicId != null) map['image_public_id'] = imagePublicId;
      if (clearImage) {
        map['image_url'] = '';
        map['image_public_id'] = '';
      }
      if (imageBytes != null) {
        map['image'] = MultipartFile.fromBytes(
          imageBytes,
          filename: imageName ?? 'image.jpg',
        );
      }
      final formData = FormData.fromMap(map);
      final res = await _dio.put(
        '${ApiConstants.products}/$id',
        data: formData,
      );
      final data = res.data as Map<String, dynamic>;
      return ProductModel.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.handleError(e);
    }
  }

  Future<void> delete(int id) async {
    try {
      await _dio.delete('${ApiConstants.products}/$id');
    } on DioException catch (e) {
      throw ApiClient.handleError(e);
    }
  }
}
