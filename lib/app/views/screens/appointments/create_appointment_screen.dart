import 'package:color_os/app/controllers/book_appointment_controller.dart';
import 'package:color_os/app/controllers/auth_controller.dart';
import 'package:color_os/app/controllers/working_hours_controller.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';
import 'package:color_os/app/core/constant/themes/app_colors.dart';
import 'package:color_os/app/models/client_model.dart';
import 'package:color_os/app/models/service_type_model.dart';
import 'package:color_os/app/views/screens/onboarding/working_hours_setup_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CreateAppointmentScreen extends StatelessWidget {
  final ClientModel? client;
  const CreateAppointmentScreen({Key? key, this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BookAppointmentController());

    // Pre-select client if provided
    if (client != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.selectClient(client!);
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: Colors.black87, size: 24.sp),
        ),
        centerTitle: true,
        title: Text(
          'Book Appointment',
          style: AppTextStyle.headlineSmall.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Select Client ─────────────────────────────────────────────
            _sectionLabel('Select Client'),
            SizedBox(height: 8.h),
            _buildClientSelector(context, controller),

            SizedBox(height: 24.h),

            // ── Appointment Date (Calendar) ───────────────────────────────
            _sectionLabel('Appointment Date'),
            SizedBox(height: 8.h),
            Obx(() => _buildCalendar(controller)),

            SizedBox(height: 24.h),

            // ── Available Slots ───────────────────────────────────────────
            _sectionLabel('Available Slots'),
            SizedBox(height: 8.h),
            Obx(() => _buildSlots(controller)),

            SizedBox(height: 24.h),

            // ── Services ─────────────────────────────────────────────────
            _sectionLabel('Services'),
            SizedBox(height: 8.h),
            Obx(() => _buildServicesSelector(context, controller)),

            SizedBox(height: 24.h),

            // ── Optional Times ──────────────────────────────────────────
            _sectionLabel('Optional Times (min)'),
            SizedBox(height: 8.h),
            _buildOptionalTimesRow(controller),

            SizedBox(height: 24.h),

            // ── Notes ─────────────────────────────────────────────────────
            _sectionLabel('Notes (Optional)'),
            SizedBox(height: 8.h),
            _buildNotesField(controller),

            SizedBox(height: 36.h),

            // ── Submit Button ─────────────────────────────────────────────
            Obx(() => _buildSubmitButton(controller)),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  // ── Client Selector ───────────────────────────────────────────────────────

  Widget _buildClientSelector(
    BuildContext context,
    BookAppointmentController controller,
  ) {
    return InkWell(
      onTap: () => _showClientSheet(context, controller),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Obx(() {
              final c = controller.selectedClient.value;
              if (c != null) {
                return Row(
                  children: [
                    _clientAvatar(c),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          c.contactNumber,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
              return Text(
                'Select a client',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
              );
            }),
            const Spacer(),
            Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  Widget _clientAvatar(ClientModel c) {
    if (c.profileImage != null && c.profileImage!.isNotEmpty) {
      return CircleAvatar(
        radius: 18.r,
        backgroundImage: NetworkImage(c.profileImage!),
        backgroundColor: Colors.grey.shade200,
      );
    }
    return CircleAvatar(
      radius: 18.r,
      backgroundColor: AppColors.primaryColor.withOpacity(0.15),
      child: Text(
        c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  // ── Calendar ──────────────────────────────────────────────────────────────

  Widget _buildCalendar(BookAppointmentController controller) {
    final now = DateTime.now();
    final month = controller.currentMonth.value;
    final selected = controller.selectedDate.value;

    // First day of the month
    final firstDay = DateTime(month.year, month.month, 1);
    // Weekday: Mon=1…Sun=7, offset so Mon=0
    final startOffset = (firstDay.weekday - 1) % 7;
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);

    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Month nav row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: controller.previousMonth,
                icon: Icon(Icons.chevron_left, size: 22.sp, color: Colors.black87),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Text(
                      '${_monthName(month.month)} ${month.year}',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down,
                        size: 18.sp, color: Colors.black54),
                  ],
                ),
              ),
              IconButton(
                onPressed: controller.nextMonth,
                icon: Icon(Icons.chevron_right, size: 22.sp, color: Colors.black87),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Day name row
          Row(
            children: dayNames
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          SizedBox(height: 8.h),

          // Date grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4.h,
              crossAxisSpacing: 4.w,
            ),
            itemCount: startOffset + daysInMonth,
            itemBuilder: (_, idx) {
              if (idx < startOffset) return const SizedBox.shrink();
              final day = idx - startOffset + 1;
              final date = DateTime(month.year, month.month, day);
              final isSelected = DateUtils.isSameDay(date, selected);
              final isToday = DateUtils.isSameDay(date, now);
              final isPast = date.isBefore(DateTime(now.year, now.month, now.day));

              return GestureDetector(
                onTap: isPast ? null : () => controller.selectDate(date),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight:
                            isSelected || isToday ? FontWeight.w700 : FontWeight.w400,
                        color: isSelected
                            ? Colors.white
                            : isPast
                                ? Colors.grey.shade400
                                : isToday
                                    ? AppColors.primaryColor
                                    : Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _monthName(int m) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return names[m - 1];
  }

  // ── Time Slots ────────────────────────────────────────────────────────────

  Widget _buildSlots(BookAppointmentController controller) {
    if (controller.isLoadingSlots.value) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.availableSlots.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Center(
          child: Text(
            'No slots available for this date',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
          ),
        ),
      );
    }
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: controller.availableSlots.map((slot) {
        final isSelected = controller.selectedTimeSlot.value == slot.timeSlot;
        final isAvailable = slot.isAvailable;
        return GestureDetector(
          onTap: isAvailable ? () => controller.selectTimeSlot(slot.timeSlot) : null,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryColor
                  : isAvailable
                      ? Colors.white
                      : Colors.grey.shade100,
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryColor
                    : isAvailable
                        ? Colors.grey.shade300
                        : Colors.grey.shade200,
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              slot.timeSlot.substring(0, 5),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : isAvailable
                        ? Colors.black87
                        : Colors.grey.shade400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Services Selector ─────────────────────────────────────────────────────

  Widget _buildServicesSelector(
    BuildContext context,
    BookAppointmentController controller,
  ) {
    if (controller.isLoadingServices.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.services.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          'No services found. Add services from Profile → Services List.',
          style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _showServicesSheet(context, controller),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(
            color: controller.selectedServiceIds.isNotEmpty
                ? AppColors.primaryColor.withOpacity(0.5)
                : Colors.grey.shade200,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(
              Icons.design_services_outlined,
              size: 18.sp,
              color: controller.selectedServiceIds.isNotEmpty
                  ? AppColors.primaryColor
                  : Colors.grey.shade500,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                controller.selectedServicesLabel,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: controller.selectedServiceIds.isNotEmpty
                      ? Colors.black87
                      : Colors.grey.shade500,
                  fontWeight: controller.selectedServiceIds.isNotEmpty
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  // ── Notes ─────────────────────────────────────────────────────────────────

  Widget _buildNotesField(BookAppointmentController controller) {
    return TextField(
      controller: controller.notesController,
      maxLines: 3,
      style: TextStyle(fontSize: 14.sp, color: Colors.black87),
      decoration: InputDecoration(
        hintText: 'Add any notes for this appointment…',
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
    );
  }

  // ── Optional Times ────────────────────────────────────────────────────────

  Widget _buildOptionalTimesRow(BookAppointmentController controller) {
    return Row(
      children: [
        Expanded(
          child: _timeField(controller.processingTimeController, 'Processing'),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _timeField(controller.blockedTimeController, 'Blocked'),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _timeField(controller.extraServicingController, 'Extra'),
        ),
      ],
    );
  }

  Widget _timeField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      style: TextStyle(fontSize: 13.sp, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12.sp),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
      ),
    );
  }

  // ── Submit Button ─────────────────────────────────────────────────────────

  Widget _buildSubmitButton(BookAppointmentController controller) {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton(
        onPressed: controller.isSubmitting.value
            ? null
            : controller.submitAppointment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          disabledBackgroundColor: AppColors.primaryColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          elevation: 0,
        ),
        child: controller.isSubmitting.value
            ? SizedBox(
                width: 22.w,
                height: 22.w,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Book Appointment',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  // ── Bottom Sheets ─────────────────────────────────────────────────────────

  void _showClientSheet(
    BuildContext context,
    BookAppointmentController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (_, scrollCtrl) {
            return Column(
              children: [
                // Handle
                Padding(
                  padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  child: Text(
                    'Select Client',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoadingClients.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.clients.isEmpty) {
                      return Center(
                        child: Text(
                          'No clients found',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      controller: scrollCtrl,
                      itemCount: controller.clients.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: Colors.grey.shade100),
                      itemBuilder: (_, i) {
                        final c = controller.clients[i];
                        final isSelected =
                            controller.selectedClient.value?.id == c.id;
                        return ListTile(
                          leading: _clientAvatar(c),
                          title: Text(
                            c.name,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            c.contactNumber,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle,
                                  color: AppColors.primaryColor, size: 20.sp)
                              : null,
                          onTap: () {
                            controller.selectClient(c);
                            Get.back();
                          },
                        );
                      },
                    );
                  }),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showServicesSheet(
    BuildContext context,
    BookAppointmentController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (_, scrollCtrl) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Services',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      Obx(() => TextButton(
                            onPressed: () => Get.back(),
                            child: Text(
                              'Done (${controller.selectedServiceIds.length})',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                Expanded(
                  child: Obx(() {
                    return ListView.separated(
                      controller: scrollCtrl,
                      itemCount: controller.services.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: Colors.grey.shade100),
                      itemBuilder: (_, i) {
                        final svc = controller.services[i];
                        return Obx(() {
                          final isSelected = controller.isServiceSelected(svc.id);
                          return ListTile(
                            leading: Container(
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(
                                Icons.design_services_outlined,
                                color: AppColors.primaryColor,
                                size: 20.sp,
                              ),
                            ),
                            title: Text(
                              svc.name,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              '${svc.serviceTimeMinutes} min · ${_servicePrice(svc)}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            trailing: isSelected
                                ? Container(
                                    width: 24.w,
                                    height: 24.w,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.check,
                                        color: Colors.white, size: 14.sp),
                                  )
                                : Container(
                                    width: 24.w,
                                    height: 24.w,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                            onTap: () => controller.toggleService(svc.id),
                          );
                        });
                      },
                    );
                  }),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _servicePrice(ServiceTypeModel svc) {
    if (svc.priceType == 'free') return 'Free';
    if (svc.serviceFee != null) {
      final prefix = svc.priceType == 'from' ? 'From ' : '';
      return '$prefix\$${svc.serviceFee}';
    }
    return svc.priceTypeDisplay ?? svc.priceType;
  }
}

// ── Setup Required Dialog ─────────────────────────────────────────────────────

void showSetupRequiredDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      contentPadding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 20.h),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange.shade700,
              size: 30.sp,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Setup Required',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'You need to setup your services and working hours before you can create an appointment.',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.to(() => const WorkingHoursSetupSheet());
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    backgroundColor: AppColors.primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Go to Setup',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
