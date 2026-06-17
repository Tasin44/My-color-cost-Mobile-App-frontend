import 'package:color_os/app/models/mix_model.dart';
import 'package:color_os/app/models/client_appointment_model.dart';

class ClientModel {
  final String id;
  final String name;
  final String? profileImage;
  final String contactNumber;
  final String email;
  final String serviceType;
  final DateTime? skinTestDate;
  final String? notes;
  final List<String> beforeImages;
  final List<String> afterImages;
  final DateTime createdAt;
  final DateTime? lastVisit;
  final DateTime? nextBooking;
  final int totalMixes;
  final List<MixModel> mixHistory;
  final List<ClientAppointmentModel> appointments;

  ClientModel({
    required this.id,
    required this.name,
    this.profileImage,
    required this.contactNumber,
    required this.email,
    required this.serviceType,
    this.skinTestDate,
    this.notes,
    this.beforeImages = const [],
    this.afterImages = const [],
    required this.createdAt,
    this.lastVisit,
    this.nextBooking,
    this.totalMixes = 0,
    this.mixHistory = const [],
    this.appointments = const [],
    this.hasImages = false,
  });

  // Factory constructor for creating a new client with default values
  factory ClientModel.create({
    required String name,
    String? profileImage,
    required String contactNumber,
    required String email,
    required String serviceType,
    DateTime? skinTestDate,
    String? notes,
    List<String>? beforeImages,
    List<String>? afterImages,
    DateTime? lastVisit,
    DateTime? nextBooking,
    int? totalMixes,
    List<MixModel>? mixHistory,
    List<ClientAppointmentModel>? appointments,
    bool? hasImages,
  }) {
    return ClientModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      profileImage: profileImage,
      contactNumber: contactNumber,
      email: email,
      serviceType: serviceType,
      skinTestDate: skinTestDate,
      notes: notes,
      beforeImages: beforeImages ?? [],
      afterImages: afterImages ?? [],
      createdAt: DateTime.now(),
      lastVisit: lastVisit,
      nextBooking: nextBooking,
      totalMixes: totalMixes ?? 0,
      mixHistory: mixHistory ?? [],
      appointments: appointments ?? [],
      hasImages: hasImages ?? false,
    );
  }

  // Copy with method for updating client
  ClientModel copyWith({
    String? id,
    String? name,
    String? profileImage,
    String? contactNumber,
    String? email,
    String? serviceType,
    DateTime? skinTestDate,
    String? notes,
    List<String>? beforeImages,
    List<String>? afterImages,
    DateTime? createdAt,
    DateTime? lastVisit,
    DateTime? nextBooking,
    int? totalMixes,
    List<MixModel>? mixHistory,
    List<ClientAppointmentModel>? appointments,
    bool? hasImages,
  }) {
    return ClientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      serviceType: serviceType ?? this.serviceType,
      skinTestDate: skinTestDate ?? this.skinTestDate,
      notes: notes ?? this.notes,
      beforeImages: beforeImages ?? this.beforeImages,
      afterImages: afterImages ?? this.afterImages,
      createdAt: createdAt ?? this.createdAt,
      lastVisit: lastVisit ?? this.lastVisit,
      nextBooking: nextBooking ?? this.nextBooking,
      totalMixes: totalMixes ?? this.totalMixes,
      mixHistory: mixHistory ?? this.mixHistory,
      appointments: appointments ?? this.appointments,
      hasImages: hasImages ?? this.hasImages,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profileImage': profileImage,
      'contactNumber': contactNumber,
      'email': email,
      'serviceType': serviceType,
      'skinTestDate': skinTestDate?.toIso8601String(),
      'notes': notes,
      'beforeImages': beforeImages,
      'afterImages': afterImages,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      profileImage: json['profile_image_url'],
      contactNumber: json['contact_number'] ?? '',
      email: json['email'] ?? '',
      serviceType: json['service_type'] ?? '',
      skinTestDate: json['skin_test_date'] != null
          ? DateTime.tryParse(json['skin_test_date'].toString())
          : null,
      notes: json['notes'],
      beforeImages: json['before_images'] != null
          ? List<String>.from(json['before_images'])
          : [],
      afterImages: json['after_images'] != null
          ? List<String>.from(json['after_images'])
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      lastVisit: json['last_visit_date'] != null
          ? DateTime.tryParse(json['last_visit_date'].toString())
          : null,
      nextBooking: json['next_appointment_date'] != null
          ? DateTime.tryParse(json['next_appointment_date'].toString())
          : null,
      totalMixes: int.tryParse(json['total_mixes']?.toString() ?? '0') ?? 0,
      hasImages: json['has_images'] ?? false,
      mixHistory: json['mix_history'] != null
          ? (json['mix_history'] as List)
                .map((m) => MixModel.fromJson(m))
                .toList()
          : [],
    );
  }

  // Helper properties
  final bool hasImages;
}
