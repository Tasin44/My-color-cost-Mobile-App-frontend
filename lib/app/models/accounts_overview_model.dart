/// Model for GET/PATCH /mix/accounts_department/
///
/// API Response shape:
/// {
///   "filter_type": "monthly",
///   "year": 2026,
///   "month": 7,
///   "month_name": "July",
///   "total_income": "800.00",
///   "total_expense": "455.00",
///   "total_color_cost": "101.20",
///   "net_profit": "243.80"
/// }
class AccountsOverviewModel {
  final bool success;
  final int statusCode;
  final String message;
  final AccountsData data;

  AccountsOverviewModel({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory AccountsOverviewModel.fromJson(Map<String, dynamic> json) {
    return AccountsOverviewModel(
      success: json['success'] ?? false,
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: AccountsData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'statusCode': statusCode,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class AccountsData {
  final int? id;
  final String filterType;
  final int year;
  final int? month;
  final String? monthName;

  /// Auto-computed from Mix.charged_amount, but user can override via PATCH
  final double totalIncome;

  /// Auto-computed from Expense.amount, but user can override via PATCH
  final double totalExpense;

  /// Always auto-computed — sum of all bowl costs (non-editable)
  final double totalColorCost;

  /// Always auto-computed — totalIncome - totalExpense - totalColorCost (non-editable)
  final double netProfit;

  AccountsData({
    this.id,
    required this.filterType,
    required this.year,
    this.month,
    this.monthName,
    required this.totalIncome,
    required this.totalExpense,
    required this.totalColorCost,
    required this.netProfit,
  });

  factory AccountsData.fromJson(Map<String, dynamic> json) {
    return AccountsData(
      id: json['id'],
      filterType: json['filter_type'] ?? 'monthly',
      year: json['year'] ?? DateTime.now().year,
      month: json['month'],
      monthName: json['month_name'],
      totalIncome:
          double.tryParse(json['total_income']?.toString() ?? '0') ?? 0.0,
      totalExpense:
          double.tryParse(json['total_expense']?.toString() ?? '0') ?? 0.0,
      totalColorCost:
          double.tryParse(json['total_color_cost']?.toString() ?? '0') ?? 0.0,
      netProfit:
          double.tryParse(json['net_profit']?.toString() ?? '0') ?? 0.0,
    );
  }

  /// Only send editable fields in PATCH request.
  /// total_color_cost and net_profit are always computed by the backend.
  Map<String, dynamic> toPatchJson() {
    return {
      'total_income': totalIncome.toStringAsFixed(2),
      'total_expense': totalExpense.toStringAsFixed(2),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filter_type': filterType,
      'year': year,
      'month': month,
      'month_name': monthName,
      'total_income': totalIncome,
      'total_expense': totalExpense,
      'total_color_cost': totalColorCost,
      'net_profit': netProfit,
    };
  }
}
