class ApiEndpoints {
  ///>>> USERS<<<\\\
  // static const String baseUrl = "https://6zpmb4x8-8015.inc1.devtunnels.ms";
  static const String baseUrl = "https://api.mycolourcost.com";
  static const String login = "$baseUrl/auth/login/";
  static const String register = "$baseUrl/auth/signup/";
  static const String forgotPassword = "$baseUrl/auth/forgot-password/";
  static const String resetPassword = "$baseUrl/auth/reset-password/";
  static const String verifyEmail = "$baseUrl/auth/verify-otp/";
  static const String resendVerification = "$baseUrl/auth/resend-otp/";
  static const String teamSetup = "$baseUrl/auth/team/setup/";
  static const String accountType = "$baseUrl/auth/account-type/setup/";
  static const String workingHoursSetup =
      "$baseUrl/appointment/working-hours/setup/new/";
  static const String changePassword = "$baseUrl/change-password";
  static const String clients = "$baseUrl/client/";
  static const String checkMixCreation = "$baseUrl/mix/mixes/check/";
  static const String scanBarcode = "$baseUrl/mix/scan-barcode/";
  static const String manualProductEntry = "$baseUrl/mix/manual-product-entry/";
  static const String updateProduct = "$baseUrl/mix/product-update/";
  static const String updateScannedProduct =
      "$baseUrl/mix/update-scanned-product/";
  static const String inventory = "$baseUrl/mix/inventory/";
  static const String mixes = "$baseUrl/mix/mixes/";
  static const String newMixes = "$baseUrl/mix/mixes/new/";
  static String mixDetails(String mixId) => "$baseUrl/mix/mixes/$mixId/";
  static String deleteMix(int id) => "$baseUrl/mix/mixes/$id/";
  static const String appointmentList = "$baseUrl/appointment/list/";
  static const String availableSlots = "$baseUrl/appointment/available-slots/new/";
  static const String createAppointment = "$baseUrl/appointment/create/new/";
  static const String dashboardStats = "$baseUrl/appointment/dashboard/stats/";
  static const String mixStats = "$baseUrl/mix/mixes/stats/";
  static const String fetchProfile = "$baseUrl/auth/me/";
  static const String updateProfile = "$baseUrl/auth/profile/update/";
  static const String generateAppointmentUrl =
      "$baseUrl/appointment/generate-url/";
  static const String services = "$baseUrl/appointment/services/";
  static String serviceDetail(int id) => "$baseUrl/appointment/services/$id/";
  static const String shopProducts = "$baseUrl/mix/shop-products/";
  static const String missingProducts = "$baseUrl/retailer/missing-products/";
  static const String createCheckout = "$baseUrl/payment/create-checkout/";

  // Affiliate & Referral
  static const String myReferralCode = "$baseUrl/affiliate/referral/my-code/";
  static const String referralDashboard =
      "$baseUrl/affiliate/referral/dashboard/";
  static const String withdrawal = "$baseUrl/affiliate/referral/withdraw/";
  static const String subscriptionStatus =
      "$baseUrl/affiliate/subscription/status/";
  static const String subscriptionCreate =
      "$baseUrl/affiliate/subscription/create/";
  static const String searchReferrer = "$baseUrl/affiliate/referral/info/";

  // Expenses
  static const String expenses = "$baseUrl/mix/expenses/";

  // Earning Overview (income by mix creation + expense by product purchase)
  static String earningOverview({int? year}) {
    final y = year ?? DateTime.now().year;
    return "$baseUrl/mix/earning-overview/?year=$y";
  }

  // Accounts Overview (Monthly/Yearly)
  static String accountsOverview({
    required String filterType,
    required int year,
    int? month,
  }) {
    String url = "$baseUrl/mix/overview/?filter_type=$filterType&year=$year";
    if (month != null) {
      url += "&month=$month";
    }
    return url;
  }

  // Retailers
  static const String retailers = "$baseUrl/retailer/retailers/";
  static String retailerDetails(int retailerId) =>
      "$baseUrl/retailer/retailers/$retailerId/";

  // Product Details & Reviews
  static String productDetails(int productId) =>
      "$baseUrl/mix/shop-products/$productId/";
  static String productReviews(int productId) =>
      "$baseUrl/mix/shop-products/$productId/reviews/";
}
