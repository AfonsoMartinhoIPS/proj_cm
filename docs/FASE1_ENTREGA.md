# NutriScan - Entrega  (Fase 1)

**Unidade Curricular:** Computação Móvel  
**Docentes:** Professor Bruno Pereira · Professora Paula Miranda  
**Data de entrega:** 4 de maio de 2026  

**Grupo:**

| Nome | Número |
|------|--------|
| Samuel Silva | 202200315 |
| Afonso Martinho | 202001865 |
| Daniel Pais | 202200286 |
| Fernando Ramalho | 202002203 |


<div style="page-break-after: always;"></div>

## 1. Conceito

**NutriScan** é uma aplicação móvel de rastreio nutricional que permite ao utilizador conhecer o que come, controlar o progresso face aos seus objetivos e tomar decisões mais informadas no dia a dia.

1. O utilizador digitaliza produtos alimentares pelo código de barras e obtém a ficha nutricional completa.
2. Regista o que come ao longo do dia e acompanha o progresso face aos seus objetivos.
3. Acede ao histórico da sua alimentação para identificar padrões ao longo do tempo.

Como funcionalidade complementar, o utilizador pode também anotar preços vistos em loja diretamente na ficha de um produto, facilitando comparações futuras sem sair da app.

**Problema que resolve:**
- Conhecer o valor nutricional dos alimentos de forma rápida, sem pesquisa manual.
- Ter um registo diário centralizado da alimentação, incluindo água.
- Utilizar inúmeras apps separadas para atingir um objetivo único é fragmentado e pouco prático.


<div style="page-break-after: always;"></div>

## 2. Público-alvo

Pessoas que querem **comer de forma mais consciente** e ter controlo sobre a sua alimentação diária.

Perfis típicos:
- Jovens adultos e estudantes que querem adotar hábitos mais saudáveis
- Pessoas com objetivos de saúde (perda de peso, ganho de massa muscular, manutenção)
- Utilizadores que fazem as suas compras e querem tomar decisões mais informadas
- Pessoas com dietas específicas que precisam de controlar macronutrientes


<div style="page-break-after: always;"></div>

## 3. Funcionalidades Gerais

Funcionalidades transversais a qualquer aplicação móvel moderna.

### Splash Screen
Ecrã inicial com logótipo e nome da app.  
Verifica automaticamente se existe sessão ativa: redireciona para Onboarding (primeira vez) ou para o ecrã principal (sessão existente).

### Onboarding *(primeira interação, antes do registo)*
Primeira impressão da app — acontece antes de o utilizador criar conta.

- **Passo 1:** Dados pessoais (nome, idade, peso, altura, sexo)
- **Passo 2:** Objetivo (perder peso / ganhar massa / manter peso)
- **Passo 3:** Cálculo automático de objetivos nutricionais (fórmula Mifflin-St Jeor para TMB + fator de atividade + ajuste por objetivo)
- **Passo 4:** Confirmação e ajuste manual dos valores calculados

Os objetivos calculados ficam associados ao perfil do utilizador após o registo.

### Autenticação
- **Registo:** nome, email, palavra-passe e confirmação; validação local; criação de conta via Firebase Auth; perfil guardado no Firestore
- **Login:** email + palavra-passe; sessão persistida automaticamente pelo Firebase Auth
- **Logout:** disponível no perfil; limpa sessão local e redireciona para login
- Tratamento de erros: email já usado, credenciais erradas, sem ligação

### Navegação
- **Bottom navigation bar** com 4 tabs: Home, Refeições, Produtos, Scan
- **Navegação em pilha** para ecrãs de detalhe (botão de retrocesso + swipe)
- Estado das tabs preservado ao alternar entre elas (scroll, pesquisa ativa)

### Perfil e Definições
- Ver e editar dados do utilizador
- Definir ou ajustar objetivos nutricionais diários (calorias, proteína, hidratos, gordura, água)
- Configurar notificações (hora do lembrete, ativar/desativar)
- Acesso ao ecrã de créditos

### Créditos
Identificação dos autores, unidade curricular, instituição e ano letivo.


<div style="page-break-after: always;"></div>

## 4. Funcionalidades Específicas

A aplicação organiza-se em três conceitos centrais: **Produtos**, **Refeições** e **Histórico**.

### Produtos

#### Digitalização por código de barras (Scanner)
O utilizador aponta a câmara para o código de barras de um produto. A app lê o código, consulta a API OpenFoodFacts e apresenta:
- Nome, marca e imagem do produto
- Quantidade/volume da embalagem
- Lista de ingredientes
- Tabela nutricional por 100g/ml (calorias, proteína, hidratos, açúcares, gordura, fibra, sal)

O utilizador pode guardar o produto para acesso mais fácil no futuro.

#### Pesquisa por nome
Útil para alimentos sem código de barras (frango grelhado, arroz cozido, maçã).  
Consulta duas fontes:
- **OpenFoodFacts** — produtos embalados e de marca
- **USDA FoodData Central** — alimentos genéricos e ingredientes

Estratégia: pesquisa OpenFoodFacts primeiro; se sem resultados, consulta USDA. Resultado unificado no mesmo modelo de dados.

#### Lista de produtos guardados
Produtos já digitalizados ou pesquisados, com pesquisa local para filtrar rapidamente.  
Indicador de fonte (OpenFoodFacts / USDA / Manual).

#### Notas pessoais
Na ficha de cada produto o utilizador pode adicionar notas livres — onde comprou, o preço que viu, observações sobre o sabor, ou qualquer outra informação relevante para si.


### Refeições

#### Registo diário de alimentação
O utilizador adiciona alimentos ao diário do dia, organizados por refeição:
- Pequeno-almoço, Almoço, Jantar, Snack
- Especifica a quantidade consumida (em gramas ou ml)
- A app calcula os valores nutricionais para a porção
- Totais do dia com barras de progresso face aos objetivos definidos no perfil

#### Registo de água
- Botões rápidos para porções comuns (200 ml, 330 ml, 500 ml)
- Campo manual para quantidade personalizada
- Total diário com barra de progresso face ao objetivo


### Histórico

Vista retrospetiva da alimentação com três modos:

#### Vista de Dia
- Navegar entre dias (← →) ou selecionar data via calendário
- Refeições e alimentos registados
- Totais nutricionais + comparação com objetivos

#### Vista de Semana
- Gráfico de barras com calorias por dia nos últimos 7 dias
- Médias da semana por macro
- Destaque de dias acima/abaixo do objetivo

#### Vista de Mês
- Calendário com indicador visual por dia (verde = objetivo atingido, vermelho = abaixo, cinzento = sem registo)
- Resumo mensal: média diária de calorias, dias com registo vs. sem registo


### Notificações
- Lembrete diário configurável (hora definida pelo utilizador), enviado apenas se não houver registos no dia
- Possibilidade de ativar/desativar nas definições


<div style="page-break-after: always;"></div>

## 5. Aspetos Originais e Mais-valias

| Aspeto | Porquê é diferente |
|--------|-------------------|
| **Dupla fonte de dados nutricional** | OpenFoodFacts (embalados) + USDA (genéricos), cobre praticamente qualquer alimento |
| **Onboarding com cálculo científico** | Objetivos calculados automaticamente com fórmula Mifflin-St Jeor, não valores genéricos |
| **Registo de água integrado** | Visão completa de ingestão diária, não apenas alimentos sólidos |
| **Histórico multi-escala** | Dia / semana / mês — identifica padrões ao longo do tempo |
| **Notas livres por produto** | O utilizador pode anotar o que quiser na ficha do produto — preços, observações, preferências |


<div style="page-break-after: always;"></div>

## 6. Esquema de Navegação

```
SplashScreen
  ├─ (primeira vez) ──→ Onboarding (4 passos)
  │                         └─→ RegisterScreen
  │                                 └─→ LoginScreen
  │                                         └─→ Home
  └─ (sessão ativa) ────────────────────────→ Home


─────────────────────────────────────────────────────
BOTTOM NAV:  [ Home ]  [ Refeições ]  [ Produtos ]  [ Scan ]
─────────────────────────────────────────────────────

Home
  ├─ [avatar] ──→ PerfilScreen
  │                   ├─→ DefinicoesScreen ──→ CreditsScreen
  │                   └─→ Logout ──→ LoginScreen
  ├─ Resumo do dia (calorias, água, macros)
  ├─ Gráfico de progresso semanal
  └─ [Ver mais] ──→ HistóricoScreen
                        ├─ Vista Dia  (← →)
                        ├─ Vista Semana
                        └─ Vista Mês

Refeições
  ├─ Lista de refeições do dia (PA, Almoço, Jantar, Snack)
  ├─ Secção de água (botões rápidos + manual)
  ├─ [refeição] ──→ RefeicaoDetailScreen
  └─ [+ Adicionar] ──→ AddRefeicaoScreen
                          ├─ Pesquisa ──→ SearchScreen ──→ ProductDetailScreen
                          ├─ [Scan] ──→ ScannerScreen ──→ ProductDetailScreen
                          └─ Guardados ──→ ProductDetailScreen

Produtos
  ├─ Lista de produtos guardados
  ├─ [produto] ──→ ProductDetailScreen
  └─ [+ Adicionar] ──→ SearchScreen ──→ ProductDetailScreen

Scan (tab direto)
  └─→ ScannerScreen
        ├─ Leitura de barcode ──→ ProductDetailScreen
        └─ [Inserir manualmente] ──→ SearchScreen ──→ ProductDetailScreen
```


<div style="page-break-after: always;"></div>

## 7. Wireframes / Mockups

> Link para o projeto Figma: https://www.figma.com/design/V25ivJxTlUHjLLWmyU0g6W/Proj_CM?node-id=0-1&p=f&t=9hxaCJ1dY5zSZxIG-0


**Splash:**
![Splash Screen](assets/images/splash.png) 

**Onboarding**
![Onboarding](assets/images/registo.png)

**Login / Registo:**
![Login / Registo](assets/images/login.png)

**Home:**
![Home](assets/images/main.png)

**Refeições:**
![Refeições](assets/images/refeicao.png)

**Produtos:**
![Produtos](assets/images/produto.png)

**Scanner:**
![Scanner](assets/images/scan.png)

**Perfil + Definições**
![Perfil + Definições](assets/images/perfil.png)


<div style="page-break-after: always;"></div>

## 8. UI Implementada

Alguns exemplos do estado atual da implementação de interface:

**Login:**

![alt text](assets/images/login_inapp.png)

**Onboarding**
![alt text](assets/images/onboarding_inapp.png)

**Dashboard**
![alt text](assets/images/dashboard_inapp.png)

**Produtos**
![alt text](assets/images/productos_inapp.png)


<div style="page-break-after: always;"></div>

## 9. Estrutura de Dados (Firestore)

Os dados são organizados em Firestore com a seguinte estrutura de coleções:

```
users/
  {uid}/
    ├─ displayName, email, createdAt
    ├─ goals/
    │     calories, protein, carbs, fat, water
    │
    ├─ saved_products/
    │     {barcode}/
    │       ├─ name, brand, imageUrl
    │       ├─ ingredientsText
    │       ├─ nutriscoreGrade, novaGroup
    │       ├─ source ("openfoodfacts" | "usda" | "manual")
    │       ├─ savedAt, notes
    │       ├─ nutriments/
    │       │     caloriesPer100g, proteinPer100g, carbsPer100g,
    │       │     fatPer100g, fiberPer100g, saltPer100g, ...
    │
    └─ logs/
          {date}/         ← formato "YYYY-MM-DD"
            ├─ waterMl
            ├─ goals/     ← snapshot dos objetivos nesse dia
            └─ entries/
                  {entryId}/
                    productBarcode, productName, mealType,
                    servingGrams, loggedAt, nutriments (porção)
```

**Entidades principais:**

| Entidade | Descrição |
|----------|-----------|
| `AppUser` | Perfil do utilizador + objetivos nutricionais diários |
| `Product` | Produto alimentar com dados nutricionais por 100g |
| `SavedProduct` | Produto guardado pelo utilizador, com data de adição e notas pessoais |
| `NutritionLog` | Registo diário: refeições + água consumida |
| `MealEntry` | Entrada individual numa refeição (produto + porção) |
| `Nutriments` | Valores nutricionais por 100g (calorias, proteína, hidratos, etc.) |


<div style="page-break-after: always;"></div>

## 10. Stack Técnica

### Já configurado e em uso

| Componente | Tecnologia |
|------------|------------|
| Framework | Flutter (Dart) |
| Navegação | `go_router` |
| Autenticação | Firebase Authentication |
| Base de dados | Cloud Firestore |
| HTTP / APIs | `dio` |
| Logging | `logger` |

### A integrar nas próximas fases

| Componente | Tecnologia |
|------------|------------|
| Gestão de estado | Riverpod |
| Leitura de código de barras | `mobile_scanner` |
| Notificações locais | `flutter_local_notifications` |
| Gráficos | `fl_chart` |
| API nutricional (embalados) | OpenFoodFacts REST API |
| API nutricional (genéricos) | USDA FoodData Central API |

### Arquitetura

O projeto segue **Clean Architecture** com separação estrita em três camadas:

```
presentation/   ← UI, ecrãs, widgets
domain/         ← entidades, contratos de repositório
data/           ← implementações, modelos, datasources (APIs + Firestore)
```


<div style="page-break-after: always;"></div>

## 11. Repositório Git

> https://github.com/AfonsoMartinhoIPS/proj_cm.git


O repositório encontra-se configurado com:
- Estrutura de projeto Flutter inicializada
- Firebase configurado (Auth + Firestore)
- Arquitetura Clean Architecture implementada (domain / data / presentation)
- Camada de dados com modelos e repositórios base
- Integração inicial com a API OpenFoodFacts
- Testes de integração iniciais
