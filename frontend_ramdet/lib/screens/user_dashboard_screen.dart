import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_ramdet/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import 'user/profile/profile_screen.dart';
import 'admin/user_management_screen.dart'; // IMPORT HALAMAN BARU

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  int _currentIndex = 0;
  String _selectedCategory = 'Semua';
  late Future<Map<String, dynamic>?> _profileFuture;
  
  int _totalUsersCount = 0; // State penampung jumlah user asli dari DB
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _profileFuture = Provider.of<AuthProvider>(context, listen: false).getProfile();
    
    Future.delayed(Duration.zero, () {
      if (mounted) {
        Provider.of<ProductProvider>(context, listen: false).fetchProducts();
        _fetchRealUsersCount(); // Ambil jumlah user riil dari database MySQL
      }
    });
  }

  // Fungsi mengambil jumlah user riil dari database untuk dipajang di kartu statistik
  Future<void> _fetchRealUsersCount() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await http.get(
        // REVISI IP: Menggunakan IP Fisik Laptop agar tidak Timeout
        Uri.parse('http://192.168.100.62:8001/api/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> usersData = responseData['data'] ?? [];
        if (mounted) {
          setState(() {
            _totalUsersCount = usersData.length;
          });
        }
      }
    } catch (e) {
      debugPrint("Gagal mengambil statistik user dari DB: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return FutureBuilder<Map<String, dynamic>?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
            ),
          );
        }

        bool isAdmin = authProvider.isAdmin;

        final List<Widget> pages = [
          _buildCatalogPage(),
          _buildFavoritePage(),
          if (isAdmin) _buildAdminDashboardPage(), 
          const ProfileScreen(),
        ];

        if (_currentIndex >= pages.length) {
          _currentIndex = pages.length - 1;
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                const Icon(Icons.directions_car_filled_outlined, color: Color(0xFFFF6B00), size: 20),
                const SizedBox(width: 6),
                Text(
                  'Ramdet Otomotif',
                  style: TextStyle(
                    color: Colors.brown[800],
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.black87, size: 22),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  _currentIndex == 1 ? Icons.favorite : Icons.favorite_border,
                  color: _currentIndex == 1 ? const Color(0xFFFF6B00) : Colors.black87,
                  size: 22,
                ),
                onPressed: () {
                  setState(() {
                    _currentIndex = 1; 
                  });
                },
              ),
            ],
          ),
          body: pages[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFFEFEFEF),
            selectedItemColor: const Color(0xFFFF6B00),
            unselectedItemColor: Colors.black54,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_rounded),
                label: 'Katalog',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border_rounded),
                label: 'Favorit',
              ),
              if (isAdmin)
                const BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_customize_outlined),
                  label: 'Dashboard',
                ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCatalogPage() {
    final productProvider = Provider.of<ProductProvider>(context);
    
    final products = _selectedCategory == 'Semua'
        ? productProvider.products
        : productProvider.products.where((p) => p.category?.toLowerCase() == _selectedCategory.toLowerCase()).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 24, height: 2, color: const Color(0xFFFF6B00)),
                  const SizedBox(width: 6),
                  const Text('Performa Tanpa Batas', style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Katalog suku cadang orisinil dan\nperforma tinggi untuk kendaraan\nkesayangan Anda.',
                style: TextStyle(color: Colors.black87, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Kategori',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        Row(
          children: ['Semua', 'Mobil', 'Motor'].map((category) {
            final isSelected = _selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFF6B00) : const Color(0xFFEFEFEF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        
        productProvider.isLoading
            ? const Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00))),
              )
            : products.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text('Belum ada produk di kategori ini.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500))),
                  )
                : Column(
                    children: products.map((product) {
                      return _buildProductCard(product, productProvider);
                    }).toList(),
                  ),
                  
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18.0),
          decoration: BoxDecoration(
            color: const Color(0xFF2C3033),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Dapatkan Update Stok Terbaru', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Jadilah yang pertama tahu saat produk incaran Anda masuk gudang.', style: TextStyle(color: Colors.white.withOpacity(0.64), fontSize: 11)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const TextField(
                        style: TextStyle(color: Colors.white, fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'Email Anda',
                          hintStyle: TextStyle(color: Colors.white38, fontSize: 12),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B00),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      minimumSize: const Size(0, 38),
                    ),
                    onPressed: () {},
                    child: const Text('Daftar', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritePage() {
    final productProvider = Provider.of<ProductProvider>(context);
    final favoriteProducts = productProvider.products.where((p) => p.isFavorite).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 16, left: 16, bottom: 16),
            child: Text(
              'Box Produk Favorit Saya',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          Expanded(
            child: favoriteProducts.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada produk favorit.\nKlik ikon hati pada katalog untuk menambahkan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: favoriteProducts.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(favoriteProducts[index], productProvider);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // === HALAMAN: DASHBOARD UTAMA ADMIN ===
  Widget _buildAdminDashboardPage() {
    final productProvider = Provider.of<ProductProvider>(context);
    final products = productProvider.products;

    final int totalProducts = products.length;
    final int lowStockCount = products.where((p) => p.price < 4000000).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF6B00),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        onPressed: () {
          Navigator.of(context).pushNamed('/add-product');
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dashboard Admin',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Admin Live',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildStatCard(
            'Total Pengguna Terdaftar', 
            _totalUsersCount.toString(), 
            'KELOLA USER', 
            Colors.blue,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const UserManagementScreen()),
              ).then((_) => _fetchRealUsersCount()); // Refresh jumlah pas balik
            }
          ),
          const SizedBox(height: 12),
          _buildStatCard('Total Products', totalProducts.toString(), '+12%', Colors.black54),
          const SizedBox(height: 12),
          _buildStatCard('Low Stock', lowStockCount.toString(), 'CRITICAL', Colors.red, isAlert: true),
          
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEFEF),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Colors.black54, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Cari suku cadang atau produk',
                            hintStyle: TextStyle(color: Colors.black38, fontSize: 13),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 44,
                width: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFEFEF),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.tune, color: Colors.black87, size: 20),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Katalog Produk',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          products.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: Text('Tidak ada data produk di katalog.')),
                )
              : Column(
                  children: products.map((product) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey[100]!),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F3F5),
                              shape: BoxShape.circle,
                            ),
                            child: product.imageBytes != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(32),
                                    child: Image.memory(product.imageBytes!, fit: BoxFit.cover),
                                  )
                                : (product.image != null && product.image!.isNotEmpty)
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(32),
                                        child: Image.network(
                                          Provider.of<AuthProvider>(context, listen: false).getFullImageUrl(product.image),
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, progress) {
                                            if (progress == null) return child;
                                            return const Center(child: SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF6B00))));
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              product.category?.toLowerCase() == 'motor' ? Icons.motorcycle_rounded : Icons.directions_car_filled_outlined,
                                              color: const Color(0xFFFF6B00),
                                              size: 22,
                                            );
                                          },
                                        ),
                                      )
                                    : Icon(
                                        product.category?.toLowerCase() == 'motor' ? Icons.motorcycle_rounded : Icons.directions_car_filled_outlined,
                                        color: const Color(0xFFFF6B00),
                                        size: 22,
                                      ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Stock: Available • Cat: ${(product.category ?? 'Umum').toUpperCase()}',
                                  style: const TextStyle(color: Colors.black45, fontSize: 11),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rp ${product.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF8A4F3E)),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.grey[100],
                                child: IconButton(
                                  icon: const Icon(Icons.edit, size: 14, color: Colors.black54),
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(
                                      '/edit-product',
                                      arguments: product,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.red[50],
                                child: IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 14, color: Colors.red),
                                  onPressed: () async { 
                                    final String adminToken = Provider.of<AuthProvider>(context, listen: false).token ?? ''; 
                                    await Provider.of<ProductProvider>(context, listen: false).deleteProduct(adminToken, product.id!);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String badge, Color badgeColor, {bool isAlert = false, VoidCallback? onTap}) {
    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isAlert ? Colors.red[50] : (onTap != null ? badgeColor.withOpacity(0.1) : Colors.grey[50]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badge,
              style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: card,
      );
    }
    return card;
  }

  Widget _buildProductCard(Product product, ProductProvider provider) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 240,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: product.imageBytes != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        child: Image.memory(product.imageBytes!, fit: BoxFit.cover),
                      )
                    : (product.image != null && product.image!.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                            child: Image.network(
                              authProvider.getFullImageUrl(product.image),
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)));
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  product.category?.toLowerCase() == 'motor' ? Icons.motorcycle_rounded : Icons.directions_car_filled_outlined,
                                  size: 80,
                                  color: Colors.black.withOpacity(0.24),
                                );
                              },
                            ),
                          )
                        : Icon(
                            product.category?.toLowerCase() == 'motor' ? Icons.motorcycle_rounded : Icons.directions_car_filled_outlined,
                            size: 80,
                            color: Colors.black.withOpacity(0.24),
                          ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      provider.toggleFavorite(product.id!);
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Icon(
                      product.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: product.isFavorite ? const Color(0xFFFF6B00) : Colors.black45,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${product.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF8A4F3E)),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kategori: ${(product.category ?? 'Umum').toUpperCase()}',
                      style: const TextStyle(color: Colors.black54, fontSize: 11, fontStyle: FontStyle.italic),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1D20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        minimumSize: const Size(0, 32),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          '/product-detail',
                          arguments: product,
                        );
                      },
                      child: const Text(
                        'Lihat Detail',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}