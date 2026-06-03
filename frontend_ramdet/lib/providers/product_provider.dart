import 'dart:convert';
import 'dart:typed_data'; 
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Pastikan package ini aktif
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  final _storage = const FlutterSecureStorage();

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  // REVISI: Mengamankan alamat IP jembatan emulator LDPlayer ke port 8001 Laragon kalian
  final String baseUrl = 'http://192.168.100.160:8001/api/products';

  // 1. READ: Ambil data katalog dari Laravel
  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    // Mengambil token untuk jaga-jaga jika rute index di api.php dimasukkan ke grup auth oleh timmu
    final token = await _storage.read(key: 'auth_token'); 

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      // INDIKATOR SIDAK DATA (Cek angka ini di Debug Console VS Code saat aplikasi dibuka)
      print("========== RAMDET DEBUG CATALOG ==========");
      print("Status Code Respon Server: ${response.statusCode}");
      

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        // REVISI: Ambil dari key ['data'] hasil kembalian sendResponse Controller Laravel
        final List<dynamic> extractedData = responseData['data'] ?? []; 
        _products = extractedData.map((item) => Product.fromJson(item)).toList();
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

      request.fields['_method'] = 'PUT'; // Mengelabui rute spoofing PUT Laravel
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

  // 5. FAVORITE: Mengubah Status Favorit
  void toggleFavorite(int id) {
    final index = _products.indexWhere((prod) => prod.id == id);
    if (index >= 0) {
      _products[index].isFavorite = !_products[index].isFavorite;
      notifyListeners(); 
    }
  }
}