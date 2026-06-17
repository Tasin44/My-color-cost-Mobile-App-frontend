import 'package:color_os/app/controllers/client_controller.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/views/screens/tabs/client/widgets/basic_info_step.dart';
import 'package:color_os/app/views/screens/tabs/client/widgets/confirmation_step.dart';
import 'package:color_os/app/views/screens/tabs/client/widgets/step_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AddNewClientScreen extends StatefulWidget {
  const AddNewClientScreen({super.key});

  @override
  State<AddNewClientScreen> createState() => _AddNewClientScreenState();
}

class _AddNewClientScreenState extends State<AddNewClientScreen> {
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _skinTestDateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final ClientController _clientController = Get.put(ClientController());

  int _currentStep = 0;

  final ImagePicker _picker = ImagePicker();
  XFile? _profileImage;

  @override
  void dispose() {
    _clientNameController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _skinTestDateController.dispose();
    _notesController.dispose();
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
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Add New Client',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.more_vert, color: Colors.black, size: 24.sp),
          //   onPressed: () {},
          // ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            StepIndicator(currentStep: _currentStep),
            SizedBox(height: 24.h),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: _buildStepContent(),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Obx(() {
                final bool isLoading = _clientController.isLoading.value;

                return SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: _buildNextButton(isLoading),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton(bool isLoading) {
    return ElevatedButton(
      onPressed: isLoading ? null : _handleButtonPress,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 14.h),
      ),
      child: isLoading
          ? SizedBox(
              height: 20.h,
              width: 20.h,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              _getButtonText(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Future<void> _handleButtonPress() async {
    if (_currentStep == 0) {
      if (_clientNameController.text.isEmpty) {
        Get.snackbar('Error', 'Client Name is required');
        return;
      }

      final data = {
        "name": _clientNameController.text,
        "contact_number": _contactNumberController.text,
        "email": _emailController.text,
        "skin_test_date": _skinTestDateController.text,
        "notes": _notesController.text,
      };

      final clientId = await _clientController.createClient(
        data,
        profileImage: _profileImage,
      );
      if (clientId != null) {
        setState(() {
          _currentStep = 1; // Go directly to success step
        });
      }
    } else {
      Navigator.pop(context);
      _clientController.getClients(); // Refresh list
    }
  }

  String _getButtonText() {
    return _currentStep == 1 ? 'Done' : 'Next';
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return BasicInfoStep(
          clientNameController: _clientNameController,
          contactNumberController: _contactNumberController,
          emailController: _emailController,
          skinTestDateController: _skinTestDateController,
          notesController: _notesController,
          profileImage: _profileImage,
          onPickImage: () async {
            final XFile? image = await _picker.pickImage(
              source: ImageSource.gallery,
            );
            if (image != null) {
              setState(() {
                _profileImage = image;
              });
            }
          },
        );
      case 1:
        return ConfirmationStep(
          name: _clientNameController.text,
          phone: _contactNumberController.text,
          email: _emailController.text,
        );
      default:
        return const SizedBox();
    }
  }
}
