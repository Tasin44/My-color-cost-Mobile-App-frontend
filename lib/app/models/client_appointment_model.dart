enum AppointmentStatus { upcoming, complete, cancelled }

class ClientAppointmentModel {
  final String id;
  final String serviceType;
  final DateTime date;
  final String time;
  final AppointmentStatus status;

  ClientAppointmentModel({
    required this.id,
    required this.serviceType,
    required this.date,
    required this.time,
    required this.status,
  });

  factory ClientAppointmentModel.create({
    required String serviceType,
    required DateTime date,
    required String time,
    required AppointmentStatus status,
  }) {
    return ClientAppointmentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      serviceType: serviceType,
      date: date,
      time: time,
      status: status,
    );
  }

  ClientAppointmentModel copyWith({
    String? id,
    String? serviceType,
    DateTime? date,
    String? time,
    AppointmentStatus? status,
  }) {
    return ClientAppointmentModel(
      id: id ?? this.id,
      serviceType: serviceType ?? this.serviceType,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
    );
  }
}
