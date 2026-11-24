import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../core/network/api_exception.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();

  List<ProductModel> _items = [];
  ProductModel? _selected;
  bool _loading = false;
  String? _error;

  List<ProductModel> get items => _items;
  ProductModel? get selected => _selected;
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

  Future<void> fetchById(int id) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _selected = await _service.getById(id);
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Terjadi kesalahan';
    }
    _loading = false;
    notifyListeners();
  }

  void clearSelected() {
    _selected = null;
    notifyListeners();
  }

  Future<bool> create({
    required String name,
    required int categoryId,
    required double price,
    String? description,
    int stock = 0,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      final p = await _service.create(
        name: name,
        categoryId: categoryId,
        price: price,
        description: description,
        stock: stock,
        imageBytes: imageBytes,
        imageName: imageName,
      );
      _items = [..._items, p];
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
    int? categoryId,
    double? price,
    String? description,
    int? stock,
    Uint8List? imageBytes,
    String? imageName,
    bool clearImage = false,
  }) async {
    try {
      final p = await _service.update(
        id,
        name: name,
        categoryId: categoryId,
        price: price,
        description: description,
        stock: stock,
        imageBytes: imageBytes,
        imageName: imageName,
        clearImage: clearImage,
      );
      final idx = _items.indexWhere((x) => x.id == id);
      if (idx != -1) _items[idx] = p;
      if (_selected?.id == id) _selected = p;
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
      if (_selected?.id == id) _selected = null;
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
}