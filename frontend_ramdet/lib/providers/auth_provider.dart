import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final String baseUrl = 'http://192.168.100.62:8000/api'; // Sesuaikan dengan URL Laragon
  
  bool _isLoading = false;
  String? _token;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  // ==========================================
  // 1. FUNGSI LOGIN DENGAN TIMEOUT
  // ==========================================
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        body: {'email': email, 'password': password},
      ).timeout(const Duration(seconds: 10)); // <--- TAMBAHKAN TEPAT DI SINI

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        
        await _storage.write(key: 'auth_token', value: _token);
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Login Error: $e'); // Error timeout akan tercetak di sini
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ==========================================
  // 2. FUNGSI REGISTER DENGAN TIMEOUT
  // ==========================================
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners(); 

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        body: {'name': name, 'email': email, 'password': password},
      ).timeout(const Duration(seconds: 10)); // <--- TAMBAHKAN TEPAT DI SINI

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true; 
      }
    } catch (e) {
      debugPrint('Register Error: $e'); // Error timeout akan tercetak di sini
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
  // ==========================================
  // 3. FUNGSI AMBIL PROFIL (READ)
  // ==========================================
  Future<Map<String, dynamic>?> getProfile() async {
    _token = await _storage.read(key: 'auth_token');
    if (_token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Authorization': 'Bearer $_token', 
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        await logout(); 
      }
    } catch (e) {
      debugPrint('Profile Error: $e');
    }
    return null;
  }

  // ==========================================
  // 4. FUNGSI UPDATE PROFIL
  // ==========================================
  Future<bool> updateProfile(String name, String phone, String bio) async {
    _isLoading = true;
    notifyListeners();
    _token = await _storage.read(key: 'auth_token');

    try {
      final response = await http.post( 
        Uri.parse('$baseUrl/profile/update'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
        body: {'name': name, 'phone': phone, 'bio': bio},
      );

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Update Profile Error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ==========================================
  // 5. FUNGSI LOGOUT
  // ==========================================
  Future<void> logout() async {
    _token = await _storage.read(key: 'auth_token');
    if (_token != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {'Authorization': 'Bearer $_token'},
        );
      } catch (e) {
        debugPrint('Logout Error: $e');
      }
    }
    _token = null;
    await _storage.delete(key: 'auth_token'); 
    notifyListeners();
  }
}