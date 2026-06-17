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

class MixModel {
  final String id;
  final String mixName;
  final String serviceType;
  final DateTime date;
  final String time;
  final double profit;
  final double totalCost;
  final double chargedAmount;
  final List<MixProduct> products;
  final int productCount;
  final MixCreatedBy? createdBy;
  final String? clientName;
  final int? clientId;
  final String? pdfUrl;

  MixModel({
    required this.id,
    required this.mixName,
    required this.serviceType,
    required this.date,
    required this.time,
    required this.profit,
    required this.totalCost,
    required this.chargedAmount,
    required this.products,
    this.productCount = 0,
    this.createdBy,
    this.clientName,
    this.clientId,
    this.pdfUrl,
  });

  factory MixModel.create({
    required String mixName,
    required String serviceType,
    required DateTime date,
    required String time,
    required double profit,
    required double totalCost,
    required double chargedAmount,
    required List<MixProduct> products,
  }) {
    return MixModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mixName: mixName,
      serviceType: serviceType,
      date: date,
      time: time,
      profit: profit,
      totalCost: totalCost,
      chargedAmount: chargedAmount,
      products: products,
      productCount: products.length,
      createdBy: null,
    );
  }

  factory MixModel.fromJson(Map<String, dynamic> json) {
    var productList = json['products'] as List?;
    List<MixProduct> products = [];
    if (productList != null) {
      products = productList.map((p) => MixProduct.fromJson(p)).toList();
    }

    return MixModel(
      id: json['id']?.toString() ?? '',
      mixName: json['mix_name'] ?? 'Untitled Mix',
      serviceType: json['service_type'] ?? '',
      date: json['created_date'] != null
          ? DateTime.tryParse(json['created_date']) ?? DateTime.now()
          : DateTime.now(),
      time: json['created_time'] ?? '',
      profit: double.tryParse(json['profit']?.toString() ?? '0') ?? 0,
      totalCost: double.tryParse(json['total_cost']?.toString() ?? '0') ?? 0,
      chargedAmount:
          double.tryParse(json['charged_amount']?.toString() ?? '0') ?? 0,
      products: products,
      productCount: json['product_count'] ?? products.length,
      createdBy: json['created_by'] != null
          ? MixCreatedBy.fromJson(json['created_by'])
          : null,
      clientName: json['client_name'],
      clientId: json['client_id'],
      pdfUrl: json['pdf_url'],
    );
  }

  MixModel copyWith({
    String? id,
    String? mixName,
    String? serviceType,
    DateTime? date,
    String? time,
    double? profit,
    double? totalCost,
    double? chargedAmount,
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
      date: date ?? this.date,
      time: time ?? this.time,
      profit: profit ?? this.profit,
      totalCost: totalCost ?? this.totalCost,
      chargedAmount: chargedAmount ?? this.chargedAmount,
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
      usedWeight: json['used_weight']?.toString() ?? json['grams']?.toString() ?? '0',
      cost: double.tryParse(json['each_item_cost']?.toString() ?? json['cost']?.toString() ?? '0') ?? 0,
      marketPrice: double.tryParse(json['market_price']?.toString() ?? '0') ?? 0,
      userPrice: double.tryParse(json['user_price']?.toString() ?? '0') ?? 0,
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
