class ExpenseCategory {
  final String id;
  final String name;
  final String? icon;
  final String? color;
  final DateTime createdAt;

  ExpenseCategory({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    required this.createdAt,
  });

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ExpenseCategory copyWith({
    String? name,
    String? icon,
    String? color,
  }) {
    return ExpenseCategory(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt,
    );
  }
}

class Expense {
  final String id;
  final String categoryId;
  final double amount;
  final String? description;
  final DateTime date;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.categoryId,
    required this.amount,
    this.description,
    required this.date,
    required this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
    };
  }

  Expense copyWith({
    String? categoryId,
    double? amount,
    String? description,
    DateTime? date,
  }) {
    return Expense(
      id: id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt,
    );
  }
}
