class ProductModel {
  final int id;
  final int categoryId;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final String? imageUrl;
  final String? imagePublicId;
  final String? categoryName;
  final String? createdAt;
  final String? updatedAt;

  ProductModel({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.stock = 0,
    this.imageUrl,
    this.imagePublicId,
    this.categoryName,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      categoryId: json['category_id'] is int
          ? json['category_id']
          : int.parse(json['category_id'].toString()),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      stock: json['stock'] is int
          ? json['stock']
          : int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      imageUrl: json['image_url']?.toString(),
      imagePublicId: json['image_public_id']?.toString(),
      categoryName: json['category_name']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category_id': categoryId,
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'image_url': imageUrl,
        'image_public_id': imagePublicId,
        'category_name': categoryName,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}