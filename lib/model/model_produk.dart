class Product {
  final int? id;
  final String name;
  final String brand;
  final String category;
  final double price;
  final bool isFavorite; // Field untuk status favorit

  Product({
    this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.price,
    this.isFavorite = false, // Default false jika tidak diset
  });

  // Menambahkan isFavorite ke dalam fromMap dan toMap
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      brand: map['brand'],
      category: map['category'],
      price: map['price'],
      isFavorite:
          map['isFavorite'] == 1, // Konversi dari integer (1 atau 0) ke boolean
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'category': category,
      'price': price,
      'isFavorite': isFavorite
          ? 1
          : 0, // Simpan sebagai integer (1 untuk true, 0 untuk false)
    };
  }
}
