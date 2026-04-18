# NutriScan — Plano

## Datas

| Marco | Data |
|---|---|
| Entrega Intermédia (20%) | 4 maio 2025 |
| Entrega Final (30%) | 9 junho 2025 |

Penalizações: -0.5 (1º dia) / -1.5 acumulado (2º dia) / não aceite (3º+ dias)

---

## App

**NutriScan** — rastreio nutricional + comparação de preços em supermercado  
Público: pessoas que querem comer melhor e gastar menos  
Problema: apps de nutrição não têm preços, apps de compras não têm nutrição

---

## Documentação

| Ficheiro | Conteúdo |
|---|---|
| `FUNCIONALIDADES.md` | Descrição detalhada de cada funcionalidade |
| `NAVIGATION.md` | Mapa de navegação e fluxo entre ecrãs |
| `MOCKUPS.md` | Wireframes de cada ecrã |
| `DATABASE.md` | Schema Firestore + modelos de dados |
| `API.md` | APIs externas, endpoints e estratégia de fetching |
| `ARCHITECTURE.md` | Clean Architecture, estrutura de pastas, repositórios |

---

## TODO

### Fase 1 — Planeamento e Setup (até 4 maio)

#### Documentação
- [x] Definir ideia e funcionalidades (`FUNCIONALIDADES.md`)
- [ ] Definir navegação e ecrãs (`NAVIGATION.md`)
  - [ ] Mapa de todos os ecrãs e ligações entre eles
  - [ ] Fluxo de autenticação (splash → login/registo → main)
  - [ ] Fluxo de cada tab (Refeições, Produtos, Histórico, Perfil)
  - [ ] Ecrãs de detalhe e modais (bottom sheets, dialogs)
- [ ] Criar mockups dos ecrãs principais (`MOCKUPS.md`)
  - [ ] SplashScreen
  - [ ] LoginScreen / RegisterScreen
  - [ ] RefeicoeScreen (tab principal)
  - [ ] ProdutosScreen (scanner + pesquisa + guardados)
  - [ ] ProductDetailScreen
  - [ ] RegisterPriceScreen / PriceListScreen
  - [ ] HistoricoScreen (dia / semana / mês)
  - [ ] PerfilScreen + EditGoalsScreen
- [ ] Definir schema da base de dados (`DATABASE.md`)
  - [ ] Coleção `users/{uid}` (perfil + objetivos + notificações)
  - [ ] Subcoleção `products/{productId}` (produtos guardados)
  - [ ] Subcoleção `nutrition_logs/{logId}` (refeições + água)
  - [ ] Subcoleção `shopping_prices/{priceId}` (preços em loja)
  - [ ] Tipos de cada campo e valores possíveis
  - [ ] Regras de segurança Firestore (só o próprio utilizador lê/escreve)
- [ ] Definir APIs e estratégia de fetching (`API.md`)
  - [ ] OpenFoodFacts: endpoint por barcode + endpoint de pesquisa
  - [ ] USDA FoodData Central: endpoint de pesquisa + chave API
  - [ ] Estratégia de fallback (OFF → USDA se poucos resultados)
  - [ ] Campos a extrair de cada API e mapeamento para o modelo `Product`
  - [ ] Tratamento de erros de rede e campos em falta
- [ ] Definir arquitetura e estrutura de pastas (`ARCHITECTURE.md`)
  - [ ] Estrutura de pastas completa (`lib/`)
  - [ ] Camada `data`: datasources, models, repository impls
  - [ ] Camada `domain`: entities, repository interfaces, use cases
  - [ ] Camada `presentation`: screens, providers (Riverpod), widgets
  - [ ] Lista de dependências (`pubspec.yaml`) com versões

#### Setup do Projeto
- [ ] Criar projeto Flutter (`flutter create nutriscan`)
- [ ] Configurar Firebase
  - [ ] Criar projeto no Firebase Console
  - [ ] Ativar Firebase Auth (email + password)
  - [ ] Criar base de dados Firestore
  - [ ] Configurar `firebase_options.dart` (FlutterFire CLI)
  - [ ] Adicionar `google-services.json` (Android) e `GoogleService-Info.plist` (iOS)
- [ ] Adicionar dependências ao `pubspec.yaml`
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
- [ ] Criar estrutura de pastas (`core/`, `data/`, `domain/`, `presentation/`)
- [ ] Configurar tema global (cores, tipografia, espaçamentos)
- [ ] Configurar `go_router` com rotas e redirecionamento por estado de sessão

#### Implementação Inicial
- [ ] SplashScreen
  - [ ] Logo e nome da app
  - [ ] Verificar `FirebaseAuth.currentUser`
  - [ ] Redirecionar para Login ou MainShell
- [ ] LoginScreen
  - [ ] Campos: email + palavra-passe
  - [ ] Validação local (campos vazios, formato email)
  - [ ] `signInWithEmailAndPassword`
  - [ ] Tratar erros: credenciais erradas, sem rede
  - [ ] Link para RegisterScreen
- [ ] RegisterScreen
  - [ ] Campos: nome, email, palavra-passe, confirmação
  - [ ] Validação local (pw mínimo 6 chars, confirmação coincide)
  - [ ] `createUserWithEmailAndPassword`
  - [ ] Guardar perfil em Firestore (`users/{uid}`)
  - [ ] Tratar erros: email já usado, sem rede
- [ ] MainShell
  - [ ] BottomNavigationBar com 4 tabs (Refeições, Produtos, Histórico, Perfil)
  - [ ] `IndexedStack` para preservar estado entre tabs
- [ ] PerfilScreen
  - [ ] Exibir nome e email do utilizador autenticado
  - [ ] Formulário de objetivos (calorias, proteína, hidratos, gordura, água)
  - [ ] Guardar objetivos no Firestore
  - [ ] Botão de logout (`FirebaseAuth.signOut()`)
  - [ ] Link para CreditsScreen
- [ ] CreditsScreen
  - [ ] Nome e número de cada elemento do grupo
  - [ ] Unidade curricular, instituição, ano letivo
- [ ] Esqueletos dos ecrãs restantes (sem lógica, só estrutura visual)
  - [ ] RefeicoeScreen
  - [ ] ProdutosScreen (3 sub-tabs)
  - [ ] HistoricoScreen (3 sub-tabs)

---

### Fase 2 — Desenvolvimento (após 4 maio → 9 junho)

#### Produtos
- [ ] Scanner de código de barras → ficha nutricional
- [ ] Pesquisa por nome (OpenFoodFacts + USDA fallback)
- [ ] Lista de produtos guardados (Firestore)
- [ ] Detalhe de produto
- [ ] Registo de preços em loja + comparação

#### Refeições
- [ ] Registo de alimentos por refeição (PA, Almoço, Jantar, Snack)
- [ ] Cálculo nutricional por porção
- [ ] Barras de progresso face aos objetivos
- [ ] Registo de água

#### Histórico
- [ ] Vista de dia (navegação ← →)
- [ ] Vista de semana (gráfico de barras)
- [ ] Vista de mês (calendário com indicadores)

#### Notificações
- [ ] Pedir permissão no primeiro arranque
- [ ] Lembrete diário configurável
- [ ] Notificação ao atingir objetivo calórico

---

### Fase 3 — Refinamento (antes de 9 junho)

- [ ] Testar todos os fluxos
- [ ] Corrigir bugs
- [ ] Melhorias de UI/UX e consistência visual
- [ ] Performance (const widgets, evitar rebuilds)
- [ ] README completo
- [ ] Limpar código e commits
