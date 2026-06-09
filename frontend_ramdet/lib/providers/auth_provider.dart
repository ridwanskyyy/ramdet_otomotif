import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final String baseUrl = 'http://192.168.1.3:8001/api';

  // Taruh fungsi ini di dalam class AuthProvider kamu, di bawah variabel baseUrl
String getFullImageUrl(String? path) {
  if (path == null || path.isEmpty) return 'https://via.placeholder.com/150';
  
  // Memotong kata '/api' dari baseUrl milikmu agar tersisa IP host utama 'http://10.0.2.2:8000'
  final rootUrl = baseUrl.replaceAll('/api', '');
  return '$rootUrl/$path';
}

  bool _isLoading = false;
  String? _token;
  String? _role; 

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  
  String? get role => _role;
  bool get isAdmin => _role == 'admin';
  String? get token => _token;

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
  Future<bool> register({
  required String name,
  required String email,
  required String password,
  required String phone,
  required String address,
}) async {
  _isLoading = true;
  notifyListeners(); 

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'phone_number': phone,
        'address': address
      }),
    );

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

Future<bool> updateProfileMultipart({
  required String name,
  required String email,
  required String phone,
  required String address,
  required String membershipStatus,
  XFile? imageFile,
}) async {
  _isLoading = true;
  notifyListeners();
  _token = await _storage.read(key: 'auth_token');

  try {
    // REVISI: Tembak langsung ke endpoint POST murni /user/update
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/user/update'));
    
    request.headers.addAll({
      'Authorization': 'Bearer $_token',
      'Accept': 'application/json',
    });

    // Masukkan data field teks langsung (Hapus baris request.fields['_method'] = 'PUT')
    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['phone_number'] = phone;
    request.fields['address'] = address;
    request.fields['membership_status'] = membershipStatus;

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profile_photo',
        imageFile.path,
      ));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return true;
    }
    debugPrint('Multipart Error Response: ${response.body}');
    return false;
  } catch (e) {
    debugPrint('Multipart Exception: $e');
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
  Future<Map<String, dynamic>> changePassword({
  required String oldPassword,
  required String newPassword,
}) async {
  _isLoading = true;
  notifyListeners();
  _token = await _storage.read(key: 'auth_token');

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/user/change-password'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'old_password': oldPassword,
        'new_password': newPassword,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'message': data['message']};
    }
    return {'success': false, 'message': data['message'] ?? 'Gagal mengubah password.'};
  } catch (e) {
    debugPrint('Password Error: $e');
    return {'success': false, 'message': 'Terjadi kesalahan koneksi ke server Laragon.'};
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
}