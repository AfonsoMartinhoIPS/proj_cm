# NutriScan — Plano Completo

## Datas

| Marco | Data |
|---|---|
| Entrega Intermédia (20%) | 4 maio 2025 |
| Entrega Final (30%) | 9 junho 2025 |

Penalizações: -0.5 (1º dia) / -1.5 acumulado (2º dia) / não aceite (3º+ dias)

---

## 1. Ideia e Contexto

**App:** NutriScan — rastreio nutricional + comparação de preços em supermercado  
**Público-alvo:** Pessoas que querem comer melhor e gastar menos  
**Problema:** As apps de nutrição não têm preços. As apps de compras não têm nutrição. Esta tem as duas.

**Valor original:**
- Scanner de código de barras → ficha nutricional imediata
- Dupla fonte nutricional: OpenFoodFacts (embalados) + USDA (genéricos)
- Registo de preços por loja + cálculo automático de preço/kg
- Histórico dia / semana / mês com gráficos
- Registo de água integrado

---

## 2. Stack Técnica

| Componente | Tecnologia |
|---|---|
| Framework | Flutter (Dart) |
| Estado | Riverpod |
| Autenticação | Firebase Auth |
| Base de dados | Cloud Firestore |
| API produtos embalados | OpenFoodFacts |
| API alimentos genéricos | USDA FoodData Central |
| Scanner | `mobile_scanner` |
| HTTP | `dio` |
| Notificações | `flutter_local_notifications` |
| Navegação | `go_router` |
| Gráficos | `fl_chart` |
| Arquitetura | Clean Architecture |

---

## 3. Estrutura de Pastas

```
lib/
  core/
    constants/          # cores, strings, tamanhos
    errors/             # classes de exceção
    utils/              # formatadores, calculadores
  data/
    datasources/
      remote/
        openfoodfacts_datasource.dart
        usda_datasource.dart
      local/
        firestore_datasource.dart
    models/             # DTOs com fromJson/toJson
      product_model.dart
      nutrition_log_model.dart
      shopping_price_model.dart
      user_model.dart
    repositories/       # implementações
  domain/
    entities/           # objetos puros, sem Firebase/JSON
      product.dart
      nutrition_log.dart
      shopping_price.dart
      user.dart
      daily_summary.dart
    repositories/       # interfaces abstratas
    usecases/
      auth/
      products/
      nutrition/
      shopping/
  presentation/
    screens/
      splash/
      auth/
      meals/
      products/
      history/
      profile/
    providers/          # Riverpod providers
    widgets/
      common/
      nutrition/
      products/
      history/
  main.dart
  firebase_options.dart
```

---

## 4. Navegação

```
SplashScreen
  ├─ (sem sessão) ──→ LoginScreen ←──→ RegisterScreen
  └─ (sessão ativa) → MainShell

MainShell [BottomNavBar: Refeições | Produtos | Histórico | Perfil]
  │
  ├─ RefeicoeScreen
  │   └─ AddFoodBottomSheet
  │       ├─ → Scanner (tab Produtos, modo seleção)
  │       └─ → SavedProducts (modo seleção)
  │
  ├─ ProdutosScreen [tabs: Scanner | Pesquisa | Guardados]
  │   ├─ ScannerScreen ──→ ProductDetailScreen
  │   ├─ SearchScreen ──→ ProductDetailScreen
  │   └─ SavedProductsScreen ──→ ProductDetailScreen
  │                                   └─ RegisterPriceScreen
  │                                   └─ PriceListScreen
  │
  ├─ HistoricoScreen [tabs: Dia | Semana | Mês]
  │   ├─ DayView (navegar ← →)
  │   ├─ WeekView (gráfico barras)
  │   └─ MonthView (calendário) ──→ DayView
  │
  └─ PerfilScreen
      ├─ EditGoalsScreen
      ├─ NotificationsSettingsScreen
      ├─ CreditsScreen
      └─ Logout ──→ LoginScreen
```

---

## 5. Mockups (Wireframes)

### SplashScreen
```
┌─────────────────────┐
│                     │
│                     │
│       [LOGO]        │
│      NutriScan      │
│                     │
│   ████████████      │  ← loading indicator
│                     │
└─────────────────────┘
```

### LoginScreen
```
┌─────────────────────┐
│  ← (se vier de reg) │
│                     │
│       NutriScan     │
│   Bem-vindo de volta│
│                     │
│  ┌───────────────┐  │
│  │ Email         │  │
│  └───────────────┘  │
│  ┌───────────────┐  │
│  │ Palavra-passe │  │
│  └───────────────┘  │
│                     │
│  [  ENTRAR  ]       │
│                     │
│  Não tens conta?    │
│  Cria uma aqui →    │
└─────────────────────┘
```

### RegisterScreen
```
┌─────────────────────┐
│  ← Voltar           │
│                     │
│     Criar conta     │
│                     │
│  ┌───────────────┐  │
│  │ Nome          │  │
│  └───────────────┘  │
│  ┌───────────────┐  │
│  │ Email         │  │
│  └───────────────┘  │
│  ┌───────────────┐  │
│  │ Palavra-passe │  │
│  └───────────────┘  │
│  ┌───────────────┐  │
│  │ Confirmar pw  │  │
│  └───────────────┘  │
│                     │
│  [  REGISTAR  ]     │
└─────────────────────┘
```

### RefeicoeScreen (tab principal)
```
┌─────────────────────┐
│  Refeições  Hoje ▾  │
│─────────────────────│
│  Calorias           │
│  ████████░░░ 1200/2000 kcal
│  Proteína ██████░░ 60/90g
│  Hidratos █████░░░ 150/250g
│  Gordura  ████░░░░ 40/70g  │
│─────────────────────│
│  🌅 Pequeno-almoço  │
│  • Aveia 80g — 290kcal     │
│  • Banana 120g — 107kcal   │
│  [+ Adicionar]      │
│─────────────────────│
│  ☀️ Almoço          │
│  (vazio)            │
│  [+ Adicionar]      │
│─────────────────────│
│  🌙 Jantar          │
│  (vazio)            │
│  [+ Adicionar]      │
│─────────────────────│
│  🍎 Snack           │
│  (vazio)            │
│  [+ Adicionar]      │
│─────────────────────│
│  💧 Água            │
│  ██████░░░ 1200/2000ml     │
│  [200ml] [330ml] [500ml]   │
│  [+ Personalizado]  │
│─────────────────────│
│ 🍽️  📦  📅  👤    │  ← BottomNav
└─────────────────────┘
```

### ProdutosScreen (tab com sub-tabs)
```
┌─────────────────────┐
│  Produtos           │
│  [Scanner][Pesquisa][Guardados]
│─────────────────────│
│   (conteúdo varia   │
│    por sub-tab)     │
│─────────────────────│
│ 🍽️  📦  📅  👤    │
└─────────────────────┘
```

#### Sub-tab: Scanner
```
┌─────────────────────┐
│  Scanner            │
│─────────────────────│
│  ┌───────────────┐  │
│  │               │  │
│  │   [CÂMARA]    │  │
│  │    ┌─────┐    │  │
│  │    │     │    │  │  ← viewfinder
│  │    └─────┘    │  │
│  │               │  │
│  └───────────────┘  │
│                     │
│  Aponta para o      │
│  código de barras   │
└─────────────────────┘
```

#### Sub-tab: Pesquisa
```
┌─────────────────────┐
│  ┌─────────────────┐│
│  │ 🔍 Pesquisar... ││
│  └─────────────────┘│
│─────────────────────│
│  [Produto A]  420kcal/100g   │
│  Marca X · OpenFoodFacts     │
│─────────────────────│
│  [Frango grelhado]  165kcal  │
│  Alimento · USDA    │
│─────────────────────│
│  ...                │
└─────────────────────┘
```

#### Sub-tab: Guardados
```
┌─────────────────────┐
│  ┌─────────────────┐│
│  │ 🔍 Filtrar...   ││
│  └─────────────────┘│
│─────────────────────│
│  [img] Produto A    │
│        Marca X · 420kcal/100g│
│        ● OpenFoodFacts       │
│─────────────────────│
│  [img] Frango Grelhado       │
│        — · 165kcal/100g      │
│        ● USDA       │
│─────────────────────│
│  ← swipe p/ apagar  │
└─────────────────────┘
```

### ProductDetailScreen
```
┌─────────────────────┐
│  ← Produto          │
│─────────────────────│
│  [IMAGEM PRODUTO]   │
│                     │
│  Nome Produto       │
│  Marca · 500g       │
│  ● OpenFoodFacts    │
│─────────────────────│
│  Tabela Nutricional │
│  (por 100g)         │
│                     │
│  Calorias    420kcal│
│  Proteína    12g    │
│  Hidratos    55g    │
│   └ Açúcares 20g   │
│  Gordura     15g    │
│   └ Saturada  5g   │
│  Fibra        3g    │
│  Sal          1g    │
│─────────────────────│
│  Ingredientes:      │
│  Farinha, açúcar... │
│─────────────────────│
│  [Adicionar a ref.] │
│  [Registar preço]   │
│  [Ver preços]       │
└─────────────────────┘
```

### RegisterPriceScreen
```
┌─────────────────────┐
│  ← Registar Preço   │
│                     │
│  Produto A          │
│─────────────────────│
│  ┌───────────────┐  │
│  │ Nome da loja  │  │
│  └───────────────┘  │
│  ┌───────────────┐  │
│  │ Preço (€)     │  │
│  └───────────────┘  │
│  ┌───────────────┐  │
│  │ Quantidade(g) │  │
│  └───────────────┘  │
│                     │
│  Preço/kg: €2.10    │  ← calculado live
│                     │
│  [  GUARDAR  ]      │
└─────────────────────┘
```

### PriceListScreen
```
┌─────────────────────┐
│  ← Comparar Preços  │
│  Produto A          │
│  [Por loja][Por preço/kg]    │
│─────────────────────│
│  ★ Lidl             │  ← mais barato
│  €1.59 · 500g       │
│  €3.18/kg           │
│─────────────────────│
│  Continente         │
│  €1.89 · 500g       │
│  €3.78/kg           │
│─────────────────────│
│  Pingo Doce         │
│  €2.10 · 400g       │
│  €5.25/kg           │
└─────────────────────┘
```

### HistoricoScreen
```
┌─────────────────────┐
│  Histórico          │
│  [Dia][Semana][Mês] │
│─────────────────────│

--- Dia ---
│  ← 15 Abr 2025 →   │
│                     │
│  Calorias: 1850kcal │
│  ████████████░░     │
│  Proteína: 80g      │
│  Hidratos: 220g     │
│  Gordura: 60g       │
│  Água: 1800ml       │
│─────────────────────│
│  🌅 Pequeno-almoço  │
│  Aveia · 80g        │
│  Banana · 120g      │
│─────────────────────│
│  ☀️ Almoço          │
│  ...                │

--- Semana ---
│  Semana 14 Abr      │
│                     │
│  kcal               │
│  2500|              │
│  2000|  ██  ██  ██  │
│  1500| ███ ███ ███  │
│  1000| ...          │
│       S T Q Q S S D │
│─────────────────────│
│  Médias semana:     │
│  1820 kcal/dia      │
│  72g proteína/dia   │

--- Mês ---
│  Abril 2025  ← →    │
│  S  T  Q  Q  S  S  D│
│  1  2  3  4  5  6  7│ ← ✅🔴✅✅⬜✅🔴
│  8  9 10 11 12 13 14│
│  ...                │
│                     │
│  🟢 = objetivo      │
│  🔴 = abaixo        │
│  ⬜ = sem registo   │

└─────────────────────┘
│ 🍽️  📦  📅  👤    │
└─────────────────────┘
```

### PerfilScreen
```
┌─────────────────────┐
│  Perfil             │
│─────────────────────│
│  👤                 │
│  Samuel Silva       │
│  samuel@email.com   │
│─────────────────────│
│  Objetivos Diários  │
│  Calorias: 2000kcal │
│  Proteína: 90g      │
│  Hidratos: 250g     │
│  Gordura: 70g       │
│  Água: 2000ml       │
│  [Editar]           │
│─────────────────────│
│  Notificações       │
│  [Configurar]       │
│─────────────────────│
│  Créditos           │
│─────────────────────│
│  [  TERMINAR SESSÃO  ]      │
└─────────────────────┘
```

---

## 6. Modelos de Base de Dados (Firestore)

### Coleção: `users/{uid}`
```
{
  name:        String,
  email:       String,
  createdAt:   Timestamp,
  goals: {
    calories:  int,      // kcal
    protein:   int,      // g
    carbs:     int,      // g
    fat:       int,      // g
    water:     int       // ml
  },
  notifications: {
    enabled:       bool,
    reminderHour:  int,   // 0-23
    reminderMinute: int   // 0-59
  }
}
```

### Coleção: `users/{uid}/products/{productId}`
```
{
  productId:   String,  // barcode | "usda_{id}" | "manual_{uuid}"
  name:        String,
  brand:       String?,
  imageUrl:    String?,
  packQuantity: double, // g ou ml da embalagem
  packUnit:    String,  // "g" | "ml"
  ingredients: String?,
  nutrients: {
    calories:     double,  // por 100g
    protein:      double,
    carbs:        double,
    sugars:       double?,
    fat:          double,
    saturatedFat: double?,
    fiber:        double?,
    salt:         double?
  },
  source:      String,  // "openfoodfacts" | "usda" | "manual"
  savedAt:     Timestamp
}
```

### Coleção: `users/{uid}/nutrition_logs/{logId}`
```
{
  date:        String,    // "YYYY-MM-DD"
  mealType:    String,    // "breakfast"|"lunch"|"dinner"|"snack"|"water"
  productId:   String?,   // null se água
  productName: String,
  quantity:    double,    // g ou ml consumidos
  nutrients: {            // calculado: nutriente_100g / 100 * quantity
    calories:  double,
    protein:   double,
    carbs:     double,
    fat:       double
  },
  isWater:     bool,
  loggedAt:    Timestamp
}
```

### Coleção: `users/{uid}/shopping_prices/{priceId}`
```
{
  productId:   String,
  productName: String,
  storeName:   String,
  price:       double,    // € total da embalagem
  quantity:    double,    // g ou ml da embalagem
  unit:        String,    // "g" | "ml"
  pricePerKg:  double,    // calculado: price / (quantity / 1000)
  recordedAt:  Timestamp
}
```

---

## 7. Estratégia de Dados

### APIs Externas

#### OpenFoodFacts
```
# Produto por barcode
GET https://world.openfoodfacts.org/api/v2/product/{barcode}.json

# Pesquisa por nome
GET https://world.openfoodfacts.org/cgi/search.pl
    ?search_terms={query}
    &json=1
    &page_size=20
    &fields=code,product_name,brands,image_url,nutriments,quantity

# Campos nutricionais relevantes (em nutriments):
  energy-kcal_100g, proteins_100g, carbohydrates_100g,
  sugars_100g, fat_100g, saturated-fat_100g, fiber_100g, salt_100g
```

#### USDA FoodData Central
```
# Pesquisa por nome
GET https://api.nal.usda.gov/fdc/v1/foods/search
    ?query={query}
    &api_key={USDA_API_KEY}
    &pageSize=20
    &dataType=SR Legacy,Foundation

# Campos relevantes:
  fdcId, description, foodNutrients[].nutrientId, foodNutrients[].value
  Nutrient IDs: 208=kcal, 203=protein, 205=carbs, 204=fat
```

### Estratégia de pesquisa (fallback)
```
1. Pesquisar OpenFoodFacts
2. Se resultados < 3 → pesquisar também USDA
3. Juntar resultados no mesmo modelo Product
4. Mostrar fonte: badge "OpenFoodFacts" ou "USDA"
```

### Repositórios (Clean Architecture)

```
ProductRepository
  ├─ searchByBarcode(barcode) → Product
  │   └─ OpenFoodFactsDatasource.getByBarcode()
  ├─ searchByName(query) → List<Product>
  │   ├─ OpenFoodFactsDatasource.search()
  │   └─ UsdaDatasource.search() (fallback / complemento)
  ├─ getSavedProducts() → Stream<List<Product>>
  │   └─ FirestoreDatasource.watchProducts()
  ├─ saveProduct(product) → void
  │   └─ FirestoreDatasource.saveProduct()
  └─ deleteProduct(productId) → void

NutritionRepository
  ├─ getDailyLog(date) → Stream<DailySummary>
  ├─ addEntry(entry) → void
  ├─ removeEntry(logId) → void
  ├─ getWeeklySummary(weekStart) → List<DailySummary>
  └─ getMonthlySummary(month, year) → Map<String, DailySummary>

ShoppingRepository
  ├─ registerPrice(price) → void
  ├─ getPricesForProduct(productId) → Stream<List<ShoppingPrice>>
  └─ getAllPrices() → Stream<List<ShoppingPrice>>

AuthRepository
  ├─ signIn(email, password) → User
  ├─ signUp(name, email, password) → User
  ├─ signOut() → void
  ├─ getCurrentUser() → User?
  ├─ saveGoals(goals) → void
  └─ getGoals() → Stream<Goals>
```

---

## 8. TODO — Fase 1 (até 4 maio)

### 8.1 Definição e Planeamento
- [x] Definir ideia da app (NutriScan)
- [x] Definir funcionalidades (ver FUNCIONALIDADES.md)
- [] Escolher stack técnica
- [] Definir navegação e ecrãs
- [] Definir mockups
- [] Definir schema Firestore
- [] Definir estratégia de fetching

### 8.2 Setup do Projeto
- [ ] Criar projeto Flutter (`flutter create nutriscan`)
- [ ] Configurar Firebase (Auth + Firestore)
- [ ] Adicionar dependências ao `pubspec.yaml`:
  - [ ] `firebase_core`, `firebase_auth`, `cloud_firestore`
  - [ ] `flutter_riverpod`, `riverpod_annotation`
  - [ ] `dio`
  - [ ] `go_router`
  - [ ] `mobile_scanner`
  - [ ] `flutter_local_notifications`
  - [ ] `fl_chart`
  - [ ] `cached_network_image`
  - [ ] `intl`
  - [ ] `equatable`
- [ ] Criar estrutura de pastas (core / data / domain / presentation)
- [ ] Configurar `go_router` com rotas base
- [ ] Configurar tema global (cores, fontes, espaçamentos)

### 8.3 Autenticação (UI + lógica)
- [ ] SplashScreen com verificação de sessão
- [ ] LoginScreen (form + validação)
- [ ] RegisterScreen (form + validação)
- [ ] AuthRepository (signIn, signUp, signOut, currentUser)
- [ ] AuthProvider (Riverpod)
- [ ] Redirecionar automaticamente conforme estado de sessão

### 8.4 Navegação e Shell
- [ ] MainShell com BottomNavigationBar (4 tabs)
- [ ] Preservação de estado entre tabs (`IndexedStack`)
- [ ] Rotas protegidas (redirecionar para login se sem sessão)

### 8.5 Perfil (básico)
- [ ] PerfilScreen com nome e email
- [ ] EditGoalsScreen (form + guardar no Firestore)
- [ ] CreditsScreen

### 8.6 UI Inicial (esqueletos dos ecrãs)
- [ ] RefeicoeScreen (estrutura, sem lógica)
- [ ] ProdutosScreen com 3 sub-tabs (estrutura)
- [ ] HistoricoScreen com 3 sub-tabs (estrutura)
- [ ] Widgets comuns: LoadingWidget, ErrorWidget, EmptyStateWidget

---

## 9. TODO — Fase 2 (após 4 maio → 9 junho)

### 9.1 Produtos — Scanner
- [ ] ScannerScreen com feed da câmara (`mobile_scanner`)
- [ ] Pedir permissão de câmara + tratar negação
- [ ] Após scan → fetch OpenFoodFacts por barcode
- [ ] ProductDetailScreen com tabela nutricional
- [ ] Guardar produto automaticamente no Firestore
- [ ] Tratar: produto não encontrado, campos em falta, sem rede

### 9.2 Produtos — Pesquisa
- [ ] SearchScreen com campo de pesquisa
- [ ] Debounce (esperar 500ms após última tecla)
- [ ] Fetch OpenFoodFacts search
- [ ] Fallback USDA se poucos resultados
- [ ] Unificar resultados em modelo `Product`
- [ ] Guardar produto ao selecionar

### 9.3 Produtos — Lista Guardados
- [ ] SavedProductsScreen com Stream do Firestore
- [ ] Filtro local por nome
- [ ] Swipe para remover produto
- [ ] Badge de fonte (OpenFoodFacts / USDA / Manual)

### 9.4 Preços
- [ ] RegisterPriceScreen (form + cálculo preço/kg live)
- [ ] Guardar no Firestore
- [ ] PriceListScreen agrupado e ordenado
- [ ] Destacar entrada mais barata por kg

### 9.5 Refeições
- [ ] RefeicoeScreen com refeições do dia (Stream)
- [ ] AddFoodBottomSheet (escolher produto da lista / abrir scanner)
- [ ] Campo de quantidade + cálculo nutricional da porção
- [ ] Guardar entrada no Firestore
- [ ] Remover entrada (swipe ou botão)
- [ ] Barras de progresso: calorias, proteína, hidratos, gordura
- [ ] Secção de água: botões rápidos + campo manual
- [ ] Barra de progresso da água

### 9.6 Histórico
- [ ] HistoricoScreen — vista Dia com navegação ← →
- [ ] Vista Semana: gráfico de barras (`fl_chart`)
- [ ] Vista Mês: calendário com indicadores visuais
- [ ] Impedir navegação para datas futuras
- [ ] Tratar períodos sem dados

### 9.7 Notificações
- [ ] Pedir permissão no primeiro arranque
- [ ] NotificationsSettingsScreen (ativar/desativar + hora)
- [ ] Lembrete diário: só envia se sem registos no dia
- [ ] Notificação ao atingir objetivo calórico
- [ ] Guardar preferências no Firestore

---

## 10. TODO — Fase 3 (refinamento, antes de 9 junho)

### 10.1 Qualidade e Estabilidade
- [ ] Testar fluxo completo: registo → login → scan → refeição → histórico
- [ ] Testar offline (Firestore cache ativo)
- [ ] Testar permissão câmara negada
- [ ] Testar permissão notificações negada
- [ ] Corrigir bugs encontrados
- [ ] Verificar sem dados (estados vazios em todos os ecrãs)

### 10.2 UI/UX
- [ ] Consistência visual (cores, espaçamentos, tipografia)
- [ ] Feedback em todas as ações (loading, sucesso, erro)
- [ ] Animações de transição suaves
- [ ] Responsividade (testar em ecrãs pequenos e grandes)
- [ ] `const` em todos os widgets possíveis

### 10.3 Performance
- [ ] Evitar rebuilds desnecessários (Riverpod selectors)
- [ ] `cached_network_image` para imagens de produtos
- [ ] Paginação na lista de produtos guardados (se > 50)
- [ ] Limpar listeners e subscriptions

### 10.4 Documentação e Entrega
- [ ] README completo (instalação, configuração, funcionalidades)
- [ ] Variáveis de ambiente documentadas (chaves API, Firebase)
- [ ] Histórico de commits limpo e organizado
- [ ] Remover código temporário / debug prints
- [ ] Verificar que não há chaves hardcoded

---

## 11. Checklist de Requisitos Obrigatórios

- [ ] Autenticação (Firebase Auth)
- [ ] Notificações (flutter_local_notifications)
- [ ] API externa (OpenFoodFacts + USDA)
- [ ] Base de dados remota (Firestore)
- [ ] Clean Architecture (data / domain / presentation)
- [ ] Gestão de estado (Riverpod)
- [ ] Sem lógica de negócio na UI
- [ ] Tratamento de erros em todos os fluxos
- [ ] README com instruções de instalação
