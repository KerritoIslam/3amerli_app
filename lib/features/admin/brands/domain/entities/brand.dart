class Brand {
  final String id;
  final String name;

  Brand({required this.id, required this.name});

  Brand copyWith({String? id, String? name}) => Brand(id: id ?? this.id, name: name ?? this.name);

  @override
  String toString() => 'Brand(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Brand && other.id == id && other.name == name);

  @override
  int get hashCode => Object.hash(id, name);
}
