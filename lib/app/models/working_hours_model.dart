class WorkingDayModel {
  final int id;
  final int weekday;
  final String weekdayName;
  String? startTime;
  String? endTime;
  bool isOff;

  WorkingDayModel({
    required this.id,
    required this.weekday,
    required this.weekdayName,
    this.startTime,
    this.endTime,
    required this.isOff,
  });

  factory WorkingDayModel.fromJson(Map<String, dynamic> json) {
    return WorkingDayModel(
      id: json['id'] ?? 0,
      weekday: json['weekday'] ?? 0,
      weekdayName: json['weekday_name'] ?? '',
      startTime: json['start_time'],
      endTime: json['end_time'],
      isOff: json['is_off'] == true,
    );
  }

  // Returns a default working day for given weekday index (0=Monday...6=Sunday)
  factory WorkingDayModel.defaultDay(int weekday) {
    const names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return WorkingDayModel(
      id: weekday,
      weekday: weekday,
      weekdayName: names[weekday],
      startTime: '09:00:00',
      endTime: '18:00:00',
      isOff: weekday == 6, // Sunday off by default
    );
  }
}

class WorkingHoursModel {
  final String id;
  final bool isLocked;
  final List<WorkingDayModel> workingDays;
  final List<int> offDays;
  final DateTime? createdAt;

  WorkingHoursModel({
    required this.id,
    required this.isLocked,
    required this.workingDays,
    required this.offDays,
    this.createdAt,
  });

  factory WorkingHoursModel.fromJson(Map<String, dynamic> json) {
    final rawDays = json['working_days'] as List<dynamic>? ?? [];
    final parsedDays = rawDays.map((d) => WorkingDayModel.fromJson(d)).toList();

    // Ensure all 7 days are represented
    final allDays = List.generate(7, (i) {
      return parsedDays.firstWhere(
        (d) => d.weekday == i,
        orElse: () => WorkingDayModel.defaultDay(i),
      );
    });

    return WorkingHoursModel(
      id: json['id']?.toString() ?? '',
      isLocked: json['is_locked'] == true,
      workingDays: allDays,
      offDays: List<int>.from(json['off_days'] ?? []),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  factory WorkingHoursModel.empty() {
    return WorkingHoursModel(
      id: '',
      isLocked: false,
      workingDays: List.generate(7, (i) => WorkingDayModel.defaultDay(i)),
      offDays: [6],
    );
  }
}
