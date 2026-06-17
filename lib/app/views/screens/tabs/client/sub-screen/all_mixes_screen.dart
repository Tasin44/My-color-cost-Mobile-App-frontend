import 'package:color_os/app/controllers/new_mix_controller.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/models/mix_model.dart';
import 'package:color_os/app/views/screens/tabs/client/widgets/mix_details_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AllMixesScreen extends StatefulWidget {
  const AllMixesScreen({super.key});

  @override
  State<AllMixesScreen> createState() => _AllMixesScreenState();
}

class _AllMixesScreenState extends State<AllMixesScreen> {
  final NewMixController _mixController = Get.find<NewMixController>();
  List<MixModel> _mixes = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchMixes();
  }

  Future<void> _fetchMixes() async {
    setState(() => _isLoading = true);
    final mixes = await _mixController.getAllMixes();
    setState(() {
      _mixes = mixes;
      _isLoading = false;
    });
  }

  List<MixModel> get _filteredMixes {
    if (_searchQuery.isEmpty) return _mixes;
    return _mixes.where((mix) {
      return mix.mixName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          mix.serviceType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (mix.clientName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  Future<void> _confirmDeleteMix(MixModel mix) async {
    final mixId = int.tryParse(mix.id);
    if (mixId == null) {
      Get.snackbar(
        'Error',
        'Invalid mix ID',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Mix'),
        content: Text(
          'Are you sure you want to delete "${mix.mixName}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading while API call is in-flight
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
      barrierDismissible: false,
    );

    final success = await _mixController.deleteMix(mixId);
    Get.back(); // close loading dialog

    if (success) {
      setState(() {
        _mixes.removeWhere((m) => m.id == mix.id);
      });
    }
  }

  Future<void> _showMixDetails(MixModel basicMix) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
      barrierDismissible: false,
    );

    try {
      final detailedMix = await _mixController.fetchMixDetails(basicMix.id);
      Get.back(); // close dialog
      
      if (detailedMix != null) {
        Get.bottomSheet(
          MixDetailsBottomSheet(mix: detailedMix),
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
        );
      }
    } catch (e) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'All Mixes',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search mixes...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 14.h),
              ),
            ),
          ),

          // Mix List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchMixes,
              color: AppColors.primaryColor,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredMixes.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
                          itemCount: _filteredMixes.length,
                          itemBuilder: (context, index) {
                            return _buildMixItem(_filteredMixes[index]);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: 500.h,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.science_outlined, size: 60.sp, color: Colors.grey[300]),
            SizedBox(height: 16.h),
            Text(
              'No mixes found',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMixItem(MixModel mix) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: InkWell(
        onTap: () => _showMixDetails(mix),
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      Icons.science,
                      color: AppColors.primaryColor,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mix.mixName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          mix.serviceType,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '£${mix.profit.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.green.shade700,
                        ),
                      ),
                      Text(
                        'PROFIT',
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      GestureDetector(
                        onTap: () => _confirmDeleteMix(mix),
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.delete_outline,
                            color: Colors.red.shade400,
                            size: 16.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Divider(height: 1, color: Colors.grey[50]),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 14.sp, color: Colors.grey[400]),
                      SizedBox(width: 6.w),
                      Text(
                        DateFormat('dd MMM yyyy').format(mix.date),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 12.sp, color: Colors.grey[500]),
                        SizedBox(width: 4.w),
                        Text(
                          '${mix.productCount} Products',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
