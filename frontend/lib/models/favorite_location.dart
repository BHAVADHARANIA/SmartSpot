class FavoriteLocation {
  final String id;
  String label;
  double latitude;
  double longitude;
  String? address;
  DateTime createdAt;
  DateTime updatedAt;
  bool dirty;

  FavoriteLocation({
    required this.id,
    required this.label,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.createdAt,
    required this.updatedAt,
    this.dirty = true,
  });

  factory FavoriteLocation.fromLocalMap(Map<String, dynamic> map) {
    return FavoriteLocation(
      id: map['id'] as String,
      label: map['label'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      address: map['address'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      dirty: (map['dirty'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'label': label,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'dirty': dirty ? 1 : 0,
    };
  }

  factory FavoriteLocation.fromApiJson(Map<String, dynamic> json) {
    return FavoriteLocation(
      id: json['id'] as String,
      label: json['label'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      dirty: false,
    );
  }

  Map<String, dynamic> toApiJson() {
    return {
      'label': label,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}
