### Projeto Época Normal

**UC:** Computação Móvel
**Docentes:** Professor Bruno Pereira e  Professora Paula Miranda

**Alunos:** 

* Samuel Silva, N: 202200315
* Afonso Martinho, 202001865
* Daniel Pais, N: 202200286
* Fernando Ramalho, N: 202002203

<div style="page-break-after: always;"></div>




## 1. Conceito

![[Pasted image 20260424095632.png]]

**NutriScan** é uma aplicação móvel que une dois domínios habitualmente separados: 

* **rastreio nutricional** 
* **comparação de preços em supermercado**.

1. O utilizador digitaliza produtos alimentares pelo código de barras e obtém a ficha nutricional completa
2. Regista o que come ao longo do dia e acompanha o progresso face aos seus objetivos. 
3. Em paralelo, pode registar os preços que viu em diferentes lojas e comparar qual a opção mais barata por kg/L.

**Problema que resolve:**
- Apps de nutrição não têm preços
- Utilizar inumeras apps para atingir um objetivo único

- NutriScan junta ambos numa só experiência

<div style="page-break-after: always;"></div>

## 2. Público-alvo

Pessoas que querem simultaneamente **comer melhor** e **gastar menos** no supermercado.

Perfis típicos:
- Jovens adultos e estudantes com orçamento controlado
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

Primeira impressão da app, "agarra" logo a interação visto que acontece antes de o utilizador criar conta.

Registo de algumas informação iniciais: 

- **1:** Dados pessoais: nome, idade, peso, altura, sexo
- **2:** Objetivo: perder peso / ganhar massa / manter peso
- **3:** Cálculo automático de objetivos nutricionais (fórmula Mifflin-St Jeor para TMB + fator de atividade + ajuste por objetivo)
- **Step 4:** Confirmação e ajuste manual dos valores calculados

Os objetivos calculados são guardados no perfil do utilizador após o registo.

### Autenticação

- **Registo:** nome, email, palavra-passe e confirmação; validação local; criação de conta via Firebase Auth; perfil guardado no Firestore
- **Login:** email + palavra-passe; sessão persistida automaticamente pelo Firebase Auth
- **Logout:** disponível no perfil; limpa sessão local e redireciona para login
- Tratamento de erros: email já usado, credenciais erradas, sem ligação

### Navegação
- **Bottom navigation bar** com 4 tabs: Home, Refeições, Produtos, Scan
- **Navegação em pilha** para ecrãs de detalhe (botão de retrocesso + swipe)

Extra:
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

### PRODUTOS

#### Digitalização por código de barras (Scanner)
O utilizador aponta a câmara para o código de barras de um produto. A app lê o código, consulta a API OpenFoodFacts e apresenta:
- Nome, marca. (possivelmente também a imagem)
- Quantidade/volume da embalagem
- Lista de ingredientes
- Tabela nutricional por 100g/ml (calorias, proteína, hidratos, açúcares, gordura, fibra, sal)

O utilizador pode guardar o produto para acesso mais fácil no futuro.

#### Pesquisa por nome

Útil para alimentos sem código de barras (frango grelhado, arroz cozido, maçã). 
Consulta duas fontes:
- **OpenFoodFacts:** produtos embalados e de marca
- **USDA FoodData Central:** alimentos genéricos e ingredientes

Estratégia: pesquisa OpenFoodFacts primeiro; se sem resultados, consulta USDA. 
Resultado unificado no mesmo modelo de dados.

#### Lista de produtos guardados
Produtos já digitalizados ou pesquisados, com pesquisa local para filtrar rapidamente. 
Indicador de fonte (OpenFoodFacts / USDA / Manual).

#### Registo de preços em loja
A partir de qualquer produto, o utilizador pode registar o preço visto numa loja:
- Nome da loja, preço (€), quantidade/volume da embalagem
- Cálculo automático de **preço por kg/L** para comparação justa entre embalagens de tamanhos diferentes
- Destaque do preço mais barato

---

### REFEIÇÕES

#### Registo diário de alimentação
O utilizador adiciona alimentos ao diário do dia, organizados por refeição:
- Pequeno-almoço, Almoço, Jantar, Snack
- Especifica a quantidade consumida (gramas ou ml)
- A app calcula os valores nutricionais para a porção
- Totais do dia com barras de progresso face aos objetivos definidos no perfil

#### Registo de água
- Botões rápidos para porções comuns (200 ml, 330 ml, 500 ml)
- Campo manual para quantidade personalizada
- Total diário com barra de progresso face ao objetivo

---

### HISTÓRICO

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

---

### NOTIFICAÇÕES

- Lembrete diário configurável (hora definida pelo utilizador), só enviado se não houver registos no dia
- Possibilidade de ativar/desativar nas definições


## 5. Originalidade e Mais-valias

| Aspeto                                | Porquê é diferente                                                                             |
| ------------------------------------- | ---------------------------------------------------------------------------------------------- |
| **Nutrição + preços na mesma app**    | Um local só, organizado e fácil de utilizar                                                    |
| **Dupla fonte de dados nutricional**  | OpenFoodFacts (embalados) + USDA (genéricos), cobre praticamente qualquer alimento             |
| **Onboarding com cálculo científico** | Objetivos calculados automaticamente com fórmula (E.x Mifflin-St Jeor) e não valores genéricos |
| **Registo de água integrado**         | Visão completa de ingestão diária, não apenas alimentos sólidos                                |
| **Preço por kg/L automático**         | Comparação justa entre embalagens de tamanhos diferentes                                       |
| **Histórico multi-escala**            | Dia / semana / mês, permite identificar padrões ao longo do tempo                              |

<div style="page-break-after: always;"></div>

## 6. Esquema de Navegação

```
SplashScreen
  ├─ (primeira vez, sem sessão) ──→ Onboarding (4 steps)
  │                                     └─→ RegisterScreen
  │                                             └─→ LoginScreen
  │                                                     └─→ Home
  └─ (sessão ativa) ──────────────────────────────────→ Home


─────────────────────────────────────────────────────────────────

BOTTOM NAV:  [ Home ]  [ Refeições ]  [ Produtos ]  [ Scan ]

─────────────────────────────────────────────────────────────────

Home
  ├─ [avatar] ──→ PerfilScreen
  │                   ├─→ DefinicoesScreen ──→ CreditsScreen
  │                   └─→ Logout ──→ LoginScreen
  ├─ Gráfico progresso semanal
  ├─ Resumo do dia (calorias, água, macros)
  └─ [Ver mais] ──→ HistoricoScreen
                        ├─ Vista Dia (← →)
                        ├─ Vista Semana
                        └─ Vista Mês

─────────────────────────────────────────────────────────────────

Refeições
  ├─ Lista de refeições do dia (PA, Almoço, Jantar, Snack)
  ├─ Secção de água (botões rápidos + manual)
  ├─ [refeição] ──→ RefeicaoDetailScreen
  └─ [+ Adicionar] ──→ AddRefeicaoScreen
                          ├─ Pesquisa ──→ SearchScreen ──→ ProductDetailScreen
                          ├─ [Scan] ──→ ScannerScreen ──→ ProductDetailScreen
                          └─ Guardados ──→ ProductDetailScreen

─────────────────────────────────────────────────────────────────

Produtos
  ├─ Lista de produtos guardados
  ├─ [produto] ──→ ProductDetailScreen
  │                   └─→ RegisterPriceScreen ──→ PriceListScreen
  └─ [+ Adicionar] ──→ SearchScreen ──→ ProductDetailScreen

─────────────────────────────────────────────────────────────────

Scan (tab direto)
  └─→ ScannerScreen
        ├─ Leitura de barcode ──→ ProductDetailScreen
        └─ [Inserir manualmente] ──→ SearchScreen ──→ ProductDetailScreen
```

<div style="page-break-after: always;"></div>

## 7. Stack Técnica

| Componente                  | Tecnologia                                                 |
| --------------------------- | ---------------------------------------------------------- |
| Framework                   | Flutter (Dart)                                             |
| Gestão de estado            | (E.x Riverpod)                                             |
| Autenticação                | Firebase Authentication                                    |
| Base de dados               | Cloud Firestore                                            |
| API nutricional (embalados) | OpenFoodFacts                                              |
| API nutricional (genéricos) | USDA FoodData Central                                      |
| Leitura de código de barras | `mobile_scanner` (https://pub.dev/packages/mobile_scanner) |
| HTTP                        | (E.x dio)                                                  |
| Notificações                | `flutter_local_notifications`                              |
| Gráficos                    | (E.x `fl_chart`)                                           |
| Arquitetura                 | (data / domain / presentation) Usar o repository pattern   |

