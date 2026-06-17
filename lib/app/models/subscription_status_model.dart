class SubscriptionStatusModel {
  final bool success;
  final int statusCode;
  final String message;
  final SubscriptionData? data;

  SubscriptionStatusModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory SubscriptionStatusModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatusModel(
      success: json['success'] ?? false,
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? SubscriptionData.fromJson(json['data'])
          : null,
    );
  }
}

class SubscriptionData {
  final bool isSubscribed;
  final String planType;
  final String status;
  final SubscriptionDetails? subscriptionDetails;

  SubscriptionData({
    required this.isSubscribed,
    required this.planType,
    required this.status,
    this.subscriptionDetails,
  });

  factory SubscriptionData.fromJson(Map<String, dynamic> json) {
    return SubscriptionData(
      isSubscribed: json['is_subscribed'] ?? false,
      planType: json['plan_type'] ?? '',
      status: json['status'] ?? '',
      subscriptionDetails: json['subscription_details'] != null
          ? SubscriptionDetails.fromJson(json['subscription_details'])
          : null,
    );
  }
}

class SubscriptionDetails {
  final String status;
  final String productId;
  final String? trialEndDate;
  final String planType;
  final String? subscriptionStartDate;
  final String? subscriptionEndDate;
  final String subscriptionAmount;
  final bool isActive;

  SubscriptionDetails({
    required this.status,
    required this.productId,
    this.trialEndDate,
    required this.planType,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    required this.subscriptionAmount,
    required this.isActive,
  });

  factory SubscriptionDetails.fromJson(Map<String, dynamic> json) {
    return SubscriptionDetails(
      status: json['status'] ?? '',
      productId: json['product_id'] ?? '',
      trialEndDate: json['trial_end_date'],
      planType: json['plan_type'] ?? '',
      subscriptionStartDate: json['subscription_start_date'],
      subscriptionEndDate: json['subscription_end_date'],
      subscriptionAmount: json['subscription_amount'] ?? '0.00',
      isActive: json['is_active'] ?? false,
    );
  }
}
