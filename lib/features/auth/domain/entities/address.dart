class Address {
  final int id;
  final String? street;
  final String? city;
  final String? district;

  Address({
    required this.id,
    this.street,
    this.city,
    this.district,
  });

  @override
  String toString() {
    final parts = [street, district, city].where((e) => e != null && e.isNotEmpty).toList();
    return parts.join(', ');
  }
}
