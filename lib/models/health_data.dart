class HealthData {
  final String? id;
  final String? metric;
  final dynamic value;
  final DateTime? timestamp;

  HealthData({
    this.id,
    this.metric,
    this.value,
    this.timestamp,
  });

  factory HealthData.fromMap(Map<String, dynamic> data) {
    return HealthData(
      id: data['id'],
      metric: data['metric'],
      value: data['value'],
      timestamp: data['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'metric': metric,
      'value': value,
      'timestamp': timestamp,
    };
  }
}
