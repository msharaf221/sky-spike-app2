/// A named training team / age group stored in the `teams` table (schema v4).
class TeamModel {
  final int? id;
  final String name;
  final int sortOrder;
  final bool isActive;

  const TeamModel({
    this.id,
    required this.name,
    required this.sortOrder,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'sort_order': sortOrder,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory TeamModel.fromMap(Map<String, dynamic> map) {
    return TeamModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      sortOrder: map['sort_order'] as int? ?? 0,
      isActive: (map['is_active'] as int? ?? 1) == 1,
    );
  }

  TeamModel copyWith({
    int? id,
    String? name,
    int? sortOrder,
    bool? isActive,
  }) {
    return TeamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
    );
  }
}
