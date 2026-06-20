/// Models used in the new multi-bowl mix creation flow.
/// Maps directly to the POST /mix/mixes/new/ API payload.

class BowlProductData {
  int userProductId;
  String productName;
  String? productImage;
  double usedWeight;
  double userPrice;
  double marketPrice;

  BowlProductData({
    required this.userProductId,
    required this.productName,
    this.productImage,
    required this.usedWeight,
    required this.userPrice,
    required this.marketPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_product_id': userProductId,
      'used_weight': usedWeight,
      'user_price': userPrice,
      'market_price': marketPrice,
    };
  }

  BowlProductData copyWith({
    int? userProductId,
    String? productName,
    String? productImage,
    double? usedWeight,
    double? userPrice,
    double? marketPrice,
  }) {
    return BowlProductData(
      userProductId: userProductId ?? this.userProductId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      usedWeight: usedWeight ?? this.usedWeight,
      userPrice: userPrice ?? this.userPrice,
      marketPrice: marketPrice ?? this.marketPrice,
    );
  }
}

class BowlData {
  String serviceName;
  String mixName;
  double? chargedAmount;
  String bleachTimerStartTime;
  List<BowlProductData> products;

  BowlData({
    required this.serviceName,
    required this.mixName,
    this.chargedAmount,
    required this.bleachTimerStartTime,
    List<BowlProductData>? products,
  }) : products = products ?? [];

  Map<String, dynamic> toJson() {
    return {
      'service_name': serviceName,
      'mix_name': mixName,
      'charged_amount': chargedAmount ?? 0.0,
      'bleach_timer_start_time': bleachTimerStartTime,
      'products': products.map((p) => p.toJson()).toList(),
    };
  }

  /// Total cost for all products in this bowl
  double get totalProductCost {
    double total = 0.0;
    for (final p in products) {
      // each_item_cost = (user_price / original_weight) * used_weight
      // Since we don't have original_weight here, we track a simple sum
      // The backend calculates the real cost; this is a client-side estimate
      total += p.userPrice > 0 ? (p.userPrice / 100) * p.usedWeight : 0.0;
    }
    return total;
  }

  BowlData copyWith({
    String? serviceName,
    String? mixName,
    double? chargedAmount,
    String? bleachTimerStartTime,
    List<BowlProductData>? products,
  }) {
    return BowlData(
      serviceName: serviceName ?? this.serviceName,
      mixName: mixName ?? this.mixName,
      chargedAmount: chargedAmount ?? this.chargedAmount,
      bleachTimerStartTime:
          bleachTimerStartTime ?? this.bleachTimerStartTime,
      products: products ?? List<BowlProductData>.from(this.products),
    );
  }
}
