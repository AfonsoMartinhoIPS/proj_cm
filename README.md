# NutriScan

Aplicação móvel em Flutter que permite ao utilizador analisar a informação
nutricional de produtos alimentares através da leitura de códigos de barras,
registar refeições diárias e acompanhar o progresso face a objetivos
nutricionais personalizados.

Projeto desenvolvido no âmbito da unidade curricular de **Computação Móvel
(2025/2026)** — IPS, ESTSetúbal.

> Repositório: https://github.com/AfonsoMartinhoIPS/proj_cm
> Ficheiros extra: ver pasta partilhada da equipa

---

## Equipa

- 2310SamuelSilva — `202200315@estudantes.ips.pt`
- AfonsoMartinhoIPS — `202002203@estudantes.ips.pt`
- Fjmr18 — `202002203@estudantes.ips.pt`
- dannhypais

---

## Funcionalidades

- **Autenticação** — Firebase Auth (email/password), com sessão persistida
  entre arranques e fluxo de logout com confirmação.
- **Onboarding** — recolha de dados pessoais (nome, data de nascimento,
  género, peso, altura), objetivo (perder/manter/ganhar peso) e cálculo
  automático de metas diárias via fórmula de Mifflin-St Jeor.
- **Scanner de códigos de barras** — câmara ao vivo (EAN/UPC/QR) com
  recuperação de erros (permissões, câmara indisponível), entrada manual
  como alternativa, e pausa automática quando o ecrã fica em segundo plano
  para poupar bateria.
- **Integração com OpenFoodFacts** — consulta de produtos por código de
  barras com cache no Firestore (15 dias).
- **Registo de refeições** — adicionar/editar/eliminar refeições por dia,
  agrupadas por tipo (Pequeno-almoço / Almoço / Jantar / Snack). Mover
  refeições entre dias.
- **Histórico** — visualização semanal/mensal/anual com estatísticas
  (média kcal/dia, dias registados, total de refeições).
- **Notificações locais diárias** — lembrete configurável (hora à escolha)
  com mensagem dinâmica baseada no progresso do dia: "Objetivo cumprido" ou
  "Faltam X kcal". Reagendado automaticamente a cada alteração de refeição.
- **Tema claro / escuro / sistema** — persistido via `SharedPreferences`.
- **Edição de objetivos** — atualização das metas nutricionais a qualquer
  momento, mantendo congelados os snapshots históricos.

---

## Arquitetura

Arquitetura **Clean Architecture** estrita, com três camadas e regra de
dependência unidirecional `presentation → domain → data`.

```
lib/
  main.dart                 ponto de entrada (Firebase init + notificações)
  firebase_options.dart     config gerada pelo FlutterFire CLI
  core/
    config/                 configuração da app (debug flags, etc.)
    constants/              cores, tamanhos, paths Firestore
    network/                cliente HTTP (Dio) + init do Firestore
    notifications/          NotificationService + NotificationCoordinator
    router/                 GoRouter + observers
    theme/                  ThemeData (claro/escuro)
    utils/                  helpers (datas, logger)
  data/
    datasources/            OpenFoodFacts datasource
    models/                 DTOs (json ↔ entidade)
    repositories/           implementações dos repositórios
  domain/
    entities/               objetos de negócio puros
    repositories/           interfaces abstratas
  presentation/
    providers/              Riverpod AsyncNotifier (auth, meals, theme, ...)
    screens/                ecrãs (auth, home, meals, scanner, profile, ...)
    widgets/                componentes reutilizáveis (NutriCard, NutriLabel, ...)
```

### Decisões técnicas

- **Riverpod** para gestão de estado — providers `AsyncNotifier` com
  `AsyncValue.when` para tratar loading/error/data de forma uniforme.
- **go_router** para navegação com `ShellRoute` (bottom nav) e
  redirecionamentos baseados no estado de autenticação.
- **Firestore** com a estrutura `users/{uid}` + `users/{uid}/saved_products`
  + `users/{uid}/nutrition_logs/{YYYY-MM-DD}` (logs com snapshot congelado
  dos objetivos do dia).
- **`flutter_local_notifications`** com timezone fixo Europe/Lisbon. As
  notificações são reagendadas a cada mutação de refeição para refletirem
  o estado atualizado ao disparar.
- **`mobile_scanner`** para a câmara de códigos de barras, com `RouteAware`
  + `WidgetsBindingObserver` a parar a câmara em segundo plano.

---

## Setup

### Pré-requisitos

- Flutter `^3.11.4`
- Dart `^3.x`
- Android Studio + Android SDK (API 34+) — para Android
- Xcode 15+ — para iOS
- Conta Firebase com projeto configurado

### Instalação

```bash
git clone https://github.com/AfonsoMartinhoIPS/proj_cm.git
cd proj_cm
flutter pub get
```

### Configuração Firebase

O ficheiro `lib/firebase_options.dart` já está incluído. Se quiseres usar
o teu próprio projeto Firebase:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Depois ativa em **Firebase Console → Authentication → Sign-in method**:
- **Email/Password** (obrigatório)

E em **Firestore → Rules** define a permissão básica:

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
    match /products/{barcode} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

### Executar

```bash
# Emulador / dispositivo Android
flutter run -d emulator-5554

# iOS Simulator (notificações não funcionam visualmente — usar dispositivo real)
flutter run -d "iPhone 15"

# Web (scanner + notificações limitados/indisponíveis)
flutter run -d chrome
```

### Geração de ícones e splash

```bash
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
```

---

## Testes

```bash
# Unit + widget
flutter test

# Análise estática
flutter analyze
```

Cobertura atual: entidades de domínio, providers principais (auth,
nutrition_log), ecrãs de produtos e scanner.

---

## Estrutura Firestore

```
users/{uid}
├── displayName, email, gender, dateOfBirth, height, weight, createdAt
├── objective (loseWeight | maintainWeight | gainWeight)
└── nutritionGoals { calories, protein, carbs, fat, water }

users/{uid}/saved_products/{barcode}
├── barcode, name, brand, imageUrl, caloriesPer100g, savedAt
└── notes[]

users/{uid}/nutrition_logs/{YYYY-MM-DD}
├── date, waterMl
├── entries[] { id, productBarcode, productName, mealType, servingGrams,
│              calories, protein, carbs, fat, loggedAt }
└── goals (snapshot congelado)

products/{barcode}      (cache partilhado de OpenFoodFacts)
├── barcode, name, brand, nutriments, imageUrl, allergenTags
├── nutriscore, novaGroup, source, fetchedAt
```

---

## Plataformas suportadas

| Plataforma | Estado | Notas |
|---|---|---|
| Android | ✅ Funcional | Plataforma principal de demonstração |
| iOS | ✅ Funcional | Notificações requerem dispositivo real (simulador não exibe) |
| Web | ⚠️ Parcial | Scanner com decode limitado, notificações indisponíveis |
| macOS / Linux / Windows | ⚠️ Não testado | Esqueleto presente, sem QA |

---

## Limitações conhecidas

- Notificações: zero suporte em web (`flutter_local_notifications` é no-op).
- iOS Simulator não mostra notificações visualmente (limitação Apple).
- Ícone das notificações Android usa o launcher icon (quadrado tintado);
  podes substituir por um PNG monocromático em
  `android/app/src/main/res/drawable/ic_notification.png`.
- Login com Google não foi implementado neste projeto; apenas
  email/password.

---

## Licença

Trabalho académico — IPS / ESTSetúbal, 2025/2026.
