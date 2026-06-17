/// Model representing a client image
class ClientImage {
  final int id;
  final String imageType;
  final String imageUrl;
  final DateTime uploadDate;

  ClientImage({
    required this.id,
    required this.imageType,
    required this.imageUrl,
    required this.uploadDate,
  });

  factory ClientImage.fromJson(Map<String, dynamic> json) {
    return ClientImage(
      id: json['id'] ?? 0,
      imageType: json['image_type'] ?? '',
      imageUrl: json['image_url'] ?? '',
      uploadDate: json['upload_date'] != null
          ? DateTime.tryParse(json['upload_date']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Container for client images response
class ClientImagesData {
  final List<ClientImage> beforeImages;
  final List<ClientImage> afterImages;
  final int totalImages;

  ClientImagesData({
    required this.beforeImages,
    required this.afterImages,
    required this.totalImages,
  });

  factory ClientImagesData.fromJson(Map<String, dynamic> json) {
    return ClientImagesData(
      beforeImages: json['before_images'] != null
          ? (json['before_images'] as List)
                .map((e) => ClientImage.fromJson(e))
                .toList()
          : [],
      afterImages: json['after_images'] != null
          ? (json['after_images'] as List)
                .map((e) => ClientImage.fromJson(e))
                .toList()
          : [],
      totalImages: json['total_images'] ?? 0,
    );
  }
}
