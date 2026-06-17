import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:color_os/app/controllers/account_type_controller.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/views/widgets/primary_button.dart';
import 'package:color_os/app/views/widgets/reusable/selection_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountTypeScreen extends StatelessWidget {
  const AccountTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AccountTypeController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              // Header Section
              Padding(
                padding: EdgeInsets.only(top: 40.h, bottom: 30.h),
                child: _buildHeader(),
              ),

              // Account Type Options
              Expanded(child: _buildAccountTypeOptions(controller)),

              SizedBox(height: 20.h),
              _buildContinueButton(controller),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  /// Build header section with title and description
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose\naccount type',
          style: AppTextStyle.headlineLarge.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Your role determines features, permissions, and account set up.',
          style: AppTextStyle.bodyMedium.copyWith(
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
      ],
    );
  }

  /// Build account type options list
  Widget _buildAccountTypeOptions(AccountTypeController controller) {
    return ListView.separated(
      itemCount: controller.accountTypeOptions.length,
      separatorBuilder: (context, index) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final option = controller.accountTypeOptions[index];

        return Obx(() {
          final isSelected = controller.isSelected(option.type);

          return SelectionCard(
            title: option.title,
            description: option.description,
            icon: IconContainer(
              icon: _getIconForAccountType(option.type),
              backgroundColor: _getIconBackgroundColor(option.type),
              iconColor: _getIconColor(option.type),
            ),
            isSelected: isSelected,
            onTap: () async {
              if (option.type == AccountType.retailer) {
                final Uri url = Uri.parse('https://retailer.mycolourcost.com');
                if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                  Get.snackbar('Error', 'Could not launch $url');
                }
              } else {
                controller.selectAccountType(option.type);
              }
            },
            showRecommended: option.isRecommended,
          );
        });
      },
    );
  }

  /// Build continue button
  Widget _buildContinueButton(AccountTypeController controller) {
    return Obx(() {
      return PrimaryButton(
        text: 'Continue',
        onPressed:
            controller.selectedAccountType.value != null &&
                !controller.isLoading.value
            ? controller.continueToNextStep
            : null,
        isLoading: controller.isLoading.value,
        height: 48.h,
      );
    });
  }

  /// Get icon for account type
  Widget _getIconForAccountType(AccountType type) {
    switch (type) {
      case AccountType.salonOwner:
        return Icon(Icons.business);
      case AccountType.selfEmployed:
        return Icon(Icons.person);
      case AccountType.salonStaff:
        return Icon(Icons.group);
      case AccountType.retailer:
        return Icon(Icons.shopping_cart);
    }
  }

  /// Get icon background color for account type
  Color _getIconBackgroundColor(AccountType type) {
    switch (type) {
      case AccountType.salonOwner:
        return AppColors.primaryColor.withOpacity(0.1);
      case AccountType.selfEmployed:
        return const Color(0xFF3B82F6).withOpacity(0.1);
      case AccountType.salonStaff:
        return const Color(0xFF8B5CF6).withOpacity(0.1);
      case AccountType.retailer:
        return const Color(0xFFF59E0B).withOpacity(0.1);
    }
  }

  /// Get icon color for account type
  Color _getIconColor(AccountType type) {
    switch (type) {
      case AccountType.salonOwner:
        return AppColors.primaryColor;
      case AccountType.selfEmployed:
        return const Color(0xFF3B82F6);
      case AccountType.salonStaff:
        return const Color(0xFF8B5CF6);
      case AccountType.retailer:
        return const Color(0xFFF59E0B);
    }
  }
}
