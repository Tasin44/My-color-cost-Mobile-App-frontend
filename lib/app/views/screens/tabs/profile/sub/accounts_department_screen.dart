import 'package:color_os/app/core/constant/api_endpoints.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/core/services/api_services.dart';
import 'package:color_os/app/models/api_response.dart';
import 'package:color_os/app/models/accounts_overview_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AccountsDepartmentScreen extends StatefulWidget {
  const AccountsDepartmentScreen({Key? key}) : super(key: key);

  @override
  State<AccountsDepartmentScreen> createState() =>
      _AccountsDepartmentScreenState();
}

class _AccountsDepartmentScreenState extends State<AccountsDepartmentScreen> {
  final RxBool isLoading = false.obs;
  final Rx<AccountsOverviewModel?> accountsData = Rx<AccountsOverviewModel?>(
    null,
  );

  // Filter settings
  final RxString filterType = 'monthly'.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  @override
  void initState() {
    super.initState();
    _loadAccountsData();
  }

  Future<void> _loadAccountsData() async {
    try {
      isLoading.value = true;

      final year = selectedDate.value.year;
      final month = filterType.value == 'monthly'
          ? selectedDate.value.month
          : null;

      debugPrint('--- [Accounts Department] Loading Data ---');
      debugPrint('Filter Type: ${filterType.value}');
      debugPrint('Year: $year');
      debugPrint('Month: $month');

      final response = await ApiServices.getData(
        ApiEndpoints.accountsOverview(
          filterType: filterType.value,
          year: year,
          month: month,
        ),
      );

      debugPrint('--- [Accounts Department] Response ---');
      debugPrint('Status Code: ${response?.statusCode}');
      debugPrint('Response Data: ${response?.data}');

      if (response != null &&
          ApiResponse.isSuccessfulHttpStatus(response.statusCode) &&
          response.data != null) {
        final overview = AccountsOverviewModel.fromJson(response.data);
        accountsData.value = overview;

        debugPrint('--- [Accounts Department] Parsed Data ---');
        debugPrint('Total Income: ${overview.data.totalIncome}');
        debugPrint('Total Expense: ${overview.data.totalExpense}');
        debugPrint('Net Profit: ${overview.data.netProfit}');
      } else {
        Get.snackbar(
          'Error',
          'Failed to load accounts data',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('--- [Accounts Department] Error ---');
      debugPrint('Error: $e');
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _showMonthPicker() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected != null) {
      selectedDate.value = selected;
      _loadAccountsData();
    }
  }

  void _showYearPicker() {
    showDialog(
      context: context,
      builder: (context) {
        final currentYear = DateTime.now().year;
        return AlertDialog(
          title: const Text('Select Year'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: currentYear - 2019,
              itemBuilder: (context, index) {
                final year = currentYear - index;
                return ListTile(
                  title: Text(
                    year.toString(),
                    style: TextStyle(
                      fontWeight: year == selectedDate.value.year
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: year == selectedDate.value.year
                          ? AppColors.primaryColor
                          : Colors.black,
                    ),
                  ),
                  onTap: () {
                    selectedDate.value = DateTime(year, 1);
                    Navigator.pop(context);
                    _loadAccountsData();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Accounts Department',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: Obx(() {
        final data = accountsData.value;
        final loading = isLoading.value;

        return RefreshIndicator(
          onRefresh: _loadAccountsData,
          color: AppColors.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter Type Selector
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildFilterButton(
                          'Monthly',
                          filterType.value == 'monthly',
                          () {
                            filterType.value = 'monthly';
                            _loadAccountsData();
                          },
                        ),
                      ),
                      Expanded(
                        child: _buildFilterButton(
                          'Yearly',
                          filterType.value == 'yearly',
                          () {
                            filterType.value = 'yearly';
                            _loadAccountsData();
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Date Selector
                InkWell(
                  onTap: filterType.value == 'monthly'
                      ? _showMonthPicker
                      : _showYearPicker,
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.primaryColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: AppColors.primaryColor,
                              size: 20.sp,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              filterType.value == 'monthly'
                                  ? DateFormat(
                                      'MMMM yyyy',
                                    ).format(selectedDate.value)
                                  : selectedDate.value.year.toString(),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.primaryColor,
                          size: 24.sp,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // Loading or Data Display
                if (loading)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.h),
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  )
                else if (data != null) ...[
                  _buildSummaryCard(
                    'Total Income',
                    data.data.totalIncome,
                    Icons.trending_up,
                    Colors.green,
                  ),
                  SizedBox(height: 12.h),
                  _buildSummaryCard(
                    'Total Expense',
                    data.data.totalExpense,
                    Icons.trending_down,
                    Colors.red,
                  ),
                  SizedBox(height: 12.h),
                  _buildSummaryCard(
                    'Net Profit',
                    data.data.netProfit,
                    Icons.account_balance_wallet,
                    data.data.netProfit >= 0 ? Colors.blue : Colors.orange,
                  ),

                  SizedBox(height: 24.h),

                  // Period Info
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: 20.sp,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Showing ${data.data.filterType} data for ${data.data.filterMonth != null ? '${DateFormat('MMMM').format(DateTime(0, data.data.filterMonth!))} ' : ''}${data.data.filterYear}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.h),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No data available',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFilterButton(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.h,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 28.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '£${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
