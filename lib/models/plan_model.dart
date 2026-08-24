/// Subscription Plan Model for Sky Spike
class PlanModel {
  final int? id;
  final String name;
  final int sessionsCount;
  final double price;
  final int durationDays;

  PlanModel({
    this.id,
    required this.name,
    required this.sessionsCount,
    required this.price,
    required this.durationDays,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'sessions_count': sessionsCount,
      'price': price,
      'duration_days': durationDays,
    };
  }

  factory PlanModel.fromMap(Map<String, dynamic> map) {
    return PlanModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      sessionsCount: map['sessions_count'] as int,
      price: (map['price'] as num).toDouble(),
      durationDays: map['duration_days'] as int,
    );
  }

  PlanModel copyWith({
    int? id,
    String? name,
    int? sessionsCount,
    double? price,
    int? durationDays,
  }) {
    return PlanModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sessionsCount: sessionsCount ?? this.sessionsCount,
      price: price ?? this.price,
      durationDays: durationDays ?? this.durationDays,
    );
  }

  @override
  String toString() => '$name ($sessionsCount حصص - $price ج.م)';
}
