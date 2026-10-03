import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/water_log.dart';

class WaterLogModel extends WaterLog {
  const WaterLogModel({
    required super.id,
    required super.amountMl,
    required super.date,
  });

  factory WaterLogModel.fromMap(Map<String, dynamic> map, String id) {
    final timestamp = map['date'];

    return WaterLogModel(
      id: id,
      amountMl: (map['amountMl'] as num?)?.toInt() ?? 0,
      date: timestamp is Timestamp
          ? timestamp.toDate()
          : timestamp is DateTime
          ? timestamp
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amountMl': amountMl,
      'date': Timestamp.fromDate(date),
    };
  }
}
