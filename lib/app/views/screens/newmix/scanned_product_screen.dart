import 'package:color_os/app/controllers/new_mix_controller.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ScannedProductScreen extends StatefulWidget {
  final Map<String, dynamic> productData;

  const ScannedProductScreen({super.key, required this.productData});

  @override
  State<ScannedProductScreen> createState() => _ScannedProductScreenState();
}

class _ScannedProductScreenState extends State<ScannedProductScreen> {
  final NewMixController _controller = Get.find<NewMixController>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _marketPriceController;
  late TextEditingController _userPriceController;
  late TextEditingController _gramsController;
  late TextEditingController _barcodeController;

  @override
  void initState() {
    super.initState();
    final product = widget.productData;
    _nameController = TextEditingController(
      text: product['name']?.toString() ?? '',
    );

    // Check api_data attributes for description if root description is empty
    String description = product['description']?.toString() ?? '';
    if (description.isEmpty &&
        product['api_data'] != null &&
        product['api_data']['item_attributes'] != null) {
      description =
          product['api_data']['item_attributes']['description']?.toString() ??
          '';
    }
    _descriptionController = TextEditingController(text: description);

    _marketPriceController = TextEditingController(
      text: product['market_price']?.toString() ?? '',
    );
    _userPriceController = TextEditingController(
      text: product['user_price']?.toString() ?? '',
    );
    _gramsController = TextEditingController(
      text: product['current_weight_grams']?.toString() ?? '',
    );
    _barcodeController = TextEditingController(
      text: product['barcode']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _marketPriceController.dispose();
    _userPriceController.dispose();
    _gramsController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  void _onDone() async {
    final Map<String, dynamic> updateData = {
      'market_price': double.tryParse(_marketPriceController.text) ?? 0.0,
      'current_weight_grams': double.tryParse(_gramsController.text) ?? 0.0,
      'user_price': double.tryParse(_userPriceController.text) ?? 0.0,
      'description': _descriptionController.text,
      'name': _nameController.text,
    };

    final String productId = widget.productData['id'].toString();
    final updatedProduct = await _controller.updateScannedProduct(
      productId,
      updateData,
    );

    if (updatedProduct != null) {
      Get.back(); // Close edit screen

      // Bowl already has items OR bowl name has been set → add directly
      final bool isInMixCreation =
          _controller.mixItems.isNotEmpty ||
          (_controller.mixTypeController.text.isNotEmpty &&
              _controller.serviceTypeController.text.isNotEmpty);

      if (isInMixCreation) {
        _controller.openAddToBowlSheet(updatedProduct);
      } else {
        // Fresh start: pre-select the updated product so that
        // submitBowlDetails() opens AddToBowlSheet automatically.
        _controller.selectedInventoryProduct.value = updatedProduct;
        _controller.showBowlDetailsSheet();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String? imageUrl = widget.productData['image_url'];
    if (imageUrl == null &&
        widget.productData['api_data'] != null &&
        widget.productData['api_data']['item_attributes'] != null) {
      // Try fetching from attributes if not at root
      imageUrl = widget.productData['api_data']['item_attributes']['image'];
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: _onDone, // Call save/update on back press
          icon: Icon(Icons.arrow_back, color: Colors.black87, size: 24.sp),
        ),
        title: Text(
          'Product Details',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _onDone,
            child: Text(
              'Done',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Message Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              margin: EdgeInsets.only(bottom: 24.h),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 24.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Product added successfully',
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Image
            Center(
              child: Container(
                width: 150.w,
                height: 150.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 50.sp,
                          ),
                        ),
                      )
                    : Icon(Icons.image, color: Colors.grey, size: 50.sp),
              ),
            ),
            SizedBox(height: 30.h),

            // Fields
            _buildTextField(
              controller: _barcodeController,
              label: 'Barcode',
              readOnly: true,
            ),
            SizedBox(height: 16.h),
            _buildTextField(controller: _nameController, label: 'Product Name'),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _marketPriceController,
                    label: 'Market Price',
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildTextField(
                    controller: _userPriceController,
                    label: 'User Price',
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: _gramsController,
              label: 'Total Grams',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              maxLines: 4,
            ),
          ],
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
        TextField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 16.sp, color: Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: readOnly ? Colors.grey.shade50 : Colors.white,
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
