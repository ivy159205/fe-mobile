class MetricType {
  final int id;
  final String name;

  MetricType({required this.id, required this.name});

  factory MetricType.fromJson(Map<String, dynamic> json) {
    return MetricType(
      id: json['id'],
      name: json['name'],
    );
  }
}
