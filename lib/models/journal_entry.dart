class JournalEntry {
  final String id;
  final DateTime date;
  final String morningEntry;
  final String? eveningReflection;
  final String status; // pending, in_progress, completed
  final String? mood; // great, good, okay, bad, terrible
  final List<String>? tags;
  final DateTime createdAt;
  final DateTime? updatedAt;

  JournalEntry({
    required this.id,
    required this.date,
    required this.morningEntry,
    this.eveningReflection,
    this.status = 'pending',
    this.mood,
    this.tags,
    required this.createdAt,
    this.updatedAt,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      morningEntry: json['morning_entry'] as String,
      eveningReflection: json['evening_reflection'] as String?,
      status: json['status'] as String? ?? 'pending',
      mood: json['mood'] as String?,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0],
      'morning_entry': morningEntry,
      'evening_reflection': eveningReflection,
      'status': status,
      'mood': mood,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  JournalEntry copyWith({
    String? morningEntry,
    String? eveningReflection,
    String? status,
    String? mood,
    List<String>? tags,
    DateTime? updatedAt,
  }) {
    return JournalEntry(
      id: id,
      date: date,
      morningEntry: morningEntry ?? this.morningEntry,
      eveningReflection: eveningReflection ?? this.eveningReflection,
      status: status ?? this.status,
      mood: mood ?? this.mood,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
