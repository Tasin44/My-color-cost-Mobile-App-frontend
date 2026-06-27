import 'dart:io';

import 'package:color_os/app/controllers/new_mix_controller.dart';
import 'package:color_os/app/core/constant/api_endpoints.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/core/services/api_services.dart';
import 'package:color_os/app/models/inventory_product_model.dart';
import 'package:color_os/app/views/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class EditMyProductScreen extends StatefulWidget {
  final InventoryProduct product;

  const EditMyProductScreen({super.key, required this.product});

  @override
  State<EditMyProductScreen> createState() => _EditMyProductScreenState();
}

class _EditMyProductScreenState extends State<EditMyProductScreen> {
  late TextEditingController _nameController;
  late TextEditingController _marketPriceController;
  late TextEditingController _userPriceController;
  late TextEditingController _weightController;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.productName);
    _marketPriceController =
        TextEditingController(text: widget.product.marketPrice ?? '');
    _userPriceController =
        TextEditingController(text: widget.product.userPrice ?? '');
    _weightController =
        TextEditingController(text: widget.product.currentWeightGrams);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _marketPriceController.dispose();
    _userPriceController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _updateProduct() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = ApiEndpoints.inventoryDetail(widget.product.id);

      final Map<String, String> fields = {
        'product_name': _nameController.text.trim(),
        'market_price': _marketPriceController.text.trim(),
        'user_price': _userPriceController.text.trim(),
        'current_weight_grams': _weightController.text.trim(),
      };

      final List<http.MultipartFile> files = [];
      if (_selectedImage != null) {
        files.add(
          await http.MultipartFile.fromPath(
            'product_image',
            _selectedImage!.path,
          ),
        );
      }

      final response = await ApiServices.patchMultipartData(
        url,
        fields,
        files,
        requireAuth: true,
      );

      if (response != null && response.success) {
        Get.back();
        
        Get.snackbar('Success', 'Product updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
        
        if (Get.isRegistered<NewMixController>()) {
          Get.find<NewMixController>().fetchInventory();
        }
      } else {
        Get.snackbar(
          'Error',
          response?.message ?? 'Failed to update product',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: Colors.black87, size: 24.sp),
        ),
        title: Text(
          'Edit Product',
          style: AppTextStyle.titleLarge.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: _selectedImage != null
                        ? Image.file(_selectedImage!, fit: BoxFit.cover)
                        : (widget.product.productImage != null
                            ? Image.network(
                                widget.product.productImage!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                              )
                            : _buildImagePlaceholder()),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Center(
              child: Text(
                'Tap to change image',
                style: AppTextStyle.bodySmall.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            SizedBox(height: 32.h),

            // Form Fields
            _buildLabel('Product Name'),
            _buildTextField(
              controller: _nameController,
              hintText: 'Enter product name',
            ),
            SizedBox(height: 16.h),

            _buildLabel('Market Price'),
            _buildTextField(
              controller: _marketPriceController,
              hintText: 'Enter market price',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 16.h),

            _buildLabel('User Price'),
            _buildTextField(
              controller: _userPriceController,
              hintText: 'Enter user price',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 16.h),

            _buildLabel('Current Weight (grams)'),
            _buildTextField(
              controller: _weightController,
              hintText: 'Enter current weight',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 32.h),

            // More details from API (read-only)
            _buildDetailRow('Barcode', widget.product.barcode ?? 'N/A'),
            _buildDetailRow('Available', widget.product.isAvailable ? 'Yes' : 'No'),
            _buildDetailRow('Last Used At', _formatDate(widget.product.lastUsedAt)),
            _buildDetailRow('Scanned At', _formatDate(widget.product.scannedAt)),
            
            SizedBox(height: 32.h),
            PrimaryButton(
              text: 'Save Changes',
              onPressed: _updateProduct,
              isLoading: _isLoading,
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 40.sp,
          color: Colors.grey.shade400,
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: AppTextStyle.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyle.bodyMedium.copyWith(color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: AppTextStyle.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString).toLocal();
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateString;
    }
  }
}
