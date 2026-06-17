import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/controllers/client_controller.dart';
import 'package:color_os/app/controllers/new_mix_controller.dart';
import 'package:color_os/app/models/client_model.dart';
import 'package:color_os/app/views/screens/tabs/client/widgets/client_details_overview_tab.dart';
import 'package:color_os/app/views/screens/tabs/client/widgets/client_details_mix_history_tab.dart';
import 'package:color_os/app/views/screens/tabs/client/widgets/client_details_appointments_tab.dart';
import 'package:color_os/app/views/screens/tabs/client/widgets/client_details_photos_tab.dart';
import 'package:color_os/app/views/screens/newmix/new_mix_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:color_os/app/views/screens/tabs/client/edit_client_screen.dart';
import 'package:intl/intl.dart';

class ClientDetailsScreen extends StatefulWidget {
  final ClientModel client;

  const ClientDetailsScreen({super.key, required this.client});

  @override
  State<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ClientController _clientController = Get.find<ClientController>();
  ClientModel? _detailedClient;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Delay API call until after build phase completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchClientDetails();
    });
  }

  Future<void> _fetchClientDetails() async {
    final details = await _clientController.getClientDetails(widget.client.id);
    setState(() {
      _detailedClient = details ?? widget.client;
      _isLoading = false;
    });
  }

  void _startService() async {
    final client = _detailedClient ?? widget.client;

    // Reset any in-progress mix and pre-assign this client
    final mixController = Get.isRegistered<NewMixController>()
        ? Get.find<NewMixController>()
        : Get.put(NewMixController());
    mixController.resetMix();
    mixController.selectedClientId.value = client.id;
    mixController.selectedClient.value = client;

    await Get.to(() => const NewMixScreen());

    // Refresh client details once the user returns so mix history is up to date
    _fetchClientDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final client = _detailedClient ?? widget.client;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Client Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.black, size: 24.sp),
            onSelected: (value) async {
              if (value == 'edit') {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditClientScreen(client: client),
                  ),
                );
                if (result == true) {
                  _fetchClientDetails();
                }
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: Text('Edit details'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Profile Header
                _buildProfileHeader(client),

                // Stats Cards
                _buildStatsCards(client),

                // Tab Bar
                _buildTabBar(),

                // Tab View
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      ClientDetailsOverviewTab(client: client),
                      ClientDetailsMixHistoryTab(client: client),
                      ClientDetailsAppointmentsTab(client: client),
                      ClientDetailsPhotosTab(client: client),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProfileHeader(ClientModel client) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        children: [
          // Profile Image
          Container(
            width: 100.w,
            height: 100.w,
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
                ? Icon(Icons.person, color: Colors.grey[600], size: 45.sp)
                : null,
          ),

          SizedBox(height: 12.h),

          // Name
          Text(
            client.name,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),

          SizedBox(height: 8.h),

          // Start Service button — inline below the name
          GestureDetector(
            onTap: _startService,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 9.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9B26AF), Color(0xFFE0177A)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE0177A).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_circle_outline,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Start Service',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 6.h),

          if (client.skinTestDate != null)
            Text(
              DateFormat('dd MMM yyyy').format(client.skinTestDate!),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(ClientModel client) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Last Visit',
              client.lastVisit != null
                  ? DateFormat('dd MMM yyyy').format(client.lastVisit!)
                  : '---',
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _buildStatCard(
              'Next Booking',
              client.nextBooking != null
                  ? DateFormat('dd MMM yyyy').format(client.nextBooking!)
                  : '---',
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _buildStatCard('Total Mixes', client.totalMixes.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        indicatorColor: AppColors.primaryColor,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Mix History'),
          Tab(text: 'Appointments'),
          Tab(text: 'Photos'),
        ],
      ),
    );
  }
}
