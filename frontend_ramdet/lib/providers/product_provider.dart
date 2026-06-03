import 'dart:convert';
import 'dart:typed_data'; // WAJIB DIIMPORT agar Uint8List dikenali
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  // Sesuaikan URL ini dengan path project Laragon lokalmu
  final String baseUrl = 'http://127.0.0.1:8001/api/products';

  // 1. READ: Ambil data katalog dari Laravel
  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> extractedData = jsonDecode(response.body);
        _products = extractedData.map((item) => Product.fromJson(item)).toList();
      }
    } catch (error) {
      print("Error terdeteksi: $error. Mengaktifkan data dummy lokal.");
      
      // REVISI: Tambahkan properti category agar filter ChoiceChip depan langsung aktif mendeteksi
      _products = [
        Product(
          id: 1, 
          name: 'Velg Enkei Tuning R17', 
          price: 7500000, 
          description: 'Velg original sporty ring 17 cocok untuk mobil sedan.',
          category: 'Mobil', // Set kategori default
        ),
        Product(
          id: 2, 
          name: 'Knalpot Racing Akrapovic', 
          price: 3500000, 
          description: 'Suara ngebass adem, meningkatkan performa mesin.',
          category: 'Motor', // Set kategori default
        ),
      ];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. CREATE: Menambah Produk Baru ke Katalog
  Future<bool> addProduct(String name, int price, String description, String category, {Uint8List? imageBytes}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'name': name,
          'price': price,
          'description': description,
          'category': category,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchProducts(); 
        return true;
      }
      return false;
    } catch (error) {
      print("Koneksi API Gagal ($error). Mengalihkan penyimpanan ke dummy lokal beserta gambar.");

      final newProduct = Product(
        id: DateTime.now().millisecondsSinceEpoch, 
        name: name,
        price: price,
        description: description,
        category: category,
        imageBytes: imageBytes, 
      );

      _products.insert(0, newProduct);
      return true; 
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. UPDATE: Mengedit Data Produk Lama dengan Pengaman Status Favorit User
  Future<bool> updateProduct(int id, String name, int price, String description, String category, {Uint8List? imageBytes}) async {
    _isLoading = true;
    notifyListeners();

    // ─── SKEMA REVISI PENGAMANTAN STATUS FAVORIT USER ───
    // Cari indeks produk lama di memori dan amankan status favorit aslinya
    final index = _products.indexWhere((product) => product.id == id);
    bool currentFavoriteStatus = false;
    if (index >= 0) {
      currentFavoriteStatus = _products[index].isFavorite;
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'name': name,
          'price': price,
          'description': description,
          'category': category,
        }),
      );

      if (response.statusCode == 200) {
        // Ambil list produk terbaru yang ditarik dari database online
        await fetchProducts();
        
        // Kembalikan status favorit ke item baru hasil fetch agar tidak kembali menjadi 'false'
        final newIndex = _products.indexWhere((product) => product.id == id);
        if (newIndex >= 0) {
          _products[newIndex].isFavorite = currentFavoriteStatus;
        }
        return true;
      }
      return false;
    } catch (error) {
      print("Koneksi API Gagal ($error). Mengubah data di dummy lokal.");

      // Jalur Fallback Lokal: masukkan status favorit lama agar tidak reset menjadi false
      if (index >= 0) {
        _products[index] = Product(
          id: id,
          name: name,
          price: price,
          description: description,
          category: category,
          isFavorite: currentFavoriteStatus, // STATUS FAVORIT TETAP TERKUNCI AMAN
          imageBytes: imageBytes ?? _products[index].imageBytes, 
          image: _products[index].image,
        );
      }
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 4. DELETE: Menghapus Produk dari Katalog
  Future<bool> deleteProduct(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      if (response.statusCode == 200) {
        await fetchProducts();
        return true;
      }
      return false;
    } catch (error) {
      print("Koneksi API Gagal ($error). Menghapus data dari dummy lokal.");

      // Hapus langsung dari list di memori lokal
      _products.removeWhere((product) => product.id == id);
      return true; 
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 5. FAVORITE: Mengubah Status Favorit Produk di Memori Lokal
  void toggleFavorite(int id) {
    final index = _products.indexWhere((prod) => prod.id == id);
    if (index >= 0) {
      _products[index].isFavorite = !_products[index].isFavorite;
      notifyListeners(); // Memicu UI Dashboard & Halaman Favorit ter-render instan
    }
  }
}