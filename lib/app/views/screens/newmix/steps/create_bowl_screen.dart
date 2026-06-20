import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/controllers/new_mix_controller.dart';

class CreateBowlScreen extends StatefulWidget {
  const CreateBowlScreen({Key? key}) : super(key: key);

  @override
  State<CreateBowlScreen> createState() => _CreateBowlScreenState();
}

class _CreateBowlScreenState extends State<CreateBowlScreen> {
  final TextEditingController serviceNameController = TextEditingController();
  final TextEditingController mixNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late NewMixController mixController;

  @override
  void initState() {
    super.initState();
    mixController = Get.find<NewMixController>();

    // Pre-fill with suggestions
    final bowlCount = mixController.bowls.length;
    mixNameController.text = 'Bowl ${bowlCount + 1} Mix';
  }

  @override
  void dispose() {
    serviceNameController.dispose();
    mixNameController.dispose();
    super.dispose();
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
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: Colors.black87, size: 24.sp),
        ),
        title: Text(
          'Add Bowl',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Context banner
              Obx(() {
                final service = mixController.selectedServiceType.value;
                final client = mixController.selectedClient.value;
                final existingBowls = mixController.bowls.length;

                return Container(
                  padding: EdgeInsets.all(14.w),
                  margin: EdgeInsets.only(bottom: 24.h),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person_outline,
                              size: 18.sp, color: AppColors.primaryColor),
                          SizedBox(width: 8.w),
                          Text(
                            'Client: ${client?.name ?? 'Unknown'}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(Icons.spa_outlined,
                              size: 18.sp, color: AppColors.primaryColor),
                          SizedBox(width: 8.w),
                          Text(
                            'Service: ${service?.name ?? 'Unknown'}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (existingBowls > 0) ...[
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Icon(Icons.layers_outlined,
                                size: 18.sp, color: Colors.green),
                            SizedBox(width: 8.w),
                            Text(
                              '$existingBowls bowl${existingBowls > 1 ? 's' : ''} already added',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              }),

              // Mix Name
              Text(
                'Mix Name',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: mixNameController,
                textCapitalization: TextCapitalization.words,
                style: TextStyle(fontSize: 15.sp, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Enter mix name',
                  hintStyle:
                      TextStyle(fontSize: 15.sp, color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.science_outlined,
                      color: Colors.grey[400], size: 20.sp),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 16.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide:
                        BorderSide(color: AppColors.primaryColor, width: 1.5),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Mix name is required'
                    : null,
              ),

              SizedBox(height: 20.h),

              // Service Name (per bowl)
              Text(
                'Service Name',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: serviceNameController,
                textCapitalization: TextCapitalization.words,
                style: TextStyle(fontSize: 15.sp, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Enter service name',
                  hintStyle:
                      TextStyle(fontSize: 15.sp, color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.cut_outlined,
                      color: Colors.grey[400], size: 20.sp),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 16.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide:
                        BorderSide(color: AppColors.primaryColor, width: 1.5),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Service name is required'
                    : null,
              ),

              SizedBox(height: 40.h),

              // Select Product Button
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;

                    mixController.createNewBowl(
                      serviceNameController.text.trim(),
                      mixNameController.text.trim(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Select Product',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
