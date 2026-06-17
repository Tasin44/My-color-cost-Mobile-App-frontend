import 'package:color_os/app/controllers/service_controller.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/models/service_type_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CreateEditServiceScreen extends StatefulWidget {
  final ServiceTypeModel? service;

  const CreateEditServiceScreen({super.key, this.service});

  @override
  State<CreateEditServiceScreen> createState() =>
      _CreateEditServiceScreenState();
}

class _CreateEditServiceScreenState extends State<CreateEditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final ServiceController _controller = Get.find<ServiceController>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _feeController;

  int _selectedDuration = 30; // Default 30 min
  String _selectedPriceType = 'fixed'; // Default fixed

  final List<int> _durations = [15, 30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.service?.description ?? '');
    _feeController =
        TextEditingController(text: widget.service?.serviceFee ?? '');

    if (widget.service != null) {
      _selectedDuration = widget.service!.serviceTimeMinutes;
      if (!_durations.contains(_selectedDuration)) {
        _durations.add(_selectedDuration);
        _durations.sort();
      }
      _selectedPriceType = widget.service!.priceType.toLowerCase();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      bool success;
      if (widget.service == null) {
        // Create
        success = await _controller.createService(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          serviceTimeMinutes: _selectedDuration,
          priceType: _selectedPriceType,
          serviceFee: _selectedPriceType != 'free' ? _feeController.text.trim() : null,
        );
      } else {
        // Update
        success = await _controller.updateService(
          id: widget.service!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          serviceTimeMinutes: _selectedDuration,
          priceType: _selectedPriceType,
          serviceFee: _selectedPriceType != 'free' ? _feeController.text.trim() : null,
        );
      }

      if (success) {
        Get.back();
        Get.snackbar(
          'Success',
          widget.service == null 
              ? 'Service created successfully' 
              : 'Service updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade400,
          colorText: Colors.white,
        );
      }
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
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.service == null ? 'Create New Service' : 'Edit Service',
          style: AppTextStyle.headlineSmall.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        return Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // General Information
                    _buildSectionTitle('General Information'),
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: _cardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Service Name *'),
                          SizedBox(height: 8.h),
                          TextFormField(
                            controller: _nameController,
                            decoration: _inputDecoration('e.g., Hair Color'),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter service name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.h),
                          _buildLabel('Description'),
                          SizedBox(height: 8.h),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: _inputDecoration('Describe your service...'),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Service Duration
                    _buildSectionTitle('Service Duration'),
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: _cardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Duration (Minutes)'),
                          SizedBox(height: 12.h),
                          Wrap(
                            spacing: 12.w,
                            runSpacing: 12.h,
                            children: _durations.map((duration) {
                              final isSelected = _selectedDuration == duration;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedDuration = duration;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20.w, vertical: 10.h),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryColor
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryColor
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    '$duration min',
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Pricing & Fees
                    _buildSectionTitle('Pricing & Fees'),
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: _cardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Price Type'),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              _buildPriceTypeOption('Free', 'free'),
                              SizedBox(width: 10.w),
                              _buildPriceTypeOption('Fixed', 'fixed'),
                              SizedBox(width: 10.w),
                              _buildPriceTypeOption('From', 'from'),
                            ],
                          ),
                          
                          if (_selectedPriceType != 'free') ...[
                            SizedBox(height: 20.h),
                            _buildLabel('Service Fee *'),
                            SizedBox(height: 8.h),
                            TextFormField(
                              controller: _feeController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              decoration: _inputDecoration('0.00', prefixText: '\$ '),
                              validator: (value) {
                                if (_selectedPriceType != 'free') {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter service fee';
                                  }
                                }
                                return null;
                              },
                            ),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(height: 40.h),

                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Text(
                          widget.service == null
                              ? 'Create Service'
                              : 'Update Service',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
            if (_controller.isLoading.value)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: Colors.grey[800],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: Colors.grey.shade100),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, {String? prefixText}) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefixText,
      prefixStyle: TextStyle(
        color: Colors.black87,
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: AppColors.primaryColor, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
    );
  }

  Widget _buildPriceTypeOption(String label, String value) {
    final isSelected = _selectedPriceType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPriceType = value;
            if (value == 'free') {
              _feeController.clear();
            }
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primaryColor : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
