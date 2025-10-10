import '../../domain/entities/category.dart';

class CategoryModel {
  final int id;
  final String name;
  final String? description;

  CategoryModel({required this.id, required this.name, this.description});

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: (json['id'] is num) ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '') ?? 0,
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString(),
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'description': description};

  Category toEntity() => Category(id: id, name: name, description: description);
}
