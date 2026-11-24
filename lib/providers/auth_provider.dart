import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../core/storage/token_storage.dart';
import '../core/network/api_exception.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  UserModel? _user;
  bool _loading = false;
  String? _error;

  UserModel? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  Future<void> tryAutoLogin() async {
    _loading = true;
    notifyListeners();
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        _user = null;
      } else {
        _user = await _service.me();
      }
    } catch (_) {
      await TokenStorage.clear();
      _user = null;
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _service.login(email: email, password: password);
      final data = res['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final userJson = data['user'] as Map<String, dynamic>;
      await TokenStorage.saveToken(token);
      await TokenStorage.saveUser(jsonEncode(userJson));
      _user = UserModel.fromJson(userJson);
      _loading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Terjadi kesalahan';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
    String name,
    String email,
    String password, [
    String role = 'user',
  ]) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _service.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      _loading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Terjadi kesalahan';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await TokenStorage.clear();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}