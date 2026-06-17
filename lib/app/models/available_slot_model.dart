class AvailableSlotModel {
  final String timeSlot;
  final int availableCapacity;
  final int maxCapacity;
  final bool isAvailable;

  AvailableSlotModel({
    required this.timeSlot,
    required this.availableCapacity,
    required this.maxCapacity,
    required this.isAvailable,
  });

  factory AvailableSlotModel.fromJson(Map<String, dynamic> json) {
    return AvailableSlotModel(
      timeSlot: json['time_slot'],
      availableCapacity: json['available_capacity'],
      maxCapacity: json['max_capacity'],
      isAvailable: json['is_available'],
    );
  }
}
