import 'package:color_os/app/controllers/affiliate_controller.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class WithdrawSheet extends StatefulWidget {
  const WithdrawSheet({super.key});

  @override
  State<WithdrawSheet> createState() => _WithdrawSheetState();
}

class _WithdrawSheetState extends State<WithdrawSheet> {
  final _formKey = GlobalKey<FormState>();
  final _bankNameController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _routingNumberController = TextEditingController();
  final _bankAddressController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill amount with available commission
    final controller = Get.find<AffiliateController>();
    _amountController.text = controller.availableCommission.value
        .toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final affiliateController = Get.find<AffiliateController>();

    return Padding(
      // Padding to handle keyboard overlap
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            SizedBox(
              height: 40.h,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.close,
                        size: 24.sp,
                        color: Colors.grey[700],
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Withdraw Funds',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Enter your bank details to receive funds.',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 24.h),

            _buildTextField(
              controller: _bankNameController,
              label: 'Bank Name',
              hint: 'e.g. Chase Bank',
              validator: (val) =>
                  val == null || val.isEmpty ? 'Please enter bank name' : null,
            ),
            SizedBox(height: 16.h),

            _buildTextField(
              controller: _accountNameController,
              label: 'Account Holder Name',
              hint: 'e.g. John Doe',
              validator: (val) => val == null || val.isEmpty
                  ? 'Please enter account holder name'
                  : null,
            ),
            SizedBox(height: 16.h),

            _buildTextField(
              controller: _accountNumberController,
              label: 'Account Number',
              hint: 'Enter account number',
              keyboardType: TextInputType.number,
              validator: (val) => val == null || val.isEmpty
                  ? 'Please enter account number'
                  : null,
            ),
            SizedBox(height: 16.h),

            _buildTextField(
              controller: _routingNumberController,
              label: 'Routing / IFSC Code',
              hint: 'Enter routing symbol',
              validator: (val) => val == null || val.isEmpty
                  ? 'Please enter routing/IFSC code'
                  : null,
            ),
            SizedBox(height: 16.h),

            _buildTextField(
              controller: _bankAddressController,
              label: 'Bank Address',
              hint: 'e.g. 123 Main St, New York, NY',
              validator: (val) => val == null || val.isEmpty
                  ? 'Please enter bank address'
                  : null,
            ),
            SizedBox(height: 16.h),

            _buildTextField(
              controller: _amountController,
              label: 'Amount to Withdraw',
              hint: 'Enter amount',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Please enter amount';
                if (double.tryParse(val) == null) return 'Invalid amount';
                return null;
              },
            ),
            SizedBox(height: 30.h),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    affiliateController
                        .submitWithdrawRequest(
                          bankName: _bankNameController.text.trim(),
                          accountName: _accountNameController.text.trim(),
                          accountNumber: _accountNumberController.text.trim(),
                          routingNumber: _routingNumberController.text.trim(),
                          bankAddress: _bankAddressController.text.trim(),
                          amount: double.tryParse(_amountController.text) ?? 0,
                        )
                        .then((success) {
                          if (success) {
                            Get.back(); // Close sheet on success
                          }
                        });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Obx(() {
                  return affiliateController.isSubmittingWithdraw.value
                      ? SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Submit Withdrawal Request',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        );
                }),
              ),
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
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 14.sp),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}
