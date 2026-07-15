class MixCreatedBy {
  final String type;
  final String name;
  final String id;
  final String email;

  MixCreatedBy({
    required this.type,
    required this.name,
    required this.id,
    required this.email,
  });

  factory MixCreatedBy.fromJson(Map<String, dynamic> json) {
    return MixCreatedBy(
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
    );
  }
}

/// A product inside a bowl from the API response.
class MixBowlProduct {
  final int id;
  final String productName;
  final String usedWeight;
  final double marketPrice;
  final double userPrice;
  final double eachItemCost;

  MixBowlProduct({
    required this.id,
    required this.productName,
    required this.usedWeight,
    required this.marketPrice,
    required this.userPrice,
    required this.eachItemCost,
  });

  factory MixBowlProduct.fromJson(Map<String, dynamic> json) {
    return MixBowlProduct(
      id: json['id'] ?? 0,
      productName: json['product_name'] ?? '',
      usedWeight: json['used_weight']?.toString() ?? '0',
      marketPrice:
          double.tryParse(json['market_price']?.toString() ?? '0') ?? 0,
      userPrice: double.tryParse(json['user_price']?.toString() ?? '0') ?? 0,
      eachItemCost:
          double.tryParse(json['each_item_cost']?.toString() ?? '0') ?? 0,
    );
  }
}

/// A bowl inside a mix from the API response.
class MixBowl {
  final int id;
  final String serviceName;
  final String mixName;
  final String? bleachTimerStartTime;
  final double totalCost;
  final List<MixBowlProduct> products;
  final String createdAt;

  MixBowl({
    required this.id,
    required this.serviceName,
    required this.mixName,
    this.bleachTimerStartTime,
    required this.totalCost,
    required this.products,
    required this.createdAt,
  });

  factory MixBowl.fromJson(Map<String, dynamic> json) {
    final productList = json['products'] as List? ?? [];
    return MixBowl(
      id: json['id'] ?? 0,
      serviceName: json['service_name'] ?? '',
      mixName: json['mix_name'] ?? '',
      bleachTimerStartTime: json['bleach_timer_start_time'],
      totalCost:
          double.tryParse(json['total_cost']?.toString() ?? '0') ?? 0,
      products: productList
          .map((p) => MixBowlProduct.fromJson(p as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] ?? '',
    );
  }
}

class MixModel {
  final String id;
  final String? clientName;
  final int? clientId;
  final String serviceType;

  /// The date the salon owner selected for this service (from API: service_date)
  final DateTime? serviceDate;

  final double chargedAmount;
  final double totalCost;
  final double profit;
  final DateTime date;
  final String time;
  final String? pdfUrl;
  final MixCreatedBy? createdBy;

  /// Bowls included in this mix (new API structure)
  final List<MixBowl> bowls;

  /// Legacy flat product list (old API — kept for backward compat)
  final List<MixProduct> products;
  final int productCount;

  // Keep mixName for legacy screens that still reference it
  final String mixName;
  final String time2;

  MixModel({
    required this.id,
    this.clientName,
    this.clientId,
    required this.serviceType,
    this.serviceDate,
    required this.chargedAmount,
    required this.totalCost,
    required this.profit,
    required this.date,
    required this.time,
    this.pdfUrl,
    this.createdBy,
    List<MixBowl>? bowls,
    List<MixProduct>? products,
    this.productCount = 0,
    String? mixName,
  })  : bowls = bowls ?? [],
        products = products ?? [],
        mixName = mixName ?? serviceType,
        time2 = time;

  factory MixModel.fromJson(Map<String, dynamic> json) {
    // Parse bowls (new API)
    final bowlList = json['bowls'] as List? ?? [];
    final List<MixBowl> bowls =
        bowlList.map((b) => MixBowl.fromJson(b as Map<String, dynamic>)).toList();

    // Parse flat products (old API — fallback)
    final productList = json['products'] as List? ?? [];
    final List<MixProduct> products =
        productList.map((p) => MixProduct.fromJson(p as Map<String, dynamic>)).toList();

    return MixModel(
      id: json['id']?.toString() ?? '',
      clientName: json['client_name'],
      clientId: json['client_id'],
      serviceType: json['service_type'] ?? '',
      serviceDate: json['service_date'] != null
          ? DateTime.tryParse(json['service_date'])
          : null,
      chargedAmount:
          double.tryParse(json['charged_amount']?.toString() ?? '0') ?? 0,
      totalCost: double.tryParse(json['total_cost']?.toString() ?? '0') ?? 0,
      profit: double.tryParse(json['profit']?.toString() ?? '0') ?? 0,
      date: json['created_date'] != null
          ? DateTime.tryParse(json['created_date']) ?? DateTime.now()
          : DateTime.now(),
      time: json['created_time'] ?? '',
      pdfUrl: json['pdf_url'],
      createdBy: json['created_by'] != null
          ? MixCreatedBy.fromJson(json['created_by'])
          : null,
      bowls: bowls,
      products: products,
      productCount: json['product_count'] ?? products.length,
      mixName: json['mix_name'] ?? json['service_type'] ?? 'Untitled Mix',
    );
  }

  MixModel copyWith({
    String? id,
    String? mixName,
    String? serviceType,
    DateTime? serviceDate,
    DateTime? date,
    String? time,
    double? profit,
    double? totalCost,
    double? chargedAmount,
    List<MixBowl>? bowls,
    List<MixProduct>? products,
    int? productCount,
    MixCreatedBy? createdBy,
    String? clientName,
    int? clientId,
    String? pdfUrl,
  }) {
    return MixModel(
      id: id ?? this.id,
      mixName: mixName ?? this.mixName,
      serviceType: serviceType ?? this.serviceType,
      serviceDate: serviceDate ?? this.serviceDate,
      date: date ?? this.date,
      time: time ?? this.time,
      profit: profit ?? this.profit,
      totalCost: totalCost ?? this.totalCost,
      chargedAmount: chargedAmount ?? this.chargedAmount,
      bowls: bowls ?? this.bowls,
      products: products ?? this.products,
      productCount: productCount ?? this.productCount,
      createdBy: createdBy ?? this.createdBy,
      clientName: clientName ?? this.clientName,
      clientId: clientId ?? this.clientId,
      pdfUrl: pdfUrl ?? this.pdfUrl,
    );
  }
}

class MixProduct {
  final int id;
  final String name;
  final String category;
  final String usedWeight;
  final double cost;
  final double marketPrice;
  final double userPrice;
  final bool isBleachTimerOn;
  final String? bleachTimerStartTime;
  final String? bleachTimerDuration;

  MixProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.usedWeight,
    required this.cost,
    required this.marketPrice,
    required this.userPrice,
    this.isBleachTimerOn = false,
    this.bleachTimerStartTime,
    this.bleachTimerDuration,
  });

  factory MixProduct.fromJson(Map<String, dynamic> json) {
    return MixProduct(
      id: json['id'] ?? 0,
      name: json['product_name'] ?? json['name'] ?? '',
      category: json['category'] ?? '',
      usedWeight: json['used_weight']?.toString() ??
          json['grams']?.toString() ??
          '0',
      cost: double.tryParse(
              json['each_item_cost']?.toString() ??
                  json['cost']?.toString() ??
                  '0') ??
          0,
      marketPrice:
          double.tryParse(json['market_price']?.toString() ?? '0') ?? 0,
      userPrice:
          double.tryParse(json['user_price']?.toString() ?? '0') ?? 0,
      isBleachTimerOn: json['is_bleach_timer_on'] ?? false,
      bleachTimerStartTime: json['bleach_timer_start_time'],
      bleachTimerDuration: json['bleach_timer_duration'],
    );
  }

  MixProduct copyWith({
    int? id,
    String? name,
    String? category,
    String? usedWeight,
    double? cost,
    double? marketPrice,
    double? userPrice,
    bool? isBleachTimerOn,
    String? bleachTimerStartTime,
    String? bleachTimerDuration,
  }) {
    return MixProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      usedWeight: usedWeight ?? this.usedWeight,
      cost: cost ?? this.cost,
      marketPrice: marketPrice ?? this.marketPrice,
      userPrice: userPrice ?? this.userPrice,
      isBleachTimerOn: isBleachTimerOn ?? this.isBleachTimerOn,
      bleachTimerStartTime: bleachTimerStartTime ?? this.bleachTimerStartTime,
      bleachTimerDuration: bleachTimerDuration ?? this.bleachTimerDuration,
    );
  }
}
