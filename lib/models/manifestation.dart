class Manifestation {
  final String id;
  final String affirmation;
  final String? description;
  final String category; // career, health, relationships, financial, personal_growth, spiritual
  final String status; // active, manifesting, manifested, released
  final DateTime? targetDate;
  final DateTime createdAt;
  final DateTime? manifestedAt;

  Manifestation({
    required this.id,
    required this.affirmation,
    this.description,
    required this.category,
    required this.status,
    this.targetDate,
    required this.createdAt,
    this.manifestedAt,
  });

  factory Manifestation.fromJson(Map<String, dynamic> json) {
    return Manifestation(
      id: json['id'] as String,
      affirmation: json['affirmation'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      status: json['status'] as String,
      targetDate: json['target_date'] != null
          ? DateTime.parse(json['target_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      manifestedAt: json['manifested_at'] != null
          ? DateTime.parse(json['manifested_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'affirmation': affirmation,
      'description': description,
      'category': category,
      'status': status,
      'target_date': targetDate?.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
      'manifested_at': manifestedAt?.toIso8601String(),
    };
  }

  Manifestation copyWith({
    String? affirmation,
    String? description,
    String? category,
    String? status,
    DateTime? targetDate,
    DateTime? manifestedAt,
  }) {
    return Manifestation(
      id: id,
      affirmation: affirmation ?? this.affirmation,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt,
      manifestedAt: manifestedAt ?? this.manifestedAt,
    );
  }

  static const List<String> categories = [
    'career',
    'health',
    'relationships',
    'financial',
    'personal_growth',
    'spiritual',
  ];

  static String categoryLabel(String category) {
    switch (category) {
      case 'career':
        return 'Career';
      case 'health':
        return 'Health';
      case 'relationships':
        return 'Relationships';
      case 'financial':
        return 'Financial';
      case 'personal_growth':
        return 'Personal Growth';
      case 'spiritual':
        return 'Spiritual';
      default:
        return category;
    }
  }

  static String statusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Active';
      case 'manifesting':
        return 'Manifesting';
      case 'manifested':
        return 'Manifested';
      case 'released':
        return 'Released';
      default:
        return status;
    }
  }
}

/// Daily practice log for a manifestation (affirm, visualize, gratitude)
class ManifestationPractice {
  final String id;
  final String manifestationId;
  final DateTime date;
  final bool affirmed;
  final bool visualized;
  final String? gratitudeNote;
  final DateTime createdAt;

  ManifestationPractice({
    required this.id,
    required this.manifestationId,
    required this.date,
    required this.affirmed,
    required this.visualized,
    this.gratitudeNote,
    required this.createdAt,
  });

  factory ManifestationPractice.fromJson(Map<String, dynamic> json) {
    return ManifestationPractice(
      id: json['id'] as String,
      manifestationId: json['manifestation_id'] as String,
      date: DateTime.parse(json['date'] as String),
      affirmed: json['affirmed'] as bool,
      visualized: json['visualized'] as bool,
      gratitudeNote: json['gratitude_note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'manifestation_id': manifestationId,
      'date': date.toIso8601String().split('T')[0],
      'affirmed': affirmed,
      'visualized': visualized,
      'gratitude_note': gratitudeNote,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ManifestationPractice copyWith({
    bool? affirmed,
    bool? visualized,
    String? gratitudeNote,
  }) {
    return ManifestationPractice(
      id: id,
      manifestationId: manifestationId,
      date: date,
      affirmed: affirmed ?? this.affirmed,
      visualized: visualized ?? this.visualized,
      gratitudeNote: gratitudeNote ?? this.gratitudeNote,
      createdAt: createdAt,
    );
  }
}

/// Signs and synchronicities observed
class ManifestationSign {
  final String id;
  final String manifestationId;
  final String description;
  final DateTime date;
  final DateTime createdAt;

  ManifestationSign({
    required this.id,
    required this.manifestationId,
    required this.description,
    required this.date,
    required this.createdAt,
  });

  factory ManifestationSign.fromJson(Map<String, dynamic> json) {
    return ManifestationSign(
      id: json['id'] as String,
      manifestationId: json['manifestation_id'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'manifestation_id': manifestationId,
      'description': description,
      'date': date.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
    };
  }
}
