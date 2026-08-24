/// Trainee Entity Model with calculated fields & helpers
class TraineeModel {
  final int? id;
  final String name;
  final String phone;
  final int age;
  final String groupName;
  final int planId;
  final int totalSessions;
  final int attendedSessions;
  final double totalFee;
  final double paidAmount;
  final String status; // 'Active', 'Suspended', 'Expired'
  final String joinDate; // YYYY-MM-DD
  final String? planName; // Optional joined field

  TraineeModel({
    this.id,
    required this.name,
    required this.phone,
    required this.age,
    required this.groupName,
    required this.planId,
    required this.totalSessions,
    this.attendedSessions = 0,
    required this.totalFee,
    this.paidAmount = 0.0,
    this.status = 'Active',
    required this.joinDate,
    this.planName,
  });

  // Computed Business Logic Properties
  int get remainingSessions {
    final remaining = totalSessions - attendedSessions;
    return remaining < 0 ? 0 : remaining;
  }

  double get remainingDebt {
    final debt = totalFee - paidAmount;
    return debt < 0 ? 0.0 : debt;
  }

  double get attendanceProgress {
    if (totalSessions <= 0) return 0.0;
    final progress = attendedSessions / totalSessions;
    return progress.clamp(0.0, 1.0);
  }

  bool get isFullyPaid => paidAmount >= totalFee;
  bool get hasZeroSessions => remainingSessions <= 0;
  bool get isActive => status == 'Active';

  String get localizedStatus {
    switch (status) {
      case 'Active':
        return 'نشط';
      case 'Suspended':
        return 'موقوف';
      case 'Expired':
        return 'منتهي';
      default:
        return status;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      'age': age,
      'group_name': groupName,
      'plan_id': planId,
      'total_sessions': totalSessions,
      'attended_sessions': attendedSessions,
      'total_fee': totalFee,
      'paid_amount': paidAmount,
      'status': status,
      'join_date': joinDate,
    };
  }

  factory TraineeModel.fromMap(Map<String, dynamic> map) {
    return TraineeModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String,
      age: map['age'] as int,
      groupName: map['group_name'] as String,
      planId: map['plan_id'] as int,
      totalSessions: map['total_sessions'] as int,
      attendedSessions: (map['attended_sessions'] as int?) ?? 0,
      totalFee: (map['total_fee'] as num).toDouble(),
      paidAmount: (map['paid_amount'] as num?)?.toDouble() ?? 0.0,
      status: (map['status'] as String?) ?? 'Active',
      joinDate: map['join_date'] as String,
      planName: map['plan_name'] as String?,
    );
  }

  TraineeModel copyWith({
    int? id,
    String? name,
    String? phone,
    int? age,
    String? groupName,
    int? planId,
    int? totalSessions,
    int? attendedSessions,
    double? totalFee,
    double? paidAmount,
    String? status,
    String? joinDate,
    String? planName,
  }) {
    return TraineeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      groupName: groupName ?? this.groupName,
      planId: planId ?? this.planId,
      totalSessions: totalSessions ?? this.totalSessions,
      attendedSessions: attendedSessions ?? this.attendedSessions,
      totalFee: totalFee ?? this.totalFee,
      paidAmount: paidAmount ?? this.paidAmount,
      status: status ?? this.status,
      joinDate: joinDate ?? this.joinDate,
      planName: planName ?? this.planName,
    );
  }
}
