import 'dart:typed_data';

class Product {
  final int? id;
  final String name;
  final String? description;
  final int price;
  final String? image;
  final String? category;
  final Uint8List? imageBytes;
  bool isFavorite; 

  Product({
    this.id,
    required this.name,
    this.description,
    required this.price,
    this.image,
    this.category,
    this.imageBytes,
    this.isFavorite = false, 
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // PROTEKSI SAKTI: Mengonversi nilai decimal "1650000.00" Laravel menjadi Integer murni di Flutter
    int parsedPrice = 0;
    if (json['price'] != null) {
      if (json['price'] is int) {
        parsedPrice = json['price'];
      } else if (json['price'] is double) {
        parsedPrice = (json['price'] as double).toInt();
      } else if (json['price'] is String) {
        parsedPrice = double.parse(json['price']).toInt();
      }
    }

    return Product(
      id: json['id'] is String ? int.parse(json['id']) : json['id'] as int?,
      name: json['name'] ?? '',
      description: json['description'],
      price: parsedPrice, 
      image: json['image'],
      category: json['category'], 
      isFavorite: false, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'category': category, 
    };
  }
}