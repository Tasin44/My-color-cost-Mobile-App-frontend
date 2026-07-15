import 'dart:io';
import 'package:color_os/app/controllers/expense_controller.dart';
import 'package:color_os/app/models/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:image_picker/image_picker.dart';

class AddMonthlyExpenseScreen extends StatefulWidget {
  final ExpenseModel? expense;
  const AddMonthlyExpenseScreen({Key? key, this.expense}) : super(key: key);

  @override
  State<AddMonthlyExpenseScreen> createState() =>
      _AddMonthlyExpenseScreenState();
}

class _AddMonthlyExpenseScreenState extends State<AddMonthlyExpenseScreen> {
  final TextEditingController expenseNameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String selectedFrequency = 'Monthly';
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> frequencies = ['Daily', 'Weekly', 'Monthly', 'Yearly'];

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      // Pre-fill for edit mode
      expenseNameController.text = widget.expense!.expenseName ?? '';
      amountController.text = widget.expense!.amount ?? '';
      categoryController.text = widget.expense!.category ?? '';
      descriptionController.text = widget.expense!.description ?? '';

      // Normalize frequency to Title Case for matching
      // (Frequency field has been removed)
    }
  }

  @override
  void dispose() {
    expenseNameController.dispose();
    amountController.dispose();
    categoryController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExpenseController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: Colors.black87, size: 24.sp),
        ),
        title: Text(
          widget.expense != null ? 'Edit Expense' : 'Add Monthly Expense',
          style: TextStyle(
            fontSize: 18.sp, // Reduced size
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),

              // Image Picker
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 100.w,
                    height: 100.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.shade300),
                      image: _selectedImage != null
                          ? DecorationImage(
                              image: FileImage(_selectedImage!),
                              fit: BoxFit.cover,
                            )
                          : (widget.expense?.image != null
                                ? DecorationImage(
                                    image: NetworkImage(widget.expense!.image!),
                                    fit: BoxFit.cover,
                                  )
                                : null),
                    ),
                    child:
                        _selectedImage == null && widget.expense?.image == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                color: Colors.grey.shade400,
                                size: 30.sp,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Add Photo',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Expense Name Field
              Text(
                'Expense Name',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: expenseNameController,
                style: TextStyle(fontSize: 15.sp, color: Colors.black87),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'e.g., Hair Products',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 15.sp,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              SizedBox(height: 18.h),

              // Amount Field
              Text(
                'Amount (£)',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 15.sp, color: Colors.black87),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: '0.00',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 15.sp,
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 16.w, right: 8.w),
                    child: Icon(
                      Icons.currency_pound,
                      color: Colors.grey[600],
                      size: 20.sp,
                    ),
                  ),
                  prefixIconConstraints: BoxConstraints(minWidth: 40.w),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              SizedBox(height: 18.h),

              // Category Field (Manual Input)
              Text(
                'Category',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: categoryController,
                style: TextStyle(fontSize: 15.sp, color: Colors.black87),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'e.g., Salon Supplies',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 15.sp,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              // (Frequency Dropdown removed)

              SizedBox(height: 18.h),

              // Description Field
              Text(
                'Description (Optional)',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: descriptionController,
                maxLines: 4,
                style: TextStyle(fontSize: 15.sp, color: Colors.black87),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Add any additional notes...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 15.sp,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              SizedBox(height: 30.h),

              // Add/Update Expense Button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: Obx(() {
                  return ElevatedButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : _submitExpense,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isSubmitting.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            widget.expense != null
                                ? 'Update Expense'
                                : 'Add Expense',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  );
                }),
              ),

              SizedBox(height: 12.h),

              // Cancel Button
              Center(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  void _submitExpense() async {
    final controller = Get.find<ExpenseController>();

    // Validate expense name
    if (expenseNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter expense name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    // Validate amount
    if (amountController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter amount',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid amount',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    // Validate category
    if (categoryController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a category',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    bool success;
    if (widget.expense != null) {
      // Update
      success = await controller.updateExpense(
        id: widget.expense!.id!,
        name: expenseNameController.text,
        amount: amountController.text,
        category: categoryController.text,
        description: descriptionController.text,
        image: _selectedImage,
      );
    } else {
      // Add
      success = await controller.addExpense(
        name: expenseNameController.text,
        amount: amountController.text,
        category: categoryController.text,
        description: descriptionController.text,
        image: _selectedImage,
      );
    }

    if (success) {
      Get.back();
      Get.snackbar(
        'Success',
        widget.expense != null
            ? 'Expense updated successfully'
            : 'Expense added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade400,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    }
  }
}
