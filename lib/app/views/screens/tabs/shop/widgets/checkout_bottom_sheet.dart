import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';
import 'package:color_os/app/controllers/shop_controller.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutBottomSheet extends StatefulWidget {
  const CheckoutBottomSheet({Key? key}) : super(key: key);

  @override
  State<CheckoutBottomSheet> createState() => _CheckoutBottomSheetState();
}

class _CheckoutBottomSheetState extends State<CheckoutBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final addressLabelController = TextEditingController(text: "Home");
  final fullAddressController = TextEditingController();
  final townCityController = TextEditingController();
  final postcodeController = TextEditingController();
  final phoneNumberController = TextEditingController();

  String selectedCountry = 'United Kingdom';
  String selectedCountryFlag = '🇬🇧';

  bool isDefault = true;
  bool _isLoadingSavedData = true;

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  Future<void> _loadSavedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      addressLabelController.text =
          prefs.getString('checkout_addressLabel') ?? "Home";
      fullAddressController.text =
          prefs.getString('checkout_fullAddress') ?? "";
      townCityController.text = prefs.getString('checkout_townCity') ?? "";
      postcodeController.text = prefs.getString('checkout_postcode') ?? "";
      phoneNumberController.text =
          prefs.getString('checkout_phoneNumber') ?? "";
      selectedCountry = prefs.getString('checkout_country') ?? "United Kingdom";
      selectedCountryFlag = prefs.getString('checkout_countryFlag') ?? "🇬🇧";

      isDefault = prefs.getBool('checkout_isDefault') ?? true;
      _isLoadingSavedData = false;
    });
  }

  Future<void> _saveAddressKeys() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('checkout_addressLabel', addressLabelController.text);
    await prefs.setString('checkout_fullAddress', fullAddressController.text);
    await prefs.setString('checkout_townCity', townCityController.text);
    await prefs.setString('checkout_postcode', postcodeController.text);
    await prefs.setString('checkout_phoneNumber', phoneNumberController.text);
    await prefs.setString('checkout_country', selectedCountry);
    await prefs.setString('checkout_countryFlag', selectedCountryFlag);
    await prefs.setBool('checkout_isDefault', isDefault);
  }

  @override
  void dispose() {
    addressLabelController.dispose();
    fullAddressController.dispose();
    townCityController.dispose();
    postcodeController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingSavedData) {
      return Container(
        height: 300.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final controller = Get.find<ShopController>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28.r),
            topRight: Radius.circular(28.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          left: 24.w,
          right: 24.w,
          top: 24.h,
          bottom: 12.h,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Checkout Details',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Enter your shipping information',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        iconSize: 20.sp,
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close, color: Colors.black87),
                        padding: EdgeInsets.all(8.w),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                _buildTextField(
                  controller: addressLabelController,
                  label: 'Address Label',
                  hint: 'e.g. Home, Office',
                  icon: Icons.label_outline,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 16.h),

                _buildCountryDropdown(),
                SizedBox(height: 16.h),

                _buildTextField(
                  controller: fullAddressController,
                  label: 'Full Address',
                  hint: 'e.g. 10 Downing Street',
                  icon: Icons.location_on_outlined,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 16.h),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: townCityController,
                        label: 'Town or City',
                        hint: 'e.g. London',
                        icon: Icons.location_city_outlined,
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _buildTextField(
                        controller: postcodeController,
                        label: 'Postcode',
                        hint: 'e.g. SW1A 2AA',
                        icon: Icons.markunread_mailbox_outlined,
                        keyboardType: TextInputType.text,
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                _buildTextField(
                  controller: phoneNumberController,
                  label: 'Phone Number',
                  hint: 'e.g. 07911 123456',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),

                SizedBox(height: 16.h),

                // Is Default Checkbox
                InkWell(
                  onTap: () {
                    setState(() {
                      isDefault = !isDefault;
                    });
                  },
                  borderRadius: BorderRadius.circular(8.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Row(
                      children: [
                        Container(
                          height: 24.w,
                          width: 24.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: isDefault
                                  ? AppColors.primaryColor
                                  : Colors.grey[400]!,
                              width: 2,
                            ),
                            color: isDefault
                                ? AppColors.primaryColor
                                : Colors.transparent,
                          ),
                          child: isDefault
                              ? Icon(
                                  Icons.check,
                                  size: 16.sp,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Save as default address',
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 28.h),

                SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                await _saveAddressKeys();
                                controller.createCheckoutSession(
                                  addressLabel: addressLabelController.text,
                                  fullAddress:
                                      '${fullAddressController.text}, $selectedCountry',
                                  area: townCityController.text,
                                  postalCode: postcodeController.text,
                                  phoneNumber: phoneNumberController.text,
                                  isDefault: isDefault,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 0,
                      ),
                      child: controller.isLoading.value
                          ? SizedBox(
                              height: 24.h,
                              width: 24.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              'Proceed to Pay',
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom + 12.h,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Country',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: () {
            showCountryPicker(
              context: context,
              showPhoneCode: false,
              countryListTheme: CountryListThemeData(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28.r),
                  topRight: Radius.circular(28.r),
                ),
                inputDecoration: InputDecoration(
                  labelText: 'Search country',
                  hintText: 'Start typing to search',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: const Color(0xFF8C98A8).withOpacity(0.2),
                    ),
                  ),
                ),
              ),
              onSelect: (Country country) {
                setState(() {
                  selectedCountry = country.name;
                  selectedCountryFlag = country.flagEmoji;
                });
              },
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Text(selectedCountryFlag, style: TextStyle(fontSize: 22.sp)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    selectedCountry,
                    style: TextStyle(fontSize: 15.sp, color: Colors.black87),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
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
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 15.sp, color: Colors.black87),
          validator: validator,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
            prefixIcon: Icon(icon, color: Colors.grey[500], size: 22.sp),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
