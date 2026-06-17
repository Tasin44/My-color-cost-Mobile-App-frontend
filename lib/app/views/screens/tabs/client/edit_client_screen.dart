import 'dart:io';
import 'package:color_os/app/controllers/client_controller.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/models/client_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditClientScreen extends StatefulWidget {
  final ClientModel client;

  const EditClientScreen({super.key, required this.client});

  @override
  State<EditClientScreen> createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  late TextEditingController _clientNameController;
  late TextEditingController _contactNumberController;
  late TextEditingController _emailController;
  late TextEditingController _skinTestDateController;
  late TextEditingController _notesController;

  final ClientController _clientController = Get.find<ClientController>();
  final ImagePicker _picker = ImagePicker();
  XFile? _profileImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _clientNameController = TextEditingController(text: widget.client.name);
    _contactNumberController = TextEditingController(
      text: widget.client.contactNumber,
    );
    _emailController = TextEditingController(text: widget.client.email);
    _notesController = TextEditingController(text: widget.client.notes ?? '');
    _skinTestDateController = TextEditingController(
      text: widget.client.skinTestDate != null
          ? widget.client.skinTestDate!.toIso8601String().split('T').first
          : '',
    );
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _skinTestDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _updateClient() async {
    if (_clientNameController.text.isEmpty ||
        _contactNumberController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all required fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final data = {
      "name": _clientNameController.text,
      "contact_number": _contactNumberController.text,
      "skin_test_date": _skinTestDateController.text,
      "notes": _notesController.text,
    };

    final success = await _clientController.updateClientDetails(
      widget.client.id,
      data,
      profileImage: _profileImage,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.pop(context, true); // Return true to indicate update
      Get.snackbar(
        'Success',
        'Client updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Edit Client',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.h),
                    // Profile Image
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 100.w,
                              height: 100.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[100],
                                image: _profileImage != null
                                    ? DecorationImage(
                                        image: FileImage(
                                          File(_profileImage!.path),
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : widget.client.profileImage != null
                                    ? DecorationImage(
                                        image: NetworkImage(
                                          widget.client.profileImage!,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child:
                                  (_profileImage == null &&
                                      widget.client.profileImage == null)
                                  ? Icon(
                                      Icons.camera_alt,
                                      color: Colors.grey[600],
                                      size: 30.sp,
                                    )
                                  : null,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Change Photo',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Client Name
                    _buildLabel('Client Name'),
                    _buildTextField(
                      controller: _clientNameController,
                      hint: 'enter client name',
                    ),
                    SizedBox(height: 20.h),

                    // Contact Number
                    _buildLabel('Contact Number'),
                    _buildTextField(
                      controller: _contactNumberController,
                      hint: 'enter client contact number',
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 20.h),

                    // Email Address (Read Only)
                    _buildLabel('Email Address'),
                    Container(
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Text(
                              widget.client.email,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 12.w),
                            child: Icon(
                              Icons.lock_outline,
                              size: 16.sp,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
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
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateClient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Update Client',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = image;
      });
    }
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
    bool readOnly = false,
    Color? fillColor,
  }) {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: fillColor ?? Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
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
        controller: _skinTestDateController,
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
            _skinTestDateController.text =
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
        controller: _notesController,
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
