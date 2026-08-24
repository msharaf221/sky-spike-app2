/// Payment Entity Model
class PaymentModel {
  final int? id;
  final int traineeId;
  final double amount;
  final String date; // YYYY-MM-DD
  final String paymentMethod; // 'Cash', 'InstaPay', 'Vodafone Cash', 'Card'
  final String? notes;
  final String? traineeName;
  final String? groupName;

  PaymentModel({
    this.id,
    required this.traineeId,
    required this.amount,
    required this.date,
    required this.paymentMethod,
    this.notes,
    this.traineeName,
    this.groupName,
  });

  String get localizedMethod {
    switch (paymentMethod) {
      case 'Cash':
      case 'كاش':
        return 'نقدي (كاش)';
      case 'InstaPay':
      case 'إنستاباي':
        return 'إنستاباي (InstaPay)';
      case 'Vodafone Cash':
      case 'فودافون كاش':
        return 'فودافون كاش';
      case 'Card':
      case 'فيزا':
        return 'بطاقة بنكية / فيزا';
      default:
        return paymentMethod;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'trainee_id': traineeId,
      'amount': amount,
      'date': date,
      'payment_method': paymentMethod,
      'notes': notes,
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'] as int?,
      traineeId: map['trainee_id'] as int,
      amount: (map['amount'] as num).toDouble(),
      date: map['date'] as String,
      paymentMethod: map['payment_method'] as String,
      notes: map['notes'] as String?,
      traineeName: map['trainee_name'] as String?,
      groupName: map['group_name'] as String?,
    );
  }

  PaymentModel copyWith({
    int? id,
    int? traineeId,
    double? amount,
    String? date,
    String? paymentMethod,
    String? notes,
    String? traineeName,
    String? groupName,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      traineeId: traineeId ?? this.traineeId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      traineeName: traineeName ?? this.traineeName,
      groupName: groupName ?? this.groupName,
    );
  }
}
