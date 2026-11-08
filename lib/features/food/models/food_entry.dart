class FoodEntry {
  const FoodEntry({
    required this.id,
    required this.name,
    required this.caloriesKcal,
    required this.carbsGrams,
    required this.proteinGrams,
    required this.fatGrams,
    required this.sugarTotalGrams,
    required this.fiberGrams,
    required this.sodiumMg,
    required this.loggedAt,
  });

  final String id;
  final String name;
  final int caloriesKcal;
  final double? carbsGrams;
  final double? proteinGrams;
  final double? fatGrams;
  final double? sugarTotalGrams;
  final double? fiberGrams;
  final double? sodiumMg;
  final DateTime loggedAt;
}
