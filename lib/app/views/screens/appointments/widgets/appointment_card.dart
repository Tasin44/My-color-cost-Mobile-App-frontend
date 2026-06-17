import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:color_os/app/models/appointment_model.dart';
import 'package:color_os/app/core/constant/app_textstyle.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onTap;

  const AppointmentCard({Key? key, required this.appointment, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: appointment.color,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking info
            Text(
              appointment.bookingInfo,
              style: AppTextStyle.bodySmall.copyWith(
                color: _getTextColor(appointment.color),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),

            // Client info row
            Row(
              children: [
                // Client avatars
                _buildClientAvatars(),
                SizedBox(width: 12.w),

                // Client appointment text
                Expanded(
                  child: Text(
                    appointment.clientName,
                    style: AppTextStyle.bodyMedium.copyWith(
                      color: _getTextColor(appointment.color),
                      fontWeight: FontWeight.w400,
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

  Widget _buildClientAvatars() {
    return SizedBox(
      height: 32.h,
      width: appointment.additionalClients > 0 ? 100.w : 32.w,
      child: Stack(
        children: [
          // Show up to 3 avatar placeholders
          ...List.generate(
            appointment.additionalClients > 0 ? 3 : 1,
            (index) => Positioned(
              left: index * 20.w,
              child: Container(
                width: 32.w,
                height: 32.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade300,
                  border: Border.all(color: Colors.white, width: 2),
                  image: appointment.clientImages.length > index
                      ? DecorationImage(
                          image:
                              appointment.clientImages[index].startsWith('http')
                              ? NetworkImage(appointment.clientImages[index])
                              : AssetImage(appointment.clientImages[index])
                                    as ImageProvider,
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: appointment.clientImages.length <= index
                    ? Icon(
                        Icons.person,
                        size: 16.sp,
                        color: Colors.grey.shade600,
                      )
                    : null,
              ),
            ),
          ),

          // Additional clients indicator
          if (appointment.additionalClients > 0)
            Positioned(
              left: 60.w,
              child: Container(
                width: 32.w,
                height: 32.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade700,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '${appointment.additionalClients}+',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getTextColor(Color backgroundColor) {
    // Calculate brightness to determine text color
    final brightness = backgroundColor.computeLuminance();
    return brightness > 0.5 ? Colors.black87 : Colors.white;
  }
}
