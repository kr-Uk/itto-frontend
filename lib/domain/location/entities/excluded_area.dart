class ExcludedArea {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final int radius;
  final List<String> h3Indexes;

  const ExcludedArea({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.h3Indexes = const [],
  });
}
