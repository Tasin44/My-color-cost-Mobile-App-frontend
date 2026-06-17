class Product {
  final String id;
  final String name;
  final String retailer;
  final double rating;
  final double price;
  final double discountedPrice;
  final String imageUrl;
  final String? description;
  final int quantity;
  final String stockStatus;
  final int totalReviews;
  final bool promoIsActive;
  final int? promoBuyQuantity;
  final int? promoFreeQuantity;
  final List<String> deliveryAreas;
  final double deliveryCharge;
  final String? barcode;
  final double vat;

  Product({
    required this.id,
    required this.name,
    required this.retailer,
    required this.rating,
    required this.price,
    double? discountedPrice,
    required this.imageUrl,
    this.description,
    this.quantity = 0,
    this.stockStatus = 'out_of_stock',
    this.totalReviews = 0,
    this.promoIsActive = false,
    this.promoBuyQuantity,
    this.promoFreeQuantity,
    this.deliveryAreas = const [],
    this.deliveryCharge = 0.0,
    this.barcode,
    this.vat = 0.0,
  }) : discountedPrice = (discountedPrice != null && discountedPrice > 0)
            ? discountedPrice
            : price;

  // Factory constructor for creating from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      retailer: json['retailer_name'] ?? json['retailer'] ?? 'Unknown',
      rating:
          double.tryParse(
            json['average_rating']?.toString() ??
                json['rating']?.toString() ??
                '0',
          ) ??
          0.0,
      price:
          double.tryParse(
            json['market_price']?.toString() ??
                json['price']?.toString() ??
                '0',
          ) ??
          0.0,
      discountedPrice:
          double.tryParse(
            json['discounted_market_price']?.toString() ??
                json['discountedPrice']?.toString() ??
                '0',
          ),
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      description: json['description'],
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      stockStatus: json['stock_status'] ?? 'out_of_stock',
      totalReviews: int.tryParse(json['total_reviews']?.toString() ?? '0') ?? 0,
      promoIsActive: json['promo_is_active'] ?? false,
      promoBuyQuantity: json['promo_buy_quantity'] != null
          ? int.tryParse(json['promo_buy_quantity'].toString())
          : null,
      promoFreeQuantity: json['promo_free_quantity'] != null
          ? int.tryParse(json['promo_free_quantity'].toString())
          : null,
      deliveryAreas: json['delivery_areas'] != null
          ? List<String>.from(json['delivery_areas'])
          : const [],
      deliveryCharge:
          double.tryParse(json['delivery_charge']?.toString() ?? '0') ?? 0.0,
      barcode: json['barcode']?.toString(),
      vat: double.tryParse(json['vat']?.toString() ?? '0') ?? 0.0,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'retailer': retailer,
      'rating': rating,
      'price': price,
      'discountedPrice': discountedPrice,
      'imageUrl': imageUrl,
      'description': description,
      'quantity': quantity,
      'stock_status': stockStatus,
      'total_reviews': totalReviews,
      'promo_is_active': promoIsActive,
      'promo_buy_quantity': promoBuyQuantity,
      'promo_free_quantity': promoFreeQuantity,
      'delivery_areas': deliveryAreas,
      'delivery_charge': deliveryCharge,
      'barcode': barcode,
      'vat': vat,
    };
  }

  // Helper getter for stock status display
  bool get isInStock => stockStatus == 'in_stock';

  // Helper getter for stock status color
  String get stockStatusText => isInStock ? 'In Stock' : 'Out of Stock';

  // Helper getter for promo text
  String? get promoText {
    if (promoIsActive && promoBuyQuantity != null && promoFreeQuantity != null) {
      return 'Buy $promoBuyQuantity Get $promoFreeQuantity Free';
    }
    if (discountedPrice < price) {
      final savings = ((price - discountedPrice) / price * 100).round();
      return '$savings% OFF';
    }
    return null;
  }
}
