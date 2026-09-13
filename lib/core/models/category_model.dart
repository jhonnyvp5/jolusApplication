class CategoryModel {
  final String id;
  final String name;
  final String? icon;

  CategoryModel({required this.id, required this.name, this.icon});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      icon: json['icon_name'],
    );
  }
}
