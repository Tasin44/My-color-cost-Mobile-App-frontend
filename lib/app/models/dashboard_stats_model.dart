class DashboardStatsModel {
  final int totalClients;
  final int totalMixes;
  final int totalPendingAppointments;
  final double totalProfit;

  DashboardStatsModel({
    required this.totalClients,
    required this.totalMixes,
    required this.totalPendingAppointments,
    required this.totalProfit,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalClients: json['total_clients'] ?? 0,
      totalMixes: json['total_mixes'] ?? 0,
      totalPendingAppointments: json['total_pending_appointments'] ?? 0,
      totalProfit: (json['total_profit'] ?? 0).toDouble(),
    );
  }

  // Empty/Error state
  factory DashboardStatsModel.empty() {
    return DashboardStatsModel(
      totalClients: 0,
      totalMixes: 0,
      totalPendingAppointments: 0,
      totalProfit: 0.0,
    );
  }
}
