import 'package:flutter/material.dart';

class AppointmentModel {
  final String id;
  final String time;
  final String bookingInfo;
  final String clientName;
  final String clientContact;
  final String? clientEmail;
  final String? clientImage;
  final DateTime dateTime;
  final Color color;
  final List<String> clientImages;
  final int additionalClients;
  final String status;
  final String serviceType;
  final String? notes;
  final int totalDurationMinutes;

  AppointmentModel({
    required this.id,
    required this.time,
    required this.bookingInfo,
    required this.clientName,
    required this.clientContact,
    this.clientEmail,
    this.clientImage,
    required this.dateTime,
    required this.color,
    this.clientImages = const [],
    this.additionalClients = 0,
    required this.status,
    required this.serviceType,
    this.notes,
    this.totalDurationMinutes = 60,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    // Parse date and time
    final dateStr = json['appointment_date'] as String;
    final timeStr = json['appointment_time'] as String;
    // Format: YYYY-MM-DD and HH:mm:ss
    final dateTime = DateTime.parse('$dateStr $timeStr');

    // Parse color or assign default
    // For now, assigning random or fixed colors based on something
    // The UI uses color for background.
    // Let's cycle through some pastel colors based on ID
    final colors = [
      const Color(0xFFB2F5EA),
      const Color(0xFFFEF3C7),
      const Color(0xFFFECDD3),
      const Color(0xFFFED7AA),
      const Color(0xFFE2E8F0),
    ];
    // Use total_time from API (already computed: service + processing + extra_servicing)
    int totalDuration = 0;
    if (json['total_time'] != null) {
      totalDuration = int.tryParse(json['total_time'].toString()) ?? 0;
    }

    // Fallback: sum service_time_minutes
    if (totalDuration == 0 && json['services'] != null && json['services'] is List) {
      for (var s in json['services']) {
        if (s['service_time_minutes'] != null) {
          totalDuration += int.tryParse(s['service_time_minutes'].toString()) ?? 0;
        }
      }
    }

    if (totalDuration <= 0) totalDuration = 60; // Fallback

    final idInt = json['id'] is int
        ? json['id'] as int
        : int.tryParse(json['id'].toString()) ?? 0;
    final color = colors[idInt % colors.length];

    final clientImg = json['client_image'] as String?;

    return AppointmentModel(
      id: json['id'].toString(),
      time: _formatTime(timeStr, totalDuration),
      bookingInfo: json['service_display'] ?? 'Booking: $dateStr|$timeStr',
      clientName: json['client_name'] ?? 'Unknown',
      clientContact: json['client_contact'] ?? '',
      clientEmail: json['client_email'] as String?,
      clientImage: clientImg,
      dateTime: dateTime,
      color: color,
      clientImages: clientImg != null ? [clientImg] : [],
      additionalClients: 0,
      status: json['status'] ?? 'scheduled',
      serviceType: json['service_display'] ?? 'General Service',
      notes: json['notes'] as String?,
      totalDurationMinutes: totalDuration,
    );
  }

  static String _formatTime(String timeStr, int durationMinutes) {
    // Input: 10:00:00
    // Output: 10:00 AM - 11:00 AM (Depending on duration)
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final dt = DateTime(2022, 1, 1, hour, minute);
      final dtEnd = dt.add(Duration(minutes: durationMinutes)); 

      String format(DateTime d) {
        int h = d.hour;
        final m = d.minute.toString().padLeft(2, '0');
        final period = h >= 12 ? 'PM' : 'AM';
        if (h > 12) h -= 12;
        if (h == 0) h = 12;
        return '$h:$m $period';
      }

      return '${format(dt)} - ${format(dtEnd)}';
    } catch (e) {
      return timeStr;
    }
  }

  factory AppointmentModel.create({
    required String time,
    required String bookingInfo,
    required String clientName,
    required DateTime dateTime,
    required Color color,
    List<String>? clientImages,
    int additionalClients = 0,
  }) {
    return AppointmentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      time: time,
      bookingInfo: bookingInfo,
      clientName: clientName,
      clientContact: '',
      dateTime: dateTime,
      color: color,
      clientImages: clientImages ?? [],
      additionalClients: additionalClients,
      status: 'scheduled',
      serviceType: 'General Service',
    );
  }

  AppointmentModel copyWith({
    String? id,
    String? time,
    String? bookingInfo,
    String? clientName,
    String? clientContact,
    String? clientEmail,
    String? clientImage,
    DateTime? dateTime,
    Color? color,
    List<String>? clientImages,
    int? additionalClients,
    String? status,
    String? serviceType,
    String? notes,
    int? totalDurationMinutes,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      time: time ?? this.time,
      bookingInfo: bookingInfo ?? this.bookingInfo,
      clientName: clientName ?? this.clientName,
      clientContact: clientContact ?? this.clientContact,
      clientEmail: clientEmail ?? this.clientEmail,
      clientImage: clientImage ?? this.clientImage,
      dateTime: dateTime ?? this.dateTime,
      color: color ?? this.color,
      clientImages: clientImages ?? this.clientImages,
      additionalClients: additionalClients ?? this.additionalClients,
      status: status ?? this.status,
      serviceType: serviceType ?? this.serviceType,
      notes: notes ?? this.notes,
      totalDurationMinutes: totalDurationMinutes ?? this.totalDurationMinutes,
    );
  }

  // Check if appointment is today
  bool get isToday {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  // Check if appointment is upcoming
  bool get isUpcoming {
    return dateTime.isAfter(DateTime.now());
  }
}
