# NutriScan — Navegação

## Fluxo Geral

```
SplashScreen
  ├─ (sem sessão, primeira vez) ──→ Onboarding ──→ RegisterScreen ──→ LoginScreen ──→ Home
  └─ (sessão ativa) ──────────────────────────────────────────────────────────────→ Home
```

---

## Bottom Navigation (4 tabs)

```
[ Home ]  [ Refeições ]  [ Produtos ]  [ Scan ]
```

> Scan não é um ecrã com estado — leva diretamente ao ScannerScreen.

---

## Mapa Completo

```
SplashScreen
  │
  ├─ (sem sessão) → [Onboarding]
  │                   Step 1: Dados pessoais (nome, idade, peso, altura)
  │                   Step 2: Objetivo (perder / ganhar / manter peso)
  │                   Step 3: Cálculo automático de objetivos
  │                   Step 4: Confirmar / ajustar objetivos
  │                       └─→ RegisterScreen
  │                               └─→ LoginScreen
  │                                       └─→ Home
  │
  └─ (sessão ativa) → Home

─────────────────────────────────────────────

Home
  ├─ [avatar topo] ──→ PerfilScreen
  │                       ├─→ DefinicoesScreen
  │                       │       └─→ CreditsScreen
  │                       └─→ Logout ──→ LoginScreen
  │
  ├─ Gráfico progresso semanal
  ├─ Resumo de hoje (calorias, água, macros)
  └─ [Ver mais] ──→ HistoricoScreen
                      ├─ Vista Dia (← →)
                      ├─ Vista Semana
                      └─ Vista Mês

─────────────────────────────────────────────

Refeições
  ├─ Lista de refeições do dia (PA, Almoço, Jantar, Snack)
  ├─ [refeição] ──→ RefeicaoDetailScreen
  │                   (lista de produtos + totais nutricionais)
  └─ [+ Adicionar refeição] ──→ AddRefeicaoScreen
                                  ├─ Campo de pesquisa ──→ SearchScreen
                                  │                           └─→ ProductDetailScreen
                                  ├─ [Scan] ──→ ScannerScreen
                                  │               └─→ ProductDetailScreen
                                  └─ Lista de produtos guardados
                                          └─→ ProductDetailScreen

─────────────────────────────────────────────

Produtos
  ├─ Lista de produtos guardados
  ├─ [produto] ──→ ProductDetailScreen
  └─ [+ Adicionar] ──→ SearchScreen
                          └─→ ProductDetailScreen

─────────────────────────────────────────────

Scan (tab direto)
  └─→ ScannerScreen
        ├─ Leitura automática de barcode ──→ ProductDetailScreen
        └─ [Inserir manualmente] ──→ SearchScreen
                                        └─→ ProductDetailScreen
```

---

## Ecrãs

| Ecrã | Descrição |
|---|---|
| `SplashScreen` | Logo + verificação de sessão |
| `OnboardingScreen` | Wizard multi-step: dados pessoais → objetivo → cálculo → confirmação |
| `RegisterScreen` | Criar conta (nome, email, password) |
| `LoginScreen` | Autenticação com email + password |
| `HomeScreen` | Gráfico semanal + resumo do dia + acesso ao perfil |
| `HistoricoScreen` | Vista detalhada dia / semana / mês |
| `RefeicoeScreen` | Lista de refeições do dia |
| `RefeicaoDetailScreen` | Detalhe de uma refeição (produtos + totais) |
| `AddRefeicaoScreen` | Adicionar produtos a uma refeição |
| `ProdutosScreen` | Lista de produtos guardados |
| `ScannerScreen` | Câmara para ler barcode + opção manual |
| `SearchScreen` | Pesquisa de produtos por nome (OFF + USDA) |
| `ProductDetailScreen` | Ficha completa: nutrição, ingredientes, preços |
| `PerfilScreen` | Dados do utilizador + objetivos + logout |
| `DefinicoesScreen` | Notificações, preferências |
| `CreditsScreen` | Autores, UC, ano letivo |

---

## Onboarding — Cálculo de Objetivos

Dados recolhidos: **idade, peso (kg), altura (cm), sexo, objetivo**

**TMB (Mifflin-St Jeor):**
```
Homem:  TMB = 10 × peso + 6.25 × altura − 5 × idade + 5
Mulher: TMB = 10 × peso + 6.25 × altura − 5 × idade − 161
```

**Calorias diárias** = TMB × fator de atividade (1.2 sedentário → 1.9 muito ativo)  
Ajuste por objetivo: −300 kcal (perder) / +300 kcal (ganhar) / 0 (manter)

**Macros calculados automaticamente:**
```
Proteína:  2.0g × peso (kg)
Gordura:   25% das calorias totais ÷ 9
Hidratos:  restante das calorias ÷ 4
Água:      35ml × peso (kg)
```

> Utilizador pode ajustar todos os valores no Step 4 antes de criar conta.
