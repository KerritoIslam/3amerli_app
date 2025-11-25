class ProductPicture {
  final String url;
  final int? id;

  const ProductPicture({
    required this.url,
    this.id,
  });

  factory ProductPicture.fromJson(Map<String, dynamic> json) {
    return ProductPicture(
      url: json['url']?.toString() ?? '',
      id: json['id'] != null ? (json['id'] as num).toInt() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      if (id != null) 'id': id,
    };
  }
}
