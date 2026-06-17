import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/controllers/new_mix_controller.dart';
import 'package:color_os/app/controllers/client_controller.dart';
import 'package:color_os/app/models/client_model.dart';

class SelectClientScreen extends StatefulWidget {
  final int? mixId;
  const SelectClientScreen({Key? key, this.mixId}) : super(key: key);

  @override
  State<SelectClientScreen> createState() => _SelectClientScreenState();
}

class _SelectClientScreenState extends State<SelectClientScreen> {
  final TextEditingController searchController = TextEditingController();
  late ClientController clientController;

  @override
  void initState() {
    super.initState();
    // Initialize ClientController if not already in memory
    clientController = Get.put(ClientController());
    // Refresh client list
    clientController.getClients();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final newMixController = Get.find<NewMixController>();

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
          'Select Client',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                _showAddClientBottomSheet(context, newMixController),
            icon: Icon(
              Icons.person_add_alt_1_outlined,
              color: AppColors.primaryColor,
              size: 24.sp,
            ),
            tooltip: 'Add New Client',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddClientBottomSheet(context, newMixController),
        backgroundColor: AppColors.primaryColor,
        child: Icon(Icons.person_add_alt_1, color: Colors.white, size: 24.sp),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(20.w),
            child: TextField(
              controller: searchController,
              onChanged: (val) {
                clientController.updateSearchQuery(val);
              },
              style: TextStyle(fontSize: 15.sp, color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Search client name',
                hintStyle: TextStyle(fontSize: 15.sp, color: Colors.grey[400]),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                  size: 22.sp,
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchController.clear();
                          clientController.updateSearchQuery('');
                        },
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey[400],
                          size: 20.sp,
                        ),
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: AppColors.primaryColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Clients List
          Expanded(
            child: Obx(() {
              if (clientController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (clientController.filteredClients.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_search,
                        size: 80.sp,
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        clientController.searchQuery.value.isNotEmpty
                            ? 'No clients match your search'
                            : 'No clients yet',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Add a new client to get started',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[400],
                        ),
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton.icon(
                        onPressed: () => _showAddClientBottomSheet(
                          context,
                          Get.find<NewMixController>(),
                        ),
                        icon: const Icon(
                          Icons.person_add_alt_1,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Add New Client',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: 28.w,
                            vertical: 14.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: clientController.filteredClients.length,
                itemBuilder: (context, index) {
                  final client = clientController.filteredClients[index];
                  // Assuming ClientModel has 'id', 'name', 'contactNumber' or 'phone'
                  // Based on ClientTab reading, it has: name, serviceType, contactNumber, profileImage
                  return Obx(() {
                    final isSelected =
                        newMixController.selectedClientId.value == client.id;
                    return _buildClientCard(client, isSelected, () async {
                      if (widget.mixId != null) {
                        final clientIdInt = int.tryParse(client.id);
                        if (clientIdInt == null) {
                          Get.snackbar('Error', 'Invalid client ID format',
                              backgroundColor: Colors.red,
                              colorText: Colors.white);
                          return;
                        }
                        final assigned = await newMixController
                            .assignClientToMix(widget.mixId!, clientIdInt);
                        if (assigned) {
                          await newMixController.fetchRecentMixes();
                          Get.back();
                        } else {
                          Get.snackbar('Error', 'Failed to assign client');
                        }
                      } else {
                        newMixController.assignToClient(client);
                        Get.back();
                      }
                    });
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showAddClientBottomSheet(
    BuildContext context,
    NewMixController newMixController,
  ) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final serviceTypeController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final RxBool isCreating = false.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                child: Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_add_alt_1,
                        color: AppColors.primaryColor,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add New Client',
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Client will be assigned to this mix',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.close,
                        color: Colors.grey[600],
                        size: 22.sp,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: Colors.grey[100]),

              // Form
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name Field
                        _buildFormLabel('Full Name *'),
                        SizedBox(height: 6.h),
                        TextFormField(
                          controller: nameController,
                          textCapitalization: TextCapitalization.words,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black87,
                          ),
                          decoration: _inputDecoration(
                            'Enter client name',
                            Icons.person_outline,
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Name is required'
                              : null,
                        ),
                        SizedBox(height: 14.h),

                        // Phone Field
                        _buildFormLabel('Phone Number'),
                        SizedBox(height: 6.h),
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black87,
                          ),
                          decoration: _inputDecoration(
                            'Enter phone number',
                            Icons.phone_outlined,
                          ),
                        ),
                        SizedBox(height: 14.h),

                        // Email Field
                        _buildFormLabel('Email Address'),
                        SizedBox(height: 6.h),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black87,
                          ),
                          decoration: _inputDecoration(
                            'Enter email address',
                            Icons.email_outlined,
                          ),
                          validator: (v) {
                            if (v != null && v.trim().isNotEmpty) {
                              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                              if (!emailRegex.hasMatch(v.trim())) {
                                return 'Enter a valid email';
                              }
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 14.h),

                        // Service Type Field
                        _buildFormLabel('Service Type'),
                        SizedBox(height: 6.h),
                        TextFormField(
                          controller: serviceTypeController,
                          textCapitalization: TextCapitalization.words,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black87,
                          ),
                          decoration: _inputDecoration(
                            'Enter service type (e.g., Salon Owner, Freelancer)',
                            Icons.work_outline,
                          ),
                        ),

                        SizedBox(height: 24.h),

                        // Submit Button
                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: ElevatedButton(
                              onPressed: isCreating.value
                                  ? null
                                  : () async {
                                      if (!formKey.currentState!.validate())
                                        return;
                                      isCreating.value = true;

                                      final data = <String, dynamic>{
                                        'name': nameController.text.trim(),
                                        if (phoneController.text
                                            .trim()
                                            .isNotEmpty)
                                          'contact_number': phoneController.text
                                              .trim(),
                                        if (emailController.text
                                            .trim()
                                            .isNotEmpty)
                                          'email': emailController.text.trim(),
                                        if (serviceTypeController.text
                                            .trim()
                                            .isNotEmpty)
                                          'service_type': serviceTypeController
                                              .text
                                              .trim(),
                                      };

                                      final createdId = await clientController
                                          .createClient(data);

                                      if (createdId != null) {
                                        // Refresh list and find the new client
                                        await clientController.getClients();
                                        final newClient = clientController
                                            .clients
                                            .firstWhereOrNull(
                                              (c) => c.id == createdId,
                                            );
                                        if (newClient != null) {
                                          if (widget.mixId != null) {
                                            final newClientIdInt =
                                                int.tryParse(newClient.id);
                                            if (newClientIdInt == null) {
                                              Get.snackbar(
                                                'Error',
                                                'Invalid client ID format',
                                                backgroundColor: Colors.red,
                                                colorText: Colors.white,
                                              );
                                              isCreating.value = false;
                                              return;
                                            }
                                            final assigned = await newMixController
                                                .assignClientToMix(
                                              widget.mixId!,
                                              newClientIdInt,
                                            );
                                            if (assigned) {
                                              await newMixController
                                                  .fetchRecentMixes();
                                              Get.back(); // Close bottom sheet
                                              Get.back(); // Return to history screen
                                            } else {
                                              Get.snackbar(
                                                'Error',
                                                'Failed to assign client',
                                              );
                                            }
                                          } else {
                                            newMixController.assignToClient(
                                              newClient,
                                            );
                                            // Automatically save and redirect after adding a new client
                                            Get.back(); // Close bottom sheet
                                            newMixController.saveMix();
                                          }
                                        } else {
                                          Get.back(); // Close bottom sheet
                                        }
                                      }

                                      isCreating.value = false;
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                disabledBackgroundColor: AppColors.primaryColor
                                    .withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                elevation: 0,
                              ),
                              child: isCreating.value
                                  ? SizedBox(
                                      width: 22.w,
                                      height: 22.h,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Add & Assign Client',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      nameController.dispose();
      phoneController.dispose();
      emailController.dispose();
      serviceTypeController.dispose();
    });
  }

  Widget _buildFormLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
      prefixIcon: Icon(icon, color: Colors.grey[400], size: 20.sp),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  Widget _buildClientCard(
    ClientModel client,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFFFFF0F6)
            : Colors.white, // Light pink if selected
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryColor
                        : Colors.grey[200],
                    shape: BoxShape.circle,
                    image: client.profileImage != null
                        ? DecorationImage(
                            image: NetworkImage(client.profileImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: client.profileImage == null
                      ? Center(
                          child: Text(
                            client.name.isNotEmpty
                                ? client.name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[600],
                            ),
                          ),
                        )
                      : null,
                ),
                SizedBox(width: 12.w),

                // Client Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.name,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (client.contactNumber.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          client.contactNumber,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Selected Indicator
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: AppColors.primaryColor,
                    size: 24.sp,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
