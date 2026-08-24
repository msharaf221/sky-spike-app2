/// Attendance Record Model
class AttendanceModel {
  final int? id;
  final int traineeId;
  final String date; // YYYY-MM-DD
  final String status; // 'Present', 'Absent', 'Excused'
  final String? traineeName;
  final String? groupName;
  final String? traineePhone;

  AttendanceModel({
    this.id,
    required this.traineeId,
    required this.date,
    required this.status,
    this.traineeName,
    this.groupName,
    this.traineePhone,
  });

  bool get isPresent => status == 'Present';
  bool get isAbsent => status == 'Absent';
  bool get isExcused => status == 'Excused';

  String get localizedStatus {
    switch (status) {
      case 'Present':
        return 'حاضر';
      case 'Absent':
        return 'غائب';
      case 'Excused':
        return 'معتذر';
      default:
        return status;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'trainee_id': traineeId,
      'date': date,
      'status': status,
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'] as int?,
      traineeId: map['trainee_id'] as int,
      date: map['date'] as String,
      status: map['status'] as String,
      traineeName: map['trainee_name'] as String?,
      groupName: map['group_name'] as String?,
      traineePhone: map['trainee_phone'] as String?,
    );
  }

  AttendanceModel copyWith({
    int? id,
    int? traineeId,
    String? date,
    String? status,
    String? traineeName,
    String? groupName,
    String? traineePhone,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      traineeId: traineeId ?? this.traineeId,
      date: date ?? this.date,
      status: status ?? this.status,
      traineeName: traineeName ?? this.traineeName,
      groupName: groupName ?? this.groupName,
      traineePhone: traineePhone ?? this.traineePhone,
    );
  }
}
