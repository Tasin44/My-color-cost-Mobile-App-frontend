import 'package:color_os/app/models/client_model.dart';
import 'package:color_os/app/models/client_appointment_model.dart';
import 'package:color_os/app/views/screens/appointments/appointments_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ClientDetailsAppointmentsTab extends StatelessWidget {
  final ClientModel client;

  const ClientDetailsAppointmentsTab({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    final upcomingAppointments = client.appointments
        .where((apt) => apt.status == AppointmentStatus.upcoming)
        .toList();
    final completedAppointments = client.appointments
        .where((apt) => apt.status == AppointmentStatus.complete)
        .toList();

    return Column(
      children: [
        // Appointments List
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Last Appointments Header
                Text(
                  'Last Appointments',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(),
                    TextButton(
                      onPressed: () => Get.to(() => const AppointmentsScreen()),
                      child: Text(
                        'See all',
                        style: TextStyle(
                          color: Colors.pink,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Upcoming Appointments
                if (upcomingAppointments.isNotEmpty)
                  ...upcomingAppointments.map(
                    (appointment) => Column(
                      children: [
                        _buildAppointmentCard(
                          appointment,
                          AppointmentStatus.upcoming,
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  )
                else
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Text(
                        'No upcoming appointments',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),

                // Completed Appointments
                if (completedAppointments.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  ...completedAppointments.map(
                    (appointment) => Column(
                      children: [
                        _buildAppointmentCard(
                          appointment,
                          AppointmentStatus.complete,
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(
    ClientAppointmentModel appointment,
    AppointmentStatus status,
  ) {
    final isUpcoming = status == AppointmentStatus.upcoming;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                appointment.serviceType,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isUpcoming ? Colors.blue[50] : Colors.green[50],
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  isUpcoming ? 'Upcoming' : 'Complete',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: isUpcoming ? Colors.blue[700] : Colors.green[700],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '${DateFormat('dd MMM yyyy').format(appointment.date)}, ${appointment.time}',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 16.h),

          // Action Buttons
          if (isUpcoming)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[50],
                      foregroundColor: Colors.pink,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey[300]!),
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'View Details',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
