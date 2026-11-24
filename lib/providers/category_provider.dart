import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';
import '../core/network/api_exception.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _service = CategoryService();

  List<CategoryModel> _items = [];
  bool _loading = false;
  String? _error;

  List<CategoryModel> get items => _items;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchAll() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _service.getAll();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Terjadi kesalahan';
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> create({
    required String name,
    String? description,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      final c = await _service.create(
        name: name,
        description: description,
        imageBytes: imageBytes,
        imageName: imageName,
      );
      _items = [..._items, c];
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Terjadi kesalahan';
      notifyListeners();
      return false;
    }
  }

  Future<bool> update(
    int id, {
    String? name,
    String? description,
    Uint8List? imageBytes,
    String? imageName,
    bool clearImage = false,
  }) async {
    try {
      final c = await _service.update(
        id,
        name: name,
        description: description,
        imageBytes: imageBytes,
        imageName: imageName,
        clearImage: clearImage,
      );
      final idx = _items.indexWhere((x) => x.id == id);
      if (idx != -1) _items[idx] = c;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Terjadi kesalahan';
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _service.delete(id);
      _items.removeWhere((x) => x.id == id);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Terjadi kesalahan';
      notifyListeners();
      return false;
    }
  }

  CategoryModel? findById(int id) {
    try {
      return _items.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}