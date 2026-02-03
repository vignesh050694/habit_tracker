class ActivityMapping {
  final String id;
  final String triggerActivity; // e.g., "After brushing"
  final String habitId;
  final String mappedAction; // e.g., "Read 20 pages of a book"
  final String? notes;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;

  ActivityMapping({
    required this.id,
    required this.triggerActivity,
    required this.habitId,
    required this.mappedAction,
    this.notes,
    this.sortOrder = 0,
    this.isActive = true,
    required this.createdAt,
  });

  factory ActivityMapping.fromJson(Map<String, dynamic> json) {
    return ActivityMapping(
      id: json['id'] as String,
      triggerActivity: json['trigger_activity'] as String,
      habitId: json['habit_id'] as String,
      mappedAction: json['mapped_action'] as String,
      notes: json['notes'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trigger_activity': triggerActivity,
      'habit_id': habitId,
      'mapped_action': mappedAction,
      'notes': notes,
      'sort_order': sortOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ActivityMapping copyWith({
    String? triggerActivity,
    String? habitId,
    String? mappedAction,
    String? notes,
    int? sortOrder,
    bool? isActive,
  }) {
    return ActivityMapping(
      id: id,
      triggerActivity: triggerActivity ?? this.triggerActivity,
      habitId: habitId ?? this.habitId,
      mappedAction: mappedAction ?? this.mappedAction,
      notes: notes ?? this.notes,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}
