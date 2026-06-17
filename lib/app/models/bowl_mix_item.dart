class BowlMixItem {
  final String bowlName;
  final double grams;
  final double cost;

  final int? productId; // Optional as manual items might not have one
  final double? userPrice;
  final double? marketPrice;
  final double? originalWeight;

  BowlMixItem({
    required this.bowlName,
    required this.grams,
    required this.cost,
    this.productId,
    this.userPrice,
    this.marketPrice,
    this.originalWeight,
  });

  // Calculate cost per gram
  double get costPerGram => grams > 0 ? cost / grams : 0.0;

  // Create a copy with updated values
  BowlMixItem copyWith({
    String? bowlName,
    double? grams,
    double? cost,
    double? originalWeight,
  }) {
    return BowlMixItem(
      bowlName: bowlName ?? this.bowlName,
      grams: grams ?? this.grams,
      cost: cost ?? this.cost,
      productId: productId,
      userPrice: userPrice,
      marketPrice: marketPrice,
      originalWeight: originalWeight ?? this.originalWeight,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'bowlName': bowlName,
      'grams': grams,
      'cost': cost,
      'originalWeight': originalWeight,
    };
  }

  // Create from JSON
  factory BowlMixItem.fromJson(Map<String, dynamic> json) {
    return BowlMixItem(
      bowlName: json['bowlName'] as String,
      grams: (json['grams'] as num).toDouble(),
      cost: (json['cost'] as num).toDouble(),
      originalWeight: json['originalWeight'] != null
          ? (json['originalWeight'] as num).toDouble()
          : null,
    );
  }

  @override
  String toString() {
    return 'BowlMixItem(bowlName: $bowlName, grams: $grams, cost: $cost)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BowlMixItem &&
        other.bowlName == bowlName &&
        other.grams == grams &&
        other.cost == cost;
  }

  @override
  int get hashCode => bowlName.hashCode ^ grams.hashCode ^ cost.hashCode;
}
