import 'dart:typed_data'; // <-- TAMBAHKAN BARIS INI DI PALING ATAS FILE

class Product {
  final int? id;
  final String name;
  final String? description;
  final int price;
  final String? image;
  final String? category;
  final Uint8List? imageBytes;

  Product({
    this.id,
    required this.name,
    this.description,
    required this.price,
    this.image,
    this.category,
    this.imageBytes,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'] is String ? int.parse(json['price']) : json['price'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
    };
  }
}