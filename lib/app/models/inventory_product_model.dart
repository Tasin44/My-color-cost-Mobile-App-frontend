class InventoryProduct {
  final int id;
  final int productId;
  final String productName;
  final String? productImage;
  final String? marketPrice;
  final String? userPrice;
  final String currentWeightGrams;
  final String? originalWeightGrams;
  final bool isAvailable;
  final String? lastUsedAt;
  final String? scannedAt;
  final String? barcode;
  final Map<String, dynamic>? apiData;

  InventoryProduct({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    this.marketPrice,
    this.userPrice,
    required this.currentWeightGrams,
    this.originalWeightGrams,
    required this.isAvailable,
    this.lastUsedAt,
    this.scannedAt,
    this.barcode,
    this.apiData,
  });

  factory InventoryProduct.fromJson(Map<String, dynamic> json) {
    return InventoryProduct(
      id: json['id'],
      productId: json['product'] ?? json['product_id'] ?? 0,
      productName: json['product_name'] ?? 'Unknown Product',
      productImage: json['product_image'],
      marketPrice: json['market_price'],
      userPrice: json['user_price'],
      currentWeightGrams: json['current_weight_grams']?.toString() ?? '0.00',
      // originalWeightGrams must ONLY come from a dedicated API field.
      // Never fall back to currentWeightGrams — that value changes after every
      // mix and would silently inflate price-per-gram over time.
      originalWeightGrams: json['original_weight_grams']?.toString(),
      isAvailable: json['is_available'] ?? false,
      lastUsedAt: json['last_used_at'],
      scannedAt: json['scanned_at'],
      barcode: json['barcode'],
      apiData: json['api_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'market_price': marketPrice,
      'user_price': userPrice,
      'current_weight_grams': currentWeightGrams,
      'original_weight_grams': originalWeightGrams,
      'is_available': isAvailable,
      'last_used_at': lastUsedAt,
      'scanned_at': scannedAt,
      'barcode': barcode,
      'api_data': apiData,
    };
  }
}
