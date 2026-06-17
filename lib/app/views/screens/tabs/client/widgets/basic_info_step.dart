import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class BasicInfoStep extends StatelessWidget {
  final TextEditingController clientNameController;
  final TextEditingController contactNumberController;
  final TextEditingController emailController;
  final TextEditingController skinTestDateController;
  final TextEditingController notesController;

  final XFile? profileImage;
  final VoidCallback onPickImage;

  const BasicInfoStep({
    super.key,
    required this.clientNameController,
    required this.contactNumberController,
    required this.emailController,
    required this.skinTestDateController,
    required this.notesController,
    required this.profileImage,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Image
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: onPickImage,
                child: Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[100],
                    image: profileImage != null
                        ? DecorationImage(
                            image: FileImage(File(profileImage!.path)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: profileImage == null
                      ? Icon(Icons.edit, color: Colors.grey[600], size: 24.sp)
                      : null,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Upload Image',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 32.h),

        // Client Name
        _buildLabel('Client Name'),
        _buildTextField(
          controller: clientNameController,
          hint: 'enter client name',
        ),
        SizedBox(height: 20.h),

        // Contact Number
        _buildLabel('Contact Number'),
        _buildTextField(
          controller: contactNumberController,
          hint: 'enter client contact number',
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 20.h),

        // Email Address
        _buildLabel('Email Address'),
        _buildTextField(
          controller: emailController,
          hint: 'enter client email address',
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 20.h),

        // Skin Test Date
        _buildLabel('Skin Test Date'),
        _buildDateField(context),
        SizedBox(height: 20.h),

        // Notes
        _buildLabel('Notes'),
        _buildNotesField(),
        SizedBox(height: 40.h),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.black,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: skinTestDateController,
        readOnly: true,
        decoration: InputDecoration(
          hintText: 'YYYY-MM-DD',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
          suffixIcon: Icon(
            Icons.calendar_today,
            color: Colors.grey[600],
            size: 20.sp,
          ),
        ),
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          );
          if (picked != null) {
            skinTestDateController.text =
                '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
          }
        },
      ),
    );
  }

  Widget _buildNotesField() {
    return Container(
      height: 120.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: notesController,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: 'enter client notes',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16.w),
        ),
      ),
    );
  }
}
