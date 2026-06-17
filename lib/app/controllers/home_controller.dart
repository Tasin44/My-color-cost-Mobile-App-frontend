import 'package:color_os/app/controllers/auth_controller.dart';
import 'package:color_os/app/controllers/working_hours_controller.dart';
import 'package:color_os/app/core/constant/api_endpoints.dart';
import 'package:color_os/app/core/services/api_services.dart';
import 'package:color_os/app/models/api_response.dart';
import 'package:color_os/app/models/appointment_model.dart';
import 'package:color_os/app/models/dashboard_stats_model.dart';
import 'package:color_os/app/models/financial_overview_model.dart';
import 'package:color_os/app/models/mix_stats_model.dart';
import 'package:color_os/app/models/stat_card_model.dart';
import 'package:color_os/app/views/screens/onboarding/working_hours_setup_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  // Observable statistics
  final RxList<StatCardModel> stats = <StatCardModel>[].obs;

  // Observable appointments
  final RxList<AppointmentModel> todayAppointmentsList =
      <AppointmentModel>[].obs;

  // Observable for total revenue
  final RxDouble totalRevenue = 0.0.obs;

  // Observable for earnings data (for chart)
  final RxList<double> earningsData = <double>[].obs;

  final RxBool isLoading = false.obs;

  // Store full mix stats for detailed display
  final Rx<MixStatsModel?> mixStatsData = Rx<MixStatsModel?>(null);

  // Financial overview data — monthly view
  final Rx<FinancialOverviewModel?> financialOverview =
      Rx<FinancialOverviewModel?>(null);
  final RxBool isLoadingFinancialOverview = false.obs;

  // Chart view toggle: false = monthly, true = yearly
  final RxBool isYearlyView = false.obs;

  // Selected year for the monthly chart (navigation arrows)
  final RxInt selectedYear = DateTime.now().year.obs;

  // Yearly chart data — aggregated annual totals for last 5 years
  final RxList<MonthlyAmount> yearlyIncomeData = <MonthlyAmount>[].obs;
  final RxList<MonthlyAmount> yearlyExpenseData = <MonthlyAmount>[].obs;
  final RxBool isLoadingYearly = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize stats with placeholders for mix statistics
    stats.value = [
      StatCardModel(
        id: '1',
        title: 'Total Mixes',
        value: '0',
        change: '',
        isPositive: true,
      ),
      StatCardModel(
        id: '2',
        title: 'Total Revenue',
        value: '£0.00',
        change: '',
        isPositive: true,
      ),
      StatCardModel(
        id: '3',
        title: 'Total Profit',
        value: '£0.00',
        change: '',
        isPositive: true,
      ),
      StatCardModel(
        id: '4',
        title: 'Total Cost',
        value: '£0.00',
        change: '',
        isPositive: true,
      ),
    ];
    refreshData();
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchMixStats(),
        fetchDashboardStats(),
        fetchTodayAppointments(),
        fetchFinancialOverview(),
        _checkWorkingHoursStatus(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _checkWorkingHoursStatus() async {
    try {
      // Only skip for confirmed staff — if user is null (not yet loaded), proceed anyway.
      // Staff do not need to set up working hours.
      if (Get.isRegistered<AuthController>()) {
        final user = Get.find<AuthController>().user.value;
        if (user != null && user.isStaff) return;
      }

      if (!Get.isRegistered<WorkingHoursController>()) {
        Get.put(WorkingHoursController());
      }
      final workingHoursController = Get.find<WorkingHoursController>();
      await workingHoursController.fetchWorkingHoursStatus();

      // is_locked = false means working hours have NOT been set yet.
      if (workingHoursController.isLocked.value == false) {
        debugPrint(
          '[HomeController] Working hours not set (is_locked=false). '
          'Navigating to setup screen.',
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.to(() => const WorkingHoursSetupSheet());
        });
      } else {
        debugPrint('[HomeController] Working hours already set (is_locked=true).');
      }
    } catch (e) {
      debugPrint('[HomeController] Error checking working hours status: $e');
    }
  }

  Future<void> fetchDashboardStats() async {
    try {
      final response = await ApiServices.getData(ApiEndpoints.dashboardStats);
      if (response != null &&
          ApiResponse.isSuccessfulHttpStatus(response.statusCode) &&
          response.data != null) {
        final data = response.data['data'];

        // Handle null data safely
        final dashboardStats = data != null
            ? DashboardStatsModel.fromJson(data)
            : DashboardStatsModel.empty();

        // Update only Client and Appointment related cards
        updateStat('1', dashboardStats.totalClients.toString(), '', true);
        updateStat(
          '3',
          dashboardStats.totalPendingAppointments.toString(),
          '',
          true,
        );

        // totalRevenue.value = dashboardStats.totalProfit; // Let fetchMixStats handle revenue
      }
    } catch (e) {
      debugPrint('Error fetching dashboard stats: $e');
    }
  }

  Future<void> fetchMixStats() async {
    try {
      debugPrint('--- [HomeController] Fetching Mix Stats ---');
      debugPrint('API Endpoint: ${ApiEndpoints.mixStats}');

      final response = await ApiServices.getData(ApiEndpoints.mixStats);

      debugPrint('--- [HomeController] Mix Stats Response ---');
      debugPrint('Response: $response');
      debugPrint('Status Code: ${response?.statusCode}');
      debugPrint('Response Data: ${response?.data}');

      if (response != null &&
          ApiResponse.isSuccessfulHttpStatus(response.statusCode) &&
          response.data != null) {
        // The stats are directly in response.data, not nested under 'data' key
        final data = response.data;

        debugPrint('--- [HomeController] Extracted Data ---');
        debugPrint('Data: $data');

        final mixStats = data != null
            ? MixStatsModel.fromJson(data)
            : MixStatsModel.empty();

        debugPrint('--- [HomeController] Parsed Mix Stats ---');
        debugPrint('Total Mixes: ${mixStats.totalMixes}');
        debugPrint('Total Profit: ${mixStats.totalProfit}');
        debugPrint('Total Revenue: ${mixStats.totalRevenue}');
        debugPrint('Total Cost: ${mixStats.totalCost}');
        debugPrint('Mixes This Month: ${mixStats.mixesThisMonth}');
        debugPrint('Most Used Service: ${mixStats.mostUsedServiceType}');

        // Store full mix stats data
        mixStatsData.value = mixStats;

        // Update all stat cards with mix statistics
        // [0] Total Mixes
        // [1] Total Revenue
        // [2] Total Profit
        // [3] Total Cost

        updateStat(
          '1',
          mixStats.totalMixes.toString(),
          '${mixStats.mixesThisMonth} this month',
          true,
        );

        updateStat(
          '2',
          '£${mixStats.totalRevenue.toStringAsFixed(2)}',
          '',
          true,
        );

        updateStat(
          '3',
          '£${mixStats.totalProfit.toStringAsFixed(2)}',
          '',
          mixStats.totalProfit >= 0,
        );

        updateStat('4', '£${mixStats.totalCost.toStringAsFixed(2)}', '', true);

        totalRevenue.value = mixStats.totalRevenue;

        debugPrint('--- [HomeController] Stats Updated Successfully ---');
      } else {
        debugPrint('--- [HomeController] Invalid Response ---');
        debugPrint('Response is null or invalid status code');
      }
    } catch (e) {
      debugPrint('--- [HomeController] Error fetching mix stats ---');
      debugPrint('Error: $e');
    }
  }

  Future<void> fetchTodayAppointments() async {
    try {
      final response = await ApiServices.getData(
        '${ApiEndpoints.appointmentList}?today=true',
      );
      if (response != null &&
          ApiResponse.isSuccessfulHttpStatus(response.statusCode) &&
          response.data != null) {
        final data = response.data['data'];

        if (data != null && data is List) {
          todayAppointmentsList.value = data
              .map((e) => AppointmentModel.fromJson(e))
              .toList();
        } else {
          todayAppointmentsList.clear();
        }
      }
    } catch (e) {
      debugPrint('Error fetching today appointments: $e');
    }
  }

  // Get today's appointments getter wrapper
  List<AppointmentModel> get todayAppointments => todayAppointmentsList;

  // Update stat value
  void updateStat(
    String statId,
    String newValue,
    String newChange,
    bool isPositive,
  ) {
    final index = stats.indexWhere((stat) => stat.id == statId);
    if (index != -1) {
      stats[index] = stats[index].copyWith(
        value: newValue,
        change: newChange,
        isPositive: isPositive,
      );
    }
  }

  Future<void> fetchFinancialOverview({int? year}) async {
    try {
      isLoadingFinancialOverview.value = true;

      final targetYear = year ?? selectedYear.value;
      final endpoint = ApiEndpoints.earningOverview(year: targetYear);
      debugPrint('--- [HomeController] Fetching Earning Overview: $endpoint');

      final response = await ApiServices.getData(endpoint);

      debugPrint('Status: ${response?.statusCode} | Data: ${response?.data}');

      if (response != null && response.data != null) {
        final overview = FinancialOverviewModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        financialOverview.value = overview;

        debugPrint(
          'Income months: ${overview.incomeByMixCreation.length}, '
          'Expense months: ${overview.expenseByProductPurchase.length}',
        );
      } else {
        debugPrint('--- [HomeController] Invalid Earning Overview Response ---');
      }
    } catch (e) {
      debugPrint('--- [HomeController] Error fetching earning overview: $e');
    } finally {
      isLoadingFinancialOverview.value = false;
    }
  }

  /// Toggle between monthly and yearly chart views.
  void toggleChartView() {
    isYearlyView.value = !isYearlyView.value;
    if (isYearlyView.value && yearlyIncomeData.isEmpty) {
      fetchYearlyOverview();
    }
  }

  /// Navigate to the next year (monthly view).
  void nextYear() {
    if (selectedYear.value < DateTime.now().year) {
      selectedYear.value++;
      fetchFinancialOverview(year: selectedYear.value);
    }
  }

  /// Navigate to the previous year (monthly view).
  void previousYear() {
    selectedYear.value--;
    fetchFinancialOverview(year: selectedYear.value);
  }

  /// Fetch the last 5 years of data and aggregate into annual totals.
  Future<void> fetchYearlyOverview() async {
    try {
      isLoadingYearly.value = true;

      final currentYear = DateTime.now().year;
      final years = List.generate(5, (i) => currentYear - 4 + i);

      debugPrint('--- [HomeController] Fetching yearly overview for: $years');

      final results = await Future.wait(
        years.map((y) => ApiServices.getData(ApiEndpoints.earningOverview(year: y))),
      );

      final incomeList = <MonthlyAmount>[];
      final expenseList = <MonthlyAmount>[];

      for (int i = 0; i < years.length; i++) {
        final res = results[i];
        double annualIncome = 0;
        double annualExpense = 0;

        if (res != null && res.data != null) {
          final model = FinancialOverviewModel.fromJson(
            res.data as Map<String, dynamic>,
          );
          annualIncome = model.incomeByMixCreation.fold(
            0.0,
            (sum, m) => sum + m.amount,
          );
          annualExpense = model.expenseByProductPurchase.fold(
            0.0,
            (sum, m) => sum + m.amount,
          );
        }

        incomeList.add(MonthlyAmount(month: years[i].toString(), amount: annualIncome));
        expenseList.add(MonthlyAmount(month: years[i].toString(), amount: annualExpense));
      }

      yearlyIncomeData.value = incomeList;
      yearlyExpenseData.value = expenseList;

      debugPrint('--- [HomeController] Yearly overview fetched ---');
    } catch (e) {
      debugPrint('--- [HomeController] Error fetching yearly overview: $e');
    } finally {
      isLoadingYearly.value = false;
    }
  }
}
