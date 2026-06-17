import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/controllers/client_controller.dart';
import 'package:color_os/app/views/screens/tabs/client/add_new_client_screen.dart';
import 'package:color_os/app/views/screens/tabs/client/sub-screen/client_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ClientTab extends StatefulWidget {
  const ClientTab({super.key});

  @override
  State<ClientTab> createState() => _ClientTabState();
}

class _ClientTabState extends State<ClientTab> {
  late ClientController controller;
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ClientController());
    searchController = TextEditingController();
    print('ClientTab initialized, clients count: ${controller.clients.length}');
  }

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const SizedBox(),
        title: Text(
          'My Client',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.black, size: 24.sp),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddNewClientScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 16.h),
              // Search bar with filter
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) =>
                            controller.updateSearchQuery(value),
                        decoration: InputDecoration(
                          hintText: 'Search by name...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14.sp,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[400],
                            size: 20.sp,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Filter button
                  GestureDetector(
                    onTap: () {
                      _showFilterBottomSheet(context, controller);
                    },
                    child: Container(
                      height: 48.h,
                      width: 48.w,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.tune, color: Colors.black, size: 20.sp),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              // Client list
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final clients = controller.filteredClients;

                  if (clients.isEmpty) {
                    return Center(
                      child: Text(
                        'No clients found',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16.sp,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      final client = clients[index];
                      return _buildClientCard(context, client);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClientCard(BuildContext context, client) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClientDetailsScreen(client: client),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile Image
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: client.profileImage != null
                    ? DecorationImage(
                        image: NetworkImage(client.profileImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: client.profileImage == null ? Colors.grey[300] : null,
              ),
              child: client.profileImage == null
                  ? Icon(Icons.person, color: Colors.grey[600], size: 24.sp)
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
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    client.serviceType,
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    client.contactNumber,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            // Arrow Icon
            Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(
    BuildContext context,
    ClientController controller,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) =>
          _buildFilterBottomSheet(bottomSheetContext, controller),
    );
  }

  Widget _buildFilterBottomSheet(
    BuildContext context,
    ClientController controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Service Type Filter
          Text(
            'Service Type',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12.h),
          Obx(
            () => Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: controller.availableServiceTypes
                  .map((type) => _buildFilterChip(type, controller))
                  .toList(),
            ),
          ),
          SizedBox(height: 24.h),

          // Sort By Filter
          Text(
            'Sort By',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12.h),
          Obx(
            () => Column(
              children: [
                _buildSortOption('Name (A-Z)', controller),
                _buildSortOption('Name (Z-A)', controller),
                _buildSortOption('Recent', controller),
                _buildSortOption('Oldest', controller),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Get.snackbar(
                  'Success',
                  'Filters applied',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.primaryColor,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Apply Filters',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, ClientController controller) {
    final isSelected = controller.selectedServiceType.value == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (value) {
        controller.updateServiceTypeFilter(label);
      },
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontSize: 14.sp,
      ),
      backgroundColor: Colors.grey[100],
      selectedColor: AppColors.primaryColor,
      checkmarkColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
    );
  }

  Widget _buildSortOption(String label, ClientController controller) {
    final isSelected = controller.selectedSortOption.value == label;
    return InkWell(
      onTap: () {
        controller.updateSortOption(label);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryColor
                      : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? AppColors.primaryColor : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 12.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
