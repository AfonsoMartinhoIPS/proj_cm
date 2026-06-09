// lib/presentation/providers/onboarding_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_scan/domain/entities/app_user.dart';

/// Estado imutável que agrega todos os dados recolhidos durante o fluxo de
/// onboarding.
///
/// Inclui informações pessoais, credenciais, objetivos de peso e as metas
/// nutricionais calculadas. É gerido pelo [OnboardingNotifier].
class OnboardingState {
  /// Nome completo do utilizador.
  final String name;

  /// Email utilizado para o registo.
  final String email;

  /// Palavra‑passe escolhida para a conta.
  final String password;

  /// Data de nascimento do utilizador.
  final DateTime? dateOfBirth;

  /// Género do utilizador.
  final Gender gender;

  /// Peso atual em quilogramas.
  final double weight;

  /// Altura em centímetros.
  final int height;

  /// Objetivo principal de peso (perder, manter ou ganhar).
  final Objective? objective;

  /// Metas nutricionais diárias calculadas (calorias, macronutrientes, água).
  final NutritionGoals? nutritionGoals;

  /// Indica se o utilizador veio do fluxo de Google Sign-In.
  /// Quando true, pula o passo de "Criar Conta" e salva diretamente.
  final bool isFromGoogle;

  /// Cria um [OnboardingState] com os valores fornecidos.
  ///
  /// Todos os parâmetros têm valores padrão (vazios ou nulos), permitindo
  /// que o estado seja construído incrementalmente ao longo do onboarding.
  const OnboardingState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.dateOfBirth,
    this.gender = Gender.other,
    this.weight = 0,
    this.height = 0,
    this.objective = Objective.maintainWeight,
    this.nutritionGoals,
    this.isFromGoogle = false,
  });

  /// Cria uma cópia deste estado substituindo apenas os campos fornecidos.
  ///
  /// Útil para atualizar o estado de forma imutável à medida que o
  /// utilizador avança nos passos do onboarding.
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
    bool? isFromGoogle,
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
      nutritionGoals: calculatedGoals ?? nutritionGoals,
      isFromGoogle: isFromGoogle ?? this.isFromGoogle,
    );
  }

  /// Calcula a idade do utilizador com base na [dateOfBirth].
  ///
  /// Se a data de nascimento não estiver definida, devolve 25 como valor
  /// padrão.
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

/// Notifier que orquestra o fluxo de onboarding.
///
/// Expõe um [OnboardingState] imutável e fornece métodos para cada passo do
/// processo: dados pessoais, credenciais, objetivo de peso e cálculo das
/// metas nutricionais.
class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  /// Define as credenciais de autenticação (email e palavra‑passe).
  void setCredentials({required String email, required String password}) {
    state = state.copyWith(email: email, password: password);
  }

  /// Define os dados pessoais do utilizador.
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

  /// Define o objetivo principal de peso.
  void setObjective(Objective? objective) {
    state = state.copyWith(objective: objective);
  }

  /// Define o flag [isFromGoogle] para indicar que o utilizador veio do Google Sign-In.
  void setFromGoogle(bool value) {
    state = state.copyWith(isFromGoogle: value);
  }

  /// Calcula as metas nutricionais com base nos dados atuais e atualiza o estado.
  ///
  /// Utiliza a fórmula de Mifflin‑St Jeor para estimar a taxa metabólica basal,
  /// aplica um fator de atividade moderada (1.55) e ajusta as calorias de
  /// acordo com o objetivo de peso. Os macronutrientes e a ingestão de água
  /// são derivados a partir das calorias e do peso corporal.
  void calculateAndSetGoals() {
    final age = state.age;
    final bmr = 10 * state.weight + 6.25 * state.height - 5 * age +
        (state.gender == Gender.male ? 5 : -161);

    final tdee = bmr * 1.55;

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

  /// Substitui manualmente as metas nutricionais.
  ///
  /// Útil quando o utilizador decide ajustar os valores sugeridos antes de
  /// finalizar o onboarding.
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

/// Provider que expõe o estado do onboarding e permite a sua manipulação.
///
/// Utilizado por todos os ecrãs do fluxo de onboarding para ler e escrever
/// os dados do utilizador antes do registo.
final onboardingProvider = NotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);