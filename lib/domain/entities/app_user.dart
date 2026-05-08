enum Gender { male, female, other }

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
  final DateTime dateOfBirth;
  final Gender gender;
  final int height;
  final double weight;
  final String email;
  final DateTime createdAt;
  final NutritionGoals? goals;

  const AppUser({
    required this.uid,
    required this.displayName,
    required this.dateOfBirth,
    required this.gender,
    required this.height,
    required this.weight,
    required this.email,
    required this.createdAt,
    required this.goals,
  });
}
