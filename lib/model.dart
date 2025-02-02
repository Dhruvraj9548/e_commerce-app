class Product {
  final int id;
  final String title;
  final dynamic price;
  final String description;
  final String category;
  final String image;

  Product(
      {required this.id,
        required this.title,
        this.price,
        required this.description,
        required this.category,
        required this.image});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        id: json['id'],
        title: json['title'],
        price: json['price'],
        description: json['description'],
        category: json['category'],
        image: json['image']);
  }
}