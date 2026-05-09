import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projeto/domain/entities/app_user.dart';

class OnboardingState {
  final String name;
  final String email;
  final String password;
  final DateTime? dateOfBirth;
  final Gender gender;
  final double weight;
  final int height;
  final Objective? objective;
  final NutritionGoals? nutritionGoals;

  const OnboardingState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.dateOfBirth,
    this.gender = Gender.other,
    this.weight = 70,
    this.height = 170,
    this.objective = Objective.maintainWeight,
    this.nutritionGoals,
  });

  OnboardingState copyWith({
    String? name,
    String? email,
    String? password,
    DateTime? dateOfBirth,
    Gender? gender,
    double? weight,
    int? height,
    Objective? objective,
    NutritionGoals? calculatedGoals,
  }) {
    return OnboardingState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      objective: objective ?? this.objective,
      nutritionGoals: calculatedGoals ?? this.nutritionGoals,
    );
  }

  int get age {
    if (dateOfBirth == null) return 25;
    final now = DateTime.now();
    int a = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      a--;
    }
    return a;
  }
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void setCredentials({required String email, required String password}) {
    state = state.copyWith(email: email, password: password);
  }

  void setPersonalData({
    required String name,
    required DateTime dateOfBirth,
    required Gender gender,
    required double weight,
    required int height,
  }) {
    state = state.copyWith(
      name: name,
      dateOfBirth: dateOfBirth,
      gender: gender,
      weight: weight,
      height: height,
    );
  }

  void setObjective(Objective? objective) {
    state = state.copyWith(objective: objective);
  }

  void calculateAndSetGoals() {
    final age = state.age;
    // Mifflin-St Jeor BMR
    final bmr = 10 * state.weight + 6.25 * state.height - 5 * age +
        (state.gender == Gender.male ? 5 : -161);

    final tdee = bmr * 1.55; // moderate activity

    final calories = switch (state.objective) {
      Objective.loseWeight => tdee - 500,
      Objective.gainWeight => tdee + 300,
      _                    => tdee,
    };

    final goals = NutritionGoals(
      calories: calories,
      protein: state.weight * 1.8,
      carbs: (calories * 0.45) / 4,
      fat: (calories * 0.25) / 9,
      water: 35 * state.weight,
    );

    state = state.copyWith(calculatedGoals: goals);
  }

  void setGoals({
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required double water,
  }) {
    state = state.copyWith(
      calculatedGoals: NutritionGoals(
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        water: water,
      ),
    );
  }

}

final onboardingProvider = NotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);
