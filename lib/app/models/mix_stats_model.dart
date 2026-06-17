class MixStatsModel {
  final int totalMixes;
  final double totalProfit;
  final double totalRevenue;
  final double totalCost;
  final int mixesThisMonth;
  final String mostUsedServiceType;

  MixStatsModel({
    required this.totalMixes,
    required this.totalProfit,
    required this.totalRevenue,
    required this.totalCost,
    required this.mixesThisMonth,
    required this.mostUsedServiceType,
  });

  factory MixStatsModel.fromJson(Map<String, dynamic> json) {
    return MixStatsModel(
      totalMixes: int.tryParse(json['total_mixes']?.toString() ?? '0') ?? 0,
      totalProfit:
          double.tryParse(json['total_profit']?.toString() ?? '0') ?? 0.0,
      totalRevenue:
          double.tryParse(json['total_revenue']?.toString() ?? '0') ?? 0.0,
      totalCost: double.tryParse(json['total_cost']?.toString() ?? '0') ?? 0.0,
      mixesThisMonth:
          int.tryParse(json['mixes_this_month']?.toString() ?? '0') ?? 0,
      mostUsedServiceType: json['most_used_service_type'] ?? 'N/A',
    );
  }

  factory MixStatsModel.empty() {
    return MixStatsModel(
      totalMixes: 0,
      totalProfit: 0.0,
      totalRevenue: 0.0,
      totalCost: 0.0,
      mixesThisMonth: 0,
      mostUsedServiceType: 'N/A',
    );
  }
}
