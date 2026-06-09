import 'dart:convert';
import 'dart:typed_data'; 
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; 
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  final _storage = const FlutterSecureStorage();

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  // URL utama katalog produk
  final String baseUrl = 'http://192.168.1.3:8001/api/products';

  // 1. READ: Ambil data katalog dari Laravel
  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    final token = await _storage.read(key: 'auth_token'); 

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      print("========== RAMDET DEBUG CATALOG ==========");
      print("Status Code Respon Server: ${response.statusCode}");
      

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> extractedData = responseData['data'] ?? []; 
        _products = extractedData.map((item) => Product.fromJson(item)).toList();

        // REVISI OTOMATIS: Jika user dalam kondisi login, langsung sinkronkan status favoritnya
        if (token != null) {
          await fetchFavorites();
        }
      } else {
        _setDummyData();
      }
    } catch (error) {
      print("Eror fatal koneksi: $error. Mengaktifkan cadangan dummy.");
      _setDummyData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setDummyData() {
    _products = [
      Product(id: 1, name: 'Velg Enkei Tuning R17', price: 7500000, description: 'Velg original sporty ring 17 cocok untuk mobil sedan.', category: 'mobil'),
      Product(id: 2, name: 'Knalpot Racing Akrapovic', price: 3500000, description: 'Suara ngebass adem, meningkatkan performa mesin.', category: 'motor'),
    ];
  }

  // 2. CREATE: Menambah Produk Baru via Multipart File Gambar Fisik
  Future<bool> addProduct(String token, String name, int price, String description, String category, {Uint8List? imageBytes}) async {
    _isLoading = true;
    notifyListeners();

    try {
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      request.headers.addAll({
        "Authorization": "Bearer $token", 
        "Accept": "application/json",
      });

      request.fields['name'] = name;
      request.fields['price'] = price.toString();
      request.fields['description'] = description;
      request.fields['category'] = category;

      if (imageBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'image', 
          imageBytes,
          filename: 'sparepart_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ));
      }

      var streamedResponse = await request.send();
      if (streamedResponse.statusCode == 201 || streamedResponse.statusCode == 200) {
        await fetchProducts(); 
        return true;
      }
      return false;
    } catch (error) {
      print("Gagal tambah produk: $error");
      return false; 
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. UPDATE: Mengedit Data Produk Lama Berupa File Multipart
  Future<bool> updateProduct(String token, int id, String name, int price, String description, String category, {Uint8List? imageBytes}) async {
    _isLoading = true;
    notifyListeners();

    final index = _products.indexWhere((product) => product.id == id);
    bool currentFavoriteStatus = false;
    if (index >= 0) {
      currentFavoriteStatus = _products[index].isFavorite;
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/$id'));
      request.headers.addAll({
        "Authorization": "Bearer $token", 
        "Accept": "application/json",
      });

      request.fields['_method'] = 'PUT'; 
      request.fields['name'] = name;
      request.fields['price'] = price.toString();
      request.fields['description'] = description;
      request.fields['category'] = category;

      if (imageBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'edit_sparepart_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ));
      }

      var streamedResponse = await request.send();
      if (streamedResponse.statusCode == 200) {
        await fetchProducts();
        final newIndex = _products.indexWhere((product) => product.id == id);
        if (newIndex >= 0) {
          _products[newIndex].isFavorite = currentFavoriteStatus;
        }
        return true;
      }
      return false;
    } catch (error) {
      print("Gagal update produk: $error");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 4. DELETE: Menghapus Produk dari Katalog Berproteksi Token Admin
  Future<bool> deleteProduct(String token, int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          "Authorization": "Bearer $token", 
          "Accept": "application/json",
        },
      );
      if (response.statusCode == 200) {
        await fetchProducts();
        return true;
      }
      return false;
    } catch (error) {
      print("Gagal hapus produk: $error");
      return false; 
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 5. REVISI BARU - FETCH FAVORITES: Ambil daftar favorit milik user dari server Laravel
  Future<void> fetchFavorites() async {
    final token = await _storage.read(key: 'auth_token');
    
    // Jika tidak login / token kosong, matikan semua status favorit di lokal
    if (token == null) {
      for (var product in _products) {
        product.isFavorite = false;
      }
      notifyListeners();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.3:8001/api/favorites'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> favoriteData = responseData['data'] ?? [];
        
        // Ambil semua ID produk yang masuk daftar favorit di database Laravel
        final List<int> favIds = favoriteData.map((item) => item['id'] as int).toList();

        // COCOKKAN DATA: Nyalakan isFavorite jika ID produknya ada di daftar database
        for (var product in _products) {
          product.isFavorite = favIds.contains(product.id);
        }
        notifyListeners();
      }
    } catch (error) {
      print("Gagal mengambil data favorit dari API: $error");
    }
  }

  // 6. REVISI TOTAL - TOGGLE FAVORITE: Kirim data secara permanen ke API Laravel
  Future<bool> toggleFavorite(int id) async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) return false;

    final index = _products.indexWhere((prod) => prod.id == id);
    if (index < 0) return false;

    // Langkah Kritis (Optimistic Update): Ubah dulu di lokal agar UI terasa instan tanpa delay koneksi
    final originalStatus = _products[index].isFavorite;
    _products[index].isFavorite = !originalStatus;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.3:8001/api/favorites/toggle'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'product_id': id}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true; 
      } else {
        // ROLLBACK: Kembalikan ke status semula kalau server mengembalikan status gagal
        _products[index].isFavorite = originalStatus;
        notifyListeners();
        return false;
      }
    } catch (error) {
      print("Gagal melakukan sinkronisasi toggle favorite: $error");
      // ROLLBACK: Kembalikan ke status semula jika terjadi kendala koneksi internet/server mati
      _products[index].isFavorite = originalStatus;
      notifyListeners();
      return false;
    }
  }
}