class FoodEntry {
  const FoodEntry({
    required this.id,
    required this.name,
    required this.caloriesKcal,
    required this.carbsGrams,
    required this.proteinGrams,
    required this.fatGrams,
    required this.loggedAt,
  });

  final String id;
  final String name;
  final int caloriesKcal;
  final double? carbsGrams;
  final double? proteinGrams;
  final double? fatGrams;
  final DateTime loggedAt;
}
