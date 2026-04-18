# Descrição de Funcionalidades — NutriScan

Aplicação móvel desenvolvida em Flutter que combina rastreio nutricional com assistência às compras, permitindo ao utilizador digitalizar produtos alimentares, consultar informação nutricional, registar refeições e consumo de água, e comparar preços de produtos em loja.

---

## Funcionalidades Gerais

Funcionalidades transversais a qualquer aplicação móvel moderna.

---

### 1. Splash Screen

**Descrição:**
Ecrã inicial exibido no arranque da aplicação. Apresenta o logótipo e nome enquanto a app verifica o estado de autenticação do utilizador.

**O que implementar:**
- Exibir logótipo e nome da aplicação
- Verificar se existe sessão ativa (token Firebase válido)
- Redirecionar para ecrã de login se sem sessão, ou para ecrã principal se sessão ativa
- Duração mínima de ~1,5 segundos para garantir experiência visual coerente

**Tratamento de erros:**
- Se verificação de sessão falhar por erro de rede, redirecionar para login (comportamento seguro por defeito)

---

### 2. Autenticação

**Descrição:**
Registo e autenticação de utilizadores via Firebase Authentication. O utilizador cria conta com email e palavra-passe, e na sessão seguinte inicia sessão com as mesmas credenciais. A sessão é persistida localmente, pelo que não é necessário voltar a autenticar em cada abertura da app.

**O que implementar:**

*Registo:*
- Formulário com campos: nome de utilizador, email, palavra-passe, confirmação de palavra-passe
- Validação local antes de enviar: email com formato válido, palavra-passe com mínimo de 6 caracteres, confirmação coincide
- Criar conta via `FirebaseAuth.createUserWithEmailAndPassword`
- Guardar perfil do utilizador no Firestore (`users/{uid}`) com nome, email e data de registo

*Login:*
- Formulário com campos: email e palavra-passe
- Autenticar via `FirebaseAuth.signInWithEmailAndPassword`
- Após login bem-sucedido, redirecionar para ecrã principal

*Sessão persistente:*
- O Firebase Auth persiste automaticamente o token localmente (via `SharedPreferences` internamente)
- No arranque da app, verificar `FirebaseAuth.currentUser` — se não nulo, sessão está ativa
- Não é necessário re-autenticar entre sessões; o utilizador só precisa de fazer login uma vez

*Terminar sessão:*
- Botão de logout no ecrã de perfil
- `FirebaseAuth.signOut()` limpa o token local
- Redirecionar para ecrã de login

**Tratamento de erros:**
- `email-already-in-use` → "Este email já está registado"
- `wrong-password` / `user-not-found` → "Email ou palavra-passe incorretos"
- `network-request-failed` → "Sem ligação à internet. Tenta novamente."
- Campos vazios → validação local antes de qualquer pedido

---

### 3. Navegação

**Descrição:**
Estrutura de navegação com barra inferior para acesso às secções principais e navegação em pilha (stack) para ecrãs de detalhe, garantindo que o utilizador pode sempre regressar ao ponto de origem.

**O que implementar:**

*Barra de navegação inferior:*
- Secções principais acessíveis a partir de qualquer ponto: Refeições, Produtos, Histórico, Perfil
- Aba ativa visualmente destacada

*Navegação em pilha:*
- Ecrãs de detalhe (ex: detalhe de produto, detalhe de dia) abrem por cima do ecrã atual
- Botão de retrocesso (seta) no topo esquerdo para regressar ao ecrã anterior
- Gesto de swipe para voltar atrás (comportamento nativo iOS/Android)

*Preservação de estado:*
- Ao trocar de aba na barra inferior, o estado da aba anterior é preservado (ex: scroll position, pesquisa ativa)
- Implementado via `IndexedStack` ou navegação com chaves de estado (`GlobalKey`)
- Dados carregados do Firestore são mantidos em cache pelo provider — não recarregam ao trocar de aba

**Tratamento de erros:**
- Se utilizador tentar navegar para ecrã protegido sem sessão ativa, redirecionar para login

---

### 4. Perfil e Definições

**Descrição:**
Ecrã com informação do utilizador autenticado e configuração de objetivos nutricionais diários.

**O que implementar:**
- Exibir nome de utilizador e email
- Formulário para definir objetivos diários: calorias (kcal), proteína (g), hidratos (g), gordura (g), água (ml)
- Guardar objetivos no Firestore (`users/{uid}`) e ler no arranque
- Opção de terminar sessão
- Valores de objetivos utilizados nas barras de progresso do ecrã de Refeições e Histórico

**Tratamento de erros:**
- Falha ao guardar objetivos → mensagem de erro, manter valores anteriores
- Campos de objetivos vazios ou negativos → validação local

---

### 5. Créditos

**Descrição:**
Ecrã acessível a partir do perfil com identificação dos autores, unidade curricular e ano letivo.

**O que implementar:**
- Nome e número de estudante de cada elemento do grupo
- Nome da unidade curricular e instituição
- Ano letivo

---

## Funcionalidades Essenciais

A aplicação organiza-se em torno de três conceitos centrais: **Produtos**, **Refeições** e **Histórico**.

---

### Conceito: PRODUTOS

Repositório de produtos alimentares conhecidos pelo utilizador — obtidos por digitalização, pesquisa ou registo manual.

---

#### 1.1 Digitalização de Produtos (Scanner)

**Descrição:**
O utilizador aponta a câmara para o código de barras de um produto. A app lê o código, consulta a API OpenFoodFacts e apresenta a ficha nutricional completa do produto. O produto é guardado automaticamente no repositório local do utilizador.

**O que implementar:**
- Ecrã de scanner com feed da câmara em tempo real
- Leitura do código de barras via pacote a definir (sugestões: `mobile_scanner`, `flutter_barcode_scanner`)
- Pedido à OpenFoodFacts API: `GET /api/v2/product/{barcode}.json`
- Apresentar ficha do produto:
  - Nome e marca
  - Imagem (se disponível)
  - Quantidade / volume da embalagem
  - Lista de ingredientes
  - Tabela nutricional por 100 g/ml: calorias, proteína, hidratos, açúcares, gordura, gordura saturada, fibra, sal
- Guardar produto no Firestore (`saved_products/{uid}/products/{barcode}`)
- Botão para adicionar produto a uma refeição diretamente a partir da ficha

**Tratamento de erros:**
- Produto não encontrado (`status: 0`) → mensagem "Produto não encontrado" + opção de pesquisar manualmente
- Campos nutricionais em falta → exibir "—" nos campos ausentes, não bloquear o ecrã
- Sem câmara disponível → mostrar mensagem de erro ao abrir scanner
- Permissão de câmara negada → mostrar explicação e redirecionar para definições do dispositivo
- Erro de rede → mensagem "Sem ligação" + botão de nova tentativa

---

#### 1.2 Pesquisa de Produtos

**Descrição:**
O utilizador pesquisa alimentos por nome — útil para alimentos sem código de barras (ex: frango grelhado, arroz cozido, maçã).

**O que implementar:**
- Campo de pesquisa com resultados em lista
- Duas fontes de dados consultadas:
  - **OpenFoodFacts** — para produtos embalados e de marca
  - **USDA FoodData Central** — para alimentos genéricos e ingredientes
- Estratégia: pesquisa primeiro OpenFoodFacts; se sem resultados, consulta USDA
- Resultado unificado no mesmo modelo de domínio `Product`
- Ao selecionar resultado, abrir ficha do produto (igual ao scanner)
- Guardar produto no repositório do utilizador após seleção

**Tratamento de erros:**
- Sem resultados em ambas as APIs → mensagem "Nenhum produto encontrado" + sugestão de registo manual
- Erro de rede → mensagem de erro + botão de nova tentativa
- Pesquisa com menos de 2 caracteres → não efetuar pedido

---

#### 1.3 Lista de Produtos Guardados

**Descrição:**
Listagem de todos os produtos que o utilizador já digitalizou ou pesquisou, para acesso rápido sem repetir scan ou pesquisa.

**O que implementar:**
- Lista de produtos com nome, marca, imagem e calorias por 100 g
- Campo de pesquisa local para filtrar a lista
- Ao tocar num produto, abrir a sua ficha nutricional
- Opção de remover produto da lista (swipe para apagar ou botão de remoção)
- Indicador de fonte do produto: OpenFoodFacts, USDA ou Manual

**Tratamento de erros:**
- Lista vazia → mensagem "Ainda não digitalizaste nenhum produto" com ícone ilustrativo
- Falha ao carregar lista do Firestore → mensagem de erro + botão de recarregar

---

#### 1.4 Registo de Preços em Loja

**Descrição:**
Para qualquer produto guardado, o utilizador pode registar o preço que viu numa loja específica, permitindo comparar preços entre lojas e marcas.

**O que implementar:**
- A partir da ficha de um produto, opção "Registar preço em loja"
- Formulário com campos:
  - Nome da loja
  - Preço (€)
  - Quantidade / volume da embalagem (g ou ml)
- Calcular automaticamente: `preço por kg/L = preço / (quantidade / 1000)`
- Guardar no Firestore (`shopping_items/{uid}/items`)
- Ecrã de listagem de preços registados:
  - Agrupado por produto ou por loja (opção de ordenação)
  - Comparação visual entre entradas do mesmo produto
  - Destaque do preço mais barato por kg/L

**Tratamento de erros:**
- Campos obrigatórios em falta → validação local antes de guardar
- Preço ou quantidade com valor zero ou negativo → mensagem de validação
- Falha ao guardar no Firestore → mensagem de erro, dados não perdidos (tentar novamente)

---

### Conceito: REFEIÇÕES

Registo diário do que o utilizador come e bebe, com acompanhamento dos valores nutricionais face aos objetivos definidos.

---

#### 2.1 Registo de Refeições

**Descrição:**
O utilizador adiciona alimentos ao seu diário do dia, organizados por refeição (pequeno-almoço, almoço, jantar, snack), especificando a quantidade consumida.

**O que implementar:**
- Ecrã principal com lista de refeições do dia atual
- Cada refeição (PA, Almoço, Jantar, Snack) com botão para adicionar alimento
- Ao adicionar: pesquisar produto da lista guardada ou efetuar novo scan
- Especificar quantidade consumida (gramas ou ml)
- Calcular valores nutricionais para a porção: `valor = (nutriente_100g / 100) × gramas`
- Exibir totais do dia: calorias, proteína, hidratos, gordura
- Barras de progresso comparando totais com objetivos definidos no perfil
- Guardar entradas no Firestore (`nutrition_logs/{uid}/entries`)
- Possibilidade de remover uma entrada do dia

**Tratamento de erros:**
- Quantidade zero ou vazia → validação antes de guardar
- Falha ao guardar entrada → mensagem de erro, não perder dados localmente
- Sem produtos guardados → sugerir digitalizar ou pesquisar produto primeiro

---

#### 2.2 Registo de Água

**Descrição:**
O utilizador regista a quantidade de água ingerida ao longo do dia, com acompanhamento face ao objetivo diário.

**O que implementar:**
- Secção de água no ecrã de Refeições
- Botões rápidos para adicionar porções comuns (200 ml, 330 ml, 500 ml)
- Campo manual para quantidade personalizada
- Total de água do dia com barra de progresso face ao objetivo (ex: 2000 ml)
- Guardar registos de água no Firestore junto com as entradas do dia

**Tratamento de erros:**
- Valor negativo ou zero → validação local
- Falha ao guardar → mensagem de erro, tentar novamente

---

### Conceito: HISTÓRICO

Visão retrospetiva da alimentação do utilizador — por dia, semana e mês.

---

#### 3.1 Histórico de Alimentação

**Descrição:**
O utilizador consulta o resumo nutricional de dias anteriores e pode navegar entre diferentes períodos (dia, semana, mês).

**O que implementar:**

*Vista de dia:*
- Selecionar data via calendário ou navegação anterior/seguinte
- Mostrar refeições e alimentos registados nesse dia
- Totais nutricionais do dia: calorias, proteína, hidratos, gordura, água
- Comparação visual com os objetivos

*Vista de semana:*
- Gráfico de barras com calorias por dia nos últimos 7 dias
- Médias da semana: calorias/dia, proteína/dia, etc.
- Destaque de dias acima ou abaixo do objetivo

*Vista de mês:*
- Calendário com indicador visual em cada dia (verde = objetivo atingido, vermelho = abaixo, cinzento = sem registo)
- Resumo mensal: média diária de calorias, dias com registo vs. dias sem registo

**O que guardar no Firestore:**
- Entradas em `nutrition_logs/{uid}/entries` com campo `date` (YYYY-MM-DD) para filtragem por período

**Tratamento de erros:**
- Sem dados para o período selecionado → mensagem "Sem registos para este período"
- Falha ao carregar dados → mensagem de erro + botão de recarregar
- Data futura selecionada → não permitir, desabilitar navegação para datas futuras

---

### Funcionalidade Transversal: Notificações

**Descrição:**
Notificações locais agendadas no dispositivo para incentivar o utilizador a registar refeições e atingir os seus objetivos.

**O que implementar:**
- Pedir permissão de notificações no primeiro arranque da app
- Lembrete diário configurável (hora definida pelo utilizador no perfil, ex: 20h00)
  - Só enviado se o utilizador não tiver registos no dia atual
- Notificação ao atingir objetivo calórico diário
- Possibilidade de ativar/desativar notificações nas definições da app

**Implementação:**
- Pacote `flutter_local_notifications`
- Agendamento local, sem servidor externo
- Verificação do estado do diário antes de enviar lembrete (consulta ao Firestore local via cache)

**Tratamento de erros:**
- Permissão negada → não crashar, guardar preferência, sugerir ativar nas definições do sistema
- Notificação não agendada (app fechada) → limitação documentada; notificações dependem de app em background

---

## Aspetos Originais e Mais-valias

- **Combinação de rastreio nutricional e comparação de preços** — dois domínios habitualmente em apps separadas, unidos numa só experiência
- **Registo de água integrado** — contexto completo de ingestão diária, não apenas alimentos sólidos
- **Dupla fonte de dados nutricional** — OpenFoodFacts para produtos embalados + USDA para alimentos genéricos, cobrindo praticamente qualquer tipo de alimento
- **Histórico com múltiplas vistas** (dia / semana / mês) — permite ao utilizador identificar padrões ao longo do tempo, não apenas o dia atual
- **Cálculo automático de preço por kg/L** — comparação justa entre embalagens de tamanhos diferentes

---

## Resumo Técnico

| Componente | Tecnologia |
|---|---|
| Framework | Flutter (Dart) |
| Gestão de estado | Riverpod |
| Autenticação | Firebase Authentication |
| Sessão persistente | Firebase Auth token (persistência automática) |
| Base de dados remota | Cloud Firestore |
| API nutricional (embalados) | OpenFoodFacts |
| API nutricional (genéricos) | USDA FoodData Central |
| Leitura de código de barras | `mobile_scanner` |
| HTTP | `dio` |
| Notificações | `flutter_local_notifications` |
| Arquitetura | Clean Architecture (data / domain / presentation) |
