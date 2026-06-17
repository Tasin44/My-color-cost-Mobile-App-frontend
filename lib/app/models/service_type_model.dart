class ServiceTypeModel {
  final int id;
  final String name;
  final String? description;
  final int serviceTimeMinutes;
  final String priceType;
  final String? priceTypeDisplay;
  final String? serviceFee;
  final String? createdAt;
  final String? updatedAt;

  ServiceTypeModel({
    required this.id,
    required this.name,
    this.description,
    required this.serviceTimeMinutes,
    required this.priceType,
    this.priceTypeDisplay,
    this.serviceFee,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceTypeModel.fromJson(Map<String, dynamic> json) {
    return ServiceTypeModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      serviceTimeMinutes: json['service_time_minutes'],
      priceType: json['price_type'],
      priceTypeDisplay: json['price_type_display'],
      serviceFee: json['service_fee']?.toString(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'service_time_minutes': serviceTimeMinutes,
      'price_type': priceType,
      'price_type_display': priceTypeDisplay,
      'service_fee': serviceFee,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
