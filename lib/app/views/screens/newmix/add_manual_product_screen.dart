import 'dart:io';

import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/controllers/new_mix_controller.dart';
import 'package:color_os/app/views/screens/newmix/barcode_scanner_screen.dart';
import 'package:color_os/app/views/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AddManualProductScreen extends StatefulWidget {
  const AddManualProductScreen({super.key});

  @override
  State<AddManualProductScreen> createState() => _AddManualProductScreenState();
}

class _AddManualProductScreenState extends State<AddManualProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final NewMixController _controller = Get.find<NewMixController>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _marketPriceController = TextEditingController();
  final TextEditingController _gramsController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Opens the camera directly — primary action
  Future<void> _takePhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  // Secondary action — pick from saved photos
  Future<void> _chooseFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _scanBarcode() async {
    final result = await Get.to(() => const BarcodeScannerScreen());
    if (result != null && result is String) {
      setState(() {
        _barcodeController.text = result;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null) {
        Get.snackbar(
          'Error',
          'Please select an image',
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final Map<String, dynamic> data = {
        'name': _nameController.text,
        'market_price': _marketPriceController.text,
        'current_weight_grams': _gramsController.text,
        'barcode': _barcodeController.text,
        'description': _descriptionController.text,
      };

      _controller.addManualProduct(data, _selectedImage!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _marketPriceController.dispose();
    _gramsController.dispose();
    _barcodeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: Colors.black87, size: 24.sp),
        ),
        title: Text(
          'Add Manual Product',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
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
              // ── Photo section ──────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    // Tap preview → opens camera immediately
                    GestureDetector(
                      onTap: _takePhoto,
                      child: Container(
                        width: 160.w,
                        height: 160.w,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: _selectedImage != null
                                ? AppColors.primaryColor.withOpacity(0.4)
                                : Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(13.r),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.grey.shade500,
                                    size: 44.sp,
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Tap to take photo',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // Two clear action buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _takePhoto,
                          icon: Icon(Icons.camera_alt, size: 18.sp),
                          label: Text(
                            'Camera',
                            style: TextStyle(fontSize: 13.sp),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 10.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        OutlinedButton.icon(
                          onPressed: _chooseFromGallery,
                          icon: Icon(
                            Icons.photo_library_outlined,
                            size: 18.sp,
                            color: AppColors.primaryColor,
                          ),
                          label: Text(
                            'Gallery',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primaryColor),
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 10.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (_selectedImage != null) ...[
                      SizedBox(height: 6.h),
                      Text(
                        'Tap the photo or "Camera" to retake',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 28.h),

              _buildTextField(
                controller: _nameController,
                label: 'Product Name',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16.h),

              _buildTextField(
                controller: _barcodeController,
                label: 'Barcode',
                suffixIcon: IconButton(
                  onPressed: _scanBarcode,
                  icon: Icon(
                    Icons.barcode_reader,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _marketPriceController,
                      label: 'Paid Price',
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildTextField(
                      controller: _gramsController,
                      label: 'Total Grams (Per tube)',
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 4,
              ),
              SizedBox(height: 30.h),

              PrimaryButton(
                text: 'Add Product',
                onPressed: _submitForm,
                height: 50.h,
                borderRadius: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          onTap: onTap,
          style: TextStyle(fontSize: 16.sp, color: Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primaryColor),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
        ),
      ],
    );
  }
}
