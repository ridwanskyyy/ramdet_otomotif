import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final String baseUrl = 'http://172.20.10.6:8000/api';

  bool _isLoading = false;
  String? _token;
  String? _role; // TAMBAHAN: Menyimpan status role aktif ('user' atau 'admin')

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  
  // TAMBAHAN: Getter global untuk mengecek status role di halaman mana pun
  String? get role => _role;
  bool get isAdmin => _role == 'admin';

  // MENGECEK KETERSEDIAAN TOKEN & ROLE DI STORAGE (UNTUK SPLASH SCREEN)
  Future<bool> checkTokenValidity() async {
    _token = await _storage.read(key: 'auth_token');
    _role = await _storage.read(key: 'user_role'); // Ambil data role lama jika ada
    if (_token != null) {
      notifyListeners();
      return true;
    }
    return false;
  }

  // PROSES LOGIN (Menangkap Token sekaligus Role dari Laravel)
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
        
        // 1. Ambil token dan simpan
        _token = data['data']['access_token'];
        await _storage.write(key: 'auth_token', value: _token);
        
        // 2. Ekstrak Role langsung dari response login (jika backend mengirimkan data user)
        // Mendukung multi-nesting response Laravel
        final userObj = data['data']['user'] ?? data['user'];
        if (userObj != null) {
          _role = userObj['role'] ?? 'user';
          await _storage.write(key: 'user_role', value: _role);
        }
        
        notifyListeners();
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

  // PROSES REGISTER (Strict: Tanpa parameter role, backend wajib auto-set ke 'user')
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
        // Sesuai permintaan, form register murni kirim data user biasa.
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

  // AMBIL DATA PROFIL USER ACTIVE (Sekaligus Sync Ulang Role Terbaru)
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
        final userData = jsonDecode(response.body);
        
        // Sinkronisasi data role terbaru dari database ke aplikasi lokal
        _role = userData['role'] ?? userData['data']?['role'] ?? 'user';
        await _storage.write(key: 'user_role', value: _role);
        
        notifyListeners();
        return userData;
      } else if (response.statusCode == 401) {
        await logout(); 
      }
      return null;
    } catch (e) {
      debugPrint('Profile Error: $e');
      return null;
    }
  }

  // UPDATE DATA PROFIL USER
  Future<bool> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String address,
  }) async {
    _isLoading = true;
    notifyListeners();
    _token = await _storage.read(key: 'auth_token');

    try {
      final response = await http.put( 
        Uri.parse('$baseUrl/user'), 
        headers: {
          if (_token != null) 'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone_number': phone,
          'address': address,
        }),
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

  // PROSES LOGOUT (Bersihkan Token dan Role)
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
        debugPrint('Logout Backend Error: $e');
      }
    }
    
    // Hapus total data sesi lokal
    _token = null;
    _role = null;
    await _storage.delete(key: 'auth_token'); 
    await _storage.delete(key: 'user_role'); 
    notifyListeners();
  }
}