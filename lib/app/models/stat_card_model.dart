class StatCardModel {
  final String id;
  final String title;
  final String value;
  final String change;
  final bool isPositive;

  StatCardModel({
    required this.id,
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
  });

  StatCardModel copyWith({
    String? id,
    String? title,
    String? value,
    String? change,
    bool? isPositive,
  }) {
    return StatCardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      value: value ?? this.value,
      change: change ?? this.change,
      isPositive: isPositive ?? this.isPositive,
    );
  }
}
