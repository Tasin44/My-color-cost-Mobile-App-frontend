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
  final String userId;
  final String name;
  final String email;
  final String role;
  final String? profileImage;
  final double totalIncome;
  final double totalExpense;
  final double netProfit;
  final String filterType;
  final int filterYear;
  final int? filterMonth;

  AccountsData({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.profileImage,
    required this.totalIncome,
    required this.totalExpense,
    required this.netProfit,
    required this.filterType,
    required this.filterYear,
    this.filterMonth,
  });

  factory AccountsData.fromJson(Map<String, dynamic> json) {
    return AccountsData(
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      profileImage: json['profile_image'],
      totalIncome: (json['total_income'] ?? 0).toDouble(),
      totalExpense: (json['total_expense'] ?? 0).toDouble(),
      netProfit: (json['net_profit'] ?? 0).toDouble(),
      filterType: json['filter_type'] ?? 'monthly',
      filterYear: json['filter_year'] ?? DateTime.now().year,
      filterMonth: json['filter_month'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'role': role,
      'profile_image': profileImage,
      'total_income': totalIncome,
      'total_expense': totalExpense,
      'net_profit': netProfit,
      'filter_type': filterType,
      'filter_year': filterYear,
      'filter_month': filterMonth,
    };
  }
}
