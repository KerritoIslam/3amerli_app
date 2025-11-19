import 'package:equatable/equatable.dart';

class Brand extends Equatable {
  final int id;
  final String name;
  final String? image;

  const Brand({required this.id, required this.name, this.image});

  @override
  List<Object?> get props => [id, name, image];
}
