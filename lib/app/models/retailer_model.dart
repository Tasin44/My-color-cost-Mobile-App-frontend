class Retailer {
  final int id;
  final String businessName;
  final String? businessLogoUrl;
  final String retailerEmail;
  final String deliveryCharge;
  final String freeDeliveryThreshold;
  final List<String> deliveryAreas;

  Retailer({
    required this.id,
    required this.businessName,
    this.businessLogoUrl,
    required this.retailerEmail,
    required this.deliveryCharge,
    required this.freeDeliveryThreshold,
    required this.deliveryAreas,
  });

  factory Retailer.fromJson(Map<String, dynamic> json) {
    return Retailer(
      id: json['id'] ?? 0,
      businessName: json['business_name'] ?? '',
      businessLogoUrl: json['business_logo_url'],
      retailerEmail: json['retailer_email'] ?? '',
      deliveryCharge: json['delivery_charge']?.toString() ?? '0.00',
      freeDeliveryThreshold:
          json['free_delivery_threshold']?.toString() ?? '0.00',
      deliveryAreas: List<String>.from(json['delivery_areas'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_name': businessName,
      'business_logo_url': businessLogoUrl,
      'retailer_email': retailerEmail,
      'delivery_charge': deliveryCharge,
      'free_delivery_threshold': freeDeliveryThreshold,
      'delivery_areas': deliveryAreas,
    };
  }
}

class RetailerProduct {
  final int id;
  final String name;
  final String description;
  final String? imageUrl;
  final String marketPrice;
  final String discountedMarketPrice;
  final int quantity;
  final String stockStatus;
  final String vat;
  final String retailerName;
  final String averageRating;
  final int totalReviews;
  final bool promoIsActive;
  final int? promoBuyQuantity;
  final int? promoFreeQuantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  RetailerProduct({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.marketPrice,
    required this.discountedMarketPrice,
    required this.quantity,
    required this.stockStatus,
    required this.vat,
    required this.retailerName,
    required this.averageRating,
    required this.totalReviews,
    required this.promoIsActive,
    this.promoBuyQuantity,
    this.promoFreeQuantity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RetailerProduct.fromJson(Map<String, dynamic> json) {
    return RetailerProduct(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'],
      marketPrice: json['market_price']?.toString() ?? '0.00',
      discountedMarketPrice: json['discounted_market_price']?.toString() ??
          json['market_price']?.toString() ??
          '0.00',
      quantity: json['quantity'] ?? 0,
      stockStatus: json['stock_status'] ?? 'out_of_stock',
      vat: json['vat']?.toString() ?? '0.00',
      retailerName: json['retailer_name'] ?? '',
      averageRating: json['average_rating']?.toString() ?? '0.00',
      totalReviews: json['total_reviews'] ?? 0,
      promoIsActive: json['promo_is_active'] ?? false,
      promoBuyQuantity: json['promo_buy_quantity'],
      promoFreeQuantity: json['promo_free_quantity'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  bool get isInStock => stockStatus == 'in_stock';

  // Helper getter for promo text
  String? get promoText {
    if (promoIsActive && promoBuyQuantity != null && promoFreeQuantity != null) {
      return 'Buy $promoBuyQuantity Get $promoFreeQuantity Free';
    }
    final price = double.tryParse(marketPrice) ?? 0.0;
    final discountedPrice = double.tryParse(discountedMarketPrice) ?? 0.0;
    if (discountedPrice < price && price > 0) {
      final savings = ((price - discountedPrice) / price * 100).round();
      return '$savings% OFF';
    }
    return null;
  }

  // Convert RetailerProduct to Product for product details screen
  toProduct() {
    return {
      'id': id.toString(),
      'name': name,
      'retailer': retailerName,
      'rating': double.tryParse(averageRating) ?? 0.0,
      'price': double.tryParse(marketPrice) ?? 0.0,
      'discounted_market_price': double.tryParse(discountedMarketPrice) ?? 0.0,
      'imageUrl': imageUrl ?? '',
      'description': description,
      'quantity': quantity,
      'stock_status': stockStatus,
      'total_reviews': totalReviews,
      'promo_is_active': promoIsActive,
      'promo_buy_quantity': promoBuyQuantity,
      'promo_free_quantity': promoFreeQuantity,
      'vat': double.tryParse(vat) ?? 0.0,
      'delivery_areas': [], // RetailerProduct list doesn't usually have these
      'delivery_charge': 0.0,
    };
  }
}

class RetailerDetails {
  final Retailer retailer;
  final List<RetailerProduct> products;
  final int totalProducts;

  RetailerDetails({
    required this.retailer,
    required this.products,
    required this.totalProducts,
  });

  factory RetailerDetails.fromJson(Map<String, dynamic> json) {
    return RetailerDetails(
      retailer: Retailer.fromJson(json['retailer']),
      products:
          (json['products'] as List?)
              ?.map((p) => RetailerProduct.fromJson(p))
              .toList() ??
          [],
      totalProducts: json['total_products'] ?? 0,
    );
  }
}
