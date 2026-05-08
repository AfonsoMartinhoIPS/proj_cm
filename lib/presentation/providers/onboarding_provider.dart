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
  final String goal; // 'lose', 'maintain', 'gain'
  final NutritionGoals? calculatedGoals;

  const OnboardingState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.dateOfBirth,
    this.gender = Gender.other,
    this.weight = 70,
    this.height = 170,
    this.goal = 'maintain',
    this.calculatedGoals,
  });

  OnboardingState copyWith({
    String? name,
    String? email,
    String? password,
    DateTime? dateOfBirth,
    Gender? gender,
    double? weight,
    int? height,
    String? goal,
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
      goal: goal ?? this.goal,
      calculatedGoals: calculatedGoals ?? this.calculatedGoals,
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

  void setObjective(String goal) {
    state = state.copyWith(goal: goal);
  }

  void calculateAndSetGoals() {
    final age = state.age;
    // Mifflin-St Jeor BMR
    final bmr = 10 * state.weight + 6.25 * state.height - 5 * age +
        (state.gender == Gender.male ? 5 : -161);

    final tdee = bmr * 1.55; // moderate activity

    final calories = switch (state.goal) {
      'lose' => tdee - 500,
      'gain' => tdee + 300,
      _      => tdee,
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
}

final onboardingProvider = NotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);
