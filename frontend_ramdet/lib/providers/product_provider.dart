import 'dart:convert';
import 'dart:typed_data'; 
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; 
import 'package:http_parser/http_parser.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  final _storage = const FlutterSecureStorage();

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  // URL utama sesuai IP laptop kamu yang valid
  final String baseUrl = 'http://192.168.100.62:8001/api'; 

  // 1. READ: Ambil data katalog dari Laravel
  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    final token = await _storage.read(key: 'auth_token'); 

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
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

        if (token != null) {
          await fetchFavorites();
        }
      } else {
        _setDummyData();
      }
    } catch (error) {
      print("Eror fatal koneksi: $error. Mengaktifkan cadangan dummy.");
      _setDummyData();
    } finally { // <-- FIX: Huruf 'l' sudah double, penutup jalan sempurna
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
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/products'));
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
          contentType: MediaType('image', 'jpeg'),
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
    } finally { // <-- FIX: Perbaikan typo
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. UPDATE: Mengedit Data Produk Lama Berupa File Multipart
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
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/products/$id'));
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
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      var streamedResponse = await request.send();
      if (streamedResponse.statusCode == 200) {
        // 1. Tarik ulang data katalog dari MySQL Laragon agar nama file image yang baru masuk ke state
        await fetchProducts();
        
        // 2. SINKRONISASI REAL-TIME: Ambil ulang status favorit lama agar tidak reset ke false
        final newIndex = _products.indexWhere((product) => product.id == id);
        if (newIndex >= 0) {
          _products[newIndex].isFavorite = currentFavoriteStatus;
          
          // REVISI METODE: Jika membawa gambar baru, paksa cache Image.network untuk melakukan refresh visual
          if (imageBytes != null) {
            imageCache.clearLiveImages();
            imageCache.clear();
          }
        }
        
        notifyListeners(); // Sentak perubahan visual ke UI Catalog & Admin Dashboard secara instan
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
        Uri.parse('$baseUrl/products/$id'),
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
    } finally { // <-- FIX: Perbaikan typo
      _isLoading = false;
      notifyListeners();
    }
  }

  // 5. FETCH FAVORITES: Ambil daftar favorit milik user dari server Laravel
  Future<void> fetchFavorites() async {
    final token = await _storage.read(key: 'auth_token');
    
    if (token == null) {
      for (var product in _products) {
        product.isFavorite = false;
      }
      notifyListeners();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/favorites'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> favoriteData = responseData['data'] ?? [];
        
        final List<int> favIds = favoriteData.map((item) => item['id'] as int).toList();

        for (var product in _products) {
          product.isFavorite = favIds.contains(product.id);
        }
        notifyListeners();
      }
    } catch (error) {
      print("Gagal mengambil data favorit dari API: $error");
    }
  }

  // 6. TOGGLE FAVORITE: Kirim data secara permanen ke API Laravel
  Future<bool> toggleFavorite(int id) async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) return false;

    final index = _products.indexWhere((prod) => prod.id == id);
    if (index < 0) return false;

    final originalStatus = _products[index].isFavorite;
    _products[index].isFavorite = !originalStatus;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/favorites/toggle'),
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
        _products[index].isFavorite = originalStatus;
        notifyListeners();
        return false;
      }
    } catch (error) {
      print("Gagal melakukan sinkronisasi toggle favorite: $error");
      _products[index].isFavorite = originalStatus;
      notifyListeners();
      return false;
    }
  }
}