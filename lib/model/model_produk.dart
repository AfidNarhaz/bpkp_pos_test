class Product {
  final int? id;
  final String name;
  final String brand;
  final String category;
  final double price;

  Product(
      {this.id,
      required this.name,
      required this.brand,
      required this.category,
      required this.price});

  // Mengubah objek menjadi Map (untuk disimpan ke database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'category': category,
      'price': price,
    };
  }

  // Membuat objek Product dari Map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      brand: map['brand'],
      category: map['category'],
      price: map['price'],
    );
  }
}
