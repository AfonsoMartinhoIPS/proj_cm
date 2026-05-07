class NutritionGoals {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double water;

  const NutritionGoals({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.water,
  });
}

class AppUser {
  final String uid;
  final String displayName;
  final String email;
  final DateTime createdAt;
  final NutritionGoals? goals;

  const AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.createdAt,
    required this.goals,
  });
}
