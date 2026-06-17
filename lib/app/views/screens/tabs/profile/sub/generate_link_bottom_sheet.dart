import 'package:color_os/app/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';

class GenerateLinkBottomSheet extends StatefulWidget {
  const GenerateLinkBottomSheet({Key? key}) : super(key: key);

  @override
  State<GenerateLinkBottomSheet> createState() =>
      _GenerateLinkBottomSheetState();
}

class _GenerateLinkBottomSheetState extends State<GenerateLinkBottomSheet> {
  final ProfileController controller = Get.find<ProfileController>();
  final TextEditingController _serviceController = TextEditingController();
  final List<String> _services = [];
  final FocusNode _focusNode = FocusNode();

  // When non-null, the sheet switches to the success view.
  String? _generatedLink;

  @override
  void dispose() {
    _serviceController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addService(String value) {
    final trimmed = value.trim().replaceAll(',', '');
    if (trimmed.isNotEmpty && !_services.contains(trimmed)) {
      setState(() {
        _services.add(trimmed);
      });
    }
    _serviceController.clear();
    _focusNode.requestFocus();
  }

  void _removeService(String service) {
    setState(() {
      _services.remove(service);
    });
  }

  void _copyLink() {
    if (_generatedLink == null) return;
    Clipboard.setData(ClipboardData(text: _generatedLink!));
    Get.snackbar(
      'Copied!',
      'Booking link copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Transparent tap-to-close strip
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(color: Colors.transparent, height: 40.h),
        ),
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 16.h),
                      width: 45.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),

                    // ── Success view (shown after link is generated) ──────
                    if (_generatedLink != null) ...[
                      _buildSuccessView(context),
                    ] else ...[

                    // ── Form view ────────────────────────────────────────
                    Flexible(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 24.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Generate Link',
                                        style: AppTextStyle.headlineSmall.copyWith(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 22.sp,
                                        ),
                                      ),
                                      SizedBox(height: 6.h),
                                      Text(
                                        'Create a direct booking link for your clients',
                                        style: AppTextStyle.bodySmall.copyWith(
                                          color: Colors.grey[500],
                                          fontSize: 13.sp,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor.withOpacity(0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.link_rounded,
                                    color: AppColors.primaryColor,
                                    size: 26.sp,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 28.h),

                            // Wrap for Chips
                            if (_services.isNotEmpty)
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16.w),
                                margin: EdgeInsets.only(bottom: 24.h),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Wrap(
                                  spacing: 10.w,
                                  runSpacing: 10.h,
                                  children: _services.map((service) {
                                    return Chip(
                                      label: Text(
                                        service,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      backgroundColor: AppColors.primaryColor,
                                      elevation: 0,
                                      deleteIcon: Icon(
                                        Icons.close_rounded,
                                        size: 16.sp,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                      onDeleted: () => _removeService(service),
                                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.r),
                                        side: BorderSide.none,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),

                            // Text Field Area
                            Text(
                              'Service Details',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[800],
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _serviceController,
                                    focusNode: _focusNode,
                                    textInputAction: TextInputAction.done,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'e.g. Hair Cut, Styling',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 14.sp,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 18.w,
                                        vertical: 16.h,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16.r),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16.r),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16.r),
                                        borderSide: BorderSide(
                                          color: AppColors.primaryColor,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      if (value.contains(',')) {
                                        final parts = value.split(',');
                                        for (var part in parts) {
                                          final trimmed = part.trim();
                                          if (trimmed.isNotEmpty) {
                                            if (!_services.contains(trimmed)) {
                                              setState(() {
                                                _services.add(trimmed);
                                              });
                                            }
                                          }
                                        }
                                        _serviceController.clear();
                                      }
                                    },
                                    onSubmitted: (value) => _addService(value),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                GestureDetector(
                                  onTap: () => _addService(_serviceController.text),
                                  child: Container(
                                    width: 54.w,
                                    height: 54.h,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(16.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryColor
                                              .withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.add_rounded,
                                      color: Colors.white,
                                      size: 32.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24.h),

                            // Tips/Instructions
                            Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: Colors.blue.shade100.withOpacity(0.5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.tips_and_updates_outlined,
                                    size: 20.sp,
                                    color: Colors.blue.shade700,
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      'Expert Tip: Separate multiple services using a comma to add them quickly.',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.blue.shade800,
                                        fontWeight: FontWeight.w600,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Generate Button - Fixed at bottom
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(
                        24.w,
                        16.h,
                        24.w,
                        24.h + MediaQuery.of(context).padding.bottom,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Obx(
                        () => SizedBox(
                          height: 56.h,
                          child: ElevatedButton(
                            onPressed: controller.isGeneratingLink.value
                                ? null
                                : () async {
                                    if (_services.isEmpty) {
                                      Get.snackbar(
                                        'Just a second',
                                        'Please add at least one service to continue',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.amber.shade700,
                                        colorText: Colors.white,
                                      );
                                      return;
                                    }
                                    final success = await controller
                                        .generateAppointmentLink(_services);
                                    if (success && mounted) {
                                      // Switch to success view — keep sheet
                                      // open so user can copy the URL.
                                      setState(() {
                                        _generatedLink =
                                            controller.appointmentLink.value;
                                      });
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.r),
                              ),
                              elevation: 0,
                            ),
                            child: controller.isGeneratingLink.value
                                ? SizedBox(
                                    width: 24.w,
                                    height: 24.w,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : Text(
                                    'Generate Link',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    ], // closes else (form view)
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Success view ──────────────────────────────────────────────────────────
  Widget _buildSuccessView(BuildContext context) {
    final link = _generatedLink ?? '';
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24.w,
        8.h,
        24.w,
        24.h + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success icon
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9B26AF), Color(0xFFE0177A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, color: Colors.white, size: 38.sp),
          ),
          SizedBox(height: 16.h),
          Text(
            'Link Generated!',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Share this link with your clients so they can book directly.',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          // URL box
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking URL',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 6.h),
                SelectableText(
                  link,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // Copy button
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton.icon(
              onPressed: _copyLink,
              icon: Icon(Icons.copy_rounded, size: 18.sp),
              label: Text(
                'Copy Link',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 0,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          // Done button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Text(
                'Done',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
