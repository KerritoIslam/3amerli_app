import '../../domain/entities/mark.dart';

class MarkModel {
  final String id;
  final String label;

  MarkModel({required this.id, required this.label});

  factory MarkModel.fromJson(Map<String, dynamic> json) => MarkModel(
        id: json['id'] as String,
        label: json['label'] as String,
      );

  Map<String, dynamic> toJson() => {'id': id, 'label': label};

  Mark toEntity() => Mark(id: id, label: label);
}
