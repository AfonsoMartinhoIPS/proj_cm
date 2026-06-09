// lib/domain/entities/app_user.dart

/// Género do utilizador.
///
/// Cada valor possui um rótulo em português acessível através da propriedade [label].
enum Gender {
  /// Género masculino.
  male,

  /// Género feminino.
  female,

  /// Outro género ou não especificado.
  other;

  /// Devolve o rótulo em português correspondente a este género.
  String get label => switch (this) {
        Gender.male => 'Masculino',
        Gender.female => 'Feminino',
        Gender.other => 'Outro',
      };
}

/// Objetivo de peso do utilizador.
///
/// Cada valor tem um [label] em português que descreve o objetivo.
enum Objective {
  /// Perder peso.
  loseWeight(label: 'Perder peso'),

  /// Manter o peso atual.
  maintainWeight(label: 'Manter peso'),

  /// Ganhar peso.
  gainWeight(label: 'Ganhar peso');

  /// Rótulo em português do objetivo.
  final String label;

  /// Cria um [Objective] com o [label] especificado.
  const Objective({required this.label});
}

/// Metas nutricionais diárias.
///
/// Define os valores-alvo para calorias, macronutrientes e ingestão de água.
class NutritionGoals {
  /// Meta calórica diária (kcal).
  final double calories;

  /// Meta diária de proteínas (g).
  final double protein;

  /// Meta diária de hidratos de carbono (g).
  final double carbs;

  /// Meta diária de lípidos (g).
  final double fat;

  /// Meta diária de ingestão de água (ml).
  final double water;

  /// Cria um [NutritionGoals] com as metas especificadas.
  ///
  /// Todos os parâmetros são obrigatórios.
  const NutritionGoals({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.water,
  });
}

/// Representa o utilizador autenticado da aplicação.
///
/// Contém os dados pessoais, credenciais, metas nutricionais e o objetivo
/// de peso definido durante o onboarding. É gerido pelo [AuthNotifier].
class AppUser {
  /// Identificador único do utilizador (proveniente do Firebase Auth).
  final String uid;

  /// Nome público do utilizador.
  final String displayName;

  /// Data de nascimento.
  final DateTime dateOfBirth;

  /// Género do utilizador.
  final Gender gender;

  /// Altura em centímetros.
  final int height;

  /// Peso atual em quilogramas.
  final double weight;

  /// Endereço de email associado à conta.
  final String email;

  /// Data e hora de criação da conta.
  final DateTime createdAt;

  /// Metas nutricionais diárias do utilizador.
  ///
  /// Pode ser `null` se ainda não tiverem sido definidas.
  final NutritionGoals? nutritionGoals;

  /// Objetivo principal de peso.
  ///
  /// Pode ser `null` se ainda não tiver sido escolhido.
  final Objective? objective;

  /// Cria um [AppUser] com os dados fornecidos.
  ///
  /// Todos os parâmetros são obrigatórios, exceto [nutritionGoals] e
  /// [objective] que podem ser `null`.
  const AppUser({
    required this.uid,
    required this.displayName,
    required this.dateOfBirth,
    required this.gender,
    required this.height,
    required this.weight,
    required this.email,
    required this.createdAt,
    required this.nutritionGoals,
    required this.objective,
  });

  /// Cria uma cópia deste utilizador, substituindo apenas os campos fornecidos.
  ///
  /// Útil para atualizar o estado de forma imutável quando o utilizador
  /// altera as suas definições ou metas.
  AppUser copyWith({
    String? displayName,
    DateTime? dateOfBirth,
    Gender? gender,
    int? height,
    double? weight,
    NutritionGoals? nutritionGoals,
    Objective? objective,
  }) {
    return AppUser(
      uid: uid,
      email: email,
      createdAt: createdAt,
      displayName: displayName ?? this.displayName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      nutritionGoals: nutritionGoals ?? this.nutritionGoals,
      objective: objective ?? this.objective,
    );
  }
}