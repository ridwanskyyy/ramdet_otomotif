import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final String baseUrl = 'http://192.168.100.160:8000/api';// Jika running di Chrome / Web Browser
  // final String baseUrl = 'http://192.168.100.62:8000/api'; // Sesuaikan IP jika menggunakan HP fisik / Emulator

  bool _isLoading = false;
  String? _token;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  // MENGECEK KETERSEDIAAN TOKEN DI STORAGE (UNTUK SPLASH SCREEN)
  Future<bool> checkTokenValidity() async {
    _token = await _storage.read(key: 'auth_token');
    if (_token != null) {
      notifyListeners();
      return true;
    }
    return false;
  }

  // PROSES LOGIN
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Memetakan sesuai struktur response {"success": true, "data": {"access_token": "..."}}
        _token = data['data']['access_token'];
        await _storage.write(key: 'auth_token', value: _token);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login Error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // PROSES REGISTER
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners(); 

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true; 
      }
      return false;
    } catch (e) {
      debugPrint('Register Error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // AMBIL DATA PROFIL USER Active
  Future<Map<String, dynamic>?> getProfile() async {
    _token = await _storage.read(key: 'auth_token');
    if (_token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Authorization': 'Bearer $_token', 
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        // Jika token di server expired / tidak valid, langsung kick ke log out lokal
        await logout(); 
      }
      return null;
    } catch (e) {
      debugPrint('Profile Error: $e');
      return null;
    }
  }

  // UPDATE DATA PROFIL USER (RAW JSON - PUT)
  Future<bool> updateProfile(String name, String phone, String bio) async {
    _isLoading = true;
    notifyListeners();
    _token = await _storage.read(key: 'auth_token');

    try {
      final response = await http.put( 
        Uri.parse('$baseUrl/user'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'name': name, 'phone': phone, 'bio': bio}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Update Profile Error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // PROSES LOGOUT
  Future<void> logout() async {
    _token = await _storage.read(key: 'auth_token');
    if (_token != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Authorization': 'Bearer $_token',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('Logout Backend Error (Tetap menghapus sesi lokal): $e');
      }
    }
    
    // Sesi lokal wajib dihapus bersih tanpa memedulikan kegagalan koneksi server
    _token = null;
    await _storage.delete(key: 'auth_token'); 
    notifyListeners();
  }
}