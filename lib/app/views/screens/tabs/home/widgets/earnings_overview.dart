import 'package:color_os/app/controllers/home_controller.dart';
import 'package:color_os/app/models/financial_overview_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class EarningsOverview extends StatelessWidget {
  const EarningsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(width: 0.7, color: Colors.grey.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title row ──────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Earning Overview',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              // Monthly / Yearly toggle
              Obx(() => _ViewToggle(
                    isYearly: controller.isYearlyView.value,
                    onToggle: controller.toggleChartView,
                  )),
            ],
          ),

          SizedBox(height: 24.h),

          // ── Year navigation (monthly view only) ───────────────────────
          Obx(() {
            if (controller.isYearlyView.value) return const SizedBox.shrink();
            return _YearNavigator(
              year: controller.selectedYear.value,
              canGoNext: controller.selectedYear.value < DateTime.now().year,
              onPrevious: controller.previousYear,
              onNext: controller.nextYear,
            );
          }),

          SizedBox(height: 24.h),

          // ── Legend ────────────────────────────────────────────────────
          Wrap(
            spacing: 16.w,
            runSpacing: 8.h,
            children: [
              _legendItem('Income by mix creation', const Color(0xFF2196F3)),
              _legendItem(
                'Expense by product purchase',
                const Color(0xFF4CAF50),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // ── Chart area ────────────────────────────────────────────────
          SizedBox(
            height: 200.h,
            child: Obx(() {
              final isYearly = controller.isYearlyView.value;

              if (isYearly) {
                if (controller.isLoadingYearly.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.yearlyIncomeData.isEmpty) {
                  return _noData();
                }
                return EarningsChart(
                  incomeData: controller.yearlyIncomeData,
                  expenseData: controller.yearlyExpenseData,
                );
              } else {
                if (controller.isLoadingFinancialOverview.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final overview = controller.financialOverview.value;
                if (overview == null || !overview.hasData) {
                  return _noData();
                }
                return EarningsChart(
                  incomeData: overview.incomeByMixCreation,
                  expenseData: overview.expenseByProductPurchase,
                );
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.black54)),
      ],
    );
  }

  Widget _noData() {
    return Center(
      child: Text(
        'No data available',
        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
      ),
    );
  }
}

// ── Toggle widget ──────────────────────────────────────────────────────────────

class _ViewToggle extends StatelessWidget {
  final bool isYearly;
  final VoidCallback onToggle;

  const _ViewToggle({required this.isYearly, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        height: 30.h,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.grey.shade300, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _tab('Monthly', !isYearly),
            SizedBox(width: 4.w),
            _tab('Yearly', isYearly),
          ],
        ),
      ),
    );
  }

  Widget _tab(String label, bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      height: double.infinity,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF2196F3) : Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: active ? Colors.white : Colors.grey.shade600,
        ),
      ),
    );
  }
}

// ── Year navigator widget ─────────────────────────────────────────────────────

class _YearNavigator extends StatelessWidget {
  final int year;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _YearNavigator({
    required this.year,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _arrowBtn(Icons.chevron_left, onPrevious, true),
        SizedBox(width: 8.w),
        Text(
          year.toString(),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(width: 8.w),
        _arrowBtn(Icons.chevron_right, onNext, canGoNext),
      ],
    );
  }

  Widget _arrowBtn(IconData icon, VoidCallback onTap, bool enabled) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 26.w,
        height: 26.w,
        decoration: BoxDecoration(
          color: enabled ? Colors.grey.shade100 : Colors.grey.shade50,
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled ? Colors.grey.shade300 : Colors.grey.shade200,
          ),
        ),
        child: Icon(
          icon,
          size: 16.sp,
          color: enabled ? Colors.black87 : Colors.grey.shade400,
        ),
      ),
    );
  }
}

// ── Reusable line chart ───────────────────────────────────────────────────────

class EarningsChart extends StatelessWidget {
  final List<MonthlyAmount> incomeData;
  final List<MonthlyAmount> expenseData;

  const EarningsChart({
    super.key,
    required this.incomeData,
    required this.expenseData,
  });

  @override
  Widget build(BuildContext context) {
    final count =
        incomeData.length > expenseData.length
            ? incomeData.length
            : expenseData.length;
    if (count == 0) return const SizedBox.shrink();

    double maxIncome = 0;
    double maxExpense = 0;
    for (final m in incomeData) {
      if (m.amount > maxIncome) maxIncome = m.amount;
    }
    for (final m in expenseData) {
      if (m.amount > maxExpense) maxExpense = m.amount;
    }
    double maxY = (maxIncome > maxExpense ? maxIncome : maxExpense) * 1.2;
    if (maxY == 0) maxY = 1000;
    final interval = maxY / 5;

    final incomeSpots = List.generate(
      incomeData.length,
      (i) => FlSpot(i.toDouble(), incomeData[i].amount),
    );
    final expenseSpots = List.generate(
      expenseData.length,
      (i) => FlSpot(i.toDouble(), expenseData[i].amount),
    );

    final labels =
        incomeData.isNotEmpty
            ? incomeData.map((m) => m.month).toList()
            : expenseData.map((m) => m.month).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < labels.length) {
                  return Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      labels[idx],
                      style: TextStyle(color: Colors.black54, fontSize: 10.sp),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: interval,
              reservedSize: 45,
              getTitlesWidget: (value, meta) {
                if (value == 0) {
                  return Text(
                    '0',
                    style: TextStyle(color: Colors.black54, fontSize: 11.sp),
                  );
                }
                if (value >= 1000) {
                  return Text(
                    '£${(value / 1000).toStringAsFixed(1)}k',
                    style: TextStyle(color: Colors.black54, fontSize: 11.sp),
                  );
                }
                return Text(
                  '£${value.toInt()}',
                  style: TextStyle(color: Colors.black54, fontSize: 11.sp),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (count - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          // Income — blue
          LineChartBarData(
            spots: incomeSpots,
            isCurved: true,
            color: const Color(0xFF2196F3),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                if (index == incomeSpots.length - 1) {
                  return FlDotCirclePainter(
                    radius: 5,
                    color: const Color(0xFF2196F3),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                }
                return FlDotCirclePainter(
                  radius: 0,
                  color: Colors.transparent,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF2196F3).withOpacity(0.06),
            ),
          ),
          // Expense — green
          LineChartBarData(
            spots: expenseSpots,
            isCurved: true,
            color: const Color(0xFF4CAF50),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF4CAF50).withOpacity(0.06),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final label = spot.barIndex == 0 ? 'Income' : 'Expense';
                return LineTooltipItem(
                  '$label\n£${spot.y.toStringAsFixed(2)}',
                  TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                );
              }).toList();
            },
          ),
          getTouchedSpotIndicator: (barData, spotIndexes) {
            return spotIndexes.map((idx) {
              return TouchedSpotIndicatorData(
                FlLine(
                  color: Colors.grey.withOpacity(0.5),
                  strokeWidth: 2,
                  dashArray: [5, 5],
                ),
                FlDotData(
                  getDotPainter: (spot, percent, bar, index) {
                    return FlDotCirclePainter(
                      radius: 6,
                      color: bar.color ?? Colors.blue,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  },
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}
