import 'dart:convert';
import 'package:color_os/app/core/constant/api_endpoints.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/core/helper/sharedpref_helper.dart';
import 'package:color_os/app/core/services/api_services.dart';
import 'package:color_os/app/models/api_response.dart';
import 'package:color_os/app/models/accounts_overview_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AccountsDepartmentScreen extends StatefulWidget {
  const AccountsDepartmentScreen({Key? key}) : super(key: key);

  @override
  State<AccountsDepartmentScreen> createState() =>
      _AccountsDepartmentScreenState();
}

class _AccountsDepartmentScreenState extends State<AccountsDepartmentScreen> {
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final Rx<AccountsOverviewModel?> accountsData = Rx<AccountsOverviewModel?>(null);

  // Filter settings
  final RxString filterType = 'monthly'.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  // Editable controllers for total_income and total_expense
  final TextEditingController incomeCtrl = TextEditingController();
  final TextEditingController expenseCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAccountsData();
  }

  @override
  void dispose() {
    incomeCtrl.dispose();
    expenseCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAccountsData() async {
    try {
      isLoading.value = true;

      final year = selectedDate.value.year;
      final month =
          filterType.value == 'monthly' ? selectedDate.value.month : null;

      final response = await ApiServices.getData(
        ApiEndpoints.accountsDepartment(
          filterType: filterType.value,
          year: year,
          month: month,
        ),
      );

      if (response != null &&
          ApiResponse.isSuccessfulHttpStatus(response.statusCode) &&
          response.data != null) {
        
        final accountsDataPayload = AccountsData.fromJson(response.data);
        final overview = AccountsOverviewModel(
          success: response.success,
          statusCode: response.statusCode,
          message: response.message,
          data: accountsDataPayload,
        );

        accountsData.value = overview;

        // Pre-fill editable fields with server values
        incomeCtrl.text = overview.data.totalIncome.toStringAsFixed(2);
        expenseCtrl.text = overview.data.totalExpense.toStringAsFixed(2);

        debugPrint('Total Income: ${overview.data.totalIncome}');
        debugPrint('Total Expense: ${overview.data.totalExpense}');
        debugPrint('Total Color Cost: ${overview.data.totalColorCost}');
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
      debugPrint('Accounts Dept Error: $e');
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

  /// PATCH /mix/accounts_department/ — only sends total_income + total_expense
  /// total_color_cost and net_profit are always auto-computed by the backend.
  Future<void> _saveChanges() async {
    final income = double.tryParse(incomeCtrl.text);
    final expense = double.tryParse(expenseCtrl.text);

    if (income == null || expense == null) {
      Get.snackbar('Error', 'Please enter valid numbers',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isSaving.value = true;

      final year = selectedDate.value.year;
      final month =
          filterType.value == 'monthly' ? selectedDate.value.month : null;

      final currentData = accountsData.value?.data;
      final url = currentData?.id != null
          ? ApiEndpoints.accountsDepartmentOverride(currentData!.id!)
          : ApiEndpoints.accountsDepartment(
              filterType: filterType.value,
              year: year,
              month: month,
            );

      final token =
          await SharedprefHelper.getString(SharedprefHelper().token);
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'total_income': income.toStringAsFixed(2),
          'total_expense': expense.toStringAsFixed(2),
        }),
      );

      if (ApiResponse.isSuccessfulHttpStatus(response.statusCode)) {
        Get.snackbar(
          'Saved',
          'Changes saved successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        // Reload to get the updated net_profit from backend
        await _loadAccountsData();
      } else {
        Get.snackbar('Error', 'Failed to save changes',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('Error saving accounts: $e');
      Get.snackbar('Error', 'An error occurred: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> _deleteOverride() async {
    final currentData = accountsData.value?.data;
    if (currentData?.id == null) return;

    try {
      isSaving.value = true;
      final url = ApiEndpoints.accountsDepartmentOverride(currentData!.id!);
      final token = await SharedprefHelper.getString(SharedprefHelper().token);

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (ApiResponse.isSuccessfulHttpStatus(response.statusCode)) {
        Get.snackbar(
          'Reverted',
          'Successfully reverted to dynamically calculated totals',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        await _loadAccountsData();
      } else {
        Get.snackbar('Error', 'Failed to delete override',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('Error deleting override: $e');
      Get.snackbar('Error', 'An error occurred: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSaving.value = false;
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
                            Icon(Icons.calendar_today,
                                color: AppColors.primaryColor, size: 20.sp),
                            SizedBox(width: 12.w),
                            Text(
                              filterType.value == 'monthly'
                                  ? DateFormat('MMMM yyyy')
                                      .format(selectedDate.value)
                                  : selectedDate.value.year.toString(),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.arrow_drop_down,
                            color: AppColors.primaryColor, size: 24.sp),
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
                          color: AppColors.primaryColor),
                    ),
                  )
                else if (data != null) ...[

                  // ── EDITABLE: Total Income ──────────────────────────────
                  _buildEditableCard(
                    title: 'Total Income',
                    subtitle: 'What clients were charged',
                    controller: incomeCtrl,
                    icon: Icons.trending_up,
                    color: Colors.green,
                    isEditable: true,
                  ),
                  SizedBox(height: 12.h),

                  // ── EDITABLE: Total Expense ─────────────────────────────
                  _buildEditableCard(
                    title: 'Total Expense',
                    subtitle: 'Your business expenses',
                    controller: expenseCtrl,
                    icon: Icons.trending_down,
                    color: Colors.red,
                    isEditable: true,
                  ),
                  SizedBox(height: 12.h),

                  // ── READ-ONLY: Total Color Cost ─────────────────────────
                  _buildReadOnlyCard(
                    title: 'Total Color Cost',
                    subtitle: 'Auto-computed from bowl products',
                    amount: data.data.totalColorCost,
                    icon: Icons.palette_outlined,
                    color: Colors.orange,
                  ),
                  SizedBox(height: 12.h),

                  // ── READ-ONLY: Net Profit ───────────────────────────────
                  _buildReadOnlyCard(
                    title: 'Net Profit',
                    subtitle: 'Income − Expense − Color Cost',
                    amount: data.data.netProfit,
                    icon: Icons.account_balance_wallet,
                    color: data.data.netProfit >= 0
                        ? Colors.blue
                        : Colors.orange,
                  ),

                  SizedBox(height: 24.h),

                  // Period info
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.blue.shade700, size: 18.sp),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'Showing ${data.data.filterType} data for '
                            '${data.data.month != null ? '${DateFormat('MMMM').format(DateTime(0, data.data.month!))} ' : ''}'
                            '${data.data.year}',
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.blue.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Save button
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton.icon(
                        onPressed:
                            isSaving.value ? null : _saveChanges,
                        icon: isSaving.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.save_outlined,
                                color: Colors.white),
                        label: Text(
                          isSaving.value ? 'Saving…' : 'Save Changes',
                          style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),

                  // Delete override button (only if override is active)
                  if (data.data.id != null) ...[
                    SizedBox(height: 12.h),
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: OutlinedButton.icon(
                          onPressed: isSaving.value ? null : _deleteOverride,
                          icon: Icon(Icons.restore,
                              color: isSaving.value
                                  ? Colors.grey
                                  : Colors.red.shade400),
                          label: Text(
                            isSaving.value ? 'Reverting…' : 'Revert to Default',
                            style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: isSaving.value
                                    ? Colors.grey
                                    : Colors.red.shade400),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: isSaving.value
                                    ? Colors.grey.shade300
                                    : Colors.red.shade200),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ] else
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.h),
                      child: Column(
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 64.sp, color: Colors.grey),
                          SizedBox(height: 16.h),
                          Text('No data available',
                              style: TextStyle(
                                  fontSize: 16.sp, color: Colors.grey)),
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

  Widget _buildFilterButton(
      String label, bool isSelected, VoidCallback onTap) {
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

  /// Editable card — user can type a new value for total_income / total_expense
  Widget _buildEditableCard({
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required IconData icon,
    required Color color,
    required bool isEditable,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.h,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: color, size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[500])),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text('Editable',
                    style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87),
            decoration: InputDecoration(
              prefixText: '£',
              prefixStyle: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: color),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w, vertical: 12.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide:
                    BorderSide(color: color, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Read-only card — total_color_cost and net_profit are always computed by backend
  Widget _buildReadOnlyCard({
    required String title,
    required String subtitle,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
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
                Row(
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500)),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Text('Auto',
                          style: TextStyle(
                              fontSize: 9.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 11.sp, color: Colors.grey[400])),
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
