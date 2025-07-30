class HealthRecord {
  final int healthRecordId;
  final String value;
  final int logId;
  final String logDate;
  final int metricId;
  final String metricName;
  final String unit;

  HealthRecord({
    required this.healthRecordId,
    required this.value,
    required this.logId,
    required this.logDate,
    required this.metricId,
    required this.metricName,
    required this.unit,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      healthRecordId: json['healthRecordId'],
      value: json['value'],
      logId: json['logId'],
      logDate: json['logDate'],
      metricId: json['metricId'],
      metricName: json['metricName'],
      unit: json['unit'],
    );
  }
}
