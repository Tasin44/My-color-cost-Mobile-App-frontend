/// Response shape from /mix/earning-overview/
/// {
///   "success": true,
///   "year": 2026,
///   "data": {
///     "income_by_mix_creation": [{"month": "Jan", "amount": 0}, ...],
///     "expense_by_product_purchase": [{"month": "Jan", "amount": 0}, ...]
///   }
/// }
///
/// ApiResponse.fromJson sets response.data = json['data'], so
/// FinancialOverviewModel.fromJson receives:
///   {"income_by_mix_creation": [...], "expense_by_product_purchase": [...]}
class FinancialOverviewModel {
  final List<MonthlyAmount> incomeByMixCreation;
  final List<MonthlyAmount> expenseByProductPurchase;

  FinancialOverviewModel({
    required this.incomeByMixCreation,
    required this.expenseByProductPurchase,
  });

  factory FinancialOverviewModel.fromJson(Map<String, dynamic> json) {
    return FinancialOverviewModel(
      incomeByMixCreation:
          (json['income_by_mix_creation'] as List?)
              ?.map((e) => MonthlyAmount.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      expenseByProductPurchase:
          (json['expense_by_product_purchase'] as List?)
              ?.map((e) => MonthlyAmount.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  bool get hasData =>
      incomeByMixCreation.isNotEmpty || expenseByProductPurchase.isNotEmpty;

  /// Year label shown in the chart header.
  String get period => DateTime.now().year.toString();
}

class MonthlyAmount {
  final String month;
  final double amount;

  MonthlyAmount({required this.month, required this.amount});

  factory MonthlyAmount.fromJson(Map<String, dynamic> json) {
    return MonthlyAmount(
      month: (json['month'] as String?) ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
