class ExpenseModel {
  final int? id;
  final String? user;
  final String? expenseName;
  final String? amount;
  final String? category;
  final String? description;
  final String? image;
  final String? createdAt;
  final String? updatedAt;

  ExpenseModel({
    this.id,
    this.user,
    this.expenseName,
    this.amount,
    this.category,
    this.description,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      user: json['user'],
      expenseName: json['expense_name'],
      amount: json['amount'],
      category: json['category'],
      description: json['description'],
      image: json['image'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'expense_name': expenseName,
      'amount': amount,
      'category': category,
      'description': description,
      'image': image,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
