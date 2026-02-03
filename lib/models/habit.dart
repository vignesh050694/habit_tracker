class Habit {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String frequency; // daily, weekly, custom
  final List<int>? customDays; // 1=Mon, 7=Sun for custom frequency
  final DateTime createdAt;
  final bool isActive;

  Habit({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.frequency = 'daily',
    this.customDays,
    required this.createdAt,
    this.isActive = true,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      frequency: json['frequency'] as String? ?? 'daily',
      customDays: json['custom_days'] != null
          ? List<int>.from(json['custom_days'] as List)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'frequency': frequency,
      'custom_days': customDays,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  Habit copyWith({
    String? name,
    String? description,
    String? icon,
    String? frequency,
    List<int>? customDays,
    bool? isActive,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      frequency: frequency ?? this.frequency,
      customDays: customDays ?? this.customDays,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

class HabitLog {
  final String id;
  final String habitId;
  final DateTime date;
  final bool completed;
  final String? note;

  HabitLog({
    required this.id,
    required this.habitId,
    required this.date,
    this.completed = false,
    this.note,
  });

  factory HabitLog.fromJson(Map<String, dynamic> json) {
    return HabitLog(
      id: json['id'] as String,
      habitId: json['habit_id'] as String,
      date: DateTime.parse(json['date'] as String),
      completed: json['completed'] as bool? ?? false,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habit_id': habitId,
      'date': date.toIso8601String().split('T')[0],
      'completed': completed,
      'note': note,
    };
  }
}
