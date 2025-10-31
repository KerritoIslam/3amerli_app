import '../../domain/entities/brand.dart';

class BrandModel {
  final int id;
  final String name;
  final String? image;

  BrandModel({required this.id, required this.name, this.image});

  factory BrandModel.fromJson(Map<String, dynamic> json) => BrandModel(
        id: (json['id'] is num) ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '') ?? 0,
        name: json['label']?.toString() ?? json['name']?.toString() ?? '',
        image: json['image']?.toString(),
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'image': image};

  Brand toEntity() => Brand(id: id, name: name, image: image);
}
