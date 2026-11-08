class WaterLog {
  const WaterLog({
    required this.id,
    required this.volumeMl,
    required this.loggedAt,
  });

  final String id;
  final int volumeMl;
  final DateTime loggedAt;
}
