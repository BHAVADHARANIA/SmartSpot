class Reminder {
  final String id;
  String title;
  String? notes;
  double? latitude;
  double? longitude;
  double radiusMeters;
  String? category;
  String conditionType; // arrive | leave | time | combo
  DateTime? scheduledAt;
  String status; // active | completed | archived
  bool isFavorite;
  DateTime createdAt;
  DateTime updatedAt;
  bool dirty; // true if changed locally and not yet synced to server

  Reminder({
    required this.id,
    required this.title,
    this.notes,
    this.latitude,
    this.longitude,
    this.radiusMeters = 100,
    this.category,
    this.conditionType = 'arrive',
    this.scheduledAt,
    this.status = 'active',
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
    this.dirty = true,
  });

  factory Reminder.fromLocalMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as String,
      title: map['title'] as String,
      notes: map['notes'] as String?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      radiusMeters: (map['radius_meters'] as num?)?.toDouble() ?? 100,
      category: map['category'] as String?,
      conditionType: map['condition_type'] as String? ?? 'arrive',
      scheduledAt: map['scheduled_at'] != null ? DateTime.tryParse(map['scheduled_at']) : null,
      status: map['status'] as String? ?? 'active',
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      dirty: (map['dirty'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
      'radius_meters': radiusMeters,
      'category': category,
      'condition_type': conditionType,
      'scheduled_at': scheduledAt?.toIso8601String(),
      'status': status,
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'dirty': dirty ? 1 : 0,
    };
  }

  factory Reminder.fromApiJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      title: json['title'] as String,
      notes: json['notes'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      radiusMeters: (json['radius_meters'] as num?)?.toDouble() ?? 100,
      category: json['category'] as String?,
      conditionType: json['condition_type'] as String? ?? 'arrive',
      scheduledAt: json['scheduled_at'] != null ? DateTime.tryParse(json['scheduled_at']) : null,
      status: json['status'] as String? ?? 'active',
      isFavorite: (json['is_favorite'] == 1 || json['is_favorite'] == true),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      dirty: false,
    );
  }

  Map<String, dynamic> toApiJson() {
    return {
      'title': title,
      'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
      'radiusMeters': radiusMeters,
      'category': category,
      'conditionType': conditionType,
      'scheduledAt': scheduledAt?.toIso8601String(),
      'status': status,
      'isFavorite': isFavorite,
    };
  }
}
